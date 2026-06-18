import { http } from '@/utils/request'
import type { PageResult } from '@/types/api'

export interface FavoriteItem {
  id: number
  goodsId: number
  name: string
  cover: string
  price: number
  createdAt: string
}

export const favoriteApi = {
  list: (page = 1, size = 20) =>
    http<PageResult<FavoriteItem>>('/user/favorite', { page, size }),

  add: (goodsId: number) =>
    http<void>('/user/favorite', { goodsId }, { method: 'POST' }),

  remove: (goodsId: number) =>
    http<void>(`/user/favorite/${goodsId}`, undefined, { method: 'DELETE' }),
}
