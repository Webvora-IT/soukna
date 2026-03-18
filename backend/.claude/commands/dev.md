# Start Development Environment

Start the SOUKNA backend in development mode.

## Steps

1. Make sure PostgreSQL is running (via Docker or local)
2. Copy `.env.example` to `.env` if not done
3. Install dependencies:
   ```bash
   cd C:\Users\hp\Desktop\projet\soukna\backend
   npm install
   ```
4. Generate Prisma client:
   ```bash
   npm run prisma:generate
   ```
5. Run migrations:
   ```bash
   npm run prisma:migrate
   ```
6. Seed the database:
   ```bash
   npm run prisma:seed
   ```
7. Start dev server:
   ```bash
   npm run dev
   ```

## Quick start with Docker Compose
```bash
cd C:\Users\hp\Desktop\projet\soukna
docker-compose -f docker-compose.dev.yml up -d db
# Wait for DB to be ready, then:
docker-compose -f docker-compose.dev.yml up backend
```

## URLs
- API: http://localhost:5000
- Via nginx: http://localhost:3080/api
- Health: http://localhost:5000/health
