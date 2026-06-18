import { get, post, put, del, unwrap } from '@/utils/request'

export function getBannerList() {
  return get<any>('/admin/banner').then(unwrap)
}

export function saveBanner(data: any) {
  if (data.id) {
    return put<any>(`/admin/banner/${data.id}`, data).then(unwrap)
  }
  return post<any>('/admin/banner', data).then(unwrap)
}

export function deleteBanner(id: number) {
  return del(`/admin/banner/${id}`).then(unwrap)
}
