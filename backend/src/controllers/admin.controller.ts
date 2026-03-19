import { Request, Response, NextFunction } from 'express'
import { prisma } from '../lib/prisma'
import { AuthRequest } from '../middleware/auth'
import { StoreStatus } from '@prisma/client'

export async function getDashboardStats(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const now = new Date()
    const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate())
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1)
    const startOfPrevMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1)
    const endOfPrevMonth = new Date(now.getFullYear(), now.getMonth(), 0)

    const [
      totalUsers,
      totalStores,
      activeStores,
      pendingStores,
      totalOrders,
      ordersToday,
      ordersThisMonth,
      ordersPrevMonth,
      revenueThisMonth,
      revenuePrevMonth,
      totalProducts,
      pendingProducts,
      recentOrders,
      ordersByStatus,
      ordersByDay,
      topStores,
    ] = await Promise.all([
      prisma.user.count({ where: { isActive: true } }),
      prisma.store.count(),
      prisma.store.count({ where: { status: StoreStatus.ACTIVE } }),
      prisma.store.count({ where: { status: StoreStatus.PENDING } }),
      prisma.order.count(),
      prisma.order.count({ where: { createdAt: { gte: startOfDay } } }),
      prisma.order.count({ where: { createdAt: { gte: startOfMonth } } }),
      prisma.order.count({ where: { createdAt: { gte: startOfPrevMonth, lte: endOfPrevMonth } } }),
      prisma.order.aggregate({
        where: { createdAt: { gte: startOfMonth }, status: { in: ['DELIVERED', 'DELIVERING'] } },
        _sum: { total: true },
      }),
      prisma.order.aggregate({
        where: {
          createdAt: { gte: startOfPrevMonth, lte: endOfPrevMonth },
          status: { in: ['DELIVERED', 'DELIVERING'] },
        },
        _sum: { total: true },
      }),
      prisma.product.count({ where: { status: 'AVAILABLE' } }),
      prisma.product.count({ where: { status: 'PENDING_REVIEW' } }),
      prisma.order.findMany({
        take: 10,
        orderBy: { createdAt: 'desc' },
        include: {
          customer: { select: { name: true } },
          store: { select: { name: true } },
        },
      }),
      prisma.order.groupBy({ by: ['status'], _count: { id: true } }),
      prisma.$queryRaw`
        SELECT DATE(created_at) as date, COUNT(*) as count, SUM(total) as revenue
        FROM "Order"
        WHERE created_at >= ${startOfMonth}
        GROUP BY DATE(created_at)
        ORDER BY date ASC
      `,
      prisma.store.findMany({
        where: { status: StoreStatus.ACTIVE },
        orderBy: { rating: 'desc' },
        take: 5,
        select: { id: true, name: true, nameAr: true, rating: true, reviewCount: true, type: true, _count: { select: { orders: true } } },
      }),
    ])

    const ordersGrowth = ordersPrevMonth > 0
      ? ((ordersThisMonth - ordersPrevMonth) / ordersPrevMonth) * 100
      : 0

    const revenueGrowth =
      (revenuePrevMonth._sum.total || 0) > 0
        ? (((revenueThisMonth._sum.total || 0) - (revenuePrevMonth._sum.total || 0)) /
            (revenuePrevMonth._sum.total || 1)) * 100
        : 0

    res.json({
      success: true,
      data: {
        stats: {
          totalUsers,
          totalStores,
          activeStores,
          pendingStores,
          totalOrders,
          ordersToday,
          ordersThisMonth,
          revenueThisMonth: revenueThisMonth._sum.total || 0,
          totalProducts,
          pendingProducts,
          ordersGrowth: Math.round(ordersGrowth),
          revenueGrowth: Math.round(revenueGrowth),
        },
        recentOrders,
        ordersByStatus,
        ordersByDay,
        topStores,
      },
    })
  } catch (err) {
    next(err)
  }
}

