import { get, post, put, del } from '@/utils/request'

export interface GoodsItem {
  id: number
  name: string
  image: string
  price: number
  stock: number
  sales: number
  status: number
  categoryId: number
}

export function getGoodsList(params?: { page?: number; size?: number; keyword?: string; categoryId?: number }) {
  return get<{ list: GoodsItem[]; total: number }>('/admin/goods/list', params)
}

export function getGoodsDetail(id: number) {
  return get(`/admin/goods/detail`, { id })
}

export function saveGoods(data: any) {
  return data.id ? put('/admin/goods/update', data) : post('/admin/goods/add', data)
}

export function deleteGoods(id: number) {
  return del(`/admin/goods/delete?id=${id}`)
}
