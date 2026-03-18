import { Outlet, useNavigate } from 'react-router-dom'
import { Bell, Globe, ChevronDown, LogOut, User } from 'lucide-react'
import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import Sidebar from './Sidebar'
import { useAuth } from '../hooks/useAuth'

export default function Layout() {
  const { user, logout } = useAuth()
  const navigate = useNavigate()
  const [lang, setLang] = useState<'fr' | 'ar' | 'en'>('fr')
  const [showUserMenu, setShowUserMenu] = useState(false)
  const [showLangMenu, setShowLangMenu] = useState(false)

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  const langs = [
    { code: 'fr' as const, label: 'Français' },
    { code: 'ar' as const, label: 'العربية' },
    { code: 'en' as const, label: 'English' },
  ]

  return (
    <div className="min-h-screen bg-gray-50">
      <Sidebar />

      {/* Main content */}
      <div className="ml-64 min-h-screen flex flex-col">
        {/* Topbar */}
        <header className="h-16 bg-white border-b border-gray-100 flex items-center justify-between px-6 sticky top-0 z-30 shadow-sm">
          <div />

          <div className="flex items-center gap-3">
            {/* Language switcher */}
            <div className="relative">
              <button
                onClick={() => { setShowLangMenu(!showLangMenu); setShowUserMenu(false) }}
                className="flex items-center gap-1.5 px-3 py-1.5 text-sm text-gray-600 hover:bg-gray-50 rounded-lg transition-colors"
              >
                <Globe className="w-4 h-4" />
                <span className="font-medium uppercase">{lang}</span>
                <ChevronDown className="w-3 h-3" />
              </button>
              <AnimatePresence>
                {showLangMenu && (
                  <motion.div
                    initial={{ opacity: 0, y: -8 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -8 }}
                    className="absolute right-0 top-full mt-1 w-36 bg-white rounded-xl shadow-lg border border-gray-100 overflow-hidden z-50"
                  >
                    {langs.map((l) => (
                      <button
                        key={l.code}
                        onClick={() => { setLang(l.code); setShowLangMenu(false) }}
                        className={`w-full text-left px-4 py-2.5 text-sm transition-colors ${
                          lang === l.code ? 'bg-amber-50 text-amber-700 font-medium' : 'text-gray-600 hover:bg-gray-50'
                        }`}
                      >
                        {l.label}
                      </button>
                    ))}
                  </motion.div>
                )}
              </AnimatePresence>
            </div>

            {/* Notification bell */}
            <button
              onClick={() => navigate('/notifications')}
              className="relative p-2 text-gray-500 hover:bg-gray-50 rounded-lg transition-colors"
            >
              <Bell className="w-5 h-5" />
            </button>

            {/* User menu */}
            <div className="relative">
              <button
                onClick={() => { setShowUserMenu(!showUserMenu); setShowLangMenu(false) }}
                className="flex items-center gap-2.5 px-3 py-1.5 hover:bg-gray-50 rounded-xl transition-colors"
              >
                <div className="w-8 h-8 rounded-full bg-amber-100 flex items-center justify-center">
                  <span className="text-amber-700 font-bold text-sm">
                    {user?.name?.charAt(0).toUpperCase()}
                  </span>
                </div>
                <span className="text-sm font-medium text-gray-700 hidden sm:block max-w-24 truncate">
                  {user?.name}
                </span>
                <ChevronDown className="w-4 h-4 text-gray-400" />
              </button>
              <AnimatePresence>
                {showUserMenu && (
                  <motion.div
                    initial={{ opacity: 0, y: -8 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -8 }}
                    className="absolute right-0 top-full mt-1 w-48 bg-white rounded-xl shadow-lg border border-gray-100 overflow-hidden z-50"
                  >
                    <div className="px-4 py-3 border-b border-gray-50">
                      <p className="text-sm font-semibold text-gray-800">{user?.name}</p>
                      <p className="text-xs text-gray-400 truncate">{user?.email}</p>
                    </div>
                    <button
                      onClick={() => { navigate('/store'); setShowUserMenu(false) }}
                      className="w-full flex items-center gap-2 px-4 py-2.5 text-sm text-gray-600 hover:bg-gray-50 transition-colors"
                    >
                      <User className="w-4 h-4" />
                      Ma boutique
                    </button>
                    <button
                      onClick={handleLogout}
                      className="w-full flex items-center gap-2 px-4 py-2.5 text-sm text-red-500 hover:bg-red-50 transition-colors"
                    >
                      <LogOut className="w-4 h-4" />
                      Déconnexion
                    </button>
                  </motion.div>
                )}
              </AnimatePresence>
            </div>
          </div>
        </header>

        {/* Page content */}
        <main className="flex-1 p-6">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
