import { Outlet, useLocation } from 'react-router-dom'
import { useState } from 'react'
import Sidebar from './Sidebar'
import Topbar from './Topbar'
import { Language } from '../types'

const PAGE_TITLES: Record<string, string> = {
  '/dashboard': 'Tableau de bord',
  '/stores': 'Gestion des Boutiques',
  '/orders': 'Gestion des Commandes',
  '/products': 'Gestion des Produits',
  '/users': 'Gestion des Utilisateurs',
  '/reviews': 'Avis & Évaluations',
  '/categories': 'Catégories',
  '/banners': 'Bannières Promotionnelles',
  '/settings': 'Paramètres',
}

export default function Layout() {
  const [lang, setLang] = useState<Language>(
    (localStorage.getItem('soukna_lang') as Language) || 'fr'
  )
  const location = useLocation()

  const handleLangChange = (newLang: Language) => {
    setLang(newLang)
    localStorage.setItem('soukna_lang', newLang)
  }

  const title = PAGE_TITLES[location.pathname] || 'SOUKNA Admin'

  return (
    <div className="flex min-h-screen bg-[#0f0f1a]" dir={lang === 'ar' ? 'rtl' : 'ltr'}>
      <Sidebar lang={lang} />
      <div className="flex-1 ml-64 flex flex-col min-h-screen">
        <Topbar lang={lang} onLangChange={handleLangChange} title={title} />
        <main className="flex-1 p-6 overflow-auto">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
