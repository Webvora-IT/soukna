import { Bell, Globe, Search } from 'lucide-react'
import { useState } from 'react'
import { Language } from '../types'

interface TopbarProps {
  lang: Language
  onLangChange: (lang: Language) => void
  title: string
}

const languages: { code: Language; label: string; flag: string }[] = [
  { code: 'fr', label: 'Français', flag: '🇫🇷' },
  { code: 'ar', label: 'العربية', flag: '🇲🇷' },
  { code: 'en', label: 'English', flag: '🇬🇧' },
]

export default function Topbar({ lang, onLangChange, title }: TopbarProps) {
  const [showLang, setShowLang] = useState(false)

  return (
    <header className="h-16 bg-[#1a1a2e]/80 backdrop-blur-sm border-b border-[#2a2a40] flex items-center justify-between px-6 sticky top-0 z-30">
      <h2 className="text-lg font-semibold text-white">{title}</h2>

      <div className="flex items-center gap-3">
        {/* Search */}
        <div className="relative hidden md:block">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-500" />
          <input
            type="text"
            placeholder="Rechercher..."
            className="bg-[#0f0f1a] border border-[#2a2a40] text-sm text-white placeholder-slate-500 rounded-lg pl-9 pr-4 py-2 focus:outline-none focus:border-primary-500 w-48"
          />
        </div>

        {/* Language switcher */}
        <div className="relative">
          <button
            onClick={() => setShowLang(!showLang)}
            className="flex items-center gap-2 px-3 py-2 text-sm text-slate-300 hover:text-white hover:bg-[#252538] rounded-lg transition-colors"
          >
            <Globe className="w-4 h-4" />
            <span className="hidden sm:inline">{languages.find((l) => l.code === lang)?.flag}</span>
          </button>

          {showLang && (
            <div className="absolute right-0 top-full mt-1 bg-[#1a1a2e] border border-[#2a2a40] rounded-xl shadow-xl overflow-hidden z-50 min-w-[140px]">
              {languages.map((l) => (
                <button
                  key={l.code}
                  onClick={() => { onLangChange(l.code); setShowLang(false) }}
                  className={`w-full flex items-center gap-3 px-4 py-2.5 text-sm transition-colors ${
                    lang === l.code
                      ? 'bg-primary-500/20 text-primary-400'
                      : 'text-slate-300 hover:bg-[#252538] hover:text-white'
                  }`}
                >
                  <span>{l.flag}</span>
                  <span>{l.label}</span>
                </button>
              ))}
            </div>
          )}
        </div>

        {/* Notifications */}
        <button className="relative p-2 text-slate-400 hover:text-white hover:bg-[#252538] rounded-lg transition-colors">
          <Bell className="w-5 h-5" />
          <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-primary-500 rounded-full" />
        </button>
      </div>
    </header>
  )
}
