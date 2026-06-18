import { get, put, unwrap } from '@/utils/request'

export function getUserList(params?: { page?: number; keyword?: string; status?: number }) {
  return get<any>('/admin/user', params).then(unwrap)
}

export function getUserDetail(id: number) {
  return get<any>(`/admin/user/${id}`).then(unwrap)
}

export function updateUserStatus(id: number, status: number) {
  return put(`/admin/user/${id}/status?status=${status}`).then(unwrap)
}
