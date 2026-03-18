import useSWR from 'swr'
import { fetcher } from '../lib/api'
import StatCard from '../components/StatCard'
import {
  ShoppingCart, Users, Store, Package,
  TrendingUp, Clock, CheckCircle
} from 'lucide-react'
import {
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip,
  ResponsiveContainer, PieChart, Pie, Cell, Legend
} from 'recharts'
import { format } from 'date-fns'
import { fr } from 'date-fns/locale'

const ORDER_STATUS_COLORS: Record<string, string> = {
  PENDING: '#f59e0b',
  CONFIRMED: '#3b82f6',
  PREPARING: '#8b5cf6',
  READY: '#06b6d4',
  DELIVERING: '#f97316',
  DELIVERED: '#10b981',
  CANCELLED: '#ef4444',
}

const ORDER_STATUS_LABELS: Record<string, string> = {
  PENDING: 'En attente',
  CONFIRMED: 'Confirmées',
  PREPARING: 'En préparation',
  READY: 'Prêtes',
  DELIVERING: 'En livraison',
  DELIVERED: 'Livrées',
  CANCELLED: 'Annulées',
}

export default function Dashboard() {
  const { data, error } = useSWR('/admin/stats', fetcher)

  if (error) {
    return (
      <div className="flex items-center justify-center h-64">
        <p className="text-red-400">Erreur de chargement des statistiques</p>
      </div>
    )
  }

  if (!data) {
    return (
      <div className="space-y-6 animate-pulse">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {[...Array(4)].map((_, i) => (
            <div key={i} className="glass-card p-6 h-32" />
          ))}
        </div>
      </div>
    )
  }

  const { stats, recentOrders, ordersByStatus, ordersByDay, topStores } = data.data

  return (
    <div className="space-y-6">
      {/* Stat Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          title="Commandes aujourd'hui"
          value={stats.ordersToday}
          icon={ShoppingCart}
          trend={stats.ordersGrowth}
          color="primary"
        />
        <StatCard
          title="Revenus ce mois"
          value={`${stats.revenueThisMonth.toLocaleString()} MRU`}
          icon={TrendingUp}
          trend={stats.revenueGrowth}
          color="accent"
        />
        <StatCard
          title="Boutiques actives"
          value={stats.activeStores}
          icon={Store}
          subtitle={`${stats.pendingStores} en attente`}
          color="blue"
        />
        <StatCard
          title="Utilisateurs"
          value={stats.totalUsers}
          icon={Users}
          color="primary"
        />
      </div>

      {/* Secondary stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <StatCard title="Total commandes" value={stats.totalOrders} icon={CheckCircle} color="accent" />
        <StatCard title="Produits disponibles" value={stats.totalProducts} icon={Package} color="blue" />
        <StatCard title="Commandes ce mois" value={stats.ordersThisMonth} icon={Clock} color="primary" />
      </div>

      {/* Charts row */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Area chart */}
        <div className="lg:col-span-2 glass-card p-6">
          <h3 className="text-base font-semibold text-white mb-4">Commandes & Revenus (ce mois)</h3>
          {ordersByDay && ordersByDay.length > 0 ? (
            <ResponsiveContainer width="100%" height={220}>
              <AreaChart data={ordersByDay}>
                <defs>
                  <linearGradient id="colorCount" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#f59e0b" stopOpacity={0.3} />
                    <stop offset="95%" stopColor="#f59e0b" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#2a2a40" />
                <XAxis dataKey="date" tick={{ fill: '#64748b', fontSize: 11 }} />
                <YAxis tick={{ fill: '#64748b', fontSize: 11 }} />
                <Tooltip
                  contentStyle={{ background: '#1a1a2e', border: '1px solid #2a2a40', borderRadius: '8px', color: '#e2e8f0' }}
                />
                <Area type="monotone" dataKey="count" stroke="#f59e0b" strokeWidth={2} fill="url(#colorCount)" name="Commandes" />
              </AreaChart>
            </ResponsiveContainer>
          ) : (
            <div className="h-[220px] flex items-center justify-center text-slate-500 text-sm">
              Pas encore de données ce mois
            </div>
          )}
        </div>

        {/* Pie chart */}
        <div className="glass-card p-6">
          <h3 className="text-base font-semibold text-white mb-4">Statuts des commandes</h3>
          {ordersByStatus && ordersByStatus.length > 0 ? (
            <ResponsiveContainer width="100%" height={220}>
              <PieChart>
                <Pie
                  data={ordersByStatus.map((s: { status: string; _count: { id: number } }) => ({
                    name: ORDER_STATUS_LABELS[s.status] || s.status,
                    value: s._count.id,
                  }))}
                  cx="50%"
                  cy="50%"
                  innerRadius={50}
                  outerRadius={80}
                  dataKey="value"
                >
                  {ordersByStatus.map((s: { status: string }, i: number) => (
                    <Cell key={i} fill={ORDER_STATUS_COLORS[s.status] || '#94a3b8'} />
                  ))}
                </Pie>
                <Tooltip contentStyle={{ background: '#1a1a2e', border: '1px solid #2a2a40', borderRadius: '8px', color: '#e2e8f0' }} />
                <Legend iconType="circle" wrapperStyle={{ fontSize: '11px', color: '#94a3b8' }} />
              </PieChart>
            </ResponsiveContainer>
          ) : (
            <div className="h-[220px] flex items-center justify-center text-slate-500 text-sm">Aucune commande</div>
          )}
        </div>
      </div>

      {/* Bottom row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Orders */}
        <div className="glass-card p-6">
          <h3 className="text-base font-semibold text-white mb-4">Commandes récentes</h3>
          <div className="space-y-3">
            {recentOrders?.slice(0, 6).map((order: { id: string; customer?: { name: string }; store?: { name: string }; total: number; status: string; createdAt: string }) => (
              <div key={order.id} className="flex items-center justify-between py-2 border-b border-[#2a2a40] last:border-0">
                <div>
                  <p className="text-sm text-white font-medium">{order.customer?.name}</p>
                  <p className="text-xs text-slate-500">{order.store?.name}</p>
                </div>
                <div className="text-right">
                  <p className="text-sm text-primary-400 font-semibold">{order.total.toLocaleString()} MRU</p>
                  <p className="text-xs text-slate-500">
                    {format(new Date(order.createdAt), 'dd/MM HH:mm', { locale: fr })}
                  </p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Top Stores */}
        <div className="glass-card p-6">
          <h3 className="text-base font-semibold text-white mb-4">Meilleures boutiques</h3>
          <div className="space-y-3">
            {topStores?.map((store: { id: string; name: string; nameAr?: string; type: string; rating: number; reviewCount: number; _count: { orders: number } }, idx: number) => (
              <div key={store.id} className="flex items-center gap-3 py-2 border-b border-[#2a2a40] last:border-0">
                <span className="w-7 h-7 bg-primary-500/20 text-primary-400 rounded-full flex items-center justify-center text-xs font-bold">
                  {idx + 1}
                </span>
                <div className="flex-1">
                  <p className="text-sm text-white font-medium">{store.name}</p>
                  <p className="text-xs text-slate-500">{store.type}</p>
                </div>
                <div className="text-right">
                  <p className="text-sm text-yellow-400">★ {store.rating}</p>
                  <p className="text-xs text-slate-500">{store._count.orders} cmd</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}
