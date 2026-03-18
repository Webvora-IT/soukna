import { Request, Response, NextFunction } from 'express'
import { z } from 'zod'
import { prisma } from '../lib/prisma'
import { AuthRequest } from '../middleware/auth'
import bcrypt from 'bcryptjs'

const updateProfileSchema = z.object({
  name: z.string().min(2).optional(),
  phone: z.string().optional(),
  avatar: z.string().optional(),
  language: z.string().optional(),
})

const addressSchema = z.object({
  label: z.string().min(1),
  street: z.string().min(2),
  district: z.string().min(2),
  city: z.string().optional().default('Nouakchott'),
  lat: z.number().optional(),
  lng: z.number().optional(),
  isDefault: z.boolean().optional().default(false),
})

export async function getProfile(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user!.id },
      select: {
        id: true, email: true, phone: true, name: true,
        role: true, avatar: true, language: true, isActive: true,
        createdAt: true, updatedAt: true,
        addresses: true,
        _count: { select: { orders: true } },
      },
    })
    if (!user) { res.status(404).json({ success: false, message: 'Utilisateur introuvable' }); return }
    res.json({ success: true, data: user })
  } catch (err) {
    next(err)
  }
}

export async function updateProfile(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const data = updateProfileSchema.parse(req.body)
    const user = await prisma.user.update({
      where: { id: req.user!.id },
      data,
      select: { id: true, email: true, name: true, phone: true, avatar: true, language: true },
    })
    res.json({ success: true, data: user })
  } catch (err) {
    next(err)
  }
}

export async function changePassword(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const { currentPassword, newPassword } = req.body
    if (!currentPassword || !newPassword) {
      res.status(400).json({ success: false, message: 'Mots de passe requis' })
      return
    }
    if (newPassword.length < 6) {
      res.status(400).json({ success: false, message: 'Nouveau mot de passe min 6 caractères' })
      return
    }

    const user = await prisma.user.findUnique({ where: { id: req.user!.id } })
    if (!user) { res.status(404).json({ success: false, message: 'Utilisateur introuvable' }); return }

    const valid = await bcrypt.compare(currentPassword, user.password)
    if (!valid) { res.status(401).json({ success: false, message: 'Mot de passe actuel incorrect' }); return }

    const hashed = await bcrypt.hash(newPassword, 12)
    await prisma.user.update({ where: { id: req.user!.id }, data: { password: hashed } })

    res.json({ success: true, message: 'Mot de passe modifié' })
  } catch (err) {
    next(err)
  }
}

export async function getAddresses(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const addresses = await prisma.address.findMany({
      where: { userId: req.user!.id },
      orderBy: { isDefault: 'desc' },
    })
    res.json({ success: true, data: addresses })
  } catch (err) {
    next(err)
  }
}

export async function createAddress(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const data = addressSchema.parse(req.body)
    if (data.isDefault) {
      await prisma.address.updateMany({ where: { userId: req.user!.id }, data: { isDefault: false } })
    }
    const address = await prisma.address.create({ data: { ...data, userId: req.user!.id } })
    res.status(201).json({ success: true, data: address })
  } catch (err) {
    next(err)
  }
}

export async function updateAddress(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const addr = await prisma.address.findUnique({ where: { id: req.params.id } })
    if (!addr || addr.userId !== req.user!.id) {
      res.status(404).json({ success: false, message: 'Adresse introuvable' }); return
    }
    const data = addressSchema.partial().parse(req.body)
    if (data.isDefault) {
      await prisma.address.updateMany({ where: { userId: req.user!.id }, data: { isDefault: false } })
    }
    const updated = await prisma.address.update({ where: { id: req.params.id }, data })
    res.json({ success: true, data: updated })
  } catch (err) {
    next(err)
  }
}

export async function deleteAddress(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const addr = await prisma.address.findUnique({ where: { id: req.params.id } })
    if (!addr || addr.userId !== req.user!.id) {
      res.status(404).json({ success: false, message: 'Adresse introuvable' }); return
    }
    await prisma.address.delete({ where: { id: req.params.id } })
    res.json({ success: true, message: 'Adresse supprimée' })
  } catch (err) {
    next(err)
  }
}

export async function getNotifications(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const notifications = await prisma.notification.findMany({
      where: { userId: req.user!.id },
      orderBy: { createdAt: 'desc' },
      take: 50,
    })
    res.json({ success: true, data: notifications })
  } catch (err) {
    next(err)
  }
}

export async function markNotificationsRead(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    await prisma.notification.updateMany({
      where: { userId: req.user!.id, isRead: false },
      data: { isRead: true },
    })
    res.json({ success: true, message: 'Notifications marquées comme lues' })
  } catch (err) {
    next(err)
  }
}
