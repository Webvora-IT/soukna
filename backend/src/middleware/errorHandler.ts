import { Request, Response, NextFunction } from 'express'
import { ZodError } from 'zod'

export interface AppError extends Error {
  statusCode?: number
  code?: string
}

export function errorHandler(
  err: AppError,
  req: Request,
  res: Response,
  _next: NextFunction
): void {
  console.error(`[ERROR] ${req.method} ${req.path}:`, err.message)

  // Zod validation errors
  if (err instanceof ZodError) {
    res.status(400).json({
      success: false,
      message: 'Données invalides',
      errors: err.errors.map((e) => ({ field: e.path.join('.'), message: e.message })),
    })
    return
  }

  // Prisma errors
  if (err.code === 'P2002') {
    res.status(409).json({
      success: false,
      message: 'Cette ressource existe déjà',
    })
    return
  }

  if (err.code === 'P2025') {
    res.status(404).json({
      success: false,
      message: 'Ressource introuvable',
    })
    return
  }

  // Default
  const statusCode = err.statusCode || 500
  const message =
    process.env.NODE_ENV === 'production' && statusCode === 500
      ? 'Erreur interne du serveur'
      : err.message || 'Erreur interne du serveur'

  res.status(statusCode).json({ success: false, message })
}

export function notFound(req: Request, res: Response): void {
  res.status(404).json({
    success: false,
    message: `Route ${req.method} ${req.path} introuvable`,
  })
}

export function createError(message: string, statusCode: number): AppError {
  const err: AppError = new Error(message)
  err.statusCode = statusCode
  return err
}
