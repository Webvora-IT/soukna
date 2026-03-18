import { useState } from 'react'
import useSWR from 'swr'
import { fetcher, adminApi } from '../lib/api'
import { User } from '../types'
import toast from 'react-hot-toast'
import { Search, UserCheck, UserX, RefreshCw } from 'lucide-react'
import { format } from 'date-fns'

const ROLE_BADGE: Record<string, string> = {
  ADMIN: 'badge-danger',
  VENDOR: 'badge-warning',
  DELIVERY: 'badge-info',
  CUSTOMER: 'badge-neutral',
}

const ROLE_LABEL: Record<string, string> = {
  ADMIN: 'Admin',
  VENDOR: 'Vendeur',
  DELIVERY: 'Livreur',
  CUSTOMER: 'Client',
}

export default function Users() {
  const [role, setRole] = useState('')
  const [search, setSearch] = useState('')
  const [page, setPage] = useState(1)

  const params = new URLSearchParams({ page: String(page), limit: '20' })
  if (role) params.set('role', role)
  if (search) params.set('search', search)

  const { data, mutate } = useSWR(`/admin/users?${params}`, fetcher)

  const users: User[] = data?.data || []
  const meta = data?.meta

  const handleToggle = async (id: string, isActive: boolean) => {
    try {
      await adminApi.updateUserStatus(id, !isActive)
      toast.success(`Utilisateur ${!isActive ? 'activé' : 'désactivé'}`)
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
            placeholder="Nom, email, téléphone..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="input-dark pl-9"
          />
        </div>
        <select value={role} onChange={(e) => setRole(e.target.value)} className="input-dark w-auto">
          <option value="">Tous les rôles</option>
          {Object.entries(ROLE_LABEL).map(([v, l]) => <option key={v} value={v}>{l}</option>)}
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
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">Utilisateur</th>
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">Téléphone</th>
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">Rôle</th>
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">Boutique</th>
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">Commandes</th>
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">Statut</th>
                <th className="text-left text-xs text-slate-500 font-medium px-4 py-3">Inscrit le</th>
                <th className="text-right text-xs text-slate-500 font-medium px-4 py-3">Actions</th>
              </tr>
            </thead>
            <tbody>
              {users.map((user) => (
                <tr key={user.id} className="border-b border-[#2a2a40]/50 hover:bg-[#252538] transition-colors">
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-2">
                      <div className="w-8 h-8 bg-primary-500/20 rounded-full flex items-center justify-center text-primary-400 text-xs font-bold">
                        {user.name.charAt(0).toUpperCase()}
                      </div>
                      <div>
                        <p className="text-sm text-white">{user.name}</p>
                        <p className="text-xs text-slate-500">{user.email}</p>
                      </div>
                    </div>
                  </td>
                  <td className="px-4 py-3"><span className="text-sm text-slate-300">{user.phone || '-'}</span></td>
                  <td className="px-4 py-3"><span className={ROLE_BADGE[user.role]}>{ROLE_LABEL[user.role]}</span></td>
                  <td className="px-4 py-3">
                    {user.store ? (
                      <div>
                        <p className="text-xs text-white">{user.store.name}</p>
                        <span className={`badge text-[10px] ${user.store.status === 'ACTIVE' ? 'badge-success' : user.store.status === 'PENDING' ? 'badge-warning' : 'badge-danger'}`}>
                          {user.store.status}
                        </span>
                      </div>
                    ) : <span className="text-slate-500 text-sm">-</span>}
                  </td>
                  <td className="px-4 py-3"><span className="text-sm text-slate-300">{user._count?.orders || 0}</span></td>
                  <td className="px-4 py-3">
                    <span className={user.isActive ? 'badge-success' : 'badge-danger'}>
                      {user.isActive ? 'Actif' : 'Inactif'}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <span className="text-xs text-slate-500">{format(new Date(user.createdAt), 'dd/MM/yyyy')}</span>
                  </td>
                  <td className="px-4 py-3">
                    {user.role !== 'ADMIN' && (
                      <button
                        onClick={() => handleToggle(user.id, user.isActive)}
                        className={`p-1.5 rounded-lg transition-colors ${user.isActive ? 'text-red-400 hover:bg-red-500/10' : 'text-accent-500 hover:bg-accent-500/10'}`}
                        title={user.isActive ? 'Désactiver' : 'Activer'}
                      >
                        {user.isActive ? <UserX className="w-4 h-4" /> : <UserCheck className="w-4 h-4" />}
                      </button>
                    )}
                  </td>
                </tr>
              ))}
              {users.length === 0 && (
                <tr><td colSpan={8} className="text-center py-12 text-slate-500">Aucun utilisateur</td></tr>
              )}
            </tbody>
          </table>
        </div>
        {meta && meta.totalPages > 1 && (
          <div className="flex items-center justify-between px-4 py-3 border-t border-[#2a2a40]">
            <p className="text-xs text-slate-500">{meta.total} utilisateurs</p>
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
