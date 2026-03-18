# SOUKNA - سوقنا
## Notre Marché Mauritanien

A complete full-stack marketplace platform built for Mauritania, serving Nouakchott and beyond.

---

## Architecture

```
soukna/
├── backend/          Node.js + Express + TypeScript + Prisma v7 + PostgreSQL
├── admin/            React + TypeScript + Vite + Tailwind CSS (dark theme)
├── mobile/
│   ├── client/       Flutter app for customers
│   └── delivery/     Flutter app for delivery personnel
├── nginx/            Nginx configs (dev + production)
├── docker-compose.dev.yml
├── docker-compose.yml
└── .env.example
```

## Stack

| Layer | Technology |
|-------|-----------|
| Backend API | Node.js + Express + TypeScript |
| Database | PostgreSQL 16 + Prisma v7 (PrismaPg adapter) |
| Image Storage | Cloudinary v2 |
| Authentication | JWT + bcryptjs |
| Admin Panel | React 18 + Vite + Tailwind CSS |
| Mobile | Flutter 3 (Dart) |
| Reverse Proxy | Nginx |
| Containerization | Docker Compose |

## Quick Start (Development)

### Prerequisites
- Docker Desktop
- Node.js 20+ (for local dev)
- Flutter 3+ (for mobile)

### 1. Clone & Configure

```bash
cd C:\Users\hp\Desktop\projet\soukna
cp .env.example .env
# Edit .env with your Cloudinary credentials
```

### 2. Start with Docker Compose

```bash
docker-compose -f docker-compose.dev.yml up -d
```

Services started:
- **PostgreSQL** on port `5434`
- **Backend API** on port `5000` (and via nginx on `3080/api`)
- **Admin Panel** on port `3002` (and via nginx on `3080`)
- **Nginx** on port `3080`

### 3. Run Database Migrations & Seed

```bash
# Enter backend container
docker-compose -f docker-compose.dev.yml exec backend sh

# Or locally:
cd backend
npm install
npm run prisma:migrate
npm run prisma:seed
```

### 4. Access the Services

| Service | URL |
|---------|-----|
| Admin Panel | http://localhost:3080 or http://localhost:3002 |
| Backend API | http://localhost:3080/api |
| Health Check | http://localhost:3080/health |
| PostgreSQL | localhost:5434 |

## Default Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@soukna.mr | Admin@Soukna2024 |
| Customer | aminata@gmail.com | Test@123 |
| Vendor | vendor.restaurant@soukna.mr | Test@123 |
| Delivery | delivery1@soukna.mr | Test@123 |

## API Documentation

### Base URL
```
http://localhost:3080/api
```

### Authentication
```
POST /api/auth/register    Create account
POST /api/auth/login       Login
GET  /api/auth/me          Get current user (requires token)
POST /api/auth/refresh     Refresh JWT token
```

### Stores
```
GET    /api/stores          List stores (filters: type, search, district, city)
GET    /api/stores/:id      Get store details with products
POST   /api/stores          Create store (requires auth)
PATCH  /api/stores/:id      Update store
DELETE /api/stores/:id      Close store
GET    /api/stores/my       Get my store (vendor)
```

### Products
```
GET    /api/products        List products (filters: storeId, categoryId, status)
GET    /api/products/:id    Get product
POST   /api/products        Create product (vendor/admin)
PATCH  /api/products/:id    Update product
DELETE /api/products/:id    Delete product
```

### Orders
```
POST   /api/orders              Create order
GET    /api/orders              List orders (filtered by role)
GET    /api/orders/:id          Get order detail
PATCH  /api/orders/:id/status   Update order status
POST   /api/orders/:id/rate     Rate completed order
```

### Categories
```
GET    /api/categories      List categories
POST   /api/categories      Create (admin only)
PATCH  /api/categories/:id  Update (admin only)
DELETE /api/categories/:id  Delete (admin only)
```

### Upload
```
POST   /api/upload/single    Upload single image → Cloudinary
POST   /api/upload/multiple  Upload multiple images
DELETE /api/upload           Delete image by publicId
```

### Admin
```
GET    /api/admin/stats              Dashboard statistics
GET    /api/admin/users              List all users
PATCH  /api/admin/users/:id/status   Activate/deactivate user
GET    /api/admin/stores             List all stores
PATCH  /api/admin/stores/:id/status  Approve/suspend store
GET    /api/admin/banners            List banners
POST   /api/admin/banners            Create banner
PATCH  /api/admin/banners/:id        Update banner
DELETE /api/admin/banners/:id        Delete banner
GET    /api/admin/config             Get site config
POST   /api/admin/config             Update config key
```

## Order Status Flow

```
PENDING → CONFIRMED → PREPARING → READY → DELIVERING → DELIVERED
    ↓           ↓
CANCELLED   CANCELLED
```

## Store Types

| Type | Arabic | Description |
|------|--------|-------------|
| RESTAURANT | مطعم | Restaurants, cafés, food |
| GROCERY | بقالة | Épiceries, supermarkets |
| BOUTIQUE | بوتيك | Clothing, electronics |
| SERVICE | خدمات | Various services |

## Nouakchott Districts

Delivery zones covered:
- Tevragh-Zeina (تفرغ زينة)
- Ksar (القصر)
- Dar Naim (دار النعيم)
- Teyarett (تيارت)
- Arafat (عرفات)
- Sebkha (السبخة)
- El Mina (الميناء)
- Riyad (الرياض)

## Currency

All prices are in **MRU (Ouguiya Mauritanienne / أوقية موريتانية)**.

## Multi-language Support

The platform supports 3 languages:
- **Français** (default)
- **العربية** (Arabic, RTL)
- **English**

Backend: Use `Accept-Language` header or `lang` query param.
Admin: Toggle in the top navigation bar.
Mobile: Device locale or user preference.

## Docker Production Deployment

```bash
# Configure production environment
cp .env.example .env
# Edit .env with production values

# Build and start
docker-compose up -d --build

# Check status
docker-compose ps
docker-compose logs -f

# The app runs on port 82
```

## Flutter Mobile Setup

### Client App
```bash
cd mobile/client
flutter pub get
flutter run
```

### Delivery App
```bash
cd mobile/delivery
flutter pub get
flutter run
```

### Update API URL for device testing
In `mobile/client/lib/services/api_service.dart`:
```dart
static const String _baseUrl = 'http://YOUR_LOCAL_IP:3080/api';
```

## Development

### Backend
```bash
cd backend
npm install
npm run prisma:generate
npm run prisma:migrate
npm run prisma:seed
npm run dev          # Start with ts-node-dev
npm run build        # Compile TypeScript
```

### Admin Panel
```bash
cd admin
npm install
npm run dev          # Start Vite dev server
npm run build        # Build for production
```

## Project Structure Details

### Backend Controllers
Each route has its own controller with proper TypeScript types, Zod validation, and error handling.

### Prisma v7 Pattern
Uses `PrismaPg` adapter instead of direct `pg.Pool`:
```typescript
const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL! })
const prisma = new PrismaClient({ adapter })
```

### Seed Data
Realistic Mauritanian data includes:
- 5 stores in different Nouakchott districts
- 20+ products with Arabic/French names
- 8 categories covering all store types
- Sample orders and reviews
- Delivery zones for all Nouakchott districts

---

Made with love for Mauritanie
سوقنا - Notre Marché - Our Market
