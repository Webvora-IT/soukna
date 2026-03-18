# Add a New API Route

To add a new route to the SOUKNA backend:

## Steps

### 1. Create the Controller
Create `src/controllers/<name>.controller.ts`:
```ts
import { Request, Response, NextFunction } from 'express'
import { prisma } from '../lib/prisma'
import { AuthRequest } from '../middleware/auth'
import { z } from 'zod'

const schema = z.object({
  // define validation
})

export async function list(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const items = await prisma.<model>.findMany()
    res.json({ success: true, data: items })
  } catch (err) { next(err) }
}

export async function create(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const data = schema.parse(req.body)
    const item = await prisma.<model>.create({ data })
    res.status(201).json({ success: true, data: item })
  } catch (err) { next(err) }
}
```

### 2. Create the Router
Create `src/routes/<name>.ts`:
```ts
import { Router } from 'express'
import { list, create } from '../controllers/<name>.controller'
import { authenticate, authorize } from '../middleware/auth'

const router = Router()
router.get('/', list)
router.post('/', authenticate, authorize('ADMIN'), create)
export default router
```

### 3. Register in src/index.ts
```ts
import newRoutes from './routes/<name>'
app.use('/api/<name>', newRoutes)
```

### 4. Add Prisma model if needed
Edit `prisma/schema.prisma`, then run:
```bash
npm run prisma:migrate
npm run prisma:generate
```
