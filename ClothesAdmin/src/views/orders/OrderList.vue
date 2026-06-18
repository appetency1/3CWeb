<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import { showFailToast, showConfirmDialog } from 'vant'
import { getOrderList, shipOrder, refundOrder } from '@/api/order'

const orders = ref<any[]>([])
const loading = ref(false)
const active = ref(0)
const page = ref(1)
const size = 20
const finished = ref(false)

const tabs = ['全部', '待付款', '待发货', '待收货', '已完成']
const statusMap: Record<number, string> = { 0: '待付款', 1: '待发货', 2: '待收货', 3: '已完成', 4: '已取消' }

async function fetchOrders(append = false) {
  if (loading.value) return
  loading.value = true
  try {
    const status = active.value === 0 ? undefined : active.value - 1
    const res = await getOrderList({ page: page.value, size, status })
    const list = res?.list || res || []
    if (Array.isArray(list)) {
      orders.value = append ? [...orders.value, ...list] : list
    }
    finished.value = (list?.length || 0) < size
    page.value++
  } catch (e: any) {
    showFailToast(e?.message || '加载失败')
  } finally {
    loading.value = false
  }
}

async function onShip(id: number) {
  try {
    await showConfirmDialog({ message: '确定发货？' })
    await shipOrder(id)
    await fetchOrders()
  } catch { /* */ }
}

async function onRefund(id: number) {
  try {
    await showConfirmDialog({ message: '确定退款？' })
    await refundOrder(id)
    await fetchOrders()
  } catch { /* */ }
}

watch(active, () => {
  page.value = 1
  orders.value = []
  finished.value = false
  fetchOrders()
})

onMounted(() => fetchOrders())
</script>

<template>
  <div class="order-list">
    <van-nav-bar title="订单管理" />

    <van-tabs v-model:active="active">
      <van-tab v-for="(tab, idx) in tabs" :key="idx" :title="tab">
        <van-cell
          v-for="order in orders"
          :key="order.id"
        >
          <template #title>
            <span>{{ order.orderNo }}</span>
            <van-tag style="margin-left: 8px">{{ statusMap[order.status] || '未知' }}</van-tag>
          </template>
          <template #label>
            ¥{{ order.totalAmount || order.payAmount }} | {{ order.createTime }}
          </template>
          <template #extra>
            <van-button
              v-if="order.status === 1"
              size="mini" type="primary" plain
              @click.stop="onShip(order.id)"
            >发货</van-button>
            <van-button
              v-if="order.status === 1 || order.status === 2"
              size="mini" type="danger" plain
              style="margin-left: 6px"
              @click.stop="onRefund(order.id)"
            >退款</van-button>
          </template>
        </van-cell>
        <van-empty v-if="orders.length === 0" :description="`暂无${tab}订单`" />
        <van-loading v-if="loading" size="20" style="padding: 20px; text-align: center">加载中...</van-loading>
      </van-tab>
    </van-tabs>
  </div>
</template>
