import { get, post, put, del } from '@/utils/request'

export function getBannerList() {
  return get<any[]>('/admin/banner/list')
}

export function saveBanner(data: any) {
  return data.id ? put('/admin/banner/update', data) : post('/admin/banner/add', data)
}

export function deleteBanner(id: number) {
  return del(`/admin/banner/delete?id=${id}`)
}
