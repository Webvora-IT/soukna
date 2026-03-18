# Deploy SOUKNA Backend

## Production Docker Build

```bash
cd C:\Users\hp\Desktop\projet\soukna

# 1. Create .env from example
cp .env.example .env
# Edit .env with real values (DB password, JWT secret, Cloudinary)

# 2. Build and start all services
docker-compose up -d --build

# 3. Check logs
docker-compose logs -f backend

# 4. Run migrations (auto via entrypoint.sh)
# Or manually:
docker-compose exec backend npx prisma migrate deploy

# 5. Seed data (optional, first time)
docker-compose exec backend npm run prisma:seed
```

## URLs (production)
- App: http://localhost:82
- API: http://localhost:82/api

## Health Check
```bash
curl http://localhost:82/health
```
