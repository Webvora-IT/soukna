import { Router } from 'express'
import { register, login, getMe, refreshToken, firebaseAuth, forgotPassword, resetPassword } from '../controllers/auth.controller'
import { authenticate } from '../middleware/auth'

const router = Router()

router.post('/register', register)
router.post('/login', login)
router.post('/firebase', firebaseAuth)
router.post('/refresh', refreshToken)
router.get('/me', authenticate, getMe)
router.post('/forgot-password', forgotPassword)
router.post('/reset-password', resetPassword)

export default router
