export type ProductStatus = 'PENDING_REVIEW' | 'AVAILABLE' | 'UNAVAILABLE' | 'OUT_OF_STOCK' | 'REJECTED'
export type OrderStatus = 'PENDING' | 'CONFIRMED' | 'PREPARING' | 'READY' | 'DELIVERING' | 'DELIVERED' | 'CANCELLED'
export type StoreType = 'RESTAURANT' | 'GROCERY' | 'BOUTIQUE' | 'SERVICE'
export type StoreStatus = 'PENDING' | 'ACTIVE' | 'SUSPENDED' | 'CLOSED'

export interface Store {
  id: string
  name: string
  nameAr?: string
  type: StoreType
  status: StoreStatus
  logo?: string
  coverImage?: string
  description?: string
  descriptionAr?: string
  phone?: string
  address?: string
  district?: string
  city: string
  isOpen: boolean
  deliveryFee: number
  minOrder: number
  rating: number
  reviewCount: number
  openTime?: string
  closeTime?: string
  _count?: { products: number; orders: number; reviews: number }
}

export interface Product {
  id: string
  storeId: string
  name: string
  nameAr?: string
  nameEn?: string
  description?: string
  descriptionAr?: string
  price: number
  originalPrice?: number
  images: string[]
  status: ProductStatus
  rejectionReason?: string
  stock?: number
  unit?: string
  categoryId?: string
  category?: { id: string; name: string; nameAr?: string }
  createdAt: string
}

export interface OrderItem {
  id: string
  quantity: number
  price: number
  product: { name: string; nameAr?: string; images: string[] }
}

export interface Order {
  id: string
  status: OrderStatus
  total: number
  subtotal: number
  deliveryFee: number
  notes?: string
  createdAt: string
  customer: { name: string; phone?: string }
  items: OrderItem[]
  address?: { street: string; district: string; city: string }
}

export interface Notification {
  id: string
  title: string
  body: string
  type: string
  isRead: boolean
  createdAt: string
}

export interface DashboardStats {
  totalProducts: number
  pendingProducts: number
  availableProducts: number
  rejectedProducts: number
  totalOrders: number
  ordersThisMonth: number
  pendingOrders: number
  revenueThisMonth: number
}

export interface DashboardData {
  store: Store
  stats: DashboardStats
  recentOrders: Order[]
}
