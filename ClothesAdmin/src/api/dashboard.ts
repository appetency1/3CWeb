import { get } from '@/utils/request'

export function getDashboardStats() {
  return get<{
    orderCount: number
    goodsCount: number
    userCount: number
    revenue: number
  }>('/admin/dashboard/stats')
}