export async function listUsers(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const { role, isActive, search, page = '1', limit = '20' } = req.query
    const pageNum = Math.max(1, parseInt(String(page)) || 1)
    const limitNum = Math.min(100, Math.max(1, parseInt(String(limit)) || 20))
    const skip = (pageNum - 1) * limitNum

    const where: Record<string, unknown> = {}
    if (role) where.role = role
    if (isActive !== undefined) where.isActive = isActive === 'true'
    if (search) {
      where.OR = [
        { name: { contains: search as string, mode: 'insensitive' } },
        { email: { contains: search as string, mode: 'insensitive' } },
        { phone: { contains: search as string, mode: 'insensitive' } },
      ]
    }

    const [users, total] = await Promise.all([
      prisma.user.findMany({
        where,
        skip,
        take: limitNum,
        orderBy: { createdAt: 'desc' },
        select: {
          id: true, email: true, phone: true, name: true, role: true,
          avatar: true, language: true, isActive: true, createdAt: true,
          _count: { select: { orders: true } },
          store: { select: { id: true, name: true, status: true } },
        },
      }),
      prisma.user.count({ where }),
    ])

    res.json({
      success: true,
      data: users,
      meta: { total, page: pageNum, limit: limitNum, totalPages: Math.ceil(total / limitNum) },
    })
  } catch (err) {
    next(err)
  }
}

export async function updateUserStatus(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const { isActive } = req.body
    const user = await prisma.user.update({
      where: { id: req.params.id },
      data: { isActive },
      select: { id: true, name: true, email: true, isActive: true },
    })
    res.json({ success: true, data: user })
  } catch (err) {
    next(err)
  }
}

export async function approveStore(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const { status } = req.body
    if (!['ACTIVE', 'SUSPENDED', 'CLOSED'].includes(status)) {
      res.status(400).json({ success: false, message: 'Statut invalide' })
      return
    }

    const store = await prisma.store.update({
      where: { id: req.params.id },
      data: { status: status as StoreStatus },
      include: { owner: { select: { id: true, name: true, email: true } } },
    })
    res.json({ success: true, data: store })
  } catch (err) {
    next(err)
  }
}

export async function listAllStoresAdmin(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const { status, type, search, page = '1', limit = '20' } = req.query
    const pageNum2 = Math.max(1, parseInt(String(page)) || 1)
    const limitNum2 = Math.min(100, Math.max(1, parseInt(String(limit)) || 20))
    const skip = (pageNum2 - 1) * limitNum2

    const where: Record<string, unknown> = {}
    if (status) where.status = status
    if (type) where.type = type
    if (search) {
      where.OR = [
        { name: { contains: search as string, mode: 'insensitive' } },
        { nameAr: { contains: search as string, mode: 'insensitive' } },
      ]
    }

    const [stores, total] = await Promise.all([
      prisma.store.findMany({
        where,
        skip,
        take: limitNum2,
        orderBy: { createdAt: 'desc' },
        include: {
          owner: { select: { id: true, name: true, email: true, phone: true } },
          _count: { select: { products: true, orders: true } },
        },
      }),
      prisma.store.count({ where }),
    ])

    res.json({
      success: true,
      data: stores,
      meta: { total, page: pageNum2, limit: limitNum2, totalPages: Math.ceil(total / limitNum2) },
    })
  } catch (err) {
    next(err)
  }
}

export async function listBanners(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const { isActive } = req.query
    const where: Record<string, unknown> = {}
    if (isActive !== undefined) where.isActive = isActive === 'true'
    const banners = await prisma.banner.findMany({ where, orderBy: { order: 'asc' } })
    res.json({ success: true, data: banners })
  } catch (err) {
    next(err)
  }
}

export async function createBanner(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const banner = await prisma.banner.create({ data: req.body })
    res.status(201).json({ success: true, data: banner })
  } catch (err) {
    next(err)
  }
}

export async function updateBanner(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const banner = await prisma.banner.update({ where: { id: req.params.id }, data: req.body })
    res.json({ success: true, data: banner })
  } catch (err) {
    next(err)
  }
}

