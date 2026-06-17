import { get, post } from '@/utils/request'

export function getOrderList(params?: { page?: number; status?: number }) {
  return get<{ list: any[]; total: number }>('/admin/order/list', params)
}

export function getOrderDetail(id: number) {
  return get(`/admin/order/detail`, { id })
}

export function updateOrderStatus(id: number, status: number) {
  return post('/admin/order/updateStatus', { id, status })
}
