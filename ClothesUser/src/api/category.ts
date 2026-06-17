import { http } from '@/utils/request'
import type { Category } from '@/types/model'

export interface CategoryItem {
  id: number
  name: string
  icon?: string
  children?: CategoryItem[]
}

export function getCategoryList() {
  return http<Category[]>('/public/category')
}