export async function deleteBanner(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    await prisma.banner.delete({ where: { id: req.params.id } })
    res.json({ success: true, message: 'Bannière supprimée' })
  } catch (err) {
    next(err)
  }
}

export async function getSiteConfig(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const configs = await prisma.siteConfig.findMany({ orderBy: { key: 'asc' } })
    const configMap = configs.reduce((acc, c) => ({ ...acc, [c.key]: c.value }), {} as Record<string, string>)
    res.json({ success: true, data: configMap })
  } catch (err) {
    next(err)
  }
}

export async function updateSiteConfig(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const { key, value } = req.body
    if (!key || value === undefined) {
      res.status(400).json({ success: false, message: 'key et value requis' })
      return
    }
    const config = await prisma.siteConfig.upsert({
      where: { key },
      create: { key, value },
      update: { value },
    })
    res.json({ success: true, data: config })
  } catch (err) {
    next(err)
  }
}

export async function listPendingProducts(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const { page = '1', limit = '20' } = req.query
    const pageNum3 = Math.max(1, parseInt(String(page)) || 1)
    const limitNum3 = Math.min(100, Math.max(1, parseInt(String(limit)) || 20))
    const skip = (pageNum3 - 1) * limitNum3
    const [products, total] = await Promise.all([
      prisma.product.findMany({
        where: { status: 'PENDING_REVIEW' },
        skip,
        take: limitNum3,
        orderBy: { createdAt: 'desc' },
        include: {
          store: { select: { id: true, name: true, nameAr: true, type: true, owner: { select: { name: true, email: true } } } },
          category: { select: { id: true, name: true, nameAr: true } },
        },
      }),
      prisma.product.count({ where: { status: 'PENDING_REVIEW' } }),
    ])
    res.json({ success: true, data: products, meta: { total, page: pageNum3, limit: limitNum3, totalPages: Math.ceil(total / limitNum3) } })
  } catch (err) { next(err) }
}

export async function listAllReviews(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const { storeId, isVisible, rating, page = '1', limit = '20' } = req.query
    const pageNum4 = Math.max(1, parseInt(String(page)) || 1)
    const limitNum4 = Math.min(100, Math.max(1, parseInt(String(limit)) || 20))
    const skip = (pageNum4 - 1) * limitNum4

    const where: Record<string, unknown> = {}
    if (storeId) where.storeId = storeId
    if (isVisible === 'true' || isVisible === 'false') where.isVisible = isVisible === 'true'
    if (rating) where.rating = Number(rating)

    const [reviews, total] = await Promise.all([
      prisma.review.findMany({
        where,
        skip,
        take: limitNum4,
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
      meta: { total, page: pageNum4, limit: limitNum4, totalPages: Math.ceil(total / limitNum4) },
    })
  } catch (err) {
    next(err)
  }
}

export async function reviewProduct(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const { action, rejectionReason } = req.body
    if (!['approve', 'reject'].includes(action)) {
      res.status(400).json({ success: false, message: 'Action invalide. Utilisez approve ou reject.' })
      return
    }
    const product = await prisma.product.update({
      where: { id: req.params.id },
      data: {
        status: action === 'approve' ? 'AVAILABLE' : 'REJECTED',
        rejectionReason: action === 'reject' ? (rejectionReason || 'Non conforme aux règles de la plateforme') : null,
      },
      include: { store: { select: { id: true, name: true, ownerId: true } } },
    })
    await prisma.notification.create({
      data: {
        userId: product.store.ownerId,
        title: action === 'approve' ? 'Produit approuvé ✓' : 'Produit refusé ✗',
        body: action === 'approve'
          ? `Votre produit "${product.name}" a été approuvé et est maintenant visible.`
          : `Votre produit "${product.name}" a été refusé. Raison: ${product.rejectionReason}`,
        type: action === 'approve' ? 'PRODUCT_APPROVED' : 'PRODUCT_REJECTED',
        data: JSON.stringify({ productId: product.id }),
      },
    })
    res.json({ success: true, data: product })
  } catch (err) { next(err) }
}
