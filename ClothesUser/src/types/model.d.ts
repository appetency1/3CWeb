export interface Banner {
  id: number
  title: string
  image: string
  link?: string
  sort?: number
  status: number
}

export interface Category {
  id: number
  parentId: number
  name: string
  icon?: string
  sort?: number
  status: number
  children?: Category[]
}

export interface Sku {
  id: number
  goodsId: number
  spec: string | Record<string, string>
  price: number
  stock: number
  sales: number
  image?: string
  sort?: number
}

export interface Goods {
  id: number
  categoryId: number
  name: string
  brand?: string
  cover: string
  images?: string[]
  description?: string
  detail?: string
  price: number
  originalPrice?: number
  stock: number
  sales: number
  viewCount?: number
  status: number
  isHot?: number
  isNew?: number
  skus?: Sku[]
}

export type GoodsItem = Pick<Goods, 'id' | 'name' | 'cover' | 'price' | 'originalPrice' | 'sales' | 'categoryId'>
export type GoodsDetail = Pick<Goods, 'id' | 'name' | 'images' | 'price' | 'originalPrice' | 'description' | 'sales' | 'categoryId' | 'skus'> & { detail: string }

export interface Address {
  id: number
  userId: number
  receiver: string
  phone: string
  province: string
  city: string
  district: string
  detail: string
  isDefault: number
  tag?: string
}

export interface CartItem {
  id: number
  goodsId: number
  skuId: number
  goodsName: string
  goodsCover: string
  spec: string
  price: number
  quantity: number
  selected: number
  stock?: number
}

export interface OrderItem {
  id: number
  goodsId: number
  skuId: number
  goodsName: string
  goodsCover: string
  spec: string
  price: number
  quantity: number
  subtotal: number
}

export interface Order {
  id: number
  orderNo: string
  totalAmount: number
  payAmount: number
  freightAmount: number
  discountAmount: number
  receiver: string
  phone: string
  address: string
  remark?: string
  status: number
  payTime?: string
  shipTime?: string
  finishTime?: string
  cancelTime?: string
  createTime: string
  items: OrderItem[]
}

export interface UserInfo {
  id: number
  username: string
  nickname: string
  avatar: string
  phone?: string
  email?: string
  gender?: number
  birthday?: string
  status?: number
}

export interface LoginVO {
  userInfo: UserInfo
}
