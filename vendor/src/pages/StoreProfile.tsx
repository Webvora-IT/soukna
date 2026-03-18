import useSWR from 'swr'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { useState, useEffect } from 'react'
import { Store, Clock, CheckCircle, XCircle, Upload } from 'lucide-react'
import { motion } from 'framer-motion'
import toast from 'react-hot-toast'
import api from '../lib/api'
import { Store as StoreType } from '../types'

const fetcher = (url: string) => api.get(url).then((r) => r.data.data)

const storeSchema = z.object({
  name: z.string().min(2, 'Nom requis'),
  nameAr: z.string().optional(),
  description: z.string().optional(),
  descriptionAr: z.string().optional(),
  phone: z.string().optional(),
  address: z.string().optional(),
  district: z.string().optional(),
  openTime: z.string().optional(),
  closeTime: z.string().optional(),
  isOpen: z.boolean().optional(),
  deliveryFee: z.number().min(0).optional(),
  minOrder: z.number().min(0).optional(),
  logo: z.string().optional(),
  coverImage: z.string().optional(),
})

type StoreForm = z.infer<typeof storeSchema>

const statusConfig = {
  PENDING: { label: "En attente d'approbation", className: 'bg-yellow-100 text-yellow-700 border-yellow-200', icon: <Clock className="w-4 h-4" /> },
  ACTIVE: { label: 'Boutique active', className: 'bg-green-100 text-green-700 border-green-200', icon: <CheckCircle className="w-4 h-4" /> },
  SUSPENDED: { label: 'Boutique suspendue', className: 'bg-red-100 text-red-700 border-red-200', icon: <XCircle className="w-4 h-4" /> },
  CLOSED: { label: 'Boutique fermée', className: 'bg-gray-100 text-gray-600 border-gray-200', icon: <XCircle className="w-4 h-4" /> },
}

