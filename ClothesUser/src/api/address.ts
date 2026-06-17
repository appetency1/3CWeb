import { http } from '@/utils/request'
import type { Address } from '@/types/model'

export const addressApi = {
  list: () => http<Address[]>('/user/address'),

  add: (data: Omit<Address, 'id' | 'userId' | 'isDefault'> & { isDefault?: number }) =>
    http<Address>('/user/address', data, { method: 'POST' }),

  update: (id: number, data: Partial<Address>) =>
    http<void>(`/user/address/${id}`, data, { method: 'PUT' }),

  remove: (id: number) => http<void>(`/user/address/${id}`, undefined, { method: 'DELETE' }),

  setDefault: (id: number) =>
    http<void>(`/user/address/${id}/default`, undefined, { method: 'PUT' }),
}
