import { useState } from 'react'
import useSWR from 'swr'
import { fetcher, api } from '../lib/api'
import { Category } from '../types'
import toast from 'react-hot-toast'
import { Plus, Trash2, Edit } from 'lucide-react'
import { useForm } from 'react-hook-form'

interface CategoryForm {
  name: string
  nameAr: string
  nameEn: string
  icon: string
  storeType: string
  isActive: boolean
}

export default function Categories() {
  const [showForm, setShowForm] = useState(false)
  const [editing, setEditing] = useState<Category | null>(null)
  const { data, mutate } = useSWR('/categories?isActive=', fetcher)
  const categories: Category[] = data?.data || []

  const { register, handleSubmit, reset, setValue } = useForm<CategoryForm>({
    defaultValues: { isActive: true },
  })

  const openEdit = (cat: Category) => {
    setEditing(cat)
    setValue('name', cat.name)
    setValue('nameAr', cat.nameAr || '')
    setValue('nameEn', cat.nameEn || '')
    setValue('icon', cat.icon || '')
    setValue('storeType', cat.storeType || '')
    setValue('isActive', cat.isActive)
    setShowForm(true)
  }

  const onSubmit = async (data: CategoryForm) => {
    try {
      const payload = { ...data, storeType: data.storeType || null }
      if (editing) {
        await api.patch(`/categories/${editing.id}`, payload)
        toast.success('Catégorie mise à jour')
      } else {
        await api.post('/categories', payload)
        toast.success('Catégorie créée')
      }
      mutate()
      setShowForm(false)
      setEditing(null)
      reset()
    } catch {
      toast.error('Erreur')
    }
  }

  const handleDelete = async (id: string) => {
    if (!confirm('Supprimer cette catégorie?')) return
    try {
      await api.delete(`/categories/${id}`)
      toast.success('Catégorie supprimée')
      mutate()
    } catch { toast.error('Erreur - des produits peuvent y être liés') }
  }

  const STORE_TYPES: Record<string, string> = {
    RESTAURANT: 'Restaurant', GROCERY: 'Épicerie', BOUTIQUE: 'Boutique', SERVICE: 'Service',
  }

  return (
    <div className="space-y-4">
      <div className="flex justify-end">
        <button onClick={() => { setShowForm(true); setEditing(null); reset() }} className="btn-primary flex items-center gap-2">
          <Plus className="w-4 h-4" /> Nouvelle catégorie
        </button>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        {categories.map((cat) => (
          <div key={cat.id} className={`glass-card p-4 ${!cat.isActive ? 'opacity-50' : ''}`}>
            <div className="flex items-start justify-between mb-3">
              <div className="text-3xl">{cat.icon || '📦'}</div>
              <div className="flex gap-1">
                <button onClick={() => openEdit(cat)} className="p-1.5 text-slate-400 hover:text-white hover:bg-[#2a2a40] rounded-lg">
                  <Edit className="w-3.5 h-3.5" />
                </button>
                <button onClick={() => handleDelete(cat.id)} className="p-1.5 text-red-400 hover:bg-red-500/10 rounded-lg">
                  <Trash2 className="w-3.5 h-3.5" />
                </button>
              </div>
            </div>
            <h3 className="text-sm font-semibold text-white">{cat.name}</h3>
            {cat.nameAr && <p className="text-xs text-slate-400 font-arabic">{cat.nameAr}</p>}
            <div className="flex items-center gap-2 mt-2">
              {cat.storeType && <span className="badge-info text-[10px]">{STORE_TYPES[cat.storeType]}</span>}
              <span className={cat.isActive ? 'badge-success text-[10px]' : 'badge-neutral text-[10px]'}>
                {cat.isActive ? 'Active' : 'Inactive'}
              </span>
            </div>
            <p className="text-xs text-slate-500 mt-2">{cat._count?.products || 0} produits</p>
          </div>
        ))}
      </div>

      {showForm && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="glass-card w-full max-w-md p-6 animate-slide-in">
            <div className="flex items-center justify-between mb-5">
              <h3 className="text-lg font-semibold text-white">{editing ? 'Modifier' : 'Nouvelle'} catégorie</h3>
              <button onClick={() => { setShowForm(false); setEditing(null); reset() }} className="text-slate-400 hover:text-white text-xl">&times;</button>
            </div>
            <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
              <div>
                <label className="block text-xs text-slate-400 mb-1">Nom (FR)</label>
                <input {...register('name', { required: true })} className="input-dark" placeholder="Cuisine Mauritanienne" />
              </div>
              <div>
                <label className="block text-xs text-slate-400 mb-1">Nom (AR)</label>
                <input {...register('nameAr')} className="input-dark font-arabic" placeholder="المطبخ الموريتاني" dir="rtl" />
              </div>
              <div>
                <label className="block text-xs text-slate-400 mb-1">Nom (EN)</label>
                <input {...register('nameEn')} className="input-dark" placeholder="Mauritanian Cuisine" />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs text-slate-400 mb-1">Icône (emoji)</label>
                  <input {...register('icon')} className="input-dark" placeholder="🍖" />
                </div>
                <div>
                  <label className="block text-xs text-slate-400 mb-1">Type de boutique</label>
                  <select {...register('storeType')} className="input-dark">
                    <option value="">Tous</option>
                    {Object.entries(STORE_TYPES).map(([v, l]) => <option key={v} value={v}>{l}</option>)}
                  </select>
                </div>
              </div>
              <div className="flex items-center gap-2">
                <input type="checkbox" {...register('isActive')} id="isActive" className="w-4 h-4 accent-primary-500" />
                <label htmlFor="isActive" className="text-sm text-slate-300">Active</label>
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
