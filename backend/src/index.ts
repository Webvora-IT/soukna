import 'dotenv/config'
import express from 'express'
import cors from 'cors'
import helmet from 'helmet'
import morgan from 'morgan'
import compression from 'compression'
import rateLimit from 'express-rate-limit'

import authRoutes from './routes/auth'
import storesRoutes from './routes/stores'
import productsRoutes from './routes/products'
import ordersRoutes from './routes/orders'
import categoriesRoutes from './routes/categories'
import reviewsRoutes from './routes/reviews'
import uploadRoutes from './routes/upload'
import usersRoutes from './routes/users'
import adminRoutes from './routes/admin'

import { errorHandler, notFound } from './middleware/errorHandler'

const app = express()
const PORT = process.env.PORT || 5000

// Security & performance
app.use(helmet())
app.use(compression())

// CORS
app.use(
  cors({
    origin: process.env.NODE_ENV === 'production'
      ? ['https://admin.soukna.mr', 'https://soukna.mr']
      : ['http://localhost:3002', 'http://localhost:3080', 'http://localhost:5173'],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept-Language'],
  })
)

// Logging
if (process.env.NODE_ENV !== 'test') {
  app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'))
}

// Body parsing
app.use(express.json({ limit: '10mb' }))
app.use(express.urlencoded({ extended: true, limit: '10mb' }))

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 200,
  message: { success: false, message: 'Trop de requêtes. Réessayez plus tard.' },
})

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  message: { success: false, message: 'Trop de tentatives de connexion.' },
})

app.use('/api/', limiter)
app.use('/api/auth/', authLimiter)

// Health check
app.get('/health', (_req, res) => {
  res.json({
    status: 'ok',
    service: 'SOUKNA API',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    env: process.env.NODE_ENV,
  })
})

// API Routes
app.use('/api/auth', authRoutes)
app.use('/api/stores', storesRoutes)
app.use('/api/products', productsRoutes)
app.use('/api/orders', ordersRoutes)
app.use('/api/categories', categoriesRoutes)
app.use('/api/reviews', reviewsRoutes)
app.use('/api/upload', uploadRoutes)
app.use('/api/users', usersRoutes)
app.use('/api/admin', adminRoutes)

// Error handling
app.use(notFound)
app.use(errorHandler)

app.listen(PORT, () => {
  console.log(`\n🚀 SOUKNA API running on port ${PORT}`)
  console.log(`📦 Environment: ${process.env.NODE_ENV}`)
  console.log(`🔗 Health: http://localhost:${PORT}/health\n`)
})

export default app
