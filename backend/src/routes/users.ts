import { Router } from 'express'
import {
  getProfile,
  updateProfile,
  changePassword,
  getAddresses,
  createAddress,
  updateAddress,
  deleteAddress,
  getNotifications,
  markNotificationsRead,
} from '../controllers/users.controller'
import { authenticate } from '../middleware/auth'

const router = Router()

router.get('/profile', authenticate, getProfile)
router.patch('/profile', authenticate, updateProfile)
router.post('/change-password', authenticate, changePassword)
router.get('/addresses', authenticate, getAddresses)
router.post('/addresses', authenticate, createAddress)
router.patch('/addresses/:id', authenticate, updateAddress)
router.delete('/addresses/:id', authenticate, deleteAddress)
router.get('/notifications', authenticate, getNotifications)
router.post('/notifications/read-all', authenticate, markNotificationsRead)

export default router
