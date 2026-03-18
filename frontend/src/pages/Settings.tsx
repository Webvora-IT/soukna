import { useState } from 'react'
import useSWR from 'swr'
import { fetcher, adminApi } from '../lib/api'
import toast from 'react-hot-toast'
import { Save, Edit2 } from 'lucide-react'

export default function Settings() {
  const { data, mutate } = useSWR('/admin/config', fetcher)
  const config: Record<string, string> = data?.data || {}
  const [editKey, setEditKey] = useState<string | null>(null)
  const [editValue, setEditValue] = useState('')
  const [newKey, setNewKey] = useState('')
  const [newValue, setNewValue] = useState('')

  const handleSave = async (key: string, value: string) => {
    try {
      await adminApi.updateConfig(key, value)
      toast.success('Paramètre sauvegardé')
      mutate()
      setEditKey(null)
    } catch { toast.error('Erreur') }
  }

  const handleAddNew = async () => {
    if (!newKey || !newValue) { toast.error('Clé et valeur requis'); return }
    await handleSave(newKey, newValue)
    setNewKey('')
    setNewValue('')
  }

  const GROUPED_KEYS = [
    { label: 'Informations du site', keys: ['site_name', 'site_name_ar', 'site_description', 'site_description_ar'] },
    { label: 'Contact', keys: ['contact_email', 'contact_phone'] },
    { label: 'Paramètres de livraison', keys: ['default_delivery_fee', 'min_order_amount', 'currency', 'currency_symbol'] },
    { label: 'Localisation', keys: ['city', 'country', 'timezone'] },
    { label: 'Langues', keys: ['supported_languages', 'default_language'] },
  ]

  const KEY_LABELS: Record<string, string> = {
    site_name: 'Nom du site',
    site_name_ar: 'Nom du site (AR)',
    site_description: 'Description',
    site_description_ar: 'Description (AR)',
    contact_email: 'Email de contact',
    contact_phone: 'Téléphone',
    default_delivery_fee: 'Frais de livraison par défaut (MRU)',
    min_order_amount: 'Montant minimum de commande (MRU)',
    currency: 'Devise',
    currency_symbol: 'Symbole de devise',
    city: 'Ville principale',
    country: 'Pays',
    timezone: 'Fuseau horaire',
    supported_languages: 'Langues supportées',
    default_language: 'Langue par défaut',
  }

  const allKnownKeys = GROUPED_KEYS.flatMap(g => g.keys)
  const otherKeys = Object.keys(config).filter(k => !allKnownKeys.includes(k))

  return (
    <div className="space-y-6 max-w-3xl">
      {GROUPED_KEYS.map((group) => (
        <div key={group.label} className="glass-card p-6">
          <h3 className="text-base font-semibold text-white mb-4">{group.label}</h3>
          <div className="space-y-3">
            {group.keys.map((key) => (
              <div key={key} className="flex items-center gap-3">
                <div className="flex-1">
                  <p className="text-xs text-slate-500 mb-1">{KEY_LABELS[key] || key}</p>
                  {editKey === key ? (
                    <div className="flex gap-2">
                      <input
                        value={editValue}
                        onChange={(e) => setEditValue(e.target.value)}
                        className="input-dark flex-1"
                        autoFocus
                        onKeyDown={(e) => e.key === 'Enter' && handleSave(key, editValue)}
                      />
                      <button onClick={() => handleSave(key, editValue)} className="btn-primary px-3">
                        <Save className="w-4 h-4" />
                      </button>
                      <button onClick={() => setEditKey(null)} className="btn-ghost px-3">×</button>
                    </div>
                  ) : (
                    <div className="flex items-center justify-between group">
                      <span className="text-sm text-white">{config[key] || <span className="text-slate-500 italic">Non défini</span>}</span>
                      <button
                        onClick={() => { setEditKey(key); setEditValue(config[key] || '') }}
                        className="opacity-0 group-hover:opacity-100 p-1.5 text-slate-400 hover:text-white hover:bg-[#2a2a40] rounded-lg transition-all"
                      >
                        <Edit2 className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      ))}

      {otherKeys.length > 0 && (
        <div className="glass-card p-6">
          <h3 className="text-base font-semibold text-white mb-4">Autres paramètres</h3>
          <div className="space-y-3">
            {otherKeys.map((key) => (
              <div key={key} className="flex items-center gap-3">
                <div className="flex-1">
                  <p className="text-xs text-slate-500 mb-1 font-mono">{key}</p>
                  {editKey === key ? (
                    <div className="flex gap-2">
                      <input value={editValue} onChange={(e) => setEditValue(e.target.value)} className="input-dark flex-1" autoFocus />
                      <button onClick={() => handleSave(key, editValue)} className="btn-primary px-3"><Save className="w-4 h-4" /></button>
                      <button onClick={() => setEditKey(null)} className="btn-ghost px-3">×</button>
                    </div>
                  ) : (
                    <div className="flex items-center justify-between group">
                      <span className="text-sm text-white">{config[key]}</span>
                      <button onClick={() => { setEditKey(key); setEditValue(config[key]) }} className="opacity-0 group-hover:opacity-100 p-1.5 text-slate-400 hover:text-white hover:bg-[#2a2a40] rounded-lg transition-all">
                        <Edit2 className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Add new config */}
      <div className="glass-card p-6">
        <h3 className="text-base font-semibold text-white mb-4">Ajouter un paramètre</h3>
        <div className="flex gap-3">
          <input
            value={newKey}
            onChange={(e) => setNewKey(e.target.value)}
            className="input-dark flex-1"
            placeholder="clé_du_parametre"
          />
          <input
            value={newValue}
            onChange={(e) => setNewValue(e.target.value)}
            className="input-dark flex-1"
            placeholder="valeur"
          />
          <button onClick={handleAddNew} className="btn-primary flex items-center gap-2 whitespace-nowrap">
            <Save className="w-4 h-4" /> Ajouter
          </button>
        </div>
      </div>
    </div>
  )
}
