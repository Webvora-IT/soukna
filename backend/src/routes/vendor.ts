import { Router } from 'express'
import { authenticate, authorize } from '../middleware/auth'
import { prisma } from '../lib/prisma'
import { AuthRequest } from '../middleware/auth'
import { Response, NextFunction } from 'express'

const router = Router()

// GET /api/vendor/dashboard - vendor dashboard stats
router.get('/dashboard', authenticate, authorize('VENDOR'), async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const store = await prisma.store.findUnique({ where: { ownerId: req.user!.id } })
    if (!store) { res.status(404).json({ success: false, message: 'Aucune boutique trouvée' }); return }

    const now = new Date()
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1)

    const [
      totalProducts,
      pendingProducts,
      availableProducts,
      rejectedProducts,
      totalOrders,
      ordersThisMonth,
      pendingOrders,
      revenueThisMonth,
      recentOrders,
    ] = await Promise.all([
      prisma.product.count({ where: { storeId: store.id } }),
      prisma.product.count({ where: { storeId: store.id, status: 'PENDING_REVIEW' } }),
      prisma.product.count({ where: { storeId: store.id, status: 'AVAILABLE' } }),
      prisma.product.count({ where: { storeId: store.id, status: 'REJECTED' } }),
      prisma.order.count({ where: { storeId: store.id } }),
      prisma.order.count({ where: { storeId: store.id, createdAt: { gte: startOfMonth } } }),
      prisma.order.count({ where: { storeId: store.id, status: { in: ['PENDING', 'CONFIRMED', 'PREPARING'] } } }),
      prisma.order.aggregate({
        where: { storeId: store.id, status: { in: ['DELIVERED', 'DELIVERING'] }, createdAt: { gte: startOfMonth } },
        _sum: { total: true },
      }),
      prisma.order.findMany({
        where: { storeId: store.id },
        take: 5,
        orderBy: { createdAt: 'desc' },
        include: { customer: { select: { name: true } }, items: { include: { product: { select: { name: true } } } } },
      }),
    ])

    res.json({
      success: true,
      data: {
        store,
        stats: {
          totalProducts, pendingProducts, availableProducts, rejectedProducts,
          totalOrders, ordersThisMonth, pendingOrders,
          revenueThisMonth: revenueThisMonth._sum.total || 0,
        },
        recentOrders,
      },
    })
  } catch (err) { next(err) }
})

// GET /api/vendor/store - get vendor's own store
router.get('/store', authenticate, authorize('VENDOR'), async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const store = await prisma.store.findUnique({
      where: { ownerId: req.user!.id },
      include: { categories: { include: { category: true } }, _count: { select: { products: true, orders: true, reviews: true } } },
    })
    if (!store) { res.status(404).json({ success: false, message: 'Aucune boutique trouvée' }); return }
    res.json({ success: true, data: store })
  } catch (err) { next(err) }
})

// PATCH /api/vendor/store - update vendor's own store
router.patch('/store', authenticate, authorize('VENDOR'), async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const store = await prisma.store.findUnique({ where: { ownerId: req.user!.id } })
    if (!store) { res.status(404).json({ success: false, message: 'Aucune boutique trouvée' }); return }
    const { name, nameAr, description, descriptionAr, phone, address, district, openTime, closeTime, isOpen, deliveryFee, minOrder, logo, coverImage } = req.body
    const updated = await prisma.store.update({
      where: { id: store.id },
      data: { name, nameAr, description, descriptionAr, phone, address, district, openTime, closeTime, isOpen, deliveryFee, minOrder, logo, coverImage },
    })
    res.json({ success: true, data: updated })
  } catch (err) { next(err) }
})