export default function StoreProfile() {
  const { data: store, mutate } = useSWR<StoreType>('/vendor/store', fetcher)
  const [uploading, setUploading] = useState<'logo' | 'cover' | null>(null)

  const {
    register,
    handleSubmit,
    reset,
    setValue,
    watch,
    formState: { errors, isSubmitting, isDirty },
  } = useForm<StoreForm>({ resolver: zodResolver(storeSchema) })

  useEffect(() => {
    if (store) {
      reset({
        name: store.name,
        nameAr: store.nameAr || '',
        description: store.description || '',
        descriptionAr: store.descriptionAr || '',
        phone: store.phone || '',
        address: store.address || '',
        district: store.district || '',
        openTime: store.openTime || '',
        closeTime: store.closeTime || '',
        isOpen: store.isOpen,
        deliveryFee: store.deliveryFee,
        minOrder: store.minOrder,
        logo: store.logo || '',
        coverImage: store.coverImage || '',
      })
    }
  }, [store, reset])

  const logoValue = watch('logo')
  const coverValue = watch('coverImage')

  const handleImageUpload = async (
    e: React.ChangeEvent<HTMLInputElement>,
    field: 'logo' | 'coverImage'
  ) => {
    const file = e.target.files?.[0]
    if (!file) return
    setUploading(field === 'logo' ? 'logo' : 'cover')
    try {
      const formData = new FormData()
      formData.append('file', file)
      const res = await api.post('/upload', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      })
      setValue(field, res.data.data.url, { shouldDirty: true })
      toast.success('Image mise à jour')
    } catch {
      toast.error("Erreur lors de l'upload")
    } finally {
      setUploading(null)
      e.target.value = ''
    }
  }

  const onSubmit = async (data: StoreForm) => {
    try {
      await api.patch('/vendor/store', {
        ...data,
        deliveryFee: Number(data.deliveryFee),
        minOrder: Number(data.minOrder),
      })
      toast.success('Boutique mise à jour')
      mutate()
    } catch (err: unknown) {
      const e = err as { response?: { data?: { message?: string } } }
      toast.error(e.response?.data?.message || 'Erreur lors de la mise à jour')
    }
  }

  if (!store) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-10 h-10 border-4 border-amber-400 border-t-transparent rounded-full animate-spin" />
      </div>
    )
  }

  const statusCfg = statusConfig[store.status] || statusConfig.PENDING

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Ma Boutique</h1>
          <p className="text-gray-500 text-sm mt-1">Gérez les informations de votre boutique</p>
        </div>
        <span className={`inline-flex items-center gap-2 px-3 py-1.5 rounded-xl text-sm font-medium border ${statusCfg.className}`}>
          {statusCfg.icon}
          {statusCfg.label}
        </span>
      </div>

      {store.status === 'PENDING' && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="p-4 bg-yellow-50 border border-yellow-200 rounded-2xl text-sm text-yellow-700"
        >
          Votre boutique est en attente d'approbation par l'équipe SOUKNA. Vous pourrez commencer à vendre dès validation.
        </motion.div>
      )}

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
        {/* Images */}
        <div className="bg-white rounded-2xl border border-gray-100 p-6 space-y-4">
          <h2 className="font-semibold text-gray-900">Images</h2>
          <div className="grid grid-cols-2 gap-4">
            {/* Logo */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Logo</label>
              <div className="relative h-28 bg-gray-50 rounded-xl overflow-hidden border border-gray-200">
                {logoValue ? (
                  <img src={logoValue} alt="logo" className="w-full h-full object-contain p-2" />
                ) : (
                  <div className="w-full h-full flex items-center justify-center">
                    <Store className="w-8 h-8 text-gray-300" />
                  </div>
                )}
                <label className="absolute inset-0 flex items-center justify-center bg-black/30 opacity-0 hover:opacity-100 transition-opacity cursor-pointer rounded-xl">
                  {uploading === 'logo' ? (
                    <div className="w-6 h-6 border-2 border-white border-t-transparent rounded-full animate-spin" />
                  ) : (
                    <Upload className="w-5 h-5 text-white" />
                  )}
                  <input type="file" accept="image/*" className="hidden" onChange={(e) => handleImageUpload(e, 'logo')} disabled={!!uploading} />
                </label>
              </div>
            </div>

            {/* Cover */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Image de couverture</label>
              <div className="relative h-28 bg-gray-50 rounded-xl overflow-hidden border border-gray-200">
                {coverValue ? (
                  <img src={coverValue} alt="cover" className="w-full h-full object-cover" />
                ) : (
                  <div className="w-full h-full flex items-center justify-center">
                    <Upload className="w-8 h-8 text-gray-300" />
                  </div>
                )}
                <label className="absolute inset-0 flex items-center justify-center bg-black/30 opacity-0 hover:opacity-100 transition-opacity cursor-pointer rounded-xl">
                  {uploading === 'cover' ? (
                    <div className="w-6 h-6 border-2 border-white border-t-transparent rounded-full animate-spin" />
                  ) : (
                    <Upload className="w-5 h-5 text-white" />
                  )}
                  <input type="file" accept="image/*" className="hidden" onChange={(e) => handleImageUpload(e, 'coverImage')} disabled={!!uploading} />
                </label>
              </div>
            </div>
          </div>
        </div>

        {/* Basic info */}
        <div className="bg-white rounded-2xl border border-gray-100 p-6 space-y-4">
          <h2 className="font-semibold text-gray-900">Informations générales</h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Nom (FR) *</label>
              <input
                {...register('name')}
                className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent"
              />
              {errors.name && <p className="text-red-500 text-xs mt-1">{errors.name.message}</p>}
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Nom en arabe</label>
              <input
                {...register('nameAr')}
                dir="rtl"
                className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent font-arabic"
              />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1.5">Description (FR)</label>
            <textarea
              {...register('description')}
              rows={3}
              className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent resize-none"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1.5">Description en arabe</label>
            <textarea
              {...register('descriptionAr')}
              rows={3}
              dir="rtl"
              className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent resize-none font-arabic"
            />
          </div>
        </div>

        {/* Contact & location */}
        <div className="bg-white rounded-2xl border border-gray-100 p-6 space-y-4">
          <h2 className="font-semibold text-gray-900">Contact & Localisation</h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Téléphone</label>
              <input
                {...register('phone')}
                type="tel"
                placeholder="+222 ..."
                className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Quartier</label>
              <input
                {...register('district')}
                placeholder="Ex: Tevragh Zeina"
                className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent"
              />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1.5">Adresse</label>
            <input
              {...register('address')}
              placeholder="Rue / numéro"
              className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent"
            />
          </div>
        </div>

        {/* Hours & settings */}
        <div className="bg-white rounded-2xl border border-gray-100 p-6 space-y-4">
          <h2 className="font-semibold text-gray-900">Horaires & Paramètres</h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Ouverture</label>
              <input
                {...register('openTime')}
                type="time"
                className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Fermeture</label>
              <input
                {...register('closeTime')}
                type="time"
                className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Frais de livraison (MRU)</label>
              <input
                {...register('deliveryFee', { valueAsNumber: true })}
                type="number"
                step="0.5"
                min="0"
                className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Commande min. (MRU)</label>
              <input
                {...register('minOrder', { valueAsNumber: true })}
                type="number"
                step="0.5"
                min="0"
                className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent"
              />
            </div>
          </div>

          {/* isOpen toggle */}
          <div className="flex items-center justify-between p-4 bg-gray-50 rounded-xl">
            <div>
              <p className="text-sm font-medium text-gray-800">Boutique ouverte</p>
              <p className="text-xs text-gray-500">Les clients peuvent passer des commandes</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                className="sr-only peer"
                {...register('isOpen')}
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-amber-500" />
            </label>
          </div>
        </div>

        {/* Submit */}
        <button
          type="submit"
          disabled={isSubmitting || !isDirty}
          className="w-full py-3 bg-amber-500 hover:bg-amber-600 text-white font-semibold rounded-xl transition-colors shadow-sm shadow-amber-200 disabled:opacity-60 disabled:cursor-not-allowed"
        >
          {isSubmitting ? (
            <span className="flex items-center justify-center gap-2">
              <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
              Sauvegarde...
            </span>
          ) : (
            'Sauvegarder les modifications'
          )}
        </button>
      </form>
    </div>
  )
}
