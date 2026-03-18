import { LucideIcon } from 'lucide-react'
import { motion } from 'framer-motion'

interface StatCardProps {
  icon: LucideIcon
  label: string
  value: string | number
  sub?: string
  color: string
  bg: string
}

export default function StatCard({ icon: Icon, label, value, sub, color, bg }: StatCardProps) {
  return (
    <motion.div
      whileHover={{ y: -2 }}
      className="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm"
    >
      <div className="flex items-center gap-4">
        <div className={`w-12 h-12 rounded-xl ${bg} flex items-center justify-center flex-shrink-0`}>
          <Icon size={22} className={color} />
        </div>
        <div>
          <p className="text-xs text-gray-500 uppercase tracking-wide font-medium">{label}</p>
          <p className="text-2xl font-bold text-gray-900">{value}</p>
          {sub && <p className="text-xs text-gray-400 mt-0.5">{sub}</p>}
        </div>
      </div>
    </motion.div>
  )
}
