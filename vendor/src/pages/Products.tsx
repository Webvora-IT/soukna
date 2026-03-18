import useSWR from 'swr'
import { useState } from 'react'
import { Link } from 'react-router-dom'
import { Plus, Package, Trash2, AlertCircle, Clock, CheckCircle, XCircle, EyeOff } from 'lucide-react'
import { motion, AnimatePresence } from 'framer-motion'
import toast from 'react-hot-toast'
import api from '../lib/api'
import { Product, ProductStatus } from '../types'

const fetcher = (url: string) => api.get(url).then((r) => r.data)

const tabs: { key: string; label: string; status?: ProductStatus }[] = [
  { key: 'all', label: 'Tous' },
  { key: 'pending', label: 'En attente', status: 'PENDING_REVIEW' },
  { key: 'available', label: 'Disponibles', status: 'AVAILABLE' },
  { key: 'rejected', label: 'Rejetés', status: 'REJECTED' },
  { key: 'unavailable', label: 'Indisponibles', status: 'UNAVAILABLE' },
]

const statusConfig: Record<ProductStatus, { label: string; className: string; icon: React.ReactNode }> = {
  PENDING_REVIEW: {
    label: 'En attente',
    className: 'bg-yellow-100 text-yellow-700',
    icon: <Clock className="w-3 h-3" />,
  },
  AVAILABLE: {
    label: 'Disponible',
    className: 'bg-green-100 text-green-700',
    icon: <CheckCircle className="w-3 h-3" />,
  },
  REJECTED: {
    label: 'Refusé',
    className: 'bg-red-100 text-red-700',
    icon: <XCircle className="w-3 h-3" />,
  },
  UNAVAILABLE: {
    label: 'Indisponible',
    className: 'bg-gray-100 text-gray-600',
    icon: <EyeOff className="w-3 h-3" />,
  },
  OUT_OF_STOCK: {
    label: 'Rupture stock',
    className: 'bg-orange-100 text-orange-700',
    icon: <AlertCircle className="w-3 h-3" />,
  },
}

export default function Products() {
  const [activeTab, setActiveTab] = useState('all')
  const [deleteId, setDeleteId] = useState<string | null>(null)

  const activeStatus = tabs.find((t) => t.key === activeTab)?.status
  const url = activeStatus ? `/vendor/products?status=${activeStatus}` : '/vendor/products'

  const { data, mutate } = useSWR(url, fetcher)
  const products: Product[] = data?.data || []

  const handleDelete = async (id: string) => {
    if (!confirm('Supprimer ce produit définitivement ?')) return
    setDeleteId(id)
    try {
      await api.delete(`/products/${id}`)
      toast.success('Produit supprimé')
      mutate()
    } catch {
      toast.error('Erreur lors de la suppression')
    } finally {
      setDeleteId(null)
    }
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Mes Produits</h1>
          <p className="text-gray-500 text-sm mt-1">
            {data?.meta?.total ?? 0} produit{(data?.meta?.total ?? 0) !== 1 ? 's' : ''} au total
          </p>
        </div>
        <Link
          to="/products/add"
          className="flex items-center gap-2 px-4 py-2.5 bg-amber-500 hover:bg-amber-600 text-white font-medium rounded-xl transition-colors shadow-sm shadow-amber-200"
        >
          <Plus className="w-4 h-4" />
          Ajouter un produit
        </Link>
      </div>

      {/* Filter tabs */}
      <div className="flex gap-1 bg-gray-100 p-1 rounded-xl w-fit">
        {tabs.map((tab) => (
          <button
            key={tab.key}
            onClick={() => setActiveTab(tab.key)}
            className={`px-4 py-2 text-sm font-medium rounded-lg transition-all ${
              activeTab === tab.key
                ? 'bg-white text-amber-700 shadow-sm'
                : 'text-gray-500 hover:text-gray-700'
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {/* Products grid */}
      {products.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-gray-400">
          <Package className="w-14 h-14 mb-3 opacity-30" />
          <p className="font-medium">Aucun produit trouvé</p>
          <p className="text-sm mt-1">Ajoutez votre premier produit</p>
        </div>
      ) : (
        <AnimatePresence>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
            {products.map((product, i) => {
              const status = statusConfig[product.status]
              return (
                <motion.div
                  key={product.id}
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: i * 0.03 }}
                  className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden hover:shadow-md transition-shadow"
                >
                  {/* Image */}
                  <div className="h-40 bg-gray-50 relative">
                    {product.images[0] ? (
                      <img
                        src={product.images[0]}
                        alt={product.name}
                        className="w-full h-full object-cover"
                      />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center">
                        <Package className="w-10 h-10 text-gray-300" />
                      </div>
                    )}
                    {/* Status badge */}
                    <div className="absolute top-2 right-2">
                      <span
                        className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-lg text-xs font-medium ${status.className}`}
                      >
                        {status.icon}
                        {status.label}
                      </span>
                    </div>
                  </div>

                  {/* Info */}
                  <div className="p-4">
                    <h3 className="font-semibold text-gray-900 text-sm truncate">{product.name}</h3>
                    {product.nameAr && (
                      <p className="text-xs text-gray-400 font-arabic truncate">{product.nameAr}</p>
                    )}
                    {product.category && (
                      <p className="text-xs text-gray-400 mt-1">{product.category.name}</p>
                    )}
                    <div className="flex items-center justify-between mt-3">
                      <div>
                        <span className="font-bold text-amber-600">
                          {product.price.toLocaleString('fr-FR')} MRU
                        </span>
                        {product.originalPrice && (
                          <span className="text-xs text-gray-400 line-through ml-2">
                            {product.originalPrice.toLocaleString('fr-FR')}
                          </span>
                        )}
                      </div>
                      <button
                        onClick={() => handleDelete(product.id)}
                        disabled={deleteId === product.id}
                        className="p-1.5 text-red-400 hover:bg-red-50 rounded-lg transition-colors"
                      >
                        {deleteId === product.id ? (
                          <div className="w-4 h-4 border-2 border-red-400 border-t-transparent rounded-full animate-spin" />
                        ) : (
                          <Trash2 className="w-4 h-4" />
                        )}
                      </button>
                    </div>

                    {/* Rejection reason */}
                    {product.status === 'REJECTED' && product.rejectionReason && (
                      <div className="mt-3 p-2.5 bg-red-50 rounded-lg border border-red-100">
                        <p className="text-xs text-red-600 flex items-start gap-1.5">
                          <AlertCircle className="w-3.5 h-3.5 flex-shrink-0 mt-0.5" />
                          <span>{product.rejectionReason}</span>
                        </p>
                      </div>
                    )}
                  </div>
                </motion.div>
              )
            })}
          </div>
        </AnimatePresence>
      )}
    </div>
  )
}
