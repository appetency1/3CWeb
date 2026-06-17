import { get, post, put, del } from '@/utils/request'

export function getCategoryList() {
  return get<any[]>('/admin/category/list')
}

export function saveCategory(data: any) {
  return data.id ? put('/admin/category/update', data) : post('/admin/category/add', data)
}

export function deleteCategory(id: number) {
  return del(`/admin/category/delete?id=${id}`)
}
