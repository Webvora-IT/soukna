import useSWR from 'swr'
import { useState } from 'react'
import { ShoppingCart, Clock, ChefHat, CheckCircle, Truck, PackageCheck, XCircle } from 'lucide-react'
import { motion } from 'framer-motion'
import { format } from 'date-fns'
import { fr } from 'date-fns/locale'
import toast from 'react-hot-toast'
import api from '../lib/api'
import { Order, OrderStatus } from '../types'

const fetcher = (url: string) => api.get(url).then((r) => r.data)

const tabs: { key: string; label: string; status?: OrderStatus }[] = [
  { key: 'all', label: 'Toutes' },
  { key: 'pending', label: 'Nouvelles', status: 'PENDING' },
  { key: 'confirmed', label: 'Confirmées', status: 'CONFIRMED' },
  { key: 'preparing', label: 'En préparation', status: 'PREPARING' },
  { key: 'ready', label: 'Prêtes', status: 'READY' },
  { key: 'delivered', label: 'Livrées', status: 'DELIVERED' },
  { key: 'cancelled', label: 'Annulées', status: 'CANCELLED' },
]

const statusConfig: Record<OrderStatus, { label: string; className: string; icon: React.ReactNode }> = {
  PENDING: { label: 'En attente', className: 'bg-yellow-100 text-yellow-700', icon: <Clock className="w-3.5 h-3.5" /> },
  CONFIRMED: { label: 'Confirmée', className: 'bg-blue-100 text-blue-700', icon: <CheckCircle className="w-3.5 h-3.5" /> },
  PREPARING: { label: 'En préparation', className: 'bg-purple-100 text-purple-700', icon: <ChefHat className="w-3.5 h-3.5" /> },
  READY: { label: 'Prête', className: 'bg-teal-100 text-teal-700', icon: <PackageCheck className="w-3.5 h-3.5" /> },
  DELIVERING: { label: 'En livraison', className: 'bg-indigo-100 text-indigo-700', icon: <Truck className="w-3.5 h-3.5" /> },
  DELIVERED: { label: 'Livrée', className: 'bg-green-100 text-green-700', icon: <CheckCircle className="w-3.5 h-3.5" /> },
  CANCELLED: { label: 'Annulée', className: 'bg-red-100 text-red-700', icon: <XCircle className="w-3.5 h-3.5" /> },
}

const nextActions: Partial<Record<OrderStatus, { label: string; nextStatus: OrderStatus; className: string }[]>> = {
  PENDING: [
    { label: 'Confirmer', nextStatus: 'CONFIRMED', className: 'bg-blue-500 hover:bg-blue-600 text-white' },
    { label: 'Annuler', nextStatus: 'CANCELLED', className: 'bg-red-100 hover:bg-red-200 text-red-700' },
  ],
  CONFIRMED: [
    { label: 'Commencer préparation', nextStatus: 'PREPARING', className: 'bg-purple-500 hover:bg-purple-600 text-white' },
    { label: 'Annuler', nextStatus: 'CANCELLED', className: 'bg-red-100 hover:bg-red-200 text-red-700' },
  ],
  PREPARING: [
    { label: 'Prêt pour livraison', nextStatus: 'READY', className: 'bg-teal-500 hover:bg-teal-600 text-white' },
  ],
}

