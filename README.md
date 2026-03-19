# SOUKNA - سوقنا
## Notre Marché Mauritanien

> Plateforme marketplace complète pour la Mauritanie — commande en ligne, livraison à domicile, gestion des boutiques, 3 applications mobiles Flutter.

![Node.js](https://img.shields.io/badge/Node.js-20-green?logo=node.js)
![Flutter](https://img.shields.io/badge/Flutter-3-blue?logo=flutter)
![React](https://img.shields.io/badge/React-18-61dafb?logo=react)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?logo=postgresql)
![Docker](https://img.shields.io/badge/Docker-ready-2496ED?logo=docker)
![Socket.io](https://img.shields.io/badge/Socket.io-realtime-black?logo=socket.io)

---

## 🎯 C'est quoi SOUKNA ?

SOUKNA (سوقنا = "notre marché" en arabe) est une **plateforme marketplace locale** dédiée à la Mauritanie, principalement à Nouakchott. Elle permet aux clients de commander des produits et repas auprès de boutiques locales, avec livraison à domicile. La plateforme réunit **4 interfaces** distinctes : une app client mobile, une app livreur mobile, un portail vendeur web et un panel admin web.

### Problème résolu
Les commerçants mauritaniens n'ont pas de présence digitale et les clients n'ont pas moyen de commander en ligne. SOUKNA connecte boutiques, clients et livreurs dans un seul écosystème.

---

## 🎬 Démo Vidéo

> 📹 **[Démo complète — App Client](./docs/demo/soukna-client-demo.mp4)**

https://github.com/user-attachments/assets/soukna-client-demo

> 📹 **[Démo — App Livreur](./docs/demo/soukna-delivery-demo.mp4)**

https://github.com/user-attachments/assets/soukna-delivery-demo

> 📹 **[Démo — Portail Vendeur](./docs/demo/soukna-vendor-demo.mp4)**

https://github.com/user-attachments/assets/soukna-vendor-demo

---

## 📸 Captures d'Écran

### 📱 App Client (Flutter)

![Splash screen](./docs/screenshots/client-01-splash.png)
*Écran de démarrage SOUKNA*

![Home screen](./docs/screenshots/client-02-home.png)
*Accueil — liste des boutiques avec filtre par type (Restaurants, Épiceries, Boutiques, Services)*

![Store detail](./docs/screenshots/client-03-store.png)
*Détail d'une boutique avec ses produits par catégorie*

![Cart](./docs/screenshots/client-04-cart.png)
*Panier avec récapitulatif et bouton de commande*

![Checkout](./docs/screenshots/client-05-checkout.png)
*Finalisation avec sélection d'adresse de livraison*

![Order tracking](./docs/screenshots/client-06-tracking.png)
*Suivi de commande en temps réel avec statut animé*

![Orders history](./docs/screenshots/client-07-orders.png)
*Historique des commandes avec filtres par statut*

![Profile](./docs/screenshots/client-08-profile.png)
*Profil avec commandes récentes et menu de navigation*

![Addresses](./docs/screenshots/client-09-addresses.png)
*Gestion des adresses de livraison*

![Notifications](./docs/screenshots/client-10-notifications.png)
*Centre de notifications in-app*

### 🚚 App Livreur (Flutter)

![Delivery home](./docs/screenshots/delivery-01-available.png)
*Liste des commandes disponibles à récupérer (statut READY)*

![Accept delivery](./docs/screenshots/delivery-02-accept.png)
*Carte commande avec détails client, adresse et bouton "Accepter"*

![My deliveries](./docs/screenshots/delivery-03-mydeliveries.png)
*Mes livraisons en cours avec bouton "Livrée"*

![Delivery detail](./docs/screenshots/delivery-04-detail.png)
*Détail complet : articles, adresse, numéro client, total*

![Delivery profile](./docs/screenshots/delivery-05-profile.png)
*Profil livreur avec stats (en cours, disponibles)*

### 🏪 Portail Vendeur (Web React)

![Vendor dashboard](./docs/screenshots/vendor-01-dashboard.png)
*Tableau de bord vendeur avec stats de la boutique*

![Vendor orders](./docs/screenshots/vendor-02-orders.png)
*Commandes entrantes avec notifications temps réel (Socket.io)*

![Vendor products](./docs/screenshots/vendor-03-products.png)
*Gestion des produits avec images Cloudinary*

![Vendor store](./docs/screenshots/vendor-04-store.png)
*Configuration de la boutique (logo, cover, horaires)*

![Vendor notifications](./docs/screenshots/vendor-05-notifications.png)
*Centre de notifications avec badge en temps réel*

### 🔑 Panel Admin (Web React)

![Admin dashboard](./docs/screenshots/admin-01-dashboard.png)
*Tableau de bord admin avec statistiques globales*

![Admin stores](./docs/screenshots/admin-02-stores.png)
*Gestion et approbation des boutiques*

![Admin users](./docs/screenshots/admin-03-users.png)
*Gestion de tous les utilisateurs (clients, vendeurs, livreurs)*

![Admin orders](./docs/screenshots/admin-04-orders.png)
*Vue globale de toutes les commandes*

---

## 👥 Rôles Utilisateurs

### 🛍️ Client (App Mobile Flutter)

| Action | Description |
|--------|-------------|
| Créer un compte | Email + mot de passe ou téléphone Firebase |
| Parcourir les boutiques | Filtrer par type : Restaurants 🍽️, Épiceries 🛒, Boutiques 👗, Services 🔧 |
| Rechercher | Recherche par nom de boutique |
| Consulter une boutique | Produits organisés par catégorie, note, horaires |
| Gérer son panier | Ajouter/retirer produits (verrouillé par boutique) |
| Passer une commande | Sélectionner adresse + notes optionnelles |
| Suivre en temps réel | Voir l'évolution du statut de sa commande |
| Historique | Toutes ses commandes filtrables par statut |
| Adresses | CRUD adresses de livraison avec adresse par défaut |
| Notifications | Push + in-app pour chaque changement de statut |
| Profil | Informations du compte |

### 🚚 Livreur (App Mobile Flutter)

| Action | Description |
|--------|-------------|
| Se connecter | Compte livreur dédié |
| Voir commandes disponibles | Toutes les commandes READY (prêtes à livrer) |
| Accepter une livraison | La commande passe en DELIVERING et apparaît dans "Mes livraisons" |
| Voir le détail | Adresse exacte, articles, téléphone client |
| Marquer comme livrée | Statut passe à DELIVERED |
| Historique | Toutes ses livraisons effectuées |
| Profil | Stats : commandes en cours, disponibles |

### 🏪 Vendeur (Portail Web — port 3081)

| Action | Description |
|--------|-------------|
| Gérer la boutique | Logo, cover, nom, description, horaires d'ouverture |
| Gestion des produits | CRUD produits avec images (Cloudinary), prix, stock |
| Commandes entrantes | Voir PENDING → Confirmer → Préparer → Marquer READY |
| Notifications temps réel | Badge Socket.io sur la cloche pour nouvelles commandes |
| Dashboard | Statistiques basiques de la boutique |

### 🔑 Admin (Panel Web React)

| Action | Description |
|--------|-------------|
| Dashboard | Statistiques globales (users, boutiques, commandes, revenus) |
| Utilisateurs | Lister, activer/désactiver clients, vendeurs, livreurs |
| Boutiques | Approuver, suspendre les boutiques |
| Produits | Vue globale + approbation produits en attente |
| Commandes | Vue et gestion de toutes les commandes |
| Catégories | CRUD catégories de produits |
| Bannières | Gestion des publicités/promotions |
| Avis | Modération des avis produits/boutiques |
| Configuration | Paramètres globaux de la plateforme |

---

## 🔄 Comment ça marche ?

### Flux d'une Commande

```
CLIENT                    VENDEUR                  LIVREUR
  │                          │                        │
  │── Passe commande ────────►│                        │
  │                          │── Confirme ────────────│
  │◄── Notif : CONFIRMED ────│                        │
  │                          │── Prépare ─────────────│
  │◄── Notif : PREPARING ────│                        │
  │                          │── Marque READY ────────►│
  │◄── Notif : READY ────────│   ◄── Disponible ───────│
  │                          │       │── Accepte ──────│
  │◄── Notif : DELIVERING ───────────────────────────────
  │                          │                        │── Livre
  │◄── Notif : DELIVERED ────────────────────────────────
```

### Statut des Commandes

```
PENDING ──► CONFIRMED ──► PREPARING ──► READY ──► DELIVERING ──► DELIVERED
   │              │
   └──────────────└──────────────────────────────────────────────► CANCELLED
```

### Architecture Technique

```
┌─────────────────────────────────────────────────────────────┐
│                         NGINX (port 3080)                    │
│              Reverse proxy + Load balancer                   │
└────────┬──────────────┬───────────────────────┬─────────────┘
         │              │                       │
    ┌────▼────┐   ┌──────▼──────┐        ┌─────▼────┐
    │ Backend │   │ Admin Panel │        │  Vendor  │
    │  :5000  │   │   :3002     │        │  :3081   │
    │ Node.js │   │  React+Vite │        │ React+   │
    │ Express │   │             │        │ Vite     │
    └────┬────┘   └─────────────┘        └──────────┘
         │              ▲ REST API           ▲ REST + Socket.io
    ┌────▼────┐         │                   │
    │PostgreSQL│────────┴───────────────────┘
    │  :5434  │
    └─────────┘
         ▲
         │ REST API + JWT
    ┌────┴─────────────────────────┐
    │  Flutter Mobile Apps         │
    │  Client App + Delivery App   │
    └──────────────────────────────┘
```

---

## 🏗️ Stack Technique

| Couche | Technologie |
|--------|-------------|
| Backend API | Node.js 20 + Express + TypeScript |
| Base de données | PostgreSQL 16 + Prisma v7 (PrismaPg adapter) |
| Images | Cloudinary v2 |
| Auth | JWT + bcryptjs |
| Temps réel | Socket.io (notifications vendeur) |
| Admin Panel | React 18 + Vite + Tailwind CSS (dark theme) |
| Portail Vendeur | React 18 + Vite + Tailwind CSS |
| Mobile (2 apps) | Flutter 3 (Dart) + Provider pattern |
| Reverse Proxy | Nginx |
| Conteneurisation | Docker Compose |

---

## 📁 Structure du Projet

```
soukna/
├── backend/                    # API REST Node.js + Express
│   ├── src/
│   │   ├── controllers/        # Logique métier par ressource
│   │   ├── routes/             # Définition des endpoints
│   │   ├── middleware/         # Auth JWT, validation, upload
│   │   └── lib/                # Utilitaires (prisma, cloudinary, socket)
│   └── prisma/
│       ├── schema.prisma       # Modèles de données
│       └── seed.ts             # Données de test réalistes
│
├── admin/                      # Panel Admin (React + Vite)
│   └── src/
│       └── pages/              # Dashboard, Users, Stores, Orders, Categories...
│
├── vendor/                     # Portail Vendeur (React + Vite, port 3081)
│   └── src/
│       ├── pages/              # Dashboard, StoreProfile, Products, Orders, Notifs
│       └── components/         # Layout avec badge Socket.io
│
├── mobile/
│   ├── client/                 # Flutter App Client
│   │   └── lib/
│   │       ├── providers/      # AuthProvider, StoreProvider, CartProvider,
│   │       │                   # OrderProvider, NotificationProvider, AddressProvider
│   │       ├── screens/        # Home, Store, Cart, Checkout, Tracking, Profile...
│   │       ├── models/         # Store, Product, Order, Address, Notification
│   │       └── services/       # ApiService (JWT auth, Cloudinary)
│   │
│   └── delivery/               # Flutter App Livreur
│       └── lib/
│           ├── providers/      # AuthProvider, DeliveryOrderProvider
│           └── screens/        # OrderList, OrderDetail, Profile
│
├── nginx/
│   ├── nginx.conf              # Production
│   └── nginx.dev.conf          # Développement
├── docker-compose.dev.yml      # Dev : PostgreSQL + Backend + Admin + Nginx
├── docker-compose.yml          # Production
└── .env.example
```

---

## 🗄️ Modèles de Données

| Modèle | Description |
|--------|-------------|
| `User` | Client, Vendeur, Livreur ou Admin (role, JWT token) |
| `Store` | Boutique (type, district, logo, cover, horaires, rating) |
| `Product` | Produit (nom FR/AR, prix, stock, catégorie) |
| `Category` | Catégorie produit |
| `Order` | Commande (items, total, adresse, statut, deliveryPersonId) |
| `OrderItem` | Ligne de commande (produit × quantité × prix) |
| `Address` | Adresse de livraison client (label, rue, quartier, ville) |
| `Review` | Avis sur boutique ou produit (note, commentaire) |
| `Banner` | Publicité/promotion admin |
| `Notification` | Notification in-app (type, message, isRead) |
| `PasswordResetToken` | Token de réinitialisation de mot de passe |

---

## 🛒 Types de Boutiques

| Type | Icône | Description |
|------|-------|-------------|
| `RESTAURANT` | 🍽️ | Restaurants, cafés, fast-food |
| `GROCERY` | 🛒 | Épiceries, supermarchés |
| `BOUTIQUE` | 👗 | Vêtements, accessoires, électronique |
| `SERVICE` | 🔧 | Services divers |

---

## 📦 State Management Mobile (Provider Pattern)

### App Client Flutter

| Provider | État géré |
|----------|----------|
| `AuthProvider` | Session utilisateur, login/logout |
| `StoreProvider` | Liste des boutiques, recherche, filtre type (mis en cache) |
| `CartProvider` | Panier avec verrou par boutique |
| `OrderProvider` | Commandes passées, commande active, placement |
| `NotificationProvider` | Notifications in-app, compteur non-lus |
| `AddressProvider` | Adresses de livraison, adresse par défaut |

### App Livreur Flutter

| Provider | État géré |
|----------|----------|
| `AuthProvider` | Session livreur |
| `DeliveryOrderProvider` | Commandes disponibles + mes livraisons |

---

## 🚀 Démarrage

### Prérequis
- Docker Desktop
- Node.js 20+ (pour dev local)
- Flutter 3+ (pour mobile)

### 1. Configuration

```bash
cd soukna
cp .env.example .env
# Éditer .env avec vos credentials Cloudinary
```

### 2. Démarrage avec Docker Compose

```bash
docker-compose -f docker-compose.dev.yml up -d
```

Services démarrés :
- **PostgreSQL** sur le port `5434`
- **Backend API** sur le port `5000` (et via nginx `3080/api`)
- **Admin Panel** sur le port `3002` (et via nginx `3080`)
- **Nginx** sur le port `3080`

### 3. Migrations & Seed

```bash
docker-compose -f docker-compose.dev.yml exec backend sh

# Dans le container :
npm run prisma:migrate
npm run prisma:seed
```

### 4. Portail Vendeur (séparé)

```bash
cd vendor
npm install
npm run dev     # http://localhost:3081
```

### 5. Apps Mobile

```bash
# App Client
cd mobile/client
flutter pub get
flutter run

# App Livreur
cd mobile/delivery
flutter pub get
flutter run
```

### Changer l'URL API pour les tests sur appareil physique

Dans `mobile/client/lib/services/api_service.dart` et `mobile/delivery/lib/services/api_service.dart` :
```dart
static const String _baseUrl = 'http://VOTRE_IP_LOCALE:3080/api';
```

---

## 🔗 URLs de Développement

| Service | URL |
|---------|-----|
| Admin Panel | http://localhost:3080 ou http://localhost:3002 |
| Backend API | http://localhost:3080/api |
| Portail Vendeur | http://localhost:3081 |
| Health Check | http://localhost:3080/health |
| PostgreSQL | localhost:5434 |

---

## 🔑 Identifiants par Défaut

| Rôle | Email | Password |
|------|-------|----------|
| Admin | admin@soukna.mr | Admin@Soukna2024 |
| Client | aminata@gmail.com | Test@123 |
| Vendeur | vendor.restaurant@soukna.mr | Test@123 |
| Livreur | delivery1@soukna.mr | Test@123 |

---

## 📡 API Endpoints Principaux

```
Auth
  POST /api/auth/register           Créer un compte
  POST /api/auth/login              Se connecter
  GET  /api/auth/me                 Profil connecté

Boutiques
  GET  /api/stores                  Lister (filtre: type, search, district)
  GET  /api/stores/:id              Détail + produits
  GET  /api/stores/my               Ma boutique (vendeur)
  PATCH /api/stores/:id             Modifier ma boutique

Produits
  GET  /api/products                Lister (filtre: storeId, categoryId)
  POST /api/products                Créer (vendeur)
  PATCH /api/products/:id           Modifier
  DELETE /api/products/:id          Supprimer

Commandes
  POST /api/orders                  Créer une commande
  GET  /api/orders                  Mes commandes (filtré par rôle)
  GET  /api/orders/:id              Détail commande
  PATCH /api/orders/:id/status      Changer le statut

Adresses
  GET  /api/users/addresses         Mes adresses
  POST /api/users/addresses         Ajouter
  DELETE /api/users/addresses/:id   Supprimer

Notifications
  GET  /api/notifications           Mes notifications
  PATCH /api/notifications/:id/read Marquer comme lue

Upload
  POST /api/upload/single           Upload image → Cloudinary

Admin
  GET  /api/admin/stats             Statistiques globales
  GET  /api/admin/users             Tous les utilisateurs
  GET  /api/admin/stores            Toutes les boutiques
  POST /api/admin/banners           Créer une bannière
```

---

## 🗺️ Districts de Nouakchott couverts

- Tevragh-Zeina (تفرغ زينة)
- Ksar (القصر)
- Dar Naim (دار النعيم)
- Teyarett (تيارت)
- Arafat (عرفات)
- Sebkha (السبخة)
- El Mina (الميناء)
- Riyad (الرياض)

---

## 💱 Devise

Tous les prix sont en **MRU (Ouguiya Mauritanienne / أوقية موريتانية)**.

---

## 🌍 Support Multi-langues

| Langue | Disponible |
|--------|-----------|
| Français | ✅ Défaut |
| العربية | ✅ RTL |
| English | ✅ |

---

## 🐳 Production Docker

```bash
cp .env.example .env
# Configurer les valeurs de production

docker-compose up -d --build
docker-compose ps
docker-compose logs -f
```

L'application tourne sur le port `82` en production.

---

Made with ❤️ for Mauritanie
سوقنا - Notre Marché - Our Market
