# MANGER — مانجي

**Vendor app for the SOUKNA marketplace**
Tagline: *Gérez votre boutique, partout*

---

## Overview

MANGER is the vendor-facing Flutter mobile application for the SOUKNA marketplace. It allows restaurant, grocery, and boutique owners to manage their store, products, and orders from their phone.

- **Platform**: Flutter (iOS + Android)
- **Role**: VENDOR accounts only
- **Backend**: SOUKNA API at `/api/vendor/*`
- **Currency**: MRU (Mauritanian Ouguiya / Ouguiya mauritanienne)

---

## Features

| Screen | Description |
|--------|-------------|
| Splash | Animated MANGER logo with auth check |
| Login | Email + password, VENDOR role validation, JWT storage |
| Dashboard | Store stats: products, pending, monthly orders, revenue |
| Products | List with filter chips (All / Pending / Available / Rejected) |
| Add Product | Full form: name FR/AR, price, discount, stock, unit, category, images |
| Orders | Manage orders with status actions (Confirm → Prepare → Ready) |
| Store | View and edit store profile (name, hours, address, logo) |
| Notifications | Product approvals/rejections, new orders with read status |
| Settings | Language switch (FR/AR/EN), about, logout |

---

## Tech Stack

| Package | Use |
|---------|-----|
| `provider` | State management (AuthProvider, LocaleProvider) |
| `flutter_secure_storage` | JWT token storage |
| `http` | REST API calls |
| `shared_preferences` | Language preference persistence |
| `cached_network_image` | Efficient image loading with cache |
| `google_fonts` | Inter font family |
| `image_picker` | Camera/gallery access (future use) |
| `intl` | Date/number formatting |
| `flutter_localizations` | FR / AR (RTL) / EN support |

---

## Theme

| Token | Value |
|-------|-------|
| Background | `#0F0F1A` (deep dark navy) |
| Surface | `#1A1A2E` (card background) |
| Primary (amber) | `#F59E0B` |
| Accent (emerald) | `#10B981` |
| Error | `#EF4444` |
| Font | Inter (Google Fonts) |

---

## Project Structure

```
lib/
├── main.dart                    # App entry point, theme, routes
├── l10n/
│   └── app_localizations.dart  # FR / AR / EN translations
├── models/
│   ├── user.dart               # VendorUser
│   ├── store.dart              # Store
│   ├── product.dart            # Product
│   ├── order.dart              # VendorOrder + OrderItem
│   └── notification_item.dart  # NotificationItem
├── providers/
│   ├── auth_provider.dart      # Auth state (login/logout/init)
│   └── locale_provider.dart    # Language state
├── services/
│   └── api_service.dart        # All HTTP calls to SOUKNA API
├── screens/
│   ├── splash_screen.dart
│   ├── auth/login_screen.dart
│   ├── home/home_screen.dart   # BottomNav with 5 tabs
│   ├── dashboard/dashboard_screen.dart
│   ├── products/
│   │   ├── products_screen.dart
│   │   └── add_product_screen.dart
│   ├── orders/orders_screen.dart
│   ├── store/
│   │   ├── store_screen.dart
│   │   └── edit_store_screen.dart
│   ├── notifications/notifications_screen.dart
│   └── settings/settings_screen.dart
└── widgets/
    ├── status_badge.dart       # Colored status chips
    ├── stat_card.dart          # Dashboard stat cards
    ├── empty_state.dart        # Empty list placeholder
    └── loading_overlay.dart    # Full-screen loading overlay
```

---

## Setup

### Prerequisites
- Flutter SDK >= 3.0.0
- Android Studio / VS Code with Flutter extension
- SOUKNA backend running on port 3080

### Install dependencies
```bash
cd mobile/vendor
flutter pub get
```

### Configure API URL

Edit `lib/services/api_service.dart`:

```dart
// Android emulator:
static const String baseUrl = 'http://10.0.2.2:3080/api';

// Physical device (replace with your machine's local IP):
static const String baseUrl = 'http://192.168.X.X:3080/api';

// Production:
static const String baseUrl = 'https://api.soukna.mr/api';
```

### Run
```bash
flutter run
```

### Build APK
```bash
flutter build apk --release
```

---

## API Endpoints Used

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | Vendor login |
| GET | `/api/vendor/dashboard` | Stats + recent orders |
| GET | `/api/vendor/store` | Store info + stats |
| PATCH | `/api/vendor/store` | Update store |
| GET | `/api/vendor/products` | Products list (filterable) |
| POST | `/api/products` | Create product |
| DELETE | `/api/products/:id` | Delete product |
| GET | `/api/vendor/orders` | Orders list (filterable) |
| PATCH | `/api/vendor/orders/:id/status` | Update order status |
| GET | `/api/vendor/notifications` | Notifications list |
| PATCH | `/api/vendor/notifications/:id/read` | Mark notification read |
| GET | `/api/categories` | Product categories |

---

## Notes

- Only accounts with `role: "VENDOR"` can log in
- New products are submitted with `PENDING_REVIEW` status — they must be approved by a SOUKNA admin before becoming visible to customers
- Store status `PENDING` means the store is awaiting admin approval
- The app supports Arabic (RTL layout), French, and English

---

*Part of the SOUKNA Marketplace project — alongside the Customer app (`mobile/client/`) and Delivery app (`mobile/delivery/`)*
