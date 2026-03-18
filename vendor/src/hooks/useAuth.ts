import { useState } from 'react'

export interface VendorUser {
  id: string
  name: string
  email: string
  role: string
  avatar?: string
}

export function useAuth() {
  const [user, setUser] = useState<VendorUser | null>(() => {
    const stored = localStorage.getItem('vendor_user')
    return stored ? JSON.parse(stored) : null
  })
  const [token, setToken] = useState<string | null>(() => localStorage.getItem('vendor_token'))

  const login = (userData: VendorUser, authToken: string) => {
    localStorage.setItem('vendor_user', JSON.stringify(userData))
    localStorage.setItem('vendor_token', authToken)
    setUser(userData)
    setToken(authToken)
  }

  const logout = () => {
    localStorage.removeItem('vendor_user')
    localStorage.removeItem('vendor_token')
    setUser(null)
    setToken(null)
  }

  return { user, token, login, logout, isAuthenticated: !!token }
}
