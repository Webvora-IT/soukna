import { Request, Response, NextFunction } from 'express'
import bcrypt from 'bcryptjs'
import { z } from 'zod'
import { prisma } from '../lib/prisma'
import { signToken, signRefreshToken, verifyRefreshToken } from '../config/jwt'
import { AuthRequest } from '../middleware/auth'
import '../config/firebase'
import admin from 'firebase-admin'

const registerSchema = z.object({
  email: z.string().email('Email invalide'),
  phone: z.string().optional(),
  password: z.string().min(6, 'Mot de passe min 6 caractères'),
  name: z.string().min(2, 'Nom min 2 caractères'),
  role: z.enum(['CUSTOMER', 'VENDOR', 'DELIVERY']).optional().default('CUSTOMER'),
  language: z.string().optional().default('fr'),
})

const loginSchema = z.object({
  email: z.string().email('Email invalide'),
  password: z.string().min(1, 'Mot de passe requis'),
})

export async function register(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const data = registerSchema.parse(req.body)

    const existing = await prisma.user.findUnique({ where: { email: data.email } })
    if (existing) {
      res.status(409).json({ success: false, message: 'Cet email est déjà utilisé' })
      return
    }

    if (data.phone) {
      const existingPhone = await prisma.user.findUnique({ where: { phone: data.phone } })
      if (existingPhone) {
        res.status(409).json({ success: false, message: 'Ce numéro est déjà utilisé' })
        return
      }
    }

    const hashedPassword = await bcrypt.hash(data.password, 12)

    const user = await prisma.user.create({
      data: {
        email: data.email,
        phone: data.phone,
        password: hashedPassword,
        name: data.name,
        role: data.role,
        language: data.language,
      },
      select: {
        id: true,
        email: true,
        phone: true,
        name: true,
        role: true,
        avatar: true,
        language: true,
        createdAt: true,
      },
    })

    const token = signToken({ userId: user.id, email: user.email, role: user.role })
    const refreshToken = signRefreshToken({ userId: user.id, email: user.email, role: user.role })

    res.status(201).json({
      success: true,
      message: 'Compte créé avec succès',
      data: { user, token, refreshToken },
    })
  } catch (err) {
    next(err)
  }
}

export async function login(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const data = loginSchema.parse(req.body)

    const user = await prisma.user.findUnique({
      where: { email: data.email },
      select: {
        id: true,
        email: true,
        phone: true,
        name: true,
        role: true,
        avatar: true,
        language: true,
        password: true,
        isActive: true,
        createdAt: true,
      },
    })

    if (!user) {
      res.status(401).json({ success: false, message: 'Email ou mot de passe incorrect' })
      return
    }

    if (!user.isActive) {
      res.status(403).json({ success: false, message: 'Compte désactivé' })
      return
    }

    const valid = await bcrypt.compare(data.password, user.password)
    if (!valid) {
      res.status(401).json({ success: false, message: 'Email ou mot de passe incorrect' })
      return
    }

    const { password: _, ...userWithoutPassword } = user
    const token = signToken({ userId: user.id, email: user.email, role: user.role })
    const refreshToken = signRefreshToken({ userId: user.id, email: user.email, role: user.role })

    res.json({
      success: true,
      message: 'Connexion réussie',
      data: { user: userWithoutPassword, token, refreshToken },
    })
  } catch (err) {
    next(err)
  }
}

export async function getMe(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user!.id },
      select: {
        id: true,
        email: true,
        phone: true,
        name: true,
        role: true,
        avatar: true,
        language: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
        addresses: {
          select: { id: true, label: true, street: true, district: true, city: true, isDefault: true },
        },
        store: {
          select: { id: true, name: true, status: true, type: true },
        },
      },
    })

    if (!user) {
      res.status(404).json({ success: false, message: 'Utilisateur introuvable' })
      return
    }

    res.json({ success: true, data: user })
  } catch (err) {
    next(err)
  }
}

export async function firebaseAuth(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const { firebaseToken, name, email, phone, avatar } = req.body
    if (!firebaseToken) {
      res.status(400).json({ success: false, message: 'Firebase token requis' })
      return
    }

    // Verify Firebase token
    let decodedToken: admin.auth.DecodedIdToken
    try {
      decodedToken = await admin.auth().verifyIdToken(firebaseToken)
    } catch {
      res.status(401).json({ success: false, message: 'Token Firebase invalide' })
      return
    }

    const firebaseUid = decodedToken.uid
    const resolvedEmail = email || decodedToken.email || `${firebaseUid}@firebase.soukna`
    const resolvedPhone = phone || decodedToken.phone_number || null
    const resolvedName = name || decodedToken.name || resolvedEmail.split('@')[0]
    const resolvedAvatar = avatar || decodedToken.picture || null

    // Find existing user by firebaseUid, email, or phone
    let user = await prisma.user.findFirst({
      where: {
        OR: [
          ...(firebaseUid ? [{ firebaseUid }] : []),
          ...(resolvedEmail ? [{ email: resolvedEmail }] : []),
          ...(resolvedPhone ? [{ phone: resolvedPhone }] : []),
        ],
      },
      select: { id: true, email: true, phone: true, name: true, role: true, avatar: true, language: true, isActive: true },
    })

    if (user) {
      if (!user.isActive) {
        res.status(403).json({ success: false, message: 'Compte désactivé' })
        return
      }
      // Update firebaseUid if not set
      await prisma.user.update({ where: { id: user.id }, data: { firebaseUid } })
    } else {
      // Create new user
      user = await prisma.user.create({
        data: {
          email: resolvedEmail,
          phone: resolvedPhone,
          name: resolvedName,
          avatar: resolvedAvatar,
          password: await bcrypt.hash(Math.random().toString(36), 10),
          role: 'CUSTOMER',
          firebaseUid,
        },
        select: { id: true, email: true, phone: true, name: true, role: true, avatar: true, language: true, isActive: true },
      })
    }

    const token = signToken({ userId: user.id, email: user.email, role: user.role })
    const refreshTkn = signRefreshToken({ userId: user.id, email: user.email, role: user.role })

    res.json({ success: true, data: { user, token, refreshToken: refreshTkn } })
  } catch (err) {
    next(err)
  }
}

export async function refreshToken(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const { refreshToken: token } = req.body
    if (!token) {
      res.status(400).json({ success: false, message: 'Refresh token requis' })
      return
    }

    const decoded = verifyRefreshToken(token)
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      select: { id: true, email: true, role: true, isActive: true },
    })

    if (!user || !user.isActive) {
      res.status(401).json({ success: false, message: 'Token invalide' })
      return
    }

    const newToken = signToken({ userId: user.id, email: user.email, role: user.role })
    const newRefreshToken = signRefreshToken({ userId: user.id, email: user.email, role: user.role })

    res.json({ success: true, data: { token: newToken, refreshToken: newRefreshToken } })
  } catch (err) {
    next(err)
  }
}
