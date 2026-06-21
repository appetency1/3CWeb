const BASE_URL = import.meta.env.VITE_API_BASE || '/api'

interface ApiResponse<T = any> {
  code: number
  message: string
  data: T
}

async function request<T = any>(
  url: string,
  options: RequestInit = {}
): Promise<ApiResponse<T>> {
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(options.headers as Record<string, string>)
  }

  const res = await fetch(`${BASE_URL}${url}`, { ...options, headers, credentials: 'include' })
  if (!res.ok) throw new Error(`HTTP ${res.status}: ${res.statusText}`)
  return res.json()
}

/**
 * 从 ApiResponse 中解出 data，供 view 层直接使用。
 * 后端所有响应格式：{ code, message, data }
 */
export function unwrap<T>(resp: ApiResponse<T>): T {
  if (resp.code !== 0 && resp.code !== 200) {
    throw new Error(resp.message || `请求失败(code=${resp.code})`)
  }
  return resp.data
}

export function get<T = any>(url: string, params?: Record<string, any>) {
  const query = params
    ? '?' + new URLSearchParams(
        Object.entries(params).filter(([_, v]) => v != null).map(([k, v]) => [k, String(v)])
      ).toString()
    : ''
  return request<T>(`${url}${query}`, { method: 'GET' })
}

export function post<T = any>(url: string, data?: any) {
  return request<T>(url, { method: 'POST', body: data ? JSON.stringify(data) : undefined })
}

export function put<T = any>(url: string, data?: any) {
  return request<T>(url, { method: 'PUT', body: data ? JSON.stringify(data) : undefined })
}

export function del<T = any>(url: string) {
  return request<T>(url, { method: 'DELETE' })
}

/** 后端文件上传 */
const UPLOAD_BASE = BASE_URL.replace(/\/api$/, '')

export function uploadFile(file: File): Promise<string> {
  const form = new FormData()
  form.append('file', file)
  return fetch(`${UPLOAD_BASE}/api/public/upload`, { method: 'POST', body: form, credentials: 'include' })
    .then(r => r.json())
    .then((resp: any) => {
      if (resp.code !== 0 && resp.code !== 200) throw new Error(resp.message || '上传失败')
      return resp.data.url  // 返回相对路径如 /uploads/2026/06/19/xxx.jpg
    })
}

/** 根据后端返回的相对路径拼出完整图片 URL */
export function imgUrl(path: string): string {
  if (!path) return ''
  if (path.startsWith('http')) return path
  // 前端静态资源（/assets/）从本机 Vite dev server 加载（proxy → ClothesUser）
  if (path.startsWith('/assets/')) return path
  // 后端上传资源（/uploads/）走后端静态文件服务
  return UPLOAD_BASE + path
}
