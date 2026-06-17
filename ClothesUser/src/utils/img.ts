const IMG_BASE = import.meta.env.VITE_IMG_BASE || ''

// Local frontend asset paths — serve directly from / (public folder)
// Includes banners, products, placeholders, icons, brand assets, etc.
const LOCAL_PREFIXES = ['/assets/']
const PLACEHOLDER = '/assets/placeholders/product-placeholder.svg'

export function fullImgUrl(path?: string | null): string {
  if (!path) return PLACEHOLDER
  if (/^(https?:|data:|blob:)/i.test(path)) return path
  // Local frontend assets: serve as-is from public folder
  if (LOCAL_PREFIXES.some(p => path.startsWith(p))) return path
  // Backend-uploaded images: prepend image base URL
  const base = IMG_BASE.replace(/\/+$/, '')
  const p = path.startsWith('/') ? path : '/' + path
  return base + p
}

export const IMG_PLACEHOLDER = PLACEHOLDER
