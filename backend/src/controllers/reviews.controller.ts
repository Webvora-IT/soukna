import { Request, Response, NextFunction } from 'express'
import { z } from 'zod'
import { prisma } from '../lib/prisma'
import { AuthRequest } from '../middleware/auth'

const reviewSchema = z.object({
  storeId: z.string(),
  rating: z.number().int().min(1).max(5),
  comment: z.string().optional(),
  images: z.array(z.string()).optional().default([]),
})

export async function listReviews(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const { storeId, userId, page = '1', limit = '20' } = req.query
    const skip = (Number(page) - 1) * Number(limit)

    const where: Record<string, unknown> = { isVisible: true }
    if (storeId) where.storeId = storeId
    if (userId) where.userId = userId

    const [reviews, total] = await Promise.all([
      prisma.review.findMany({
        where,
        skip,
        take: Number(limit),
        orderBy: { createdAt: 'desc' },
        include: {
          user: { select: { id: true, name: true, avatar: true } },
          store: { select: { id: true, name: true, nameAr: true } },
        },
      }),
      prisma.review.count({ where }),
    ])

    res.json({
      success: true,
      data: reviews,
      meta: { total, page: Number(page), limit: Number(limit), totalPages: Math.ceil(total / Number(limit)) },
    })
  } catch (err) {
    next(err)
  }
}

export async function createReview(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const data = reviewSchema.parse(req.body)

    // Check if user has an order from this store
    const order = await prisma.order.findFirst({
      where: { customerId: req.user!.id, storeId: data.storeId, status: 'DELIVERED' },
    })

    if (!order) {
      res.status(403).json({ success: false, message: 'Vous devez commander pour laisser un avis' })
      return
    }

    // Check if already reviewed
    const existing = await prisma.review.findFirst({
      where: { userId: req.user!.id, storeId: data.storeId },
    })

    if (existing) {
      res.status(409).json({ success: false, message: 'Vous avez déjà laissé un avis' })
      return
    }

    const review = await prisma.review.create({
      data: { ...data, userId: req.user!.id },
      include: { user: { select: { id: true, name: true, avatar: true } } },
    })

    // Update store rating
    const reviews = await prisma.review.findMany({
      where: { storeId: data.storeId, isVisible: true },
      select: { rating: true },
    })
    const avg = reviews.reduce((s, r) => s + r.rating, 0) / reviews.length
    await prisma.store.update({
      where: { id: data.storeId },
      data: { rating: Math.round(avg * 10) / 10, reviewCount: reviews.length },
    })

    res.status(201).json({ success: true, data: review })
  } catch (err) {
    next(err)
  }
}

export async function moderateReview(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const { isVisible } = req.body
    const review = await prisma.review.update({
      where: { id: req.params.id },
      data: { isVisible },
    })
    res.json({ success: true, data: review })
  } catch (err) {
    next(err)
  }
}

export async function deleteReview(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const review = await prisma.review.findUnique({ where: { id: req.params.id } })
    if (!review) { res.status(404).json({ success: false, message: 'Avis introuvable' }); return }
    if (review.userId !== req.user!.id && req.user!.role !== 'ADMIN') {
      res.status(403).json({ success: false, message: 'Accès interdit' }); return
    }
    await prisma.review.delete({ where: { id: req.params.id } })
    res.json({ success: true, message: 'Avis supprimé' })
  } catch (err) {
    next(err)
  }
}
