import { Router } from 'express'
import {
  getDashboardStats,
  listUsers,
  updateUserStatus,
  approveStore,
  listAllStoresAdmin,
  listBanners,
  createBanner,
  updateBanner,
  deleteBanner,
  getSiteConfig,
  updateSiteConfig,
  listPendingProducts,
  reviewProduct,
} from '../controllers/admin.controller'
import { authenticate, authorize } from '../middleware/auth'

const router = Router()

// All admin routes require ADMIN role
router.use(authenticate, authorize('ADMIN'))

router.get('/stats', getDashboardStats)
router.get('/users', listUsers)
router.patch('/users/:id/status', updateUserStatus)
router.get('/stores', listAllStoresAdmin)
router.patch('/stores/:id/status', approveStore)
router.get('/banners', listBanners)
router.post('/banners', createBanner)
router.patch('/banners/:id', updateBanner)
router.delete('/banners/:id', deleteBanner)
router.get('/config', getSiteConfig)
router.post('/config', updateSiteConfig)
router.get('/products/pending', listPendingProducts)
router.patch('/products/:id/review', reviewProduct)

export default router
