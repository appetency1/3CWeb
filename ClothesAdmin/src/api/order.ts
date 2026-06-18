import { get, post, unwrap } from '@/utils/request'

export function getOrderList(params?: { page?: number; status?: number; keyword?: string }) {
  return get<any>('/admin/order', params).then(unwrap)
}

export function getOrderDetail(id: number) {
  return get<any>(`/admin/order/${id}`).then(unwrap)
}

export function shipOrder(id: number) {
  return post(`/admin/order/${id}/ship`).then(unwrap)
}

export function refundOrder(id: number) {
  return post(`/admin/order/${id}/refund`).then(unwrap)
}
