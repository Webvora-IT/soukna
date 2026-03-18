import { Request, Response, NextFunction } from 'express'
import { z } from 'zod'
import { prisma } from '../lib/prisma'
import { AuthRequest } from '../middleware/auth'
import { ProductStatus } from '@prisma/client'
import { Role } from '@prisma/client'

const productSchema = z.object({
  name: z.string().min(2),
  nameAr: z.string().optional(),
  nameEn: z.string().optional(),
  description: z.string().optional(),
  descriptionAr: z.string().optional(),
  price: z.number().positive(),
  originalPrice: z.number().positive().optional(),
  images: z.array(z.string()).optional().default([]),
  status: z.nativeEnum(ProductStatus).optional().default(ProductStatus.AVAILABLE),
  stock: z.number().int().positive().optional(),
  unit: z.string().optional(),
  categoryId: z.string().optional(),
})

export async function listProducts(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const { storeId, categoryId, status, search, page = '1', limit = '30' } = req.query
    const skip = (Number(page) - 1) * Number(limit)

    const authReq = req as AuthRequest
    const isAdmin = authReq.user?.role === Role.ADMIN

    const where: Record<string, unknown> = {}
    if (storeId) where.storeId = storeId
    if (categoryId) where.categoryId = categoryId
    if (status && isAdmin) {
      where.status = status
    } else if (!isAdmin) {
      where.status = ProductStatus.AVAILABLE
    }
    if (search) {
      where.OR = [
        { name: { contains: search as string, mode: 'insensitive' } },
        { nameAr: { contains: search as string, mode: 'insensitive' } },
      ]
    }

    const [products, total] = await Promise.all([
      prisma.product.findMany({
        where,
        skip,
        take: Number(limit),
        orderBy: { createdAt: 'desc' },
        include: {
          category: { select: { id: true, name: true, nameAr: true } },
          store: { select: { id: true, name: true, nameAr: true } },
        },
      }),
      prisma.product.count({ where }),
    ])

    res.json({
      success: true,
      data: products,
      meta: { total, page: Number(page), limit: Number(limit), totalPages: Math.ceil(total / Number(limit)) },
    })
  } catch (err) {
    next(err)
  }
}

export async function getProduct(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const product = await prisma.product.findUnique({
      where: { id: req.params.id },
      include: {
        category: true,
        store: { select: { id: true, name: true, nameAr: true, rating: true, deliveryFee: true } },
      },
    })

    if (!product) {
      res.status(404).json({ success: false, message: 'Produit introuvable' })
      return
    }

    res.json({ success: true, data: product })
  } catch (err) {
    next(err)
  }
}

export async function createProduct(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const store = await prisma.store.findUnique({ where: { ownerId: req.user!.id } })
    if (!store) {
      res.status(404).json({ success: false, message: 'Boutique introuvable' })
      return
    }

    if (store.status !== 'ACTIVE') {
      res.status(403).json({ success: false, message: 'Boutique non active' })
      return
    }

    const data = productSchema.parse(req.body)
    const isAdmin = req.user!.role === 'ADMIN'
    const product = await prisma.product.create({
      data: {
        ...data,
        storeId: store.id,
        status: isAdmin ? (data.status ?? 'AVAILABLE') : 'PENDING_REVIEW',
      },
    })

    res.status(201).json({ success: true, data: product })
  } catch (err) {
    next(err)
  }
}

export async function updateProduct(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const product = await prisma.product.findUnique({
      where: { id: req.params.id },
      include: { store: true },
    })

    if (!product) {
      res.status(404).json({ success: false, message: 'Produit introuvable' })
      return
    }

    if (product.store.ownerId !== req.user!.id && req.user!.role !== 'ADMIN') {
      res.status(403).json({ success: false, message: 'Accès interdit' })
      return
    }

    const isAdmin = req.user!.role === 'ADMIN'
    const rawData = productSchema.partial().parse(req.body)

    // Vendors cannot change product status directly
    const data: typeof rawData & { status?: ProductStatus } = { ...rawData }
    if (!isAdmin) {
      delete data.status
      // If vendor edits a rejected product, automatically resubmit for review
      if (product.status === 'REJECTED') {
        data.status = ProductStatus.PENDING_REVIEW
      }
    }

    const updated = await prisma.product.update({ where: { id: req.params.id }, data })

    res.json({ success: true, data: updated })
  } catch (err) {
    next(err)
  }
}

export async function deleteProduct(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const product = await prisma.product.findUnique({
      where: { id: req.params.id },
      include: { store: true },
    })

    if (!product) {
      res.status(404).json({ success: false, message: 'Produit introuvable' })
      return
    }

    if (product.store.ownerId !== req.user!.id && req.user!.role !== 'ADMIN') {
      res.status(403).json({ success: false, message: 'Accès interdit' })
      return
    }

    await prisma.product.delete({ where: { id: req.params.id } })
    res.json({ success: true, message: 'Produit supprimé' })
  } catch (err) {
    next(err)
  }
}
