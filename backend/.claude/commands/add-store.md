# Add a New Store Type

To add a new StoreType to SOUKNA:

## 1. Update Prisma Schema
In `prisma/schema.prisma`, add to the `StoreType` enum:
```prisma
enum StoreType {
  RESTAURANT
  GROCERY
  BOUTIQUE
  SERVICE
  PHARMACY   # New type
}
```

## 2. Run Migration
```bash
npm run prisma:migrate
# Enter migration name: add_pharmacy_store_type
npm run prisma:generate
```

## 3. Update Admin Panel
In `admin/src/types/index.ts`:
```ts
export type StoreType = 'RESTAURANT' | 'GROCERY' | 'BOUTIQUE' | 'SERVICE' | 'PHARMACY'
```

In `admin/src/pages/Stores.tsx`:
```ts
const TYPE_LABEL: Record<StoreType, string> = {
  ...
  PHARMACY: 'Pharmacie',
}
```

## 4. Add Categories
In `prisma/seed.ts`, add relevant categories for the new store type.

## 5. Update Flutter Apps
In `mobile/client/lib/screens/home/home_screen.dart`:
```dart
{'value': 'PHARMACY', 'label': 'Pharmacies', 'icon': '💊'},
```
