import { Request, Response, NextFunction } from 'express'
import { z } from 'zod'
import { prisma } from '../lib/prisma'
import { AuthRequest } from '../middleware/auth'
import { StoreType } from '@prisma/client'

const categorySchema = z.object({
  name: z.string().min(2),
  nameAr: z.string().optional(),
  nameEn: z.string().optional(),
  icon: z.string().optional(),
  image: z.string().optional(),
  storeType: z.nativeEnum(StoreType).optional().nullable(),
  isActive: z.boolean().optional().default(true),
})

export async function listCategories(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const { storeType, isActive } = req.query
    const authReq = req as import('../middleware/auth').AuthRequest
    const isAdmin = authReq.user?.role === 'ADMIN'

    const where: Record<string, unknown> = {}
    if (storeType) where.storeType = storeType
    if (isActive === 'true' || isActive === 'false') {
      where.isActive = isActive === 'true'
    } else if (!isAdmin) {
      where.isActive = true
    }

    const categories = await prisma.category.findMany({
      where,
      orderBy: { name: 'asc' },
      include: { _count: { select: { products: true, stores: true } } },
    })

    res.json({ success: true, data: categories })
  } catch (err) {
    next(err)
  }
}

export async function getCategory(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const category = await prisma.category.findUnique({
      where: { id: req.params.id },
      include: {
        _count: { select: { products: true, stores: true } },
      },
    })

    if (!category) {
      res.status(404).json({ success: false, message: 'Catégorie introuvable' })
      return
    }

    res.json({ success: true, data: category })
  } catch (err) {
    next(err)
  }
}

export async function createCategory(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const data = categorySchema.parse(req.body)
    const category = await prisma.category.create({ data })
    res.status(201).json({ success: true, data: category })
  } catch (err) {
    next(err)
  }
}

export async function updateCategory(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const data = categorySchema.partial().parse(req.body)
    const category = await prisma.category.update({
      where: { id: req.params.id },
      data,
    })
    res.json({ success: true, data: category })
  } catch (err) {
    next(err)
  }
}

export async function deleteCategory(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    await prisma.category.delete({ where: { id: req.params.id } })
    res.json({ success: true, message: 'Catégorie supprimée' })
  } catch (err) {
    next(err)
  }
}
