import axios, { AxiosError } from 'axios'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3080/api'

export const api = axios.create({
  baseURL: API_URL,
  timeout: 15000,
  headers: { 'Content-Type': 'application/json' },
})

// Inject JWT token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('soukna_token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  const lang = localStorage.getItem('soukna_lang') || 'fr'
  config.headers['Accept-Language'] = lang
  return config
})

// Handle 401 - redirect to login
api.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('soukna_token')
      localStorage.removeItem('soukna_user')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

// SWR fetcher
export const fetcher = (url: string) => api.get(url).then((r) => r.data)

// Auth helpers
export const authApi = {
  login: (email: string, password: string) =>
    api.post('/auth/login', { email, password }).then((r) => r.data),
  me: () => api.get('/auth/me').then((r) => r.data),
}

// Admin helpers
export const adminApi = {
  stats: () => api.get('/admin/stats').then((r) => r.data),
  users: (params?: Record<string, string>) =>
    api.get('/admin/users', { params }).then((r) => r.data),
  updateUserStatus: (id: string, isActive: boolean) =>
    api.patch(`/admin/users/${id}/status`, { isActive }).then((r) => r.data),
  stores: (params?: Record<string, string>) =>
    api.get('/admin/stores', { params }).then((r) => r.data),
  approveStore: (id: string, status: string) =>
    api.patch(`/admin/stores/${id}/status`, { status }).then((r) => r.data),
  banners: () => api.get('/admin/banners').then((r) => r.data),
  createBanner: (data: unknown) => api.post('/admin/banners', data).then((r) => r.data),
  updateBanner: (id: string, data: unknown) => api.patch(`/admin/banners/${id}`, data).then((r) => r.data),
  deleteBanner: (id: string) => api.delete(`/admin/banners/${id}`).then((r) => r.data),
  config: () => api.get('/admin/config').then((r) => r.data),
  updateConfig: (key: string, value: string) => api.post('/admin/config', { key, value }).then((r) => r.data),
}
