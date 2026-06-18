import { get, post, put, del, unwrap } from '@/utils/request'

export interface GoodsItem {
  id: number
  name: string
  cover: string
  price: number
  stock: number
  sales: number
  status: number
  categoryId: number
}

/** GET /api/admin/goods/ — 列表 */
export function getGoodsList(params?: { page?: number; size?: number; keyword?: string; categoryId?: number; status?: number }) {
  return get<any>('/admin/goods', params).then(unwrap)
}

/** GET /api/admin/goods/{id} — 详情 */
export function getGoodsDetail(id: number) {
  return get<any>(`/admin/goods/${id}`).then(unwrap)
}

/** POST /api/admin/goods/ — 新增 / PUT /api/admin/goods/{id} — 修改 */
export function saveGoods(data: any) {
  if (data.id) {
    return put<any>(`/admin/goods/${data.id}`, data).then(unwrap)
  }
  return post<any>('/admin/goods', data).then(unwrap)
}

/** DELETE /api/admin/goods/{id} */
export function deleteGoods(id: number) {
  return del(`/admin/goods/${id}`).then(unwrap)
}

/** PUT /api/admin/goods/{id}/status */
export function updateGoodsStatus(id: number, status: number) {
  return put(`/admin/goods/${id}/status?status=${status}`).then(unwrap)
}
