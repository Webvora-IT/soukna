import nodemailer from 'nodemailer'

const FROM = process.env.SMTP_FROM || 'SOUKNA <noreply@soukna.mr>'
const BASE_URL = process.env.BASE_URL || 'http://localhost:5173'

let transporter: nodemailer.Transporter | null = null

function getTransporter() {
  if (!process.env.SMTP_USER || !process.env.SMTP_PASS) return null
  if (!transporter) {
    transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST || 'smtp.gmail.com',
      port: parseInt(process.env.SMTP_PORT || '587'),
      secure: process.env.SMTP_SECURE === 'true',
      auth: { user: process.env.SMTP_USER, pass: process.env.SMTP_PASS },
    })
  }
  return transporter
}

const STATUS_LABELS_FR: Record<string, { label: string; emoji: string; color: string }> = {
  CONFIRMED:  { label: 'Confirmée',        emoji: '✅', color: '#059669' },
  PREPARING:  { label: 'En préparation',   emoji: '👨‍🍳', color: '#d97706' },
  READY:      { label: 'Prête à livrer',   emoji: '📦', color: '#7c3aed' },
  DELIVERING: { label: 'En livraison',     emoji: '🚚', color: '#0ea5e9' },
  DELIVERED:  { label: 'Livrée',           emoji: '🎉', color: '#059669' },
  CANCELLED:  { label: 'Annulée',          emoji: '❌', color: '#dc2626' },
}

const STATUS_LABELS_AR: Record<string, { label: string }> = {
  CONFIRMED:  { label: 'تم التأكيد' },
  PREPARING:  { label: 'جاري التحضير' },
  READY:      { label: 'جاهزة للتسليم' },
  DELIVERING: { label: 'جاري التوصيل' },
  DELIVERED:  { label: 'تم التسليم' },
  CANCELLED:  { label: 'ملغية' },
}

export async function sendOrderConfirmation(data: {
  customerEmail: string
  customerName: string
  orderId: string
  storeName: string
  total: number
  items: Array<{ name: string; quantity: number; price: number }>
}): Promise<void> {
  const t = getTransporter()
  if (!t) return

  const itemsHtml = data.items.map(i =>
    `<tr>
      <td style="padding:8px 0;color:#374151;font-size:14px;">${i.name}</td>
      <td style="padding:8px 0;color:#6b7280;font-size:14px;text-align:center;">x${i.quantity}</td>
      <td style="padding:8px 0;color:#f59e0b;font-size:14px;text-align:right;font-weight:600;">${(i.price * i.quantity).toFixed(0)} MRU</td>
    </tr>`
  ).join('')

  const html = `
<!DOCTYPE html>
<html lang="fr">
<head><meta charset="UTF-8"></head>
<body style="margin:0;padding:0;background:#0f0f1a;font-family:Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#0f0f1a;padding:40px 16px;">
    <tr><td align="center">
      <table width="560" cellpadding="0" cellspacing="0" style="background:#1a1a2e;border-radius:16px;overflow:hidden;border:1px solid rgba(245,158,11,0.2);">
        <tr>
          <td style="background:linear-gradient(135deg,#f59e0b,#d97706);padding:28px 32px;text-align:center;">
            <span style="color:#0f0f1a;font-size:24px;font-weight:800;letter-spacing:1px;">سوقنا SOUKNA</span>
          </td>
        </tr>
        <tr>
          <td style="padding:32px;">
            <h2 style="margin:0 0 8px;color:#f59e0b;font-size:20px;">✅ Commande reçue !</h2>
            <p style="margin:0 0 20px;color:#9ca3af;font-size:14px;">Bonjour <strong style="color:#fff;">${data.customerName}</strong>, votre commande a été transmise à <strong style="color:#f59e0b;">${data.storeName}</strong>.</p>

            <div style="background:rgba(245,158,11,0.08);border:1px solid rgba(245,158,11,0.2);border-radius:12px;padding:16px;margin-bottom:20px;">
              <p style="margin:0 0 4px;color:#6b7280;font-size:12px;">Référence commande</p>
              <p style="margin:0;color:#f59e0b;font-size:14px;font-weight:700;font-family:monospace;">#${data.orderId.slice(-8).toUpperCase()}</p>
            </div>

            <table width="100%" style="margin-bottom:20px;">
              <thead><tr style="border-bottom:1px solid rgba(255,255,255,0.1);">
                <th style="padding:8px 0;color:#6b7280;font-size:12px;text-align:left;">Produit</th>
                <th style="padding:8px 0;color:#6b7280;font-size:12px;text-align:center;">Qté</th>
                <th style="padding:8px 0;color:#6b7280;font-size:12px;text-align:right;">Prix</th>
              </tr></thead>
              <tbody>${itemsHtml}</tbody>
              <tfoot><tr style="border-top:1px solid rgba(255,255,255,0.1);">
                <td colspan="2" style="padding:12px 0;color:#fff;font-weight:700;">Total</td>
                <td style="padding:12px 0;color:#f59e0b;font-size:18px;font-weight:800;text-align:right;">${data.total.toFixed(0)} MRU</td>
              </tr></tfoot>
            </table>

            <div style="text-align:center;margin-top:24px;">
              <a href="${BASE_URL}" style="display:inline-block;background:linear-gradient(135deg,#f59e0b,#d97706);color:#0f0f1a;padding:14px 32px;border-radius:50px;font-weight:700;text-decoration:none;font-size:14px;">
                Suivre ma commande
              </a>
            </div>
          </td>
        </tr>
        <tr><td style="padding:16px;border-top:1px solid rgba(255,255,255,0.05);text-align:center;">
          <p style="margin:0;color:#4b5563;font-size:12px;">© ${new Date().getFullYear()} SOUKNA — سوقنا</p>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body></html>`

  await t.sendMail({
    from: FROM,
    to: data.customerEmail,
    subject: `✅ Commande #${data.orderId.slice(-8).toUpperCase()} reçue – SOUKNA`,
    html,
  })
}

