import { get, del } from '@/utils/request'

export function getUserList(params?: { page?: number; keyword?: string }) {
  return get<{ list: any[]; total: number }>('/admin/user/list', params)
}

export function deleteUser(id: number) {
  return del(`/admin/user/delete?id=${id}`)
}
