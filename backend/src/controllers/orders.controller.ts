import { Request, Response, NextFunction } from 'express'
import { z } from 'zod'
import { prisma } from '../lib/prisma'
import { AuthRequest } from '../middleware/auth'
import { OrderStatus } from '@prisma/client'

const createOrderSchema = z.object({
  storeId: z.string(),
  addressId: z.string().optional(),
  items: z.array(
    z.object({
      productId: z.string(),
      quantity: z.number().int().positive(),
      notes: z.string().optional(),
    })
  ).min(1),
  notes: z.string().optional(),
})

export async function createOrder(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const data = createOrderSchema.parse(req.body)

    const store = await prisma.store.findUnique({ where: { id: data.storeId } })
    if (!store || store.status !== 'ACTIVE') {
      res.status(400).json({ success: false, message: 'Boutique non disponible' })
      return
    }

    // Validate products and calculate totals
    const productIds = data.items.map((i) => i.productId)
    const products = await prisma.product.findMany({
      where: { id: { in: productIds }, storeId: data.storeId, status: 'AVAILABLE' },
    })

    if (products.length !== productIds.length) {
      res.status(400).json({ success: false, message: 'Certains produits sont indisponibles' })
      return
    }

    // Validate stock availability
    for (const item of data.items) {
      const product = products.find((p) => p.id === item.productId)!
      if (product.stock !== null && product.stock !== undefined && product.stock < item.quantity) {
        res.status(400).json({
          success: false,
          message: `Stock insuffisant pour "${product.name}" (disponible: ${product.stock})`,
        })
        return
      }
    }

    let subtotal = 0
    const orderItems = data.items.map((item) => {
      const product = products.find((p) => p.id === item.productId)!
      const lineTotal = product.price * item.quantity
      subtotal += lineTotal
      return {
        productId: item.productId,
        quantity: item.quantity,
        price: product.price,
        notes: item.notes,
      }
    })

    if (subtotal < store.minOrder) {
      res.status(400).json({
        success: false,
        message: `Commande minimum: ${store.minOrder} MRU`,
      })
      return
    }

    const deliveryFee = store.deliveryFee
    const total = subtotal + deliveryFee

    const order = await prisma.order.create({
      data: {
        customerId: req.user!.id,
        storeId: data.storeId,
        addressId: data.addressId,
        notes: data.notes,
        subtotal,
        deliveryFee,
        total,
        status: OrderStatus.PENDING,
        items: { create: orderItems },
      },
      include: {
        items: { include: { product: { select: { id: true, name: true, nameAr: true, images: true } } } },
        store: { select: { id: true, name: true, nameAr: true, phone: true } },
      },
    })

    // Decrement stock for products that track it
    const stockUpdates = data.items
      .filter((item) => {
        const p = products.find((p) => p.id === item.productId)!
        return p.stock !== null && p.stock !== undefined
      })
      .map((item) =>
        prisma.product.update({
          where: { id: item.productId },
          data: { stock: { decrement: item.quantity } },
        })
      )
    if (stockUpdates.length > 0) await Promise.all(stockUpdates)

    res.status(201).json({ success: true, data: order })
  } catch (err) {
    next(err)
  }
}

export async function listOrders(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const { status, page = '1', limit = '20', role } = req.query
    const pageNum = Math.max(1, parseInt(String(page)) || 1)
    const limitNum = Math.min(100, Math.max(1, parseInt(String(limit)) || 20))
    const skip = (pageNum - 1) * limitNum

    const where: Record<string, unknown> = {}

    if (req.user!.role === 'CUSTOMER') {
      where.customerId = req.user!.id
    } else if (req.user!.role === 'VENDOR') {
      const store = await prisma.store.findUnique({ where: { ownerId: req.user!.id } })
      if (!store) { res.json({ success: true, data: [], meta: { total: 0 } }); return }
      where.storeId = store.id
    } else if (req.user!.role === 'DELIVERY') {
      where.deliveryUserId = req.user!.id
    } else if (req.user!.role === 'ADMIN') {
      // Admin can see all
    }

    if (status) where.status = status

    const [orders, total] = await Promise.all([
      prisma.order.findMany({
        where,
        skip,
        take: limitNum,
        orderBy: { createdAt: 'desc' },
        include: {
          customer: { select: { id: true, name: true, phone: true } },
          store: { select: { id: true, name: true, nameAr: true } },
          address: true,
          items: {
            include: {
              product: { select: { id: true, name: true, nameAr: true, images: true } },
            },
          },
          deliveryUser: { select: { id: true, name: true, phone: true } },
        },
      }),
      prisma.order.count({ where }),
    ])

    res.json({
      success: true,
      data: orders,
      meta: { total, page: pageNum, limit: limitNum, totalPages: Math.ceil(total / limitNum) },
    })
  } catch (err) {
    next(err)
  }
}

