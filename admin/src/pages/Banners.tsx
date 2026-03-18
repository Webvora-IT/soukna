import { useState } from 'react'
import useSWR from 'swr'
import { fetcher, adminApi } from '../lib/api'
import { Banner } from '../types'
import toast from 'react-hot-toast'
import { Plus, Trash2, Edit, ToggleLeft, ToggleRight } from 'lucide-react'
import { useForm } from 'react-hook-form'

interface BannerForm {
  title: string
  titleAr: string
  image: string
  link: string
  storeType: string
  order: number
  isActive: boolean
}

export default function Banners() {
  const [showForm, setShowForm] = useState(false)
  const [editing, setEditing] = useState<Banner | null>(null)
  const { data, mutate } = useSWR('/admin/banners', fetcher)
  const banners: Banner[] = data?.data || []

  const { register, handleSubmit, reset, setValue } = useForm<BannerForm>({
    defaultValues: { isActive: true, order: 0 },
  })

  const openEdit = (b: Banner) => {
    setEditing(b)
    setValue('title', b.title)
    setValue('titleAr', b.titleAr || '')
    setValue('image', b.image)
    setValue('link', b.link || '')
    setValue('storeType', b.storeType || '')
    setValue('order', b.order)
    setValue('isActive', b.isActive)
    setShowForm(true)
  }

  const onSubmit = async (data: BannerForm) => {
    try {
      const payload = { ...data, storeType: data.storeType || null, order: Number(data.order) }
      if (editing) {
        await adminApi.updateBanner(editing.id, payload)
        toast.success('Bannière mise à jour')
      } else {
        await adminApi.createBanner(payload)
        toast.success('Bannière créée')
      }
      mutate()
      setShowForm(false)
      setEditing(null)
      reset()
    } catch { toast.error('Erreur') }
  }

  const handleDelete = async (id: string) => {
    if (!confirm('Supprimer cette bannière?')) return
    try {
      await adminApi.deleteBanner(id)
      toast.success('Bannière supprimée')
      mutate()
    } catch { toast.error('Erreur') }
  }

  const handleToggle = async (b: Banner) => {
    try {
      await adminApi.updateBanner(b.id, { isActive: !b.isActive })
      mutate()
    } catch { toast.error('Erreur') }
  }

  const STORE_TYPES = { RESTAURANT: 'Restaurant', GROCERY: 'Épicerie', BOUTIQUE: 'Boutique', SERVICE: 'Service' }

  return (
    <div className="space-y-4">
      <div className="flex justify-end">
        <button onClick={() => { setShowForm(true); setEditing(null); reset() }} className="btn-primary flex items-center gap-2">
          <Plus className="w-4 h-4" /> Nouvelle bannière
        </button>
      </div>

      <div className="space-y-3">
        {banners.map((banner) => (
          <div key={banner.id} className={`glass-card p-4 flex items-center gap-4 ${!banner.isActive ? 'opacity-60' : ''}`}>
            <img
              src={banner.image}
              alt={banner.title}
              className="w-24 h-16 object-cover rounded-lg bg-[#0f0f1a]"
              onError={(e) => { (e.target as HTMLImageElement).style.display = 'none' }}
            />
            <div className="flex-1">
              <h3 className="text-sm font-semibold text-white">{banner.title}</h3>
              {banner.titleAr && <p className="text-xs text-slate-400 font-arabic">{banner.titleAr}</p>}
              <div className="flex items-center gap-2 mt-1">
                <span className="text-xs text-slate-500">Ordre: {banner.order}</span>
                {banner.storeType && <span className="badge-info text-[10px]">{STORE_TYPES[banner.storeType as keyof typeof STORE_TYPES]}</span>}
                <span className={banner.isActive ? 'badge-success text-[10px]' : 'badge-neutral text-[10px]'}>
                  {banner.isActive ? 'Active' : 'Inactive'}
                </span>
              </div>
              {banner.link && <p className="text-xs text-slate-500 mt-1 truncate">{banner.link}</p>}
            </div>
            <div className="flex items-center gap-2">
              <button onClick={() => handleToggle(banner)} className={`p-1.5 rounded-lg transition-colors ${banner.isActive ? 'text-accent-500' : 'text-slate-500'}`}>
                {banner.isActive ? <ToggleRight className="w-5 h-5" /> : <ToggleLeft className="w-5 h-5" />}
              </button>
              <button onClick={() => openEdit(banner)} className="p-1.5 text-slate-400 hover:text-white hover:bg-[#2a2a40] rounded-lg">
                <Edit className="w-4 h-4" />
              </button>
              <button onClick={() => handleDelete(banner.id)} className="p-1.5 text-red-400 hover:bg-red-500/10 rounded-lg">
                <Trash2 className="w-4 h-4" />
              </button>
            </div>
          </div>
        ))}
        {banners.length === 0 && (
          <div className="glass-card p-12 text-center text-slate-500">Aucune bannière</div>
        )}
      </div>

      {showForm && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="glass-card w-full max-w-md p-6 animate-slide-in">
            <div className="flex items-center justify-between mb-5">
              <h3 className="text-lg font-semibold text-white">{editing ? 'Modifier' : 'Nouvelle'} bannière</h3>
              <button onClick={() => { setShowForm(false); setEditing(null); reset() }} className="text-slate-400 hover:text-white text-xl">&times;</button>
            </div>
            <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
              <div>
                <label className="block text-xs text-slate-400 mb-1">Titre (FR)</label>
                <input {...register('title', { required: true })} className="input-dark" />
              </div>
              <div>
                <label className="block text-xs text-slate-400 mb-1">Titre (AR)</label>
                <input {...register('titleAr')} className="input-dark font-arabic" dir="rtl" />
              </div>
              <div>
                <label className="block text-xs text-slate-400 mb-1">URL de l'image</label>
                <input {...register('image', { required: true })} className="input-dark" placeholder="https://..." />
              </div>
              <div>
                <label className="block text-xs text-slate-400 mb-1">Lien (optionnel)</label>
                <input {...register('link')} className="input-dark" placeholder="/promotions" />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs text-slate-400 mb-1">Type de boutique</label>
                  <select {...register('storeType')} className="input-dark">
                    <option value="">Tous</option>
                    {Object.entries(STORE_TYPES).map(([v, l]) => <option key={v} value={v}>{l}</option>)}
                  </select>
                </div>
                <div>
                  <label className="block text-xs text-slate-400 mb-1">Ordre d'affichage</label>
                  <input type="number" {...register('order')} className="input-dark" />
                </div>
              </div>
              <div className="flex items-center gap-2">
                <input type="checkbox" {...register('isActive')} id="bannerActive" className="w-4 h-4 accent-primary-500" />
                <label htmlFor="bannerActive" className="text-sm text-slate-300">Active</label>
              </div>
              <div className="flex gap-2 pt-2">
                <button type="submit" className="btn-primary flex-1">{editing ? 'Mettre à jour' : 'Créer'}</button>
                <button type="button" onClick={() => { setShowForm(false); setEditing(null); reset() }} className="btn-ghost">Annuler</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}
