import { Router } from 'express'
import { listProducts, getProduct, createProduct, updateProduct, deleteProduct } from '../controllers/products.controller'
import { authenticate, authorize, optionalAuthenticate } from '../middleware/auth'

const router = Router()

router.get('/', optionalAuthenticate, listProducts)
router.get('/:id', getProduct)
router.post('/', authenticate, authorize('VENDOR', 'ADMIN'), createProduct)
router.patch('/:id', authenticate, authorize('VENDOR', 'ADMIN'), updateProduct)
router.delete('/:id', authenticate, authorize('VENDOR', 'ADMIN'), deleteProduct)

export default router
