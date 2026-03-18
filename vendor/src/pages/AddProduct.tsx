import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { useNavigate } from 'react-router-dom'
import { useState } from 'react'
import useSWR from 'swr'
import { Upload, X, CheckCircle, ArrowLeft } from 'lucide-react'
import { motion, AnimatePresence } from 'framer-motion'
import toast from 'react-hot-toast'
import api from '../lib/api'

interface Category {
  id: string
  name: string
  nameAr?: string
}

const productSchema = z.object({
  name: z.string().min(2, 'Nom requis (min. 2 caractères)'),
  nameAr: z.string().optional(),
  nameEn: z.string().optional(),
  description: z.string().optional(),
  descriptionAr: z.string().optional(),
  price: z.number({ invalid_type_error: 'Prix invalide' }).positive('Prix doit être positif'),
  originalPrice: z.number().positive().optional().or(z.literal('')),
  stock: z.number().int().positive().optional().or(z.literal('')),
  unit: z.string().optional(),
  categoryId: z.string().optional(),
})

type ProductForm = z.infer<typeof productSchema>

const categoriesFetcher = (url: string) => api.get(url).then((r) => r.data.data)

export default function AddProduct() {
  const navigate = useNavigate()
  const [images, setImages] = useState<string[]>([])
  const [uploading, setUploading] = useState(false)
  const [success, setSuccess] = useState(false)

  const { data: categories } = useSWR<Category[]>('/categories', categoriesFetcher)

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<ProductForm>({
    resolver: zodResolver(productSchema),
  })

  const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return
    setUploading(true)
    try {
      const formData = new FormData()
      formData.append('file', file)
      const res = await api.post('/upload', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      })
      setImages((prev) => [...prev, res.data.data.url])
      toast.success('Image uploadée')
    } catch {
      toast.error("Erreur lors de l'upload")
    } finally {
      setUploading(false)
      e.target.value = ''
    }
  }

  const removeImage = (idx: number) => {
    setImages((prev) => prev.filter((_, i) => i !== idx))
  }

  const onSubmit = async (data: ProductForm) => {
    try {
      const payload = {
        ...data,
        price: Number(data.price),
        originalPrice: data.originalPrice ? Number(data.originalPrice) : undefined,
        stock: data.stock ? Number(data.stock) : undefined,
        images,
      }
      await api.post('/products', payload)
      setSuccess(true)
      setTimeout(() => navigate('/products'), 2500)
    } catch (err: unknown) {
      const e = err as { response?: { data?: { message?: string } } }
      toast.error(e.response?.data?.message || 'Erreur lors de la création du produit')
    }
  }

  if (success) {
    return (
      <div className="flex flex-col items-center justify-center h-full py-20">
        <motion.div
          initial={{ scale: 0.8, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          className="text-center"
        >
          <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <CheckCircle className="w-10 h-10 text-green-500" />
          </div>
          <h2 className="text-2xl font-bold text-gray-900 mb-2">Produit soumis !</h2>
          <p className="text-gray-500 max-w-sm mx-auto">
            Votre produit est en attente de validation par l'équipe SOUKNA. Il sera visible dès son approbation.
          </p>
          <p className="text-amber-600 text-sm mt-3">Redirection vers vos produits...</p>
        </motion.div>
      </div>
    )
  }

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      {/* Header */}
      <div className="flex items-center gap-3">
        <button
          onClick={() => navigate('/products')}
          className="p-2 hover:bg-gray-100 rounded-xl transition-colors text-gray-500"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Ajouter un produit</h1>
          <p className="text-sm text-gray-500 mt-0.5">
            Votre produit sera examiné avant d'être publié
          </p>
        </div>
      </div>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
        {/* Images */}
        <div className="bg-white rounded-2xl border border-gray-100 p-6 space-y-4">
          <h2 className="font-semibold text-gray-900">Images du produit</h2>
          <div className="flex flex-wrap gap-3">
            <AnimatePresence>
              {images.map((img, i) => (
                <motion.div
                  key={img}
                  initial={{ opacity: 0, scale: 0.9 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.9 }}
                  className="relative w-24 h-24 rounded-xl overflow-hidden border border-gray-200"
                >
                  <img src={img} alt={`img-${i}`} className="w-full h-full object-cover" />
                  <button
                    type="button"
                    onClick={() => removeImage(i)}
                    className="absolute top-1 right-1 w-5 h-5 bg-red-500 text-white rounded-full flex items-center justify-center"
                  >
                    <X className="w-3 h-3" />
                  </button>
                </motion.div>
              ))}
            </AnimatePresence>
            <label className="w-24 h-24 border-2 border-dashed border-gray-200 rounded-xl flex flex-col items-center justify-center cursor-pointer hover:border-amber-400 hover:bg-amber-50 transition-colors">
              {uploading ? (
                <div className="w-6 h-6 border-2 border-amber-400 border-t-transparent rounded-full animate-spin" />
              ) : (
                <>
                  <Upload className="w-5 h-5 text-gray-400" />
                  <span className="text-xs text-gray-400 mt-1">Ajouter</span>
                </>
              )}
              <input
                type="file"
                accept="image/*"
                className="hidden"
                onChange={handleImageUpload}
                disabled={uploading}
              />
            </label>
          </div>
        </div>

        {/* Basic info */}
        <div className="bg-white rounded-2xl border border-gray-100 p-6 space-y-4">
          <h2 className="font-semibold text-gray-900">Informations du produit</h2>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">
                Nom (FR) <span className="text-red-500">*</span>
              </label>
              <input
                {...register('name')}
                placeholder="Ex: Poulet rôti"
                className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent"
              />
              {errors.name && <p className="text-red-500 text-xs mt-1">{errors.name.message}</p>}
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">
                Nom en arabe
              </label>
              <input
                {...register('nameAr')}
                placeholder="مثال: دجاج مشوي"
                dir="rtl"
                className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent font-arabic"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1.5">
              Nom en anglais
            </label>
            <input
              {...register('nameEn')}
              placeholder="Ex: Grilled Chicken"
              className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1.5">Description (FR)</label>
            <textarea
              {...register('description')}
              rows={3}
              placeholder="Décrivez votre produit..."
              className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent resize-none"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1.5">
              Description en arabe
            </label>
            <textarea
              {...register('descriptionAr')}
              rows={3}
              placeholder="وصف المنتج..."
              dir="rtl"
              className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent resize-none font-arabic"
            />
          </div>
        </div>

        {/* Pricing & stock */}
        <div className="bg-white rounded-2xl border border-gray-100 p-6 space-y-4">
          <h2 className="font-semibold text-gray-900">Prix et stock</h2>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">
                Prix (MRU) <span className="text-red-500">*</span>
              </label>
              <input
                {...register('price', { valueAsNumber: true })}
                type="number"
                step="0.01"
                placeholder="0.00"
                className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent"
              />
              {errors.price && <p className="text-red-500 text-xs mt-1">{errors.price.message}</p>}
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">
                Prix barré (MRU)
              </label>
              <input
                {...register('originalPrice', { valueAsNumber: true })}
                type="number"
                step="0.01"
                placeholder="0.00"
                className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Stock</label>
              <input
                {...register('stock', { valueAsNumber: true })}
                type="number"
                placeholder="Quantité disponible"
                className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Unité</label>
              <input
                {...register('unit')}
                placeholder="Ex: kg, pièce, litre..."
                className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1.5">Catégorie</label>
            <select
              {...register('categoryId')}
              className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent bg-white"
            >
              <option value="">-- Sélectionner une catégorie --</option>
              {(categories || []).map((cat) => (
                <option key={cat.id} value={cat.id}>
                  {cat.name}
                  {cat.nameAr ? ` — ${cat.nameAr}` : ''}
                </option>
              ))}
            </select>
          </div>
        </div>

        {/* Submit */}
        <div className="flex gap-3">
          <button
            type="button"
            onClick={() => navigate('/products')}
            className="flex-1 py-3 border border-gray-200 text-gray-700 font-medium rounded-xl hover:bg-gray-50 transition-colors"
          >
            Annuler
          </button>
          <button
            type="submit"
            disabled={isSubmitting}
            className="flex-1 py-3 bg-amber-500 hover:bg-amber-600 text-white font-semibold rounded-xl transition-colors shadow-sm shadow-amber-200 disabled:opacity-60"
          >
            {isSubmitting ? (
              <span className="flex items-center justify-center gap-2">
                <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                Envoi en cours...
              </span>
            ) : (
              'Soumettre le produit'
            )}
          </button>
        </div>
      </form>
    </div>
  )
}
