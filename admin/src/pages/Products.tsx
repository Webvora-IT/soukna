import { useState } from 'react'
import useSWR from 'swr'
import { fetcher, api } from '../lib/api'
import { Product } from '../types'
import toast from 'react-hot-toast'
import { Search, Trash2, Edit, RefreshCw } from 'lucide-react'

const STATUS_BADGE: Record<string, string> = {
  AVAILABLE: 'badge-success',
  UNAVAILABLE: 'badge-neutral',
  OUT_OF_STOCK: 'badge-danger',
}
const STATUS_LABEL: Record<string, string> = {
  AVAILABLE: 'Disponible',
  UNAVAILABLE: 'Indisponible',
  OUT_OF_STOCK: 'Rupture',
}

export default function Products() {
  const [search, setSearch] = useState('')
  const [status, setStatus] = useState('')
  const [page, setPage] = useState(1)

  const params = new URLSearchParams({ page: String(page), limit: '20' })
  if (search) params.set('search', search)
  if (status) params.set('status', status)
  else params.delete('status')

  const { data, mutate } = useSWR(`/products?${params}`, fetcher)
  const products: Product[] = data?.data || []
  const meta = data?.meta

  const handleDelete = async (id: string) => {
    if (!confirm('Supprimer ce produit?')) return
    try {
      await api.delete(`/products/${id}`)
      toast.success('Produit supprimé')
      mutate()
    } catch {
      toast.error('Erreur')
    }
  }

  const handleStatusChange = async (id: string, newStatus: string) => {
    try {
      await api.patch(`/products/${id}`, { status: newStatus })
      toast.success('Statut mis à jour')
      mutate()
    } catch {
      toast.error('Erreur')
    }
  }

  return (
    <div className="space-y-4">
      <div className="glass-card p-4 flex flex-wrap gap-3 items-center">
        <div className="relative flex-1 min-w-[200px]">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-500" />
          <input
            type="text"
            placeholder="Rechercher un produit..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="input-dark pl-9"
          />
        </div>
        <select value={status} onChange={(e) => setStatus(e.target.value)} className="input-dark w-auto">
          <option value="">Tous les statuts</option>
          {Object.entries(STATUS_LABEL).map(([v, l]) => <option key={v} value={v}>{l}</option>)}
        </select>
        <button onClick={() => mutate()} className="btn-ghost flex items-center gap-2">
          <RefreshCw className="w-4 h-4" /> Actualiser
        </button>
      </div>

      <div className="glass-card overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-[#2a2a40]">
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">Produit</th>
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">Boutique</th>
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">Catégorie</th>
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">Prix</th>
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">Stock</th>
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">Statut</th>
                <th className="text-right text-xs text-slate-500 font-medium px-4 py-3">Actions</th>
              </tr>
            </thead>
            <tbody>
              {products.map((product) => (
                <tr key={product.id} className="border-b border-[#2a2a40]/50 hover:bg-[#252538]">
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-3">
                      {product.images[0] ? (
                        <img src={product.images[0]} alt="" className="w-10 h-10 rounded-lg object-cover bg-[#0f0f1a]" />
                      ) : (
                        <div className="w-10 h-10 rounded-lg bg-[#0f0f1a] flex items-center justify-center text-slate-600 text-xs">IMG</div>
                      )}
                      <div>
                        <p className="text-sm text-white">{product.name}</p>
                        {product.nameAr && <p className="text-xs text-slate-500 font-arabic">{product.nameAr}</p>}
                      </div>
                    </div>
                  </td>
                  <td className="px-4 py-3"><span className="text-sm text-slate-300">{product.store?.name}</span></td>
                  <td className="px-4 py-3"><span className="text-sm text-slate-400">{product.category?.name || '-'}</span></td>
                  <td className="px-4 py-3">
                    <div>
                      <span className="text-sm text-primary-400 font-semibold">{product.price.toLocaleString()} MRU</span>
                      {product.originalPrice && (
                        <span className="text-xs text-slate-500 line-through ml-1">{product.originalPrice.toLocaleString()}</span>
                      )}
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <span className="text-sm text-slate-300">{product.stock ?? '∞'}</span>
                  </td>
                  <td className="px-4 py-3">
                    <select
                      value={product.status}
                      onChange={(e) => handleStatusChange(product.id, e.target.value)}
                      className="bg-transparent text-xs border border-[#2a2a40] rounded-lg px-2 py-1 text-white focus:border-primary-500 focus:outline-none"
                    >
                      {Object.entries(STATUS_LABEL).map(([v, l]) => <option key={v} value={v}>{l}</option>)}
                    </select>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center justify-end gap-2">
                      <button
                        onClick={() => handleDelete(product.id)}
                        className="p-1.5 text-red-400 hover:bg-red-500/10 rounded-lg transition-colors"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
              {products.length === 0 && (
                <tr><td colSpan={7} className="text-center py-12 text-slate-500">Aucun produit</td></tr>
              )}
            </tbody>
          </table>
        </div>
        {meta && meta.totalPages > 1 && (
          <div className="flex items-center justify-between px-4 py-3 border-t border-[#2a2a40]">
            <p className="text-xs text-slate-500">{meta.total} produits</p>
            <div className="flex gap-2">
              <button disabled={page <= 1} onClick={() => setPage(p => p - 1)} className="btn-ghost text-sm py-1 px-3 disabled:opacity-40">Précédent</button>
              <span className="text-sm text-slate-400 px-3 py-1">{page} / {meta.totalPages}</span>
              <button disabled={page >= meta.totalPages} onClick={() => setPage(p => p + 1)} className="btn-ghost text-sm py-1 px-3 disabled:opacity-40">Suivant</button>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
