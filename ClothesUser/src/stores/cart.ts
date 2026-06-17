import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export interface CartItem {
  id: number
  goodsId: number
  name: string
  image: string
  price: number
  count: number
  sku: string
  checked: boolean
}

export const useCartStore = defineStore('cart', () => {
  const items = ref<CartItem[]>([])

  const totalCount = computed(() => items.value.reduce((sum, i) => sum + i.count, 0))
  const totalPrice = computed(() =>
    items.value
      .filter(i => i.checked)
      .reduce((sum, i) => sum + i.price * i.count, 0)
  )
  const checkedCount = computed(() => items.value.filter(i => i.checked).length)

  function addItem(item: CartItem) {
    const existing = items.value.find(i => i.goodsId === item.goodsId && i.sku === item.sku)
    if (existing) {
      existing.count += item.count
    } else {
      items.value.push({ ...item, checked: true })
    }
  }

  function removeItem(goodsId: number, sku: string) {
    const idx = items.value.findIndex(i => i.goodsId === goodsId && i.sku === sku)
    if (idx > -1) items.value.splice(idx, 1)
  }

  function updateCount(goodsId: number, sku: string, count: number) {
    const item = items.value.find(i => i.goodsId === goodsId && i.sku === sku)
    if (item) item.count = count
  }

  function toggleCheck(goodsId: number, sku: string) {
    const item = items.value.find(i => i.goodsId === goodsId && i.sku === sku)
    if (item) item.checked = !item.checked
  }

  function toggleAll(checked: boolean) {
    items.value.forEach(i => (i.checked = checked))
  }

  function clear() {
    items.value = []
  }

  return {
    items, totalCount, totalPrice, checkedCount,
    addItem, removeItem, updateCount, toggleCheck, toggleAll, clear
  }
})