export async function sendPasswordResetEmail(data: {
  email: string
  name: string
  token: string
  locale?: string
}): Promise<void> {
  const t = getTransporter()
  if (!t) return

  const resetUrl = `${BASE_URL}/reset-password?token=${data.token}`

  const html = `
<!DOCTYPE html>
<html lang="fr">
<head><meta charset="UTF-8"></head>
<body style="margin:0;padding:0;background:#0f0f1a;font-family:Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#0f0f1a;padding:40px 16px;">
    <tr><td align="center">
      <table width="560" cellpadding="0" cellspacing="0" style="background:#1a1a2e;border-radius:16px;overflow:hidden;border:1px solid rgba(245,158,11,0.2);">
        <tr><td style="background:linear-gradient(135deg,#f59e0b,#d97706);padding:28px 32px;text-align:center;">
          <span style="color:#0f0f1a;font-size:24px;font-weight:800;letter-spacing:1px;">سوقنا SOUKNA</span>
        </td></tr>
        <tr>
          <td style="padding:32px;">
            <h2 style="margin:0 0 8px;color:#f59e0b;font-size:20px;">🔐 Réinitialisation de mot de passe</h2>
            <p style="margin:0 0 16px;color:#9ca3af;font-size:14px;">Bonjour <strong style="color:#fff;">${data.name}</strong>,</p>
            <p style="margin:0 0 24px;color:#9ca3af;font-size:14px;line-height:1.6;">
              Vous avez demandé à réinitialiser votre mot de passe. Cliquez sur le bouton ci-dessous.<br>
              Ce lien est valable <strong style="color:#f59e0b;">1 heure</strong>.
            </p>
            <div style="text-align:center;margin:24px 0;">
              <a href="${resetUrl}" style="display:inline-block;background:linear-gradient(135deg,#f59e0b,#d97706);color:#0f0f1a;padding:14px 32px;border-radius:50px;font-weight:700;text-decoration:none;font-size:14px;">
                Réinitialiser mon mot de passe
              </a>
            </div>
            <p style="margin:24px 0 0;color:#4b5563;font-size:12px;">Si vous n'avez pas fait cette demande, ignorez cet email.</p>
          </td>
        </tr>
        <tr><td style="padding:16px;border-top:1px solid rgba(255,255,255,0.05);text-align:center;">
          <p style="margin:0;color:#4b5563;font-size:12px;">© ${new Date().getFullYear()} SOUKNA — سوقنا</p>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body></html>`

  await t.sendMail({
    from: FROM,
    to: data.email,
    subject: '🔐 Réinitialisation de mot de passe – SOUKNA',
    html,
  })
}

