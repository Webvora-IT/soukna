import { useState, useEffect, useCallback } from 'react'
import { authApi } from '../lib/api'
import { User } from '../types'

interface AuthState {
  user: User | null
  token: string | null
  loading: boolean
}

export function useAuth() {
  const [state, setState] = useState<AuthState>({
    user: null,
    token: localStorage.getItem('soukna_token'),
    loading: true,
  })

  const loadUser = useCallback(async () => {
    const token = localStorage.getItem('soukna_token')
    if (!token) {
      setState({ user: null, token: null, loading: false })
      return
    }

    try {
      const res = await authApi.me()
      setState({ user: res.data, token, loading: false })
    } catch {
      localStorage.removeItem('soukna_token')
      localStorage.removeItem('soukna_user')
      setState({ user: null, token: null, loading: false })
    }
  }, [])

  useEffect(() => {
    loadUser()
  }, [loadUser])

  const login = async (email: string, password: string) => {
    const res = await authApi.login(email, password)
    if (res.success) {
      const { token, user } = res.data
      if (user.role !== 'ADMIN') {
        throw new Error('Accès réservé aux administrateurs')
      }
      localStorage.setItem('soukna_token', token)
      localStorage.setItem('soukna_user', JSON.stringify(user))
      setState({ user, token, loading: false })
    }
    return res
  }

  const logout = () => {
    localStorage.removeItem('soukna_token')
    localStorage.removeItem('soukna_user')
    setState({ user: null, token: null, loading: false })
    window.location.href = '/login'
  }

  return {
    user: state.user,
    token: state.token,
    loading: state.loading,
    isAuthenticated: !!state.token && !!state.user,
    login,
    logout,
  }
}
