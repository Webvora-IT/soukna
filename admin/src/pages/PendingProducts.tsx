import { useState } from 'react'
import useSWR from 'swr'
import { Package, CheckCircle, XCircle, Clock, Store, X } from 'lucide-react'
import { motion, AnimatePresence } from 'framer-motion'
import toast from 'react-hot-toast'
import { api, fetcher } from '../lib/api'

interface PendingProduct {
  id: string
  name: string
  nameAr?: string
  price: number
  images: string[]
  description?: string
  createdAt: string
  store: {
    id: string
    name: string
    nameAr?: string
    type: string
    owner: { name: string; email: string }
  }
  category?: { id: string; name: string; nameAr?: string }
}

interface ApiResponse {
  success: boolean
  data: PendingProduct[]
  meta: { total: number; page: number; limit: number; totalPages: number }
}

function RejectModal({
  product,
  onClose,
  onConfirm,
}: {
  product: PendingProduct
  onClose: () => void
  onConfirm: (reason: string) => void
}) {
  const [reason, setReason] = useState('')
  const [loading, setLoading] = useState(false)

  const handleSubmit = async () => {
    setLoading(true)
    await onConfirm(reason)
    setLoading(false)
  }

  return (
    <div className="fixed inset-0 bg-black/60 flex items-center justify-center z-50 p-4">
      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        exit={{ opacity: 0, scale: 0.95 }}
        className="bg-[#1a1a2e] border border-[#2a2a40] rounded-2xl w-full max-w-md p-6 shadow-2xl"
      >
        <div className="flex items-start justify-between mb-4">
          <div>
            <h3 className="text-lg font-bold text-white">Refuser le produit</h3>
            <p className="text-slate-400 text-sm mt-0.5">"{product.name}"</p>
          </div>
          <button onClick={onClose} className="text-slate-500 hover:text-white p-1">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="mb-4">
          <label className="block text-sm font-medium text-slate-300 mb-2">
            Raison du refus
          </label>
          <textarea
            value={reason}
            onChange={(e) => setReason(e.target.value)}
            rows={4}
            placeholder="Ex: Images de mauvaise qualité, prix incorrects, description insuffisante..."
            className="w-full px-4 py-3 bg-[#252538] border border-[#3a3a55] rounded-xl text-white placeholder-slate-500 text-sm focus:outline-none focus:border-primary-500 resize-none"
          />
          <p className="text-xs text-slate-500 mt-1">
            Laissez vide pour utiliser le motif par défaut.
          </p>
        </div>

        <div className="flex gap-3">
          <button
            onClick={onClose}
            className="flex-1 py-2.5 border border-[#3a3a55] text-slate-300 font-medium rounded-xl hover:bg-[#252538] transition-colors text-sm"
          >
            Annuler
          </button>
          <button
            onClick={handleSubmit}
            disabled={loading}
            className="flex-1 py-2.5 bg-red-500 hover:bg-red-600 text-white font-semibold rounded-xl transition-colors text-sm disabled:opacity-60"
          >
            {loading ? (
              <span className="flex items-center justify-center gap-2">
                <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                Refus...
              </span>
            ) : (
              'Confirmer le refus'
            )}
          </button>
        </div>
      </motion.div>
    </div>
  )
}

const storeTypeLabels: Record<string, string> = {
  RESTAURANT: 'Restaurant',
  GROCERY: 'Épicerie',
  BOUTIQUE: 'Boutique',
  SERVICE: 'Service',
}

