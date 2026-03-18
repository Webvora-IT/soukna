import { Request, Response, NextFunction } from 'express'
import { verifyToken, JwtPayload } from '../config/jwt'
import { prisma } from '../lib/prisma'

export interface AuthRequest extends Request {
  user?: {
    id: string
    email: string
    role: string
    name: string
  }
}

export function authenticate(req: AuthRequest, res: Response, next: NextFunction): void {
  try {
    const authHeader = req.headers.authorization
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      res.status(401).json({ success: false, message: 'Token manquant' })
      return
    }

    const token = authHeader.split(' ')[1]
    const decoded = verifyToken(token) as JwtPayload

    req.user = {
      id: decoded.userId,
      email: decoded.email,
      role: decoded.role,
      name: '',
    }

    next()
  } catch {
    res.status(401).json({ success: false, message: 'Token invalide ou expiré' })
  }
}

export function authorize(...roles: string[]) {
  return (req: AuthRequest, res: Response, next: NextFunction): void => {
    if (!req.user) {
      res.status(401).json({ success: false, message: 'Non authentifié' })
      return
    }

    if (!roles.includes(req.user.role)) {
      res.status(403).json({ success: false, message: 'Accès interdit' })
      return
    }

    next()
  }
}

export async function authenticateAndLoad(
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const authHeader = req.headers.authorization
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      res.status(401).json({ success: false, message: 'Token manquant' })
      return
    }

    const token = authHeader.split(' ')[1]
    const decoded = verifyToken(token) as JwtPayload

    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      select: { id: true, email: true, role: true, name: true, isActive: true },
    })

    if (!user || !user.isActive) {
      res.status(401).json({ success: false, message: 'Utilisateur inactif ou introuvable' })
      return
    }

    req.user = { id: user.id, email: user.email, role: user.role, name: user.name }
    next()
  } catch {
    res.status(401).json({ success: false, message: 'Token invalide ou expiré' })
  }
}
