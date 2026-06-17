import { http } from '@/utils/request'
import type { Order } from '@/types/model'
import type { PageResult } from '@/types/api'

export interface CreateOrderParams {
  addressId: number
  cartIds: number[]
  remark?: string
}

export const orderApi = {
  create: (data: CreateOrderParams) =>
    http<{ orderId: number; orderNo: string }>('/user/order', data, { method: 'POST' }),

  list: (params: { status?: number; page?: number; size?: number }) =>
    http<PageResult<Order>>('/user/order', params),

  detail: (id: number) => http<Order>(`/user/order/${id}`),

  pay: (id: number) => http<void>(`/user/order/${id}/pay`, undefined, { method: 'POST' }),

  cancel: (id: number) => http<void>(`/user/order/${id}/cancel`, undefined, { method: 'POST' }),

  confirm: (id: number) => http<void>(`/user/order/${id}/confirm`, undefined, { method: 'POST' }),
}
