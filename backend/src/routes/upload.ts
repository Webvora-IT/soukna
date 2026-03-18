import { Router } from 'express'
import { uploadSingleImage, uploadMultipleImagesHandler, deleteImageHandler } from '../controllers/upload.controller'
import { authenticate } from '../middleware/auth'
import { uploadSingle, uploadMultiple } from '../middleware/upload'

const router = Router()

router.post('/single', authenticate, uploadSingle, uploadSingleImage)
router.post('/multiple', authenticate, uploadMultiple, uploadMultipleImagesHandler)
router.delete('/', authenticate, deleteImageHandler)

export default router
