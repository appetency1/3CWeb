import { http } from '@/utils/request'
import type { PageResult } from '@/types/api'
import type { GoodsItem, GoodsDetail } from '@/types/model'

/** 获取商品列表 */
export function getGoodsList(params?: { categoryId?: number; keyword?: string; page?: number; size?: number }) {
  return http<PageResult<GoodsItem>>('/public/goods', params)
}

/** 获取商品详情 */
export function getGoodsDetail(id: number) {
  return http<GoodsDetail>(`/public/goods/${id}`)
}

/** 搜索商品 */
export function searchGoods(keyword: string) {
  // 后端始终返回分页结构 PageResult
  return http<PageResult<GoodsItem>>('/public/goods', { keyword, size: 50 })
}
