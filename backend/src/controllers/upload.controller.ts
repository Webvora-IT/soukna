import { Response, NextFunction } from 'express'
import { AuthRequest } from '../middleware/auth'
import { uploadImage, uploadMultipleImages, deleteImage } from '../config/cloudinary'

export async function uploadSingleImage(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.file) {
      res.status(400).json({ success: false, message: 'Image requise' })
      return
    }

    const folder = (req.query.folder as string) || 'soukna/misc'
    const result = await uploadImage(req.file.buffer, folder)

    res.json({
      success: true,
      data: { url: result.url, publicId: result.publicId },
    })
  } catch (err) {
    next(err)
  }
}

export async function uploadMultipleImagesHandler(
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const files = req.files as Express.Multer.File[]
    if (!files || files.length === 0) {
      res.status(400).json({ success: false, message: 'Images requises' })
      return
    }

    const folder = (req.query.folder as string) || 'soukna/misc'
    const buffers = files.map((f) => f.buffer)
    const results = await uploadMultipleImages(buffers, folder)

    res.json({ success: true, data: results })
  } catch (err) {
    next(err)
  }
}

export async function deleteImageHandler(
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { publicId } = req.body
    if (!publicId) {
      res.status(400).json({ success: false, message: 'publicId requis' })
      return
    }

    await deleteImage(publicId)
    res.json({ success: true, message: 'Image supprimée' })
  } catch (err) {
    next(err)
  }
}
