import { useState } from 'react'
import useSWR from 'swr'
import { fetcher, api } from '../lib/api'
import { Review } from '../types'
import toast from 'react-hot-toast'
import { Eye, EyeOff, Trash2, Star } from 'lucide-react'
import { format } from 'date-fns'

export default function Reviews() {
  const [page, setPage] = useState(1)
  const [ratingFilter, setRatingFilter] = useState('')

  const params = new URLSearchParams({ page: String(page), limit: '20' })

  const { data, mutate } = useSWR(`/admin/reviews?${params}`, fetcher)
  const reviews: Review[] = (data?.data || []).filter((r: Review) =>
    !ratingFilter || r.rating === Number(ratingFilter)
  )
  const meta = data?.meta

  const handleModerate = async (id: string, isVisible: boolean) => {
    try {
      await api.patch(`/reviews/${id}/moderate`, { isVisible })
      toast.success(isVisible ? 'Avis affiché' : 'Avis masqué')
      mutate()
    } catch { toast.error('Erreur') }
  }

  const handleDelete = async (id: string) => {
    if (!confirm('Supprimer cet avis?')) return
    try {
      await api.delete(`/reviews/${id}`)
      toast.success('Avis supprimé')
      mutate()
    } catch { toast.error('Erreur') }
  }

  return (
    <div className="space-y-4">
      <div className="glass-card p-4 flex gap-3 items-center">
        <select value={ratingFilter} onChange={(e) => setRatingFilter(e.target.value)} className="input-dark w-auto">
          <option value="">Toutes les notes</option>
          {[5,4,3,2,1].map(n => <option key={n} value={n}>{n} étoile{n > 1 ? 's' : ''}</option>)}
        </select>
      </div>

      <div className="space-y-3">
        {reviews.map((review) => (
          <div key={review.id} className={`glass-card p-4 ${!review.isVisible ? 'opacity-50' : ''}`}>
            <div className="flex items-start justify-between gap-3">
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-1">
                  <div className="w-8 h-8 bg-primary-500/20 rounded-full flex items-center justify-center text-primary-400 text-xs font-bold">
                    {review.user?.name?.charAt(0)}
                  </div>
                  <div>
                    <p className="text-sm text-white font-medium">{review.user?.name}</p>
                    <p className="text-xs text-slate-500">{review.store?.name}</p>
                  </div>
                  <div className="flex items-center gap-0.5 ml-2">
                    {[...Array(5)].map((_, i) => (
                      <Star key={i} className={`w-3 h-3 ${i < review.rating ? 'text-yellow-400 fill-yellow-400' : 'text-slate-600'}`} />
                    ))}
                  </div>
                  {!review.isVisible && <span className="badge-neutral">Masqué</span>}
                </div>
                {review.comment && <p className="text-sm text-slate-300 mt-2">{review.comment}</p>}
                <p className="text-xs text-slate-500 mt-2">{format(new Date(review.createdAt), 'dd/MM/yyyy HH:mm')}</p>
              </div>
              <div className="flex items-center gap-2 flex-shrink-0">
                <button
                  onClick={() => handleModerate(review.id, !review.isVisible)}
                  className={`p-1.5 rounded-lg transition-colors ${review.isVisible ? 'text-slate-400 hover:bg-[#2a2a40]' : 'text-accent-500 hover:bg-accent-500/10'}`}
                  title={review.isVisible ? 'Masquer' : 'Afficher'}
                >
                  {review.isVisible ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
                <button
                  onClick={() => handleDelete(review.id)}
                  className="p-1.5 text-red-400 hover:bg-red-500/10 rounded-lg transition-colors"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>
        ))}
        {reviews.length === 0 && (
          <div className="glass-card p-12 text-center text-slate-500">Aucun avis trouvé</div>
        )}
      </div>

      {meta && meta.totalPages > 1 && (
        <div className="flex items-center justify-between">
          <p className="text-xs text-slate-500">{meta.total} avis</p>
          <div className="flex gap-2">
            <button disabled={page <= 1} onClick={() => setPage(p => p - 1)} className="btn-ghost text-sm py-1 px-3 disabled:opacity-40">Précédent</button>
            <span className="text-sm text-slate-400 px-3 py-1">{page} / {meta.totalPages}</span>
            <button disabled={page >= meta.totalPages} onClick={() => setPage(p => p + 1)} className="btn-ghost text-sm py-1 px-3 disabled:opacity-40">Suivant</button>
          </div>
        </div>
      )}
    </div>
  )
}
