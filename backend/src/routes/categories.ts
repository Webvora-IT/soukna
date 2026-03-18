import { Router } from 'express'
import { listCategories, getCategory, createCategory, updateCategory, deleteCategory } from '../controllers/categories.controller'
import { authenticate, authorize } from '../middleware/auth'

const router = Router()

router.get('/', listCategories)
router.get('/:id', getCategory)
router.post('/', authenticate, authorize('ADMIN'), createCategory)
router.patch('/:id', authenticate, authorize('ADMIN'), updateCategory)
router.delete('/:id', authenticate, authorize('ADMIN'), deleteCategory)

export default router
