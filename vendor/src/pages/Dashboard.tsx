import useSWR from 'swr'
import { Package, Clock, ShoppingCart, DollarSign, AlertTriangle, CheckCircle, XCircle } from 'lucide-react'
import { motion } from 'framer-motion'
import { format } from 'date-fns'
import { fr } from 'date-fns/locale'
import api from '../lib/api'
import StatCard from '../components/StatCard'
import { DashboardData, Order, OrderStatus } from '../types'

const fetcher = (url: string) => api.get(url).then((r) => r.data.data)

const orderStatusLabels: Record<OrderStatus, string> = {
  PENDING: 'En attente',
  CONFIRMED: 'Confirmée',
  PREPARING: 'En préparation',
  READY: 'Prête',
  DELIVERING: 'En livraison',
  DELIVERED: 'Livrée',
  CANCELLED: 'Annulée',
}

const orderStatusColors: Record<OrderStatus, string> = {
  PENDING: 'bg-yellow-100 text-yellow-700',
  CONFIRMED: 'bg-blue-100 text-blue-700',
  PREPARING: 'bg-purple-100 text-purple-700',
  READY: 'bg-teal-100 text-teal-700',
  DELIVERING: 'bg-indigo-100 text-indigo-700',
  DELIVERED: 'bg-green-100 text-green-700',
  CANCELLED: 'bg-red-100 text-red-700',
}

export default function Dashboard() {
  const { data, error, isLoading } = useSWR<DashboardData>('/vendor/dashboard', fetcher)

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-10 h-10 border-4 border-amber-400 border-t-transparent rounded-full animate-spin" />
      </div>
    )
  }

  if (error) {
    return (
      <div className="flex items-center justify-center h-64 text-red-500">
        Erreur de chargement du tableau de bord.
      </div>
    )
  }

  if (!data) return null

  const { store, stats, recentOrders } = data

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Tableau de bord</h1>
        <p className="text-gray-500 text-sm mt-1">Bienvenue, {store.name}</p>
      </div>

      {/* Store status banners */}
      {store.status === 'PENDING' && (
        <motion.div
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          className="flex items-start gap-3 p-4 bg-yellow-50 border border-yellow-200 rounded-2xl"
        >
          <Clock className="w-5 h-5 text-yellow-600 mt-0.5 flex-shrink-0" />
          <div>
            <p className="font-semibold text-yellow-800">Boutique en attente d'approbation</p>
            <p className="text-sm text-yellow-600 mt-0.5">
              Votre boutique est en cours de vérification par l'équipe SOUKNA. Vous serez notifié dès l'approbation.
            </p>
          </div>
        </motion.div>
      )}

      {store.status === 'SUSPENDED' && (
        <motion.div
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          className="flex items-start gap-3 p-4 bg-red-50 border border-red-200 rounded-2xl"
        >
          <XCircle className="w-5 h-5 text-red-600 mt-0.5 flex-shrink-0" />
          <div>
            <p className="font-semibold text-red-800">Boutique suspendue</p>
            <p className="text-sm text-red-600 mt-0.5">
              Votre boutique a été suspendue. Contactez le support SOUKNA pour plus d'informations.
            </p>
          </div>
        </motion.div>
      )}

      {stats.rejectedProducts > 0 && (
        <motion.div
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          className="flex items-start gap-3 p-4 bg-red-50 border border-red-200 rounded-2xl"
        >
          <AlertTriangle className="w-5 h-5 text-red-600 mt-0.5 flex-shrink-0" />
          <div>
            <p className="font-semibold text-red-800">
              {stats.rejectedProducts} produit{stats.rejectedProducts > 1 ? 's' : ''} refusé{stats.rejectedProducts > 1 ? 's' : ''}
            </p>
            <p className="text-sm text-red-600 mt-0.5">
              Consultez vos produits refusés pour connaître les raisons et effectuer les corrections nécessaires.
            </p>
          </div>
        </motion.div>
      )}

      {stats.pendingProducts > 0 && (
        <motion.div
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          className="flex items-start gap-3 p-4 bg-amber-50 border border-amber-200 rounded-2xl"
        >
          <CheckCircle className="w-5 h-5 text-amber-600 mt-0.5 flex-shrink-0" />
          <div>
            <p className="font-semibold text-amber-800">
              {stats.pendingProducts} produit{stats.pendingProducts > 1 ? 's' : ''} en attente de validation
            </p>
            <p className="text-sm text-amber-600 mt-0.5">
              L'équipe SOUKNA examinera vos produits dans les prochaines 24h.
            </p>
          </div>
        </motion.div>
      )}

      {/* Stats grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          icon={Package}
          label="Total Produits"
          value={stats.totalProducts}
          sub={`${stats.availableProducts} disponibles`}
          color="text-amber-600"
          bg="bg-amber-50"
        />
        <StatCard
          icon={Clock}
          label="En attente validation"
          value={stats.pendingProducts}
          sub="Sous examen"
          color="text-yellow-600"
          bg="bg-yellow-50"
        />
        <StatCard
          icon={ShoppingCart}
          label="Commandes en cours"
          value={stats.pendingOrders}
          sub={`${stats.ordersThisMonth} ce mois`}
          color="text-blue-600"
          bg="bg-blue-50"
        />
        <StatCard
          icon={DollarSign}
          label="Revenus ce mois"
          value={`${stats.revenueThisMonth.toLocaleString('fr-FR')} MRU`}
          sub="Livraisons effectuées"
          color="text-emerald-600"
          bg="bg-emerald-50"
        />
      </div>

      {/* Recent orders */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-50">
          <h2 className="font-semibold text-gray-900">Dernières commandes</h2>
        </div>
        {recentOrders.length === 0 ? (
          <div className="px-6 py-12 text-center text-gray-400">
            <ShoppingCart className="w-10 h-10 mx-auto mb-2 opacity-30" />
            <p>Aucune commande pour l'instant</p>
          </div>
        ) : (
          <div className="divide-y divide-gray-50">
            {recentOrders.map((order: Order) => (
              <div key={order.id} className="px-6 py-4 hover:bg-gray-50 transition-colors">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-gray-900">
                      #{order.id.slice(-8).toUpperCase()}
                    </p>
                    <p className="text-xs text-gray-400 mt-0.5">
                      {order.customer.name} •{' '}
                      {format(new Date(order.createdAt), 'dd MMM HH:mm', { locale: fr })}
                    </p>
                    <p className="text-xs text-gray-500 mt-0.5">
                      {order.items.length} article{order.items.length > 1 ? 's' : ''}
                    </p>
                  </div>
                  <div className="flex items-center gap-3">
                    <span className="font-semibold text-gray-900 text-sm">
                      {order.total.toLocaleString('fr-FR')} MRU
                    </span>
                    <span
                      className={`px-2.5 py-1 rounded-lg text-xs font-medium ${orderStatusColors[order.status]}`}
                    >
                      {orderStatusLabels[order.status]}
                    </span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}
