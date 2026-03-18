import { LucideIcon } from 'lucide-react'
import { motion } from 'framer-motion'
import clsx from 'clsx'

interface StatCardProps {
  title: string
  value: string | number
  icon: LucideIcon
  trend?: number
  color?: 'primary' | 'accent' | 'blue' | 'red'
  subtitle?: string
}

const colorMap = {
  primary: { bg: 'bg-primary-500/10', text: 'text-primary-500', border: 'border-primary-500/20' },
  accent: { bg: 'bg-accent-500/10', text: 'text-accent-500', border: 'border-accent-500/20' },
  blue: { bg: 'bg-blue-500/10', text: 'text-blue-400', border: 'border-blue-500/20' },
  red: { bg: 'bg-red-500/10', text: 'text-red-400', border: 'border-red-500/20' },
}

export default function StatCard({ title, value, icon: Icon, trend, color = 'primary', subtitle }: StatCardProps) {
  const colors = colorMap[color]

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className={clsx('glass-card p-6 border', colors.border)}
    >
      <div className="flex items-start justify-between">
        <div>
          <p className="text-sm text-slate-400 mb-1">{title}</p>
          <p className={clsx('text-3xl font-bold', colors.text)}>{value}</p>
          {subtitle && <p className="text-xs text-slate-500 mt-1">{subtitle}</p>}
        </div>
        <div className={clsx('p-3 rounded-xl', colors.bg)}>
          <Icon className={clsx('w-6 h-6', colors.text)} />
        </div>
      </div>
      {trend !== undefined && (
        <div className="mt-4 flex items-center gap-1">
          <span className={clsx('text-sm font-medium', trend >= 0 ? 'text-accent-500' : 'text-red-400')}>
            {trend >= 0 ? '↑' : '↓'} {Math.abs(trend)}%
          </span>
          <span className="text-xs text-slate-500">vs mois dernier</span>
        </div>
      )}
    </motion.div>
  )
}
