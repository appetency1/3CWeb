import { http } from '@/utils/request'
import type { PageResult } from '@/types/api'
import type { Banner, Category, Goods, Sku } from '@/types/model'

export const publicApi = {
  banners: () => http<Banner[]>('/public/banner'),

  categories: () => http<Category[]>('/public/category'),

  hotGoods: () => http<Goods[]>('/public/goods/hot'),

  newGoods: () => http<Goods[]>('/public/goods/new'),

  goodsList: (params: { page?: number; size?: number; categoryId?: number; keyword?: string; sort?: string }) =>
    http<PageResult<Goods>>('/public/goods', params),

  goodsDetail: (id: number) => http<{ goods: Goods; skus: Sku[] }>(`/public/goods/${id}`),

  comments: (goodsId: number, params: { page?: number; size?: number }) =>
    http<PageResult<any>>('/public/comment', { goodsId, ...params }),

  upload: (formData: FormData, onProgress?: (e: ProgressEvent) => void) =>
    http<{ url: string }>('/public/upload', undefined, {
      method: 'POST',
      data: formData,
      headers: { 'Content-Type': 'multipart/form-data' },
      onUploadProgress: onProgress as any,
    }),
}
