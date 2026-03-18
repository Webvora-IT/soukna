import { Router } from 'express'
import { listReviews, createReview, moderateReview, deleteReview } from '../controllers/reviews.controller'
import { authenticate, authorize } from '../middleware/auth'

const router = Router()

router.get('/', listReviews)
router.post('/', authenticate, authorize('CUSTOMER'), createReview)
router.patch('/:id/moderate', authenticate, authorize('ADMIN'), moderateReview)
router.delete('/:id', authenticate, deleteReview)

export default router
