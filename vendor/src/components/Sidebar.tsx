import { NavLink, useNavigate } from 'react-router-dom'
import {
  LayoutDashboard,
  Package,
  ShoppingCart,
  Store,
  Bell,
  LogOut,
  ShoppingBag,
} from 'lucide-react'
import { useLocation } from 'react-router-dom'
import clsx from 'clsx'
import { useAuth } from '../hooks/useAuth'

const navItems = [
  { to: '/', icon: LayoutDashboard, label: 'Tableau de bord', exact: true },
  { to: '/products', icon: Package, label: 'Mes Produits', exact: false },
  { to: '/orders', icon: ShoppingCart, label: 'Commandes', exact: false },
  { to: '/store', icon: Store, label: 'Ma Boutique', exact: false },
  { to: '/notifications', icon: Bell, label: 'Notifications', exact: false },
]

export default function Sidebar() {
  const { logout, user } = useAuth()
  const location = useLocation()
  const navigate = useNavigate()

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  const isActive = (to: string, exact: boolean) => {
    if (exact) return location.pathname === to
    return location.pathname.startsWith(to)
  }

  return (
    <aside className="w-64 h-screen bg-white border-r border-gray-100 flex flex-col fixed left-0 top-0 z-40 shadow-sm">
      {/* Logo */}
      <div className="p-6 border-b border-gray-100">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-gradient-to-br from-amber-400 to-amber-600 rounded-xl flex items-center justify-center shadow-md">
            <ShoppingBag className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="font-bold text-gray-900 text-lg leading-none">SOUKNA</h1>
            <p className="text-amber-500 text-xs font-medium">Espace Vendeur</p>
          </div>
        </div>
      </div>

      {/* Nav */}
      <nav className="flex-1 p-4 space-y-1 overflow-y-auto">
        {navItems.map((item) => {
          const active = isActive(item.to, item.exact)
          return (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.exact}
              className={clsx(
                'flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all duration-200',
                active
                  ? 'bg-amber-50 text-amber-700 border border-amber-200'
                  : 'text-gray-500 hover:text-gray-800 hover:bg-gray-50'
              )}
            >
              <item.icon
                className={clsx('w-5 h-5 flex-shrink-0', active ? 'text-amber-600' : 'text-gray-400')}
              />
              <span>{item.label}</span>
              {active && (
                <div className="ml-auto w-1.5 h-1.5 rounded-full bg-amber-500" />
              )}
            </NavLink>
          )
        })}
      </nav>

      {/* User */}
      <div className="p-4 border-t border-gray-100">
        <div className="flex items-center gap-3 mb-3">
          <div className="w-9 h-9 rounded-full bg-amber-100 flex items-center justify-center flex-shrink-0">
            <span className="text-amber-700 font-bold text-sm">
              {user?.name?.charAt(0).toUpperCase()}
            </span>
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-semibold text-gray-800 truncate">{user?.name}</p>
            <p className="text-xs text-gray-400 truncate">{user?.email}</p>
          </div>
        </div>
        <button
          onClick={handleLogout}
          className="w-full flex items-center gap-2 px-3 py-2 text-sm text-red-500 hover:bg-red-50 rounded-lg transition-colors"
        >
          <LogOut className="w-4 h-4" />
          <span>Déconnexion</span>
        </button>
      </div>
    </aside>
  )
}
