import useSWR from 'swr'
import { Bell, CheckCircle, XCircle, Info } from 'lucide-react'
import { motion } from 'framer-motion'
import { format } from 'date-fns'
import { fr } from 'date-fns/locale'
import api from '../lib/api'
import { Notification } from '../types'

const fetcher = (url: string) => api.get(url).then((r) => r.data.data)

const typeConfig: Record<string, { icon: React.ReactNode; className: string; bg: string }> = {
  PRODUCT_APPROVED: {
    icon: <CheckCircle className="w-5 h-5 text-green-600" />,
    className: 'border-green-100',
    bg: 'bg-green-50',
  },
  PRODUCT_REJECTED: {
    icon: <XCircle className="w-5 h-5 text-red-500" />,
    className: 'border-red-100',
    bg: 'bg-red-50',
  },
  DEFAULT: {
    icon: <Info className="w-5 h-5 text-blue-500" />,
    className: 'border-blue-100',
    bg: 'bg-blue-50',
  },
}

export default function Notifications() {
  const { data: notifications, isLoading } = useSWR<Notification[]>('/vendor/notifications', fetcher)

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-10 h-10 border-4 border-amber-400 border-t-transparent rounded-full animate-spin" />
      </div>
    )
  }

  const list = notifications || []

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Notifications</h1>
        <p className="text-gray-500 text-sm mt-1">
          {list.length} notification{list.length !== 1 ? 's' : ''}
        </p>
      </div>

      {list.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-gray-400">
          <Bell className="w-14 h-14 mb-3 opacity-30" />
          <p className="font-medium">Aucune notification</p>
          <p className="text-sm mt-1">Vous êtes à jour !</p>
        </div>
      ) : (
        <div className="space-y-3">
          {list.map((notif, i) => {
            const cfg = typeConfig[notif.type] || typeConfig.DEFAULT
            return (
              <motion.div
                key={notif.id}
                initial={{ opacity: 0, y: 8 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: i * 0.04 }}
                className={`flex items-start gap-4 p-4 rounded-2xl border ${cfg.className} ${
                  notif.isRead ? 'bg-white' : cfg.bg
                } transition-colors`}
              >
                <div className="mt-0.5 flex-shrink-0">{cfg.icon}</div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between gap-2">
                    <p className={`text-sm font-semibold ${notif.isRead ? 'text-gray-700' : 'text-gray-900'}`}>
                      {notif.title}
                    </p>
                    <div className="flex items-center gap-2 flex-shrink-0">
                      {!notif.isRead && (
                        <span className="w-2 h-2 rounded-full bg-amber-500 flex-shrink-0" />
                      )}
                      <span className="text-xs text-gray-400 whitespace-nowrap">
                        {format(new Date(notif.createdAt), 'dd MMM HH:mm', { locale: fr })}
                      </span>
                    </div>
                  </div>
                  <p className="text-sm text-gray-500 mt-0.5">{notif.body}</p>
                </div>
              </motion.div>
            )
          })}
        </div>
      )}
    </div>
  )
}
