import { useState } from 'react'
import useSWR from 'swr'
import { fetcher, api } from '../lib/api'
import { Order, OrderStatus } from '../types'
import toast from 'react-hot-toast'
import { Search, Eye, RefreshCw } from 'lucide-react'
import clsx from 'clsx'
import { format } from 'date-fns'
import { fr } from 'date-fns/locale'

const STATUS_BADGE: Record<OrderStatus, string> = {
  PENDING: 'badge-warning',
  CONFIRMED: 'badge-info',
  PREPARING: 'badge-info',
  READY: 'badge-info',
  DELIVERING: 'badge-warning',
  DELIVERED: 'badge-success',
  CANCELLED: 'badge-danger',
}

const STATUS_LABEL: Record<OrderStatus, string> = {
  PENDING: 'En attente',
  CONFIRMED: 'Confirmée',
  PREPARING: 'En préparation',
  READY: 'Prête',
  DELIVERING: 'En livraison',
  DELIVERED: 'Livrée',
  CANCELLED: 'Annulée',
}

const NEXT_STATUS: Partial<Record<OrderStatus, OrderStatus>> = {
  PENDING: 'CONFIRMED',
  CONFIRMED: 'PREPARING',
  PREPARING: 'READY',
  READY: 'DELIVERING',
  DELIVERING: 'DELIVERED',
}

