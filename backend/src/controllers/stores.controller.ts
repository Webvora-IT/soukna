import { Request, Response, NextFunction } from 'express'
import { z } from 'zod'
import { prisma } from '../lib/prisma'
import { AuthRequest } from '../middleware/auth'
import { StoreType, StoreStatus } from '@prisma/client'

const createStoreSchema = z.object({
  name: z.string().min(2),
  nameAr: z.string().optional(),
  description: z.string().optional(),
  descriptionAr: z.string().optional(),
  type: z.nativeEnum(StoreType),
  phone: z.string().optional(),
  address: z.string().optional(),
  district: z.string().optional(),
  city: z.string().optional().default('Nouakchott'),
  lat: z.number().optional(),
  lng: z.number().optional(),
  openTime: z.string().optional(),
  closeTime: z.string().optional(),
  deliveryFee: z.number().optional().default(0),
  minOrder: z.number().optional().default(0),
})

const updateStoreSchema = createStoreSchema.partial().extend({
  isOpen: z.boolean().optional(),
})

export async function listStores(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const {
      type,
      status,
      search,
      district,
      city,
      page = '1',
      limit = '20',
      isOpen,
    } = req.query

    const pageNum = Math.max(1, parseInt(String(page)) || 1)
    const limitNum = Math.min(100, Math.max(1, parseInt(String(limit)) || 20))
    const skip = (pageNum - 1) * limitNum

    const where: Record<string, unknown> = { status: StoreStatus.ACTIVE }
    if (type) where.type = type as StoreType
    if (district) where.district = district
    if (city) where.city = city
    if (isOpen === 'true') where.isOpen = true
    if (search) {
      where.OR = [
        { name: { contains: search as string, mode: 'insensitive' } },
        { nameAr: { contains: search as string, mode: 'insensitive' } },
        { description: { contains: search as string, mode: 'insensitive' } },
      ]
    }

    const [stores, total] = await Promise.all([
      prisma.store.findMany({
        where,
        skip,
        take: limitNum,
        orderBy: [{ rating: 'desc' }, { createdAt: 'desc' }],
        include: {
          categories: {
            include: { category: { select: { id: true, name: true, nameAr: true, icon: true } } },
          },
          _count: { select: { products: true, orders: true } },
        },
      }),
      prisma.store.count({ where }),
    ])

    res.json({
      success: true,
      data: stores,
      meta: { total, page: pageNum, limit: limitNum, totalPages: Math.ceil(total / limitNum) },
    })
  } catch (err) {
    next(err)
  }
}

export async function getStore(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const store = await prisma.store.findUnique({
      where: { id: req.params.id },
      include: {
        owner: { select: { id: true, name: true, phone: true } },
        categories: {
          include: { category: true },
        },
        products: {
          where: { status: 'AVAILABLE' },
          orderBy: { createdAt: 'desc' },
          include: { category: { select: { id: true, name: true, nameAr: true } } },
        },
        reviews: {
          where: { isVisible: true },
          orderBy: { createdAt: 'desc' },
          take: 10,
          include: { user: { select: { id: true, name: true, avatar: true } } },
        },
        _count: { select: { products: true, orders: true, reviews: true } },
      },
    })

    if (!store) {
      res.status(404).json({ success: false, message: 'Boutique introuvable' })
      return
    }

    res.json({ success: true, data: store })
  } catch (err) {
    next(err)
  }
}

export async function createStore(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const existingStore = await prisma.store.findUnique({ where: { ownerId: req.user!.id } })
    if (existingStore) {
      res.status(409).json({ success: false, message: 'Vous avez déjà une boutique' })
      return
    }

    const data = createStoreSchema.parse(req.body)

    const store = await prisma.store.create({
      data: {
        ...data,
        ownerId: req.user!.id,
        status: StoreStatus.PENDING,
      },
    })

    // Update user role to VENDOR
    await prisma.user.update({
      where: { id: req.user!.id },
      data: { role: 'VENDOR' },
    })

    res.status(201).json({ success: true, message: 'Boutique créée, en attente d\'approbation', data: store })
  } catch (err) {
    next(err)
  }
}

export async function updateStore(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const store = await prisma.store.findUnique({ where: { id: req.params.id } })
    if (!store) {
      res.status(404).json({ success: false, message: 'Boutique introuvable' })
      return
    }

    if (store.ownerId !== req.user!.id && req.user!.role !== 'ADMIN') {
      res.status(403).json({ success: false, message: 'Accès interdit' })
      return
    }

    const data = updateStoreSchema.parse(req.body)
    const updated = await prisma.store.update({ where: { id: req.params.id }, data })

    res.json({ success: true, data: updated })
  } catch (err) {
    next(err)
  }
}

export async function deleteStore(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const store = await prisma.store.findUnique({ where: { id: req.params.id } })
    if (!store) {
      res.status(404).json({ success: false, message: 'Boutique introuvable' })
      return
    }

    if (store.ownerId !== req.user!.id && req.user!.role !== 'ADMIN') {
      res.status(403).json({ success: false, message: 'Accès interdit' })
      return
    }

    await prisma.store.update({
      where: { id: req.params.id },
      data: { status: StoreStatus.CLOSED },
    })

    res.json({ success: true, message: 'Boutique fermée' })
  } catch (err) {
    next(err)
  }
}

export async function getMyStore(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const store = await prisma.store.findUnique({
      where: { ownerId: req.user!.id },
      include: {
        categories: { include: { category: true } },
        _count: { select: { products: true, orders: true } },
      },
    })

    if (!store) {
      res.status(404).json({ success: false, message: 'Boutique introuvable' })
      return
    }

    res.json({ success: true, data: store })
  } catch (err) {
    next(err)
  }
}
