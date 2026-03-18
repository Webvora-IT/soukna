import { useState } from 'react'
import useSWR from 'swr'
import { fetcher, adminApi } from '../lib/api'
import { Store, StoreStatus, StoreType } from '../types'
import toast from 'react-hot-toast'
import { Search, CheckCircle, XCircle, Eye, RefreshCw } from 'lucide-react'
import { format } from 'date-fns'

const STATUS_BADGE: Record<StoreStatus, string> = {
  ACTIVE: 'badge-success',
  PENDING: 'badge-warning',
  SUSPENDED: 'badge-danger',
  CLOSED: 'badge-neutral',
}

const STATUS_LABEL: Record<StoreStatus, string> = {
  ACTIVE: 'Actif',
  PENDING: 'En attente',
  SUSPENDED: 'Suspendu',
  CLOSED: 'Fermé',
}

const TYPE_LABEL: Record<StoreType, string> = {
  RESTAURANT: 'Restaurant',
  GROCERY: 'Épicerie',
  BOUTIQUE: 'Boutique',
  SERVICE: 'Service',
}

export default function Stores() {
  const [search, setSearch] = useState('')
  const [status, setStatus] = useState('')
  const [type, setType] = useState('')
  const [page, setPage] = useState(1)
  const [selected, setSelected] = useState<Store | null>(null)

  const params = new URLSearchParams({ page: String(page), limit: '15' })
  if (search) params.set('search', search)
  if (status) params.set('status', status)
  if (type) params.set('type', type)

  const { data, mutate } = useSWR(`/admin/stores?${params}`, fetcher)

  const handleApprove = async (id: string, newStatus: string) => {
    try {
      await adminApi.approveStore(id, newStatus)
      toast.success(`Boutique ${newStatus === 'ACTIVE' ? 'approuvée' : newStatus === 'SUSPENDED' ? 'suspendue' : 'mise à jour'}`)
      mutate()
      if (selected?.id === id) setSelected(null)
    } catch {
      toast.error('Erreur lors de la mise à jour')
    }
  }

  const stores: Store[] = data?.data || []
  const meta = data?.meta

  return (
    <div className="space-y-4">
      {/* Filters */}
      <div className="glass-card p-4 flex flex-wrap gap-3 items-center">
        <div className="relative flex-1 min-w-[200px]">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-500" />
          <input
            type="text"
            placeholder="Rechercher une boutique..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="input-dark pl-9"
          />
        </div>
        <select value={status} onChange={(e) => setStatus(e.target.value)} className="input-dark w-auto">
          <option value="">Tous les statuts</option>
          {Object.entries(STATUS_LABEL).map(([v, l]) => <option key={v} value={v}>{l}</option>)}
        </select>
        <select value={type} onChange={(e) => setType(e.target.value)} className="input-dark w-auto">
          <option value="">Tous les types</option>
          {Object.entries(TYPE_LABEL).map(([v, l]) => <option key={v} value={v}>{l}</option>)}
        </select>
        <button onClick={() => mutate()} className="btn-ghost flex items-center gap-2">
          <RefreshCw className="w-4 h-4" />
          Actualiser
        </button>
      </div>

      {/* Table */}
      <div className="glass-card overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-[#2a2a40]">
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">Boutique</th>
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">Propriétaire</th>
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">Type</th>
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">Quartier</th>
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">Statut</th>
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">Note</th>
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">Commandes</th>
                <th className="text-right text-xs text-slate-500 font-medium px-4 py-3">Actions</th>
              </tr>
            </thead>
            <tbody>
              {stores.map((store) => (
                <tr key={store.id} className="border-b border-[#2a2a40]/50 hover:bg-[#252538] transition-colors">
                  <td className="px-4 py-3">
                    <div>
                      <p className="text-sm text-white font-medium">{store.name}</p>
                      {store.nameAr && <p className="text-xs text-slate-500 font-arabic">{store.nameAr}</p>}
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <div>
                      <p className="text-sm text-slate-300">{store.owner?.name}</p>
                      <p className="text-xs text-slate-500">{store.owner?.email}</p>
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <span className="text-sm text-slate-300">{TYPE_LABEL[store.type]}</span>
                  </td>
                  <td className="px-4 py-3">
                    <span className="text-sm text-slate-400">{store.district || '-'}</span>
                  </td>
                  <td className="px-4 py-3">
                    <span className={STATUS_BADGE[store.status]}>{STATUS_LABEL[store.status]}</span>
                  </td>
                  <td className="px-4 py-3">
                    <span className="text-yellow-400 text-sm">★ {store.rating}</span>
                    <span className="text-slate-500 text-xs ml-1">({store.reviewCount})</span>
                  </td>
                  <td className="px-4 py-3">
                    <span className="text-slate-300 text-sm">{store._count?.orders || 0}</span>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center justify-end gap-2">
                      <button
                        onClick={() => setSelected(store)}
                        className="p-1.5 text-slate-400 hover:text-white hover:bg-[#2a2a40] rounded-lg transition-colors"
                        title="Détails"
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                      {store.status === 'PENDING' && (
                        <button
                          onClick={() => handleApprove(store.id, 'ACTIVE')}
                          className="p-1.5 text-accent-500 hover:bg-accent-500/10 rounded-lg transition-colors"
                          title="Approuver"
                        >
                          <CheckCircle className="w-4 h-4" />
                        </button>
                      )}
                      {store.status === 'ACTIVE' && (
                        <button
                          onClick={() => handleApprove(store.id, 'SUSPENDED')}
                          className="p-1.5 text-red-400 hover:bg-red-500/10 rounded-lg transition-colors"
                          title="Suspendre"
                        >
                          <XCircle className="w-4 h-4" />
                        </button>
                      )}
                      {store.status === 'SUSPENDED' && (
                        <button
                          onClick={() => handleApprove(store.id, 'ACTIVE')}
                          className="p-1.5 text-accent-500 hover:bg-accent-500/10 rounded-lg transition-colors"
                          title="Réactiver"
                        >
                          <CheckCircle className="w-4 h-4" />
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}

              {stores.length === 0 && (
                <tr>
                  <td colSpan={8} className="text-center py-12 text-slate-500">
                    Aucune boutique trouvée
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        {meta && meta.totalPages > 1 && (
          <div className="flex items-center justify-between px-4 py-3 border-t border-[#2a2a40]">
            <p className="text-xs text-slate-500">{meta.total} boutiques au total</p>
            <div className="flex gap-2">
              <button disabled={page <= 1} onClick={() => setPage(p => p - 1)} className="btn-ghost text-sm py-1 px-3 disabled:opacity-40">
                Précédent
              </button>
              <span className="text-sm text-slate-400 px-3 py-1">{page} / {meta.totalPages}</span>
              <button disabled={page >= meta.totalPages} onClick={() => setPage(p => p + 1)} className="btn-ghost text-sm py-1 px-3 disabled:opacity-40">
                Suivant
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Detail Modal */}
      {selected && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="glass-card w-full max-w-lg p-6 animate-slide-in">
            <div className="flex items-start justify-between mb-6">
              <div>
                <h3 className="text-lg font-semibold text-white">{selected.name}</h3>
                {selected.nameAr && <p className="text-primary-400 font-arabic">{selected.nameAr}</p>}
              </div>
              <button onClick={() => setSelected(null)} className="text-slate-400 hover:text-white text-xl leading-none">&times;</button>
            </div>

            <div className="space-y-3 text-sm">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <p className="text-slate-500 text-xs">Type</p>
                  <p className="text-white">{TYPE_LABEL[selected.type]}</p>
                </div>
                <div>
                  <p className="text-slate-500 text-xs">Statut</p>
                  <span className={STATUS_BADGE[selected.status]}>{STATUS_LABEL[selected.status]}</span>
                </div>
                <div>
                  <p className="text-slate-500 text-xs">Quartier</p>
                  <p className="text-white">{selected.district || '-'}</p>
                </div>
                <div>
                  <p className="text-slate-500 text-xs">Téléphone</p>
                  <p className="text-white">{selected.phone || '-'}</p>
                </div>
                <div>
                  <p className="text-slate-500 text-xs">Frais de livraison</p>
                  <p className="text-white">{selected.deliveryFee} MRU</p>
                </div>
                <div>
                  <p className="text-slate-500 text-xs">Commande min</p>
                  <p className="text-white">{selected.minOrder} MRU</p>
                </div>
                <div>
                  <p className="text-slate-500 text-xs">Horaires</p>
                  <p className="text-white">{selected.openTime || '?'} - {selected.closeTime || '?'}</p>
                </div>
                <div>
                  <p className="text-slate-500 text-xs">Créé le</p>
                  <p className="text-white">{format(new Date(selected.createdAt), 'dd/MM/yyyy')}</p>
                </div>
              </div>
              {selected.description && (
                <div>
                  <p className="text-slate-500 text-xs mb-1">Description</p>
                  <p className="text-slate-300">{selected.description}</p>
                </div>
              )}
            </div>

            <div className="flex gap-2 mt-6">
              {selected.status === 'PENDING' && (
                <button onClick={() => handleApprove(selected.id, 'ACTIVE')} className="btn-primary flex items-center gap-2">
                  <CheckCircle className="w-4 h-4" /> Approuver
                </button>
              )}
              {selected.status === 'ACTIVE' && (
                <button onClick={() => handleApprove(selected.id, 'SUSPENDED')} className="btn-danger flex items-center gap-2">
                  <XCircle className="w-4 h-4" /> Suspendre
                </button>
              )}
              {selected.status === 'SUSPENDED' && (
                <button onClick={() => handleApprove(selected.id, 'ACTIVE')} className="btn-primary flex items-center gap-2">
                  <CheckCircle className="w-4 h-4" /> Réactiver
                </button>
              )}
              <button onClick={() => setSelected(null)} className="btn-ghost">Fermer</button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
