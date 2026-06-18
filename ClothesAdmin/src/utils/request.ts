const BASE_URL = 'http://localhost:8080/ClothesBack_war/api'

interface ApiResponse<T = any> {
  code: number
  message: string
  data: T
}

async function request<T = any>(
  url: string,
  options: RequestInit = {}
): Promise<ApiResponse<T>> {
  const token = localStorage.getItem('admin_token')

  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(options.headers as Record<string, string>)
  }
  if (token) headers['Authorization'] = 'Bearer ' + token

  const res = await fetch(`${BASE_URL}${url}`, { ...options, headers })
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
