import { http } from '@/utils/request'
import type { LoginVO, UserInfo } from '@/types/model'

export const userApi = {
  login: (data: { username: string; password: string }) =>
    http<LoginVO>('/user/login', data, { method: 'POST' }),

  register: (data: { username: string; password: string; phone?: string; nickname?: string }) =>
    http<void>('/user/register', data, { method: 'POST' }),

  info: () => http<UserInfo>('/user/info'),

  updateInfo: (data: Partial<UserInfo>) =>
    http<void>('/user/info', data, { method: 'PUT' }),

  changePassword: (data: { oldPassword: string; newPassword: string }) =>
    http<void>('/user/password', data, { method: 'PUT' }),

  createComment: (data: { orderId: number; goodsId: number; content: string; rating: number; images?: string[] }) =>
    http<void>('/user/comment', data, { method: 'POST' }),

  deactivateAccount: (data: { password: string }) =>
    http<void>('/user/deactivate', data, { method: 'POST' }),
}