export default function PendingProducts() {
  const [page, setPage] = useState(1)
  const [rejectTarget, setRejectTarget] = useState<PendingProduct | null>(null)
  const [loadingId, setLoadingId] = useState<string | null>(null)

  const { data, mutate } = useSWR<ApiResponse>(
    `/admin/products/pending?page=${page}&limit=12`,
    fetcher
  )

  const products: PendingProduct[] = data?.data || []
  const meta = data?.meta

  const reviewProduct = async (id: string, action: 'approve' | 'reject', rejectionReason?: string) => {
    setLoadingId(id)
    try {
      await api.patch(`/admin/products/${id}/review`, { action, rejectionReason })
      toast.success(action === 'approve' ? 'Produit approuvé !' : 'Produit refusé.')
      mutate()
      setRejectTarget(null)
    } catch (err: unknown) {
      const e = err as { response?: { data?: { message?: string } } }
      toast.error(e.response?.data?.message || 'Erreur lors de la validation')
    } finally {
      setLoadingId(null)
    }
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-white">Produits en attente</h1>
          <p className="text-slate-400 text-sm mt-1">
            Validez ou refusez les produits soumis par les vendeurs
          </p>
        </div>
        {meta && (
          <div className="flex items-center gap-2 px-4 py-2 bg-yellow-500/20 text-yellow-400 border border-yellow-500/30 rounded-xl">
            <Clock className="w-4 h-4" />
            <span className="font-semibold">{meta.total}</span>
            <span className="text-sm">en attente</span>
          </div>
        )}
      </div>

      {/* Products grid */}
      {!data ? (
        <div className="flex items-center justify-center h-64">
          <div className="w-10 h-10 border-4 border-primary-500 border-t-transparent rounded-full animate-spin" />
        </div>
      ) : products.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-24 text-slate-500">
          <Package className="w-14 h-14 mb-3 opacity-30" />
          <p className="font-medium text-slate-400">Aucun produit en attente</p>
          <p className="text-sm mt-1">Tous les produits ont été traités</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {products.map((product, i) => {
            const isLoading = loadingId === product.id
            return (
              <motion.div
                key={product.id}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: i * 0.04 }}
                className="bg-[#1a1a2e] border border-[#2a2a40] rounded-2xl overflow-hidden hover:border-[#3a3a55] transition-colors"
              >
                {/* Image */}
                <div className="h-44 bg-[#252538] relative">
                  {product.images[0] ? (
                    <img
                      src={product.images[0]}
                      alt={product.name}
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center">
                      <Package className="w-12 h-12 text-slate-600" />
                    </div>
                  )}
                  <div className="absolute top-2 left-2">
                    <span className="inline-flex items-center gap-1 px-2.5 py-1 bg-yellow-500/20 text-yellow-400 border border-yellow-500/30 rounded-lg text-xs font-medium">
                      <Clock className="w-3 h-3" />
                      En attente
                    </span>
                  </div>
                </div>

                {/* Content */}
                <div className="p-4 space-y-3">
                  {/* Product name */}
                  <div>
                    <h3 className="font-semibold text-white truncate">{product.name}</h3>
                    {product.nameAr && (
                      <p className="text-xs text-slate-500 font-arabic truncate">{product.nameAr}</p>
                    )}
                    {product.category && (
                      <span className="inline-block mt-1 px-2 py-0.5 bg-[#252538] text-slate-400 text-xs rounded-lg">
                        {product.category.name}
                      </span>
                    )}
                  </div>

                  {/* Price */}
                  <p className="text-xl font-bold text-primary-400">
                    {product.price.toLocaleString('fr-FR')} MRU
                  </p>

                  {/* Store info */}
                  <div className="p-3 bg-[#252538] rounded-xl border border-[#3a3a55]">
                    <div className="flex items-start gap-2">
                      <Store className="w-4 h-4 text-slate-400 mt-0.5 flex-shrink-0" />
                      <div className="min-w-0">
                        <p className="text-sm font-medium text-white truncate">{product.store.name}</p>
                        <p className="text-xs text-slate-500">
                          {storeTypeLabels[product.store.type] || product.store.type}
                        </p>
                        <p className="text-xs text-slate-500 truncate mt-0.5">
                          {product.store.owner.name} · {product.store.owner.email}
                        </p>
                      </div>
                    </div>
                  </div>

                  {/* Action buttons */}
                  <div className="flex gap-2 pt-1">
                    <button
                      onClick={() => reviewProduct(product.id, 'approve')}
                      disabled={isLoading}
                      className="flex-1 flex items-center justify-center gap-1.5 py-2.5 bg-emerald-500/20 hover:bg-emerald-500/30 text-emerald-400 border border-emerald-500/30 font-semibold rounded-xl transition-colors text-sm disabled:opacity-60"
                    >
                      {isLoading ? (
                        <div className="w-4 h-4 border-2 border-emerald-400 border-t-transparent rounded-full animate-spin" />
                      ) : (
                        <>
                          <CheckCircle className="w-4 h-4" />
                          Approuver
                        </>
                      )}
                    </button>
                    <button
                      onClick={() => setRejectTarget(product)}
                      disabled={isLoading}
                      className="flex-1 flex items-center justify-center gap-1.5 py-2.5 bg-red-500/20 hover:bg-red-500/30 text-red-400 border border-red-500/30 font-semibold rounded-xl transition-colors text-sm disabled:opacity-60"
                    >
                      <XCircle className="w-4 h-4" />
                      Refuser
                    </button>
                  </div>
                </div>
              </motion.div>
            )
          })}
        </div>
      )}

      {/* Pagination */}
      {meta && meta.totalPages > 1 && (
        <div className="flex items-center justify-center gap-2 pt-4">
          <button
            onClick={() => setPage((p) => Math.max(1, p - 1))}
            disabled={page === 1}
            className="px-4 py-2 text-sm text-slate-400 hover:text-white bg-[#1a1a2e] border border-[#2a2a40] rounded-xl disabled:opacity-40 transition-colors"
          >
            Précédent
          </button>
          <span className="text-sm text-slate-400">
            Page {meta.page} / {meta.totalPages}
          </span>
          <button
            onClick={() => setPage((p) => Math.min(meta.totalPages, p + 1))}
            disabled={page === meta.totalPages}
            className="px-4 py-2 text-sm text-slate-400 hover:text-white bg-[#1a1a2e] border border-[#2a2a40] rounded-xl disabled:opacity-40 transition-colors"
          >
            Suivant
          </button>
        </div>
      )}

      {/* Reject modal */}
      <AnimatePresence>
        {rejectTarget && (
          <RejectModal
            product={rejectTarget}
            onClose={() => setRejectTarget(null)}
            onConfirm={(reason) => reviewProduct(rejectTarget.id, 'reject', reason)}
          />
        )}
      </AnimatePresence>
    </div>
  )
}
