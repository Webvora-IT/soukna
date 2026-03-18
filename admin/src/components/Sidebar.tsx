import { NavLink } from 'react-router-dom'
import {
  LayoutDashboard,
  Store,
  ShoppingCart,
  Package,
  Users,
  Star,
  Tag,
  Image,
  Settings,
  LogOut,
  ShoppingBag,
  Clock,
} from 'lucide-react'
import clsx from 'clsx'
import useSWR from 'swr'
import { useAuth } from '../hooks/useAuth'
import { fetcher } from '../lib/api'

interface StatsData {
  success: boolean
  data: { stats: { pendingProducts?: number } }
}

const navItems = [
  { to: '/dashboard', icon: LayoutDashboard, label: 'Tableau de bord', labelAr: 'لوحة القيادة' },
  { to: '/stores', icon: Store, label: 'Boutiques', labelAr: 'المتاجر' },
  { to: '/orders', icon: ShoppingCart, label: 'Commandes', labelAr: 'الطلبات' },
  { to: '/products', icon: Package, label: 'Produits', labelAr: 'المنتجات' },
  { to: '/products/pending', icon: Clock, label: 'Produits en attente', labelAr: 'منتجات معلقة', badgeKey: 'pendingProducts' as const },
  { to: '/users', icon: Users, label: 'Utilisateurs', labelAr: 'المستخدمون' },
  { to: '/reviews', icon: Star, label: 'Avis', labelAr: 'التقييمات' },
  { to: '/categories', icon: Tag, label: 'Catégories', labelAr: 'الفئات' },
  { to: '/banners', icon: Image, label: 'Bannières', labelAr: 'البانرات' },
  { to: '/settings', icon: Settings, label: 'Paramètres', labelAr: 'الإعدادات' },
]

interface SidebarProps {
  lang: 'fr' | 'ar' | 'en'
}

export default function Sidebar({ lang }: SidebarProps) {
  const { logout, user } = useAuth()
  const isAr = lang === 'ar'
  const { data: statsData } = useSWR<StatsData>('/admin/stats', fetcher)
  const pendingProducts = statsData?.data?.stats?.pendingProducts ?? 0

  const getBadgeCount = (badgeKey?: 'pendingProducts') => {
    if (!badgeKey) return 0
    if (badgeKey === 'pendingProducts') return pendingProducts
    return 0
  }

  return (
    <aside className="w-64 h-screen bg-[#1a1a2e] border-r border-[#2a2a40] flex flex-col fixed left-0 top-0 z-40">
      {/* Logo */}
      <div className="p-6 border-b border-[#2a2a40]">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-primary-500 rounded-xl flex items-center justify-center">
            <ShoppingBag className="w-6 h-6 text-white" />
          </div>
          <div>
            <h1 className="font-bold text-white text-lg leading-none">SOUKNA</h1>
            <p className="text-primary-500 text-xs font-arabic">سوقنا</p>
          </div>
        </div>
      </div>

      {/* Nav */}
      <nav className="flex-1 p-4 space-y-1 overflow-y-auto">
        {navItems.map((item) => {
          const badgeCount = getBadgeCount(item.badgeKey)
          return (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.to === '/products'}
              className={({ isActive }) =>
                clsx(
                  'flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all duration-200',
                  isActive
                    ? 'bg-primary-500/20 text-primary-400 border border-primary-500/30'
                    : 'text-slate-400 hover:text-white hover:bg-[#252538]'
                )
              }
            >
              <item.icon className="w-5 h-5 flex-shrink-0" />
              <span className={clsx('flex-1', isAr ? 'font-arabic' : '')}>
                {isAr ? item.labelAr : item.label}
              </span>
              {badgeCount > 0 && (
                <span className="px-1.5 py-0.5 bg-yellow-500/20 text-yellow-400 text-xs font-bold rounded-md border border-yellow-500/30">
                  {badgeCount}
                </span>
              )}
            </NavLink>
          )
        })}
      </nav>

      {/* User */}
      <div className="p-4 border-t border-[#2a2a40]">
        <div className="flex items-center gap-3 mb-3">
          <div className="w-9 h-9 rounded-full bg-primary-500/20 flex items-center justify-center">
            <span className="text-primary-400 font-bold text-sm">
              {user?.name?.charAt(0).toUpperCase()}
            </span>
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium text-white truncate">{user?.name}</p>
            <p className="text-xs text-slate-500 truncate">{user?.email}</p>
          </div>
        </div>
        <button
          onClick={logout}
          className="w-full flex items-center gap-2 px-3 py-2 text-sm text-red-400 hover:bg-red-500/10 rounded-lg transition-colors"
        >
          <LogOut className="w-4 h-4" />
          <span>Déconnexion</span>
        </button>
      </div>
    </aside>
  )
}
