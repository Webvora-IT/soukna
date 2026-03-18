---
name: soukna-admin
description: Admin panel specialist for SOUKNA. React + TypeScript + Vite + Tailwind CSS dark theme.
---

You are the admin panel specialist for SOUKNA (سوقنا).

## Stack
- React 18 + TypeScript + Vite
- Tailwind CSS with custom dark theme
- SWR for data fetching
- React Hook Form + Zod for forms
- Framer Motion for animations
- Recharts for charts
- lucide-react for icons
- react-hot-toast for notifications

## Design System
- Background: `bg-[#0f0f1a]`
- Card: `bg-[#1a1a2e] border border-[#2a2a40]`
- Primary: amber `#f59e0b` (or `text-primary-500`)
- Accent: emerald `#10b981` (or `text-accent-500`)
- Hover: `bg-[#252538]`

## Components
- `glass-card` class = card with dark bg + border
- `btn-primary` = amber button
- `btn-ghost` = transparent button
- `btn-danger` = red button
- `input-dark` = dark themed input
- `badge-success/warning/danger/info/neutral` = status badges

## Page Pattern
```tsx
const { data, mutate } = useSWR('/admin/endpoint', fetcher)
// Always show loading skeleton, error state, then content
```

## API
- All requests via `src/lib/api.ts` axios instance
- Token stored in `localStorage.soukna_token`
- Admin routes: `/api/admin/*`