export default function Orders() {
  const [status, setStatus] = useState('')
  const [search, setSearch] = useState('')
  const [page, setPage] = useState(1)
  const [selected, setSelected] = useState<Order | null>(null)

  const params = new URLSearchParams({ page: String(page), limit: '20' })
  if (status) params.set('status', status)

  const { data, mutate } = useSWR(`/orders?${params}`, fetcher)

  const orders: Order[] = (data?.data || []).filter((o: Order) =>
    !search || o.customer?.name?.toLowerCase().includes(search.toLowerCase()) ||
    o.store?.name?.toLowerCase().includes(search.toLowerCase()) ||
    o.id.includes(search)
  )
  const meta = data?.meta

  const handleUpdateStatus = async (id: string, newStatus: string) => {
    try {
      await api.patch(`/orders/${id}/status`, { status: newStatus })
      toast.success('Statut mis à jour')
      mutate()
      if (selected?.id === id) {
        setSelected(null)
      }
    } catch {
      toast.error('Erreur lors de la mise à jour')
    }
  }

  return (
    <div className="space-y-4">
      {/* Filters */}
      <div className="glass-card p-4 flex flex-wrap gap-3 items-center">
        <div className="relative flex-1 min-w-[200px]">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-500" />
          <input
            type="text"
            placeholder="Rechercher par client, boutique, ID..."
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

      {/* Table */}
      <div className="glass-card overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-[#2a2a40]">
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">ID</th>
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">Client</th>
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">Boutique</th>
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">Total</th>
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">Statut</th>
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">Date</th>
                <th className="text-right text-xs text-slate-500 font-medium px-4 py-3">Actions</th>
              </tr>
            </thead>
            <tbody>
              {orders.map((order) => (
                <tr key={order.id} className="border-b border-[#2a2a40]/50 hover:bg-[#252538] transition-colors">
                  <td className="px-4 py-3">
                    <span className="text-xs text-slate-500 font-mono">{order.id.slice(0, 8)}...</span>
                  </td>
                  <td className="px-4 py-3">
                    <div>
                      <p className="text-sm text-white">{order.customer?.name}</p>
                      <p className="text-xs text-slate-500">{order.customer?.phone}</p>
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <span className="text-sm text-slate-300">{order.store?.name}</span>
                  </td>
                  <td className="px-4 py-3">
                    <span className="text-sm text-primary-400 font-semibold">{order.total.toLocaleString()} MRU</span>
                  </td>
                  <td className="px-4 py-3">
                    <span className={STATUS_BADGE[order.status]}>{STATUS_LABEL[order.status]}</span>
                  </td>
                  <td className="px-4 py-3">
                    <span className="text-xs text-slate-500">
                      {format(new Date(order.createdAt), 'dd/MM/yy HH:mm', { locale: fr })}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center justify-end gap-2">
                      <button
                        onClick={() => setSelected(order)}
                        className="p-1.5 text-slate-400 hover:text-white hover:bg-[#2a2a40] rounded-lg"
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                      {NEXT_STATUS[order.status] && (
                        <button
                          onClick={() => handleUpdateStatus(order.id, NEXT_STATUS[order.status]!)}
                          className="px-2 py-1 text-xs bg-primary-500/20 text-primary-400 hover:bg-primary-500/30 rounded-lg transition-colors"
                        >
                          → {STATUS_LABEL[NEXT_STATUS[order.status]!]}
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
              {orders.length === 0 && (
                <tr>
                  <td colSpan={7} className="text-center py-12 text-slate-500">Aucune commande trouvée</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
        {meta && meta.totalPages > 1 && (
          <div className="flex items-center justify-between px-4 py-3 border-t border-[#2a2a40]">
            <p className="text-xs text-slate-500">{meta.total} commandes</p>
            <div className="flex gap-2">
              <button disabled={page <= 1} onClick={() => setPage(p => p - 1)} className="btn-ghost text-sm py-1 px-3 disabled:opacity-40">Précédent</button>
              <span className="text-sm text-slate-400 px-3 py-1">{page} / {meta.totalPages}</span>
              <button disabled={page >= meta.totalPages} onClick={() => setPage(p => p + 1)} className="btn-ghost text-sm py-1 px-3 disabled:opacity-40">Suivant</button>
            </div>
          </div>
        )}
      </div>

      {/* Detail Modal */}
      {selected && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="glass-card w-full max-w-xl p-6 animate-slide-in max-h-[90vh] overflow-y-auto">
            <div className="flex items-start justify-between mb-5">
              <div>
                <h3 className="text-lg font-semibold text-white">Commande #{selected.id.slice(0, 8)}</h3>
                <span className={clsx('mt-1', STATUS_BADGE[selected.status])}>{STATUS_LABEL[selected.status]}</span>
              </div>
              <button onClick={() => setSelected(null)} className="text-slate-400 hover:text-white text-xl">&times;</button>
            </div>

            <div className="grid grid-cols-2 gap-4 mb-4 text-sm">
              <div>
                <p className="text-slate-500 text-xs mb-1">Client</p>
                <p className="text-white">{selected.customer?.name}</p>
                <p className="text-slate-400">{selected.customer?.phone}</p>
              </div>
              <div>
                <p className="text-slate-500 text-xs mb-1">Boutique</p>
                <p className="text-white">{selected.store?.name}</p>
              </div>
              {selected.address && (
                <div className="col-span-2">
                  <p className="text-slate-500 text-xs mb-1">Adresse de livraison</p>
                  <p className="text-white">{selected.address.street}, {selected.address.district}</p>
                </div>
              )}
              {selected.notes && (
                <div className="col-span-2">
                  <p className="text-slate-500 text-xs mb-1">Notes</p>
                  <p className="text-slate-300">{selected.notes}</p>
                </div>
              )}
            </div>

            <div className="border border-[#2a2a40] rounded-lg overflow-hidden mb-4">
              <table className="w-full text-sm">
                <thead className="bg-[#0f0f1a]">
                  <tr>
                    <th className="text-left text-xs text-slate-500 px-3 py-2">Produit</th>
                    <th className="text-center text-xs text-slate-500 px-3 py-2">Qté</th>
                    <th className="text-right text-xs text-slate-500 px-3 py-2">Prix</th>
                  </tr>
                </thead>
                <tbody>
                  {selected.items?.map((item) => (
                    <tr key={item.id} className="border-t border-[#2a2a40]">
                      <td className="px-3 py-2 text-white">{item.product?.name}</td>
                      <td className="px-3 py-2 text-center text-slate-300">×{item.quantity}</td>
                      <td className="px-3 py-2 text-right text-primary-400">{(item.price * item.quantity).toLocaleString()} MRU</td>
                    </tr>
                  ))}
                </tbody>
                <tfoot className="bg-[#0f0f1a]">
                  <tr className="border-t border-[#2a2a40]">
                    <td colSpan={2} className="px-3 py-2 text-slate-400 text-xs">Sous-total</td>
                    <td className="px-3 py-2 text-right text-slate-300 text-xs">{selected.subtotal.toLocaleString()} MRU</td>
                  </tr>
                  <tr>
                    <td colSpan={2} className="px-3 py-2 text-slate-400 text-xs">Livraison</td>
                    <td className="px-3 py-2 text-right text-slate-300 text-xs">{selected.deliveryFee.toLocaleString()} MRU</td>
                  </tr>
                  <tr className="border-t border-[#2a2a40]">
                    <td colSpan={2} className="px-3 py-2 text-white font-semibold">Total</td>
                    <td className="px-3 py-2 text-right text-primary-400 font-bold">{selected.total.toLocaleString()} MRU</td>
                  </tr>
                </tfoot>
              </table>
            </div>

            <div className="flex gap-2">
              {NEXT_STATUS[selected.status] && (
                <button
                  onClick={() => handleUpdateStatus(selected.id, NEXT_STATUS[selected.status]!)}
                  className="btn-primary flex-1"
                >
                  Passer à: {STATUS_LABEL[NEXT_STATUS[selected.status]!]}
                </button>
              )}
              {['PENDING', 'CONFIRMED'].includes(selected.status) && (
                <button
                  onClick={() => handleUpdateStatus(selected.id, 'CANCELLED')}
                  className="btn-danger"
                >
                  Annuler
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
