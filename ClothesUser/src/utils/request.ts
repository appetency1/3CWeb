import axios, { type AxiosInstance, type AxiosRequestConfig, type InternalAxiosRequestConfig } from 'axios'
import { showToast, showFailToast } from 'vant'
import type { ApiResponse } from '@/types/api'

const instance: AxiosInstance = axios.create({
  baseURL: import.meta.env.VITE_API_BASE,
  timeout: 15000,
  withCredentials: true,
})

instance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  // 如果 localStorage 有 token，优先用 Authorization header
  // 后端 AuthInterceptor 支持 Cookie + Authorization 两种方式
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

instance.interceptors.response.use(
  (res) => {
    const body = res.data as ApiResponse
    if (body && typeof body === 'object' && 'code' in body) {
      if (body.code === 0 || body.code === 200) {
        return body.data as any
      }
      if (body.code === 401 || body.code === 403) {
        showToast('登录已失效')
        if (typeof window !== 'undefined' && window.location.pathname !== '/login') {
          const redirect = encodeURIComponent(window.location.pathname + window.location.search)
          window.location.href = `/login?redirect=${redirect}`
        }
        return Promise.reject(new Error(body.message || '未登录'))
      }
      showFailToast(body.message || '请求失败')
      return Promise.reject(new Error(body.message || `code=${body.code}`))
    }
    return res.data as any
  },
  (err) => {
    const status = err?.response?.status
    // 后端 AuthInterceptor 写的是 HTTP 401 + 业务 message="未登录"/"token失效"
    // 拦截器会同时清 token,后续请求就不会再带坏 token
    if (status === 401) {
      const serverMsg = err?.response?.data?.message
      showToast(serverMsg === 'token失效' ? '登录已失效,请重新登录' : '请先登录')
      // 跳登录页(只在非登录页时跳)
      if (typeof window !== 'undefined' && window.location.pathname !== '/login') {
        const redirect = encodeURIComponent(window.location.pathname + window.location.search)
        window.location.href = `/login?redirect=${redirect}`
      }
      return Promise.reject(err)
    }
    const msg = err?.response?.data?.message || err.message || '网络异常'
    showFailToast(msg)
    return Promise.reject(err)
  }
)

export function request<T = unknown>(config: AxiosRequestConfig): Promise<T> {
  return instance.request<unknown, T>(config)
}

type Method = 'GET' | 'POST' | 'PUT' | 'DELETE'

const httpFn = <T = unknown>(
  url: string,
  params?: object,
  methodOrCfg: Method | AxiosRequestConfig = 'GET',
) => {
  let extra: AxiosRequestConfig = {}
  let method: Method = 'GET'

  if (typeof methodOrCfg === 'string') {
    method = methodOrCfg
  } else {
    extra = methodOrCfg
    method = (methodOrCfg.method as Method) || 'GET'
  }

  const cfg: AxiosRequestConfig = { ...extra, url, method }
  if (method === 'GET') {
    if (params !== undefined) cfg.params = params
  } else {
    if (params !== undefined) cfg.data = params
  }
  return request<T>(cfg)
}

export const http = Object.assign(httpFn, {
  get: <T = unknown>(url: string, params?: Record<string, unknown>, cfg?: AxiosRequestConfig) =>
    request<T>({ ...cfg, url, method: 'GET', params }),
  post: <T = unknown>(url: string, data?: unknown, cfg?: AxiosRequestConfig) =>
    request<T>({ ...cfg, url, method: 'POST', data }),
  put: <T = unknown>(url: string, data?: unknown, cfg?: AxiosRequestConfig) =>
    request<T>({ ...cfg, url, method: 'PUT', data }),
  del: <T = unknown>(url: string, cfg?: AxiosRequestConfig) =>
    request<T>({ ...cfg, url, method: 'DELETE' }),
})

export default instance