// GET /api/vendor/products - list vendor's products with all statuses
router.get('/products', authenticate, authorize('VENDOR'), async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const store = await prisma.store.findUnique({ where: { ownerId: req.user!.id } })
    if (!store) { res.status(404).json({ success: false, message: 'Aucune boutique trouvée' }); return }
    const { status, page = '1', limit = '20' } = req.query
    const skip = (Number(page) - 1) * Number(limit)
    const where: Record<string, unknown> = { storeId: store.id }
    if (status) where.status = status
    const [products, total] = await Promise.all([
      prisma.product.findMany({ where, skip, take: Number(limit), orderBy: { createdAt: 'desc' }, include: { category: { select: { id: true, name: true, nameAr: true } } } }),
      prisma.product.count({ where }),
    ])
    res.json({ success: true, data: products, meta: { total, page: Number(page), limit: Number(limit), totalPages: Math.ceil(total / Number(limit)) } })
  } catch (err) { next(err) }
})

// GET /api/vendor/orders - list vendor's store orders
router.get('/orders', authenticate, authorize('VENDOR'), async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const store = await prisma.store.findUnique({ where: { ownerId: req.user!.id } })
    if (!store) { res.status(404).json({ success: false, message: 'Aucune boutique trouvée' }); return }
    const { status, page = '1', limit = '20' } = req.query
    const skip = (Number(page) - 1) * Number(limit)
    const where: Record<string, unknown> = { storeId: store.id }
    if (status) where.status = status
    const [orders, total] = await Promise.all([
      prisma.order.findMany({
        where, skip, take: Number(limit), orderBy: { createdAt: 'desc' },
        include: {
          customer: { select: { name: true, phone: true } },
          items: { include: { product: { select: { name: true, nameAr: true, images: true } } } },
          address: true,
        },
      }),
      prisma.order.count({ where }),
    ])
    res.json({ success: true, data: orders, meta: { total, page: Number(page), limit: Number(limit), totalPages: Math.ceil(total / Number(limit)) } })
  } catch (err) { next(err) }
})

// PATCH /api/vendor/orders/:id/status - update order status
router.patch('/orders/:id/status', authenticate, authorize('VENDOR'), async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { status } = req.body
    const vendorAllowedTransitions: Record<string, string[]> = {
      PENDING: ['CONFIRMED', 'CANCELLED'],
      CONFIRMED: ['PREPARING', 'CANCELLED'],
      PREPARING: ['READY'],
    }
    const order = await prisma.order.findUnique({ where: { id: req.params.id }, include: { store: true } })
    if (!order) { res.status(404).json({ success: false, message: 'Commande introuvable' }); return }
    if (order.store.ownerId !== req.user!.id) { res.status(403).json({ success: false, message: 'Accès interdit' }); return }
    const allowed = vendorAllowedTransitions[order.status] || []
    if (!allowed.includes(status)) {
      res.status(400).json({ success: false, message: `Transition invalide: ${order.status} → ${status}` })
      return
    }
    const updated = await prisma.order.update({ where: { id: req.params.id }, data: { status } })
    res.json({ success: true, data: updated })
  } catch (err) { next(err) }
})

// GET /api/vendor/notifications - vendor notifications
router.get('/notifications', authenticate, authorize('VENDOR'), async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const notifications = await prisma.notification.findMany({
      where: { userId: req.user!.id },
      orderBy: { createdAt: 'desc' },
      take: 30,
    })
    const unreadCount = await prisma.notification.count({ where: { userId: req.user!.id, isRead: false } })
    res.json({ success: true, data: notifications, unreadCount })
  } catch (err) { next(err) }
})

// PATCH /api/vendor/notifications/:id/read - mark single notification as read
router.patch('/notifications/:id/read', authenticate, authorize('VENDOR'), async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const notif = await prisma.notification.findUnique({ where: { id: req.params.id } })
    if (!notif || notif.userId !== req.user!.id) {
      res.status(404).json({ success: false, message: 'Notification introuvable' }); return
    }
    await prisma.notification.update({ where: { id: req.params.id }, data: { isRead: true } })
    res.json({ success: true })
  } catch (err) { next(err) }
})

// POST /api/vendor/notifications/read-all - mark all as read
router.post('/notifications/read-all', authenticate, authorize('VENDOR'), async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    await prisma.notification.updateMany({ where: { userId: req.user!.id, isRead: false }, data: { isRead: true } })
    res.json({ success: true, message: 'Toutes les notifications marquées comme lues' })
  } catch (err) { next(err) }
})

export default router
