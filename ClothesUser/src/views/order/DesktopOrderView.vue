<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { showFailToast } from 'vant'
import { orderApi } from '@/api/order'
import { fullImgUrl } from '@/utils/img'

const router = useRouter()
const active = ref(0)
const tabs = [
  { title: '全部', status: undefined },
  { title: '待付款', status: 0 },
  { title: '待发货', status: 1 },
  { title: '待收货', status: 2 },
  { title: '已完成', status: 3 },
]

const orders = ref<any[]>([])
const loading = ref(false)
const finished = ref(false)
const page = ref(1)
const size = 10

const STATUS_MAP: Record<number, { label: string; cls: string }> = {
  0: { label: '待付款', cls: 'pending' },
  1: { label: '待发货', cls: 'paid' },
  2: { label: '待收货', cls: 'shipped' },
  3: { label: '已完成', cls: 'done' },
  4: { label: '已取消', cls: 'cancelled' },
}

async function fetchOrders() {
  if (loading.value) return
  loading.value = true
  try {
    const data: any = await orderApi.list({ status: tabs[active.value].status, page: page.value, size })
    const list = data?.list || data || []
    if (page.value === 1) orders.value = list
    else orders.value.push(...list)
    finished.value = list.length < size
    page.value++
  } catch (e: any) { showFailToast('加载失败'); finished.value = true }
  finally { loading.value = false }
}

watch(active, () => { page.value = 1; orders.value = []; finished.value = false; fetchOrders() })
onMounted(fetchOrders)
</script>

<template>
  <DesktopLayout>
    <div class="desktop-page-title">我的订单</div>

    <!-- Tabs -->
    <div class="desktop-order-tabs">
      <div
        v-for="(tab, idx) in tabs"
        :key="tab.title"
        class="desktop-order-tab"
        :class="{ active: active === idx }"
        @click="active = idx"
      >{{ tab.title }}</div>
    </div>

    <!-- Empty -->
    <div v-if="!orders.length && !loading" class="desktop-empty">
      <div class="empty-icon"><span>📋</span></div>
      <p>暂无相关订单</p>
    </div>

    <!-- Order List -->
    <div v-else>
      <div v-for="order in orders" :key="order.id" class="desktop-order-card">
        <div class="desktop-order-card-header">
          <span class="desktop-order-no">订单号: {{ order.orderNo }}</span>
          <span class="desktop-order-status" :class="STATUS_MAP[order.status]?.cls">
            {{ STATUS_MAP[order.status]?.label || '未知' }}
          </span>
        </div>

        <div
          v-for="(item, idx) in (order.items || []).slice(0, 3)"
          :key="item.id || idx"
          class="desktop-order-item-row"
          @click="router.push(`/order/${order.id}`)"
        >
          <img :src="fullImgUrl(item.goodsCover)" class="desktop-order-img" />
          <div class="desktop-order-item-info">
            <p class="desktop-order-item-name">{{ item.goodsName }}</p>
            <p class="desktop-order-item-sku">{{ item.spec || '默认规格' }} × {{ item.quantity }}</p>
          </div>
          <div class="desktop-order-item-right">
            <div class="desktop-order-item-price">¥{{ item.price }}</div>
            <div class="desktop-order-item-qty">×{{ item.quantity }}</div>
          </div>
        </div>
        <div v-if="(order.items || []).length > 3" style="padding:6px 16px;font-size:12px;color:var(--text-muted);text-align:right">
          还有 {{ order.items.length - 3 }} 件
        </div>

        <div class="desktop-order-card-footer">
          <div class="desktop-order-total">
            共{{ order.items?.length || 0 }}件 &nbsp; 合计: <strong>¥{{ order.payAmount || order.totalAmount }}</strong>
          </div>
          <div class="desktop-order-actions">
            <button class="desktop-order-action-btn" @click="router.push(`/order/${order.id}`)">查看详情</button>
            <button
              v-if="order.status === 0"
              class="desktop-order-action-btn primary"
            >去付款</button>
            <button
              v-if="order.status === 2"
              class="desktop-order-action-btn primary"
            >确认收货</button>
          </div>
        </div>
      </div>
    </div>
  </DesktopLayout>
</template>