export async function sendWelcomeEmail(data: {
  email: string
  name: string
}): Promise<void> {
  const t = getTransporter()
  if (!t) return

  const html = `
<!DOCTYPE html>
<html lang="fr">
<head><meta charset="UTF-8"></head>
<body style="margin:0;padding:0;background:#0f0f1a;font-family:Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#0f0f1a;padding:40px 16px;">
    <tr><td align="center">
      <table width="560" cellpadding="0" cellspacing="0" style="background:#1a1a2e;border-radius:16px;overflow:hidden;border:1px solid rgba(245,158,11,0.2);">
        <tr><td style="background:linear-gradient(135deg,#f59e0b,#d97706);padding:28px 32px;text-align:center;">
          <span style="color:#0f0f1a;font-size:24px;font-weight:800;letter-spacing:1px;">سوقنا SOUKNA</span>
        </td></tr>
        <tr>
          <td style="padding:32px;text-align:center;">
            <div style="font-size:48px;margin-bottom:16px;">🎉</div>
            <h2 style="margin:0 0 8px;color:#f59e0b;font-size:22px;">Bienvenue sur SOUKNA !</h2>
            <p style="margin:0 0 8px;color:#9ca3af;font-size:14px;direction:rtl;">أهلاً بك في سوقنا!</p>
            <p style="margin:16px 0 24px;color:#9ca3af;font-size:14px;line-height:1.7;">
              Bonjour <strong style="color:#fff;">${data.name}</strong>,<br>
              Votre compte a été créé avec succès. Découvrez les meilleurs commerces de Nouakchott et commandez en quelques clics !
            </p>
            <a href="${BASE_URL}" style="display:inline-block;background:linear-gradient(135deg,#f59e0b,#d97706);color:#0f0f1a;padding:14px 32px;border-radius:50px;font-weight:700;text-decoration:none;font-size:14px;">
              Explorer SOUKNA
            </a>
          </td>
        </tr>
        <tr><td style="padding:16px;border-top:1px solid rgba(255,255,255,0.05);text-align:center;">
          <p style="margin:0;color:#4b5563;font-size:12px;">© ${new Date().getFullYear()} SOUKNA — سوقنا</p>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body></html>`

  await t.sendMail({
    from: FROM,
    to: data.email,
    subject: '🎉 Bienvenue sur SOUKNA — سوقنا',
    html,
  })
}

export async function sendOrderStatusUpdate(data: {
  customerEmail: string
  customerName: string
  orderId: string
  storeName: string
  status: string
}): Promise<void> {
  const t = getTransporter()
  if (!t) return

  const info = STATUS_LABELS_FR[data.status]
  const infoAr = STATUS_LABELS_AR[data.status]
  if (!info) return

  const html = `
<!DOCTYPE html>
<html lang="fr">
<head><meta charset="UTF-8"></head>
<body style="margin:0;padding:0;background:#0f0f1a;font-family:Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#0f0f1a;padding:40px 16px;">
    <tr><td align="center">
      <table width="560" cellpadding="0" cellspacing="0" style="background:#1a1a2e;border-radius:16px;overflow:hidden;border:1px solid rgba(245,158,11,0.2);">
        <tr><td style="background:linear-gradient(135deg,#f59e0b,#d97706);padding:24px 32px;text-align:center;">
          <span style="color:#0f0f1a;font-size:22px;font-weight:800;">سوقنا SOUKNA</span>
        </td></tr>
        <tr>
          <td style="padding:32px;text-align:center;">
            <div style="font-size:48px;margin-bottom:16px;">${info.emoji}</div>
            <h2 style="margin:0 0 8px;color:#fff;font-size:22px;">${info.label}</h2>
            <p style="margin:0 0 4px;color:#9ca3af;font-size:14px;direction:rtl;">${infoAr?.label || ''}</p>
            <p style="margin:16px 0;color:#6b7280;font-size:14px;">
              Bonjour <strong style="color:#fff;">${data.customerName}</strong>,<br>
              Votre commande chez <strong style="color:#f59e0b;">${data.storeName}</strong> est maintenant <strong style="color:${info.color};">${info.label.toLowerCase()}</strong>.
            </p>
            <div style="background:rgba(245,158,11,0.08);border-radius:12px;padding:12px;display:inline-block;margin:8px 0;">
              <p style="margin:0;color:#f59e0b;font-size:13px;font-family:monospace;">#${data.orderId.slice(-8).toUpperCase()}</p>
            </div>
            <div style="margin-top:24px;">
              <a href="${BASE_URL}" style="display:inline-block;background:linear-gradient(135deg,#f59e0b,#d97706);color:#0f0f1a;padding:14px 32px;border-radius:50px;font-weight:700;text-decoration:none;font-size:14px;">
                Voir ma commande
              </a>
            </div>
          </td>
        </tr>
        <tr><td style="padding:16px;border-top:1px solid rgba(255,255,255,0.05);text-align:center;">
          <p style="margin:0;color:#4b5563;font-size:12px;">© ${new Date().getFullYear()} SOUKNA — سوقنا</p>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body></html>`

  await t.sendMail({
    from: FROM,
    to: data.customerEmail,
    subject: `${info.emoji} Commande #${data.orderId.slice(-8).toUpperCase()} — ${info.label} – SOUKNA`,
    html,
  })
}
