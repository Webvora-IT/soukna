import { prisma } from './prisma'
import { getIO } from './socket'

export async function createNotification(data: {
  userId: string
  title: string
  body: string
  type?: string
  data?: Record<string, unknown>
}) {
  try {
    const notification = await prisma.notification.create({
      data: {
        userId: data.userId,
        title: data.title,
        body: data.body,
        type: data.type || 'INFO',
        data: data.data ? JSON.stringify(data.data) : undefined,
      },
    })

    // Push via Socket.io if connected
    try {
      const io = getIO()
      io.to(`user:${data.userId}`).emit('notification', notification)
    } catch {
      // Socket.io not available — silently skip
    }

    return notification
  } catch (err) {
    console.error('Failed to create notification:', err)
  }
}

export async function notifyVendorNewOrder(vendorId: string, orderId: string, storeName: string, total: number) {
  await createNotification({
    userId: vendorId,
    title: '🛒 Nouvelle commande',
    body: `Nouvelle commande de ${total.toFixed(0)} MRU sur ${storeName}`,
    type: 'ORDER',
    data: { orderId },
  })
}

export async function notifyCustomerStatusChange(customerId: string, orderId: string, status: string) {
  const statusLabels: Record<string, string> = {
    CONFIRMED: '✅ Votre commande a été confirmée',
    PREPARING: '👨‍🍳 Votre commande est en préparation',
    READY: '📦 Votre commande est prête à être livrée',
    DELIVERING: '🚚 Votre commande est en route',
    DELIVERED: '🎉 Votre commande a été livrée',
    CANCELLED: '❌ Votre commande a été annulée',
  }

  const message = statusLabels[status]
  if (!message) return

  await createNotification({
    userId: customerId,
    title: 'Mise à jour de commande',
    body: message,
    type: 'ORDER',
    data: { orderId, status },
  })
}
