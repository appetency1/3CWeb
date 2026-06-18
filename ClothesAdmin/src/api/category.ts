import { get, post, put, del, unwrap } from '@/utils/request'

export function getCategoryList() {
  return get<any>('/admin/category').then(unwrap)
}

export function saveCategory(data: any) {
  if (data.id) {
    return put<any>(`/admin/category/${data.id}`, data).then(unwrap)
  }
  return post<any>('/admin/category', data).then(unwrap)
}

export function deleteCategory(id: number) {
  return del(`/admin/category/${id}`).then(unwrap)
}
