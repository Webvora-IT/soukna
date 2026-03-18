import { Router } from 'express'
import { listStores, getStore, createStore, updateStore, deleteStore, getMyStore } from '../controllers/stores.controller'
import { authenticate, authorize } from '../middleware/auth'

const router = Router()

router.get('/', listStores)
router.get('/my', authenticate, authorize('VENDOR', 'ADMIN'), getMyStore)
router.get('/:id', getStore)
router.post('/', authenticate, createStore)
router.patch('/:id', authenticate, updateStore)
router.delete('/:id', authenticate, deleteStore)

export default router
