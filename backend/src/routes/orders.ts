import { Router } from 'express'
import { createOrder, listOrders, getOrder, updateOrderStatus, rateOrder } from '../controllers/orders.controller'
import { authenticate } from '../middleware/auth'

const router = Router()

router.post('/', authenticate, createOrder)
router.get('/', authenticate, listOrders)
router.get('/:id', authenticate, getOrder)
router.patch('/:id/status', authenticate, updateOrderStatus)
router.post('/:id/rate', authenticate, rateOrder)

export default router
