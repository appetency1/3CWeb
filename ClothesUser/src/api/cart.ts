import { http } from '@/utils/request'
import type { CartItem } from '@/types/model'

export const cartApi = {
  list: () => http<CartItem[]>('/user/cart'),

  add: (data: { skuId: number; quantity: number }) =>
    http<void>('/user/cart', data, { method: 'POST' }),

  updateQty: (id: number, quantity: number) =>
    http<void>(`/user/cart/${id}`, { quantity }, { method: 'PUT' }),

  toggleSelect: (id: number, selected: boolean) =>
    http<void>(`/user/cart/${id}/select`, { selected }, { method: 'PUT' }),

  selectAll: (selected: boolean) =>
    http<void>('/user/cart/select-all', { selected }, { method: 'PUT' }),

  remove: (id: number) => http<void>(`/user/cart/${id}`, undefined, { method: 'DELETE' }),

  removeSelected: () => http<void>('/user/cart/selected', undefined, { method: 'DELETE' }),
}
