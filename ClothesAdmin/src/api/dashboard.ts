import { get, unwrap } from '@/utils/request'

export function getDashboardStats() {
  return get<any>('/admin/dashboard').then(unwrap)
}