export default function Orders() {
  const [activeTab, setActiveTab] = useState('all')
  const [loadingId, setLoadingId] = useState<string | null>(null)

  const activeStatus = tabs.find((t) => t.key === activeTab)?.status
  const url = activeStatus ? `/vendor/orders?status=${activeStatus}` : '/vendor/orders'

  const { data, mutate } = useSWR(url, fetcher)
  const orders: Order[] = data?.data || []

  const updateStatus = async (orderId: string, status: OrderStatus) => {
    setLoadingId(orderId)
    try {
      await api.patch(`/vendor/orders/${orderId}/status`, { status })
      toast.success('Statut mis à jour')
      mutate()
    } catch (err: unknown) {
      const e = err as { response?: { data?: { message?: string } } }
      toast.error(e.response?.data?.message || 'Erreur lors de la mise à jour')
    } finally {
      setLoadingId(null)
    }
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Commandes</h1>
        <p className="text-gray-500 text-sm mt-1">
          {data?.meta?.total ?? 0} commande{(data?.meta?.total ?? 0) !== 1 ? 's' : ''}
        </p>
      </div>

      {/* Tabs */}
      <div className="flex gap-1 flex-wrap bg-gray-100 p-1 rounded-xl w-fit">
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

      {/* Orders list */}
      {orders.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-gray-400">
          <ShoppingCart className="w-14 h-14 mb-3 opacity-30" />
          <p className="font-medium">Aucune commande</p>
        </div>
      ) : (
        <div className="space-y-4">
          {orders.map((order, i) => {
            const cfg = statusConfig[order.status]
            const actions = nextActions[order.status] || []
            const isLoading = loadingId === order.id
            return (
              <motion.div
                key={order.id}
                initial={{ opacity: 0, y: 8 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: i * 0.04 }}
                className="bg-white rounded-2xl border border-gray-100 shadow-sm p-5"
              >
                <div className="flex items-start justify-between gap-4 flex-wrap">
                  <div className="flex-1 min-w-0">
                    {/* Order ID + status */}
                    <div className="flex items-center gap-3 flex-wrap">
                      <span className="font-bold text-gray-900">
                        #{order.id.slice(-8).toUpperCase()}
                      </span>
                      <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-xs font-medium ${cfg.className}`}>
                        {cfg.icon}
                        {cfg.label}
                      </span>
                    </div>

                    {/* Customer + date */}
                    <p className="text-sm text-gray-500 mt-1">
                      {order.customer.name}
                      {order.customer.phone && ` • ${order.customer.phone}`}
                      {' • '}
                      {format(new Date(order.createdAt), "dd MMM yyyy 'à' HH:mm", { locale: fr })}
                    </p>

                    {/* Items */}
                    <div className="mt-2 space-y-0.5">
                      {order.items.map((item) => (
                        <p key={item.id} className="text-xs text-gray-500">
                          {item.quantity}× {item.product.name} —{' '}
                          {(item.price * item.quantity).toLocaleString('fr-FR')} MRU
                        </p>
                      ))}
                    </div>

                    {/* Address */}
                    {order.address && (
                      <p className="text-xs text-gray-400 mt-1">
                        {order.address.street}, {order.address.district}
                      </p>
                    )}

                    {/* Notes */}
                    {order.notes && (
                      <p className="text-xs text-amber-600 mt-1 italic">Note: {order.notes}</p>
                    )}
                  </div>

                  {/* Total + actions */}
                  <div className="flex flex-col items-end gap-3">
                    <div className="text-right">
                      <p className="text-xl font-bold text-gray-900">
                        {order.total.toLocaleString('fr-FR')} MRU
                      </p>
                      <p className="text-xs text-gray-400">
                        Livraison: {order.deliveryFee} MRU
                      </p>
                    </div>
                    {actions.length > 0 && (
                      <div className="flex gap-2">
                        {actions.map((action) => (
                          <button
                            key={action.nextStatus}
                            onClick={() => updateStatus(order.id, action.nextStatus)}
                            disabled={isLoading}
                            className={`px-3 py-1.5 text-xs font-semibold rounded-lg transition-colors disabled:opacity-60 ${action.className}`}
                          >
                            {isLoading ? (
                              <div className="w-3 h-3 border-2 border-current border-t-transparent rounded-full animate-spin" />
                            ) : (
                              action.label
                            )}
                          </button>
                        ))}
                      </div>
                    )}
                  </div>
                </div>
              </motion.div>
            )
          })}
        </div>
      )}
    </div>
  )
}