export async function getOrder(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const order = await prisma.order.findUnique({
      where: { id: req.params.id },
      include: {
        customer: { select: { id: true, name: true, phone: true, email: true } },
        store: { select: { id: true, name: true, nameAr: true, phone: true, address: true } },
        address: true,
        items: {
          include: {
            product: { select: { id: true, name: true, nameAr: true, images: true, price: true } },
          },
        },
        deliveryUser: { select: { id: true, name: true, phone: true } },
      },
    })

    if (!order) {
      res.status(404).json({ success: false, message: 'Commande introuvable' })
      return
    }

    // Check access
    const canAccess =
      order.customerId === req.user!.id ||
      order.deliveryUserId === req.user!.id ||
      req.user!.role === 'ADMIN'

    if (!canAccess) {
      const vendorStore = await prisma.store.findUnique({ where: { ownerId: req.user!.id } })
      if (!vendorStore || vendorStore.id !== order.storeId) {
        res.status(403).json({ success: false, message: 'Accès interdit' })
        return
      }
    }

    res.json({ success: true, data: order })
  } catch (err) {
    next(err)
  }
}

const STATUS_TRANSITIONS: Record<string, string[]> = {
  PENDING: ['CONFIRMED', 'CANCELLED'],
  CONFIRMED: ['PREPARING', 'CANCELLED'],
  PREPARING: ['READY'],
  READY: ['DELIVERING'],
  DELIVERING: ['DELIVERED'],
  DELIVERED: [],
  CANCELLED: [],
}

export async function updateOrderStatus(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const { status, deliveryUserId, estimatedTime } = req.body
    const userId = req.user!.id
    const userRole = req.user!.role

    const order = await prisma.order.findUnique({
      where: { id: req.params.id },
      include: { store: true },
    })

    if (!order) {
      res.status(404).json({ success: false, message: 'Commande introuvable' })
      return
    }

    // Role-based authorization
    if (userRole === 'CUSTOMER') {
      if (order.customerId !== userId) {
        res.status(403).json({ success: false, message: 'Accès interdit' })
        return
      }
      if (status !== 'CANCELLED') {
        res.status(403).json({ success: false, message: 'Les clients ne peuvent qu\'annuler une commande' })
        return
      }
    } else if (userRole === 'VENDOR') {
      if (order.store.ownerId !== userId) {
        res.status(403).json({ success: false, message: 'Accès interdit à cette commande' })
        return
      }
    } else if (userRole === 'DELIVERY') {
      const isAssigned = order.deliveryUserId === userId
      const isAvailableForPickup = order.status === 'READY' && !order.deliveryUserId
      if (!isAssigned && !isAvailableForPickup) {
        res.status(403).json({ success: false, message: 'Accès interdit à cette commande' })
        return
      }
    }
    // ADMIN: no restriction

    const allowed = STATUS_TRANSITIONS[order.status] || []
    if (!allowed.includes(status)) {
      res.status(400).json({
        success: false,
        message: `Transition ${order.status} → ${status} non autorisée`,
      })
      return
    }

    const updateData: Record<string, unknown> = { status }
    if (deliveryUserId) updateData.deliveryUserId = deliveryUserId
    if (estimatedTime) updateData.estimatedTime = estimatedTime

    const updated = await prisma.order.update({
      where: { id: req.params.id },
      data: updateData,
      include: {
        items: { include: { product: { select: { id: true, name: true } } } },
        customer: { select: { id: true, name: true } },
        store: { select: { id: true, name: true } },
      },
    })

    res.json({ success: true, data: updated })
  } catch (err) {
    next(err)
  }
}

export async function rateOrder(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const { rating, ratingComment } = req.body
    if (!rating || rating < 1 || rating > 5) {
      res.status(400).json({ success: false, message: 'Note entre 1 et 5 requis' })
      return
    }

    const order = await prisma.order.findUnique({ where: { id: req.params.id } })
    if (!order) { res.status(404).json({ success: false, message: 'Commande introuvable' }); return }
    if (order.customerId !== req.user!.id) { res.status(403).json({ success: false, message: 'Accès interdit' }); return }
    if (order.status !== 'DELIVERED') { res.status(400).json({ success: false, message: 'Commande non livrée' }); return }

    await prisma.order.update({
      where: { id: req.params.id },
      data: { rating, ratingComment },
    })

    // Update store rating
    const storeOrders = await prisma.order.findMany({
      where: { storeId: order.storeId, rating: { not: null } },
      select: { rating: true },
    })
    const avgRating = storeOrders.reduce((s, o) => s + (o.rating || 0), 0) / storeOrders.length
    await prisma.store.update({
      where: { id: order.storeId },
      data: { rating: Math.round(avgRating * 10) / 10, reviewCount: storeOrders.length },
    })

    res.json({ success: true, message: 'Merci pour votre avis!' })
  } catch (err) {
    next(err)
  }
}
