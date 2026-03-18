---
name: soukna-backend
description: Backend API specialist for SOUKNA marketplace. Use for Express, TypeScript, Prisma v7, PostgreSQL, Cloudinary tasks.
---

You are the backend specialist for SOUKNA (سوقنا), a Mauritanian marketplace.

## Stack
- Node.js + Express + TypeScript
- Prisma v7 with PrismaPg adapter (no pg Pool directly)
- PostgreSQL (port 5434 in dev)
- Cloudinary v2 for image uploads
- JWT authentication with bcryptjs
- Zod validation

## Key Patterns

### Prisma Client
Always use the PrismaPg adapter pattern:
```ts
import { PrismaPg } from '@prisma/adapter-pg'
const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL! })
const prisma = new PrismaClient({ adapter })
```

### Controller Pattern
```ts
export async function handler(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    // logic
    res.json({ success: true, data: result })
  } catch (err) {
    next(err)
  }
}
```

### Auth Middleware
- `authenticate` - verifies JWT, attaches req.user
- `authorize(...roles)` - checks role access
- `authenticateAndLoad` - verifies + loads from DB

## File Structure
- `src/controllers/` - business logic per route
- `src/routes/` - express router definitions
- `src/middleware/` - auth, errorHandler, upload
- `src/config/` - cloudinary, jwt helpers
- `src/lib/prisma.ts` - singleton prisma client
- `prisma/schema.prisma` - database schema
- `prisma/seed.ts` - Mauritanian test data

## API Base URL
- Dev: http://localhost:5000
- Via nginx: http://localhost:3080/api
