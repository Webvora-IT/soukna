export type Role = 'CUSTOMER' | 'VENDOR' | 'DELIVERY' | 'ADMIN'
export type StoreType = 'RESTAURANT' | 'GROCERY' | 'BOUTIQUE' | 'SERVICE'
export type StoreStatus = 'PENDING' | 'ACTIVE' | 'SUSPENDED' | 'CLOSED'
export type OrderStatus = 'PENDING' | 'CONFIRMED' | 'PREPARING' | 'READY' | 'DELIVERING' | 'DELIVERED' | 'CANCELLED'
export type ProductStatus = 'AVAILABLE' | 'UNAVAILABLE' | 'OUT_OF_STOCK' | 'PENDING_REVIEW' | 'REJECTED'

export interface User {
  id: string
  email: string
  phone?: string
  name: string
  avatar?: string
  role: Role
  language: string
  isActive: boolean
  createdAt: string
  updatedAt: string
  _count?: { orders: number }
  store?: { id: string; name: string; status: StoreStatus }
}

export interface Store {
  id: string
  ownerId: string
  owner?: { id: string; name: string; email: string; phone?: string }
  name: string
  nameAr?: string
  description?: string
  type: StoreType
  status: StoreStatus
  logo?: string
  coverImage?: string
  phone?: string
  address?: string
  district?: string
  city: string
  lat?: number
  lng?: number
  openTime?: string
  closeTime?: string
  isOpen: boolean
  deliveryFee: number
  minOrder: number
  rating: number
  reviewCount: number
  createdAt: string
  updatedAt: string
  _count?: { products: number; orders: number }
}

export interface Category {
  id: string
  name: string
  nameAr?: string
  nameEn?: string
  icon?: string
  image?: string
  storeType?: StoreType
  isActive: boolean
  createdAt: string
  _count?: { products: number; stores: number }
}

export interface Product {
  id: string
  storeId: string
  store?: { id: string; name: string }
  categoryId?: string
  category?: Category
  name: string
  nameAr?: string
  description?: string
  price: number
  originalPrice?: number
  images: string[]
  status: ProductStatus
  rejectionReason?: string
  stock?: number
  unit?: string
  createdAt: string
  updatedAt: string
}

export interface OrderItem {
  id: string
  productId: string
  product?: { id: string; name: string; nameAr?: string; images: string[] }
  quantity: number
  price: number
  notes?: string
}

export interface Order {
  id: string
  customerId: string
  customer?: { id: string; name: string; phone?: string; email: string }
  storeId: string
  store?: { id: string; name: string; nameAr?: string }
  deliveryUserId?: string
  deliveryUser?: { id: string; name: string; phone?: string }
  addressId?: string
  address?: Address
  status: OrderStatus
  items: OrderItem[]
  subtotal: number
  deliveryFee: number
  total: number
  notes?: string
  estimatedTime?: number
  rating?: number
  ratingComment?: string
  createdAt: string
  updatedAt: string
}

export interface Address {
  id: string
  label: string
  street: string
  district: string
  city: string
  lat?: number
  lng?: number
  isDefault: boolean
}

export interface Review {
  id: string
  userId: string
  user?: { id: string; name: string; avatar?: string }
  storeId: string
  store?: { id: string; name: string }
  rating: number
  comment?: string
  images: string[]
  isVisible: boolean
  createdAt: string
}

export interface Banner {
  id: string
  title: string
  titleAr?: string
  image: string
  link?: string
  storeType?: StoreType
  isActive: boolean
  order: number
  createdAt: string
}

export interface ApiResponse<T> {
  success: boolean
  data?: T
  message?: string
  meta?: {
    total: number
    page: number
    limit: number
    totalPages: number
  }
}

export interface DashboardStats {
  totalUsers: number
  totalStores: number
  activeStores: number
  pendingStores: number
  totalOrders: number
  ordersToday: number
  ordersThisMonth: number
  revenueThisMonth: number
  totalProducts: number
  pendingProducts: number
  ordersGrowth: number
  revenueGrowth: number
}

export type Language = 'fr' | 'ar' | 'en'
