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
const refreshing = ref(false)
const page = ref(1)
const size = 10

const STATUS_MAP: Record<number, { label: string; color: string; bg: string }> = {
  0: { label: '待付款', color: 'var(--cl-orange)', bg: 'rgba(217,124,46,0.1)' },
  1: { label: '待发货', color: 'var(--cl-blue)', bg: 'rgba(74,122,181,0.1)' },
  2: { label: '待收货', color: 'var(--cl-primary)', bg: 'rgba(26,26,46,0.08)' },
  3: { label: '已完成', color: 'var(--cl-green)', bg: 'rgba(74,157,110,0.1)' },
  4: { label: '已取消', color: 'var(--cl-text-muted)', bg: 'rgba(158,152,144,0.1)' },
}

function getStatusConf(status: number) {
  return STATUS_MAP[status] || { label: '未知', color: 'var(--cl-text-muted)', bg: 'rgba(158,152,144,0.1)' }
}

async function fetchOrders() {
  if (loading.value) return
  loading.value = true
  try {
    const status = tabs[active.value].status
    const data: any = await orderApi.list({ status, page: page.value, size })
    const list = data?.list || data || []
    if (page.value === 1) orders.value = list
    else orders.value.push(...list)
    finished.value = list.length < size
    page.value++
  } catch (e: any) {
    showFailToast('加载失败')
    finished.value = true
  } finally {
    loading.value = false
    refreshing.value = false
  }
}

async function onRefresh() {
  page.value = 1
  orders.value = []
  finished.value = false
  await fetchOrders()
}

function goDetail(id: number) {
  router.push({ name: 'orderDetail', params: { id } })
}

watch(active, () => {
  page.value = 1
  orders.value = []
  finished.value = false
  fetchOrders()
})

onMounted(fetchOrders)
</script>

<template>
  <div class="order-page">
    <van-nav-bar title="我的订单" left-arrow @click-left="router.back()" />

    <van-tabs v-model:active="active" sticky swipe-threshold="4">
      <van-tab v-for="tab in tabs" :key="tab.title" :title="tab.title">
        <!-- Pull Refresh -->
        <van-pull-refresh v-model="refreshing" @refresh="onRefresh">
          <!-- Empty -->
          <div v-if="!orders.length && !loading" class="empty-orders">
            <div class="empty-icon">📦</div>
            <p class="empty-title">暂无相关订单</p>
            <p class="empty-sub">快去逛逛商城吧</p>
            <van-button type="primary" round size="small" @click="router.push('/')" class="empty-btn">
              逛逛商城
            </van-button>
          </div>

          <!-- Order List -->
          <div v-else class="order-list">
            <div
              v-for="order in orders"
              :key="order.id"
              class="order-card"
              @click="goDetail(order.id)"
            >
              <!-- Order Header -->
              <div class="order-header">
                <span class="order-no">订单号: {{ order.orderNo }}</span>
                <span
                  class="order-status"
                  :style="{ color: getStatusConf(order.status).color, background: getStatusConf(order.status).bg }"
                >
                  {{ getStatusConf(order.status).label }}
                </span>
              </div>

              <!-- Order Items -->
              <div
                v-for="(item, idx) in (order.items || []).slice(0, 3)"
                :key="item.id || idx"
                class="order-item"
              >
                <img :src="fullImgUrl(item.goodsCover)" class="order-item-img" />
                <div class="order-item-info">
                  <p class="order-item-name">{{ item.goodsName }}</p>
                  <p class="order-item-sku">{{ item.spec || '默认规格' }} x {{ item.quantity }}</p>
                </div>
                <div class="order-item-right">
                  <span class="order-item-price">¥{{ item.price }}</span>
                </div>
              </div>
              <div v-if="(order.items || []).length > 3" class="order-more">
                还有 {{ order.items.length - 3 }} 件商品
              </div>

              <!-- Order Footer -->
              <div class="order-footer">
                <div class="order-time">{{ order.createTime?.substring(0, 16) || '' }}</div>
                <div class="order-total">
                  共{{ order.items?.length || 0 }}件 合计:
                  <span class="total-amount">¥{{ order.payAmount || order.totalAmount }}</span>
                </div>
              </div>

              <!-- Action Buttons -->
              <div class="order-actions" @click.stop>
                <van-button
                  v-if="order.status === 0"
                  size="small"
                  plain
                  round
                  @click="goDetail(order.id)"
                >去付款</van-button>
                <van-button
                  v-if="order.status === 2"
                  size="small"
                  type="primary"
                  round
                  @click="() => { orderApi.confirm(order.id); goDetail(order.id) }"
                >确认收货</van-button>
              </div>
            </div>
          </div>

          <van-list
            v-model:loading="loading"
            :finished="finished"
            finished-text="— 没有更多了 —"
            @load="fetchOrders"
          />
        </van-pull-refresh>
      </van-tab>
    </van-tabs>
  </div>
</template>

<style scoped>
.order-page {
  min-height: 100vh;
  background: var(--cl-bg);
  padding-bottom: env(safe-area-inset-bottom);
}

/* Empty */
.empty-orders {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 80px 24px 40px;
}
.empty-icon { font-size: 64px; opacity: 0.4; margin-bottom: 16px; }
.empty-title { font-size: 16px; font-weight: 600; color: var(--cl-text-primary); margin-bottom: 6px; }
.empty-sub { font-size: 13px; color: var(--cl-text-muted); margin-bottom: 20px; }
.empty-btn {
  background: var(--cl-primary) !important;
  border-color: var(--cl-primary) !important;
}

/* Order List */
.order-list {
  padding: 12px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.order-card {
  background: var(--cl-bg-card);
  border-radius: var(--radius-lg);
  overflow: hidden;
  box-shadow: var(--shadow-xs);
  cursor: pointer;
  transition: transform var(--transition-fast);
}
.order-card:active {
  transform: scale(0.99);
}
.order-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 14px 10px;
  border-bottom: 1px solid var(--cl-border-light);
}
.order-no {
  font-size: 12px;
  color: var(--cl-text-muted);
}
.order-status {
  font-size: 12px;
  font-weight: 600;
  padding: 2px 8px;
  border-radius: var(--radius-full);
}

.order-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 14px;
  border-bottom: 1px solid var(--cl-border-light);
}
.order-item:last-of-type {
  border-bottom: none;
}
.order-item-img {
  width: 60px;
  height: 60px;
  border-radius: var(--radius-sm);
  object-fit: cover;
  background: var(--cl-bg-muted);
  flex-shrink: 0;
}
.order-item-info {
  flex: 1;
  min-width: 0;
}
.order-item-name {
  font-size: 13px;
  color: var(--cl-text-primary);
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  margin-bottom: 4px;
}
.order-item-sku {
  font-size: 11px;
  color: var(--cl-text-muted);
}
.order-item-right {
  flex-shrink: 0;
  text-align: right;
}
.order-item-price {
  font-size: 13px;
  font-weight: 600;
  color: var(--cl-text-primary);
}

.order-more {
  font-size: 11px;
  color: var(--cl-text-muted);
  padding: 4px 14px 8px;
  text-align: right;
}

.order-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 14px;
  border-top: 1px solid var(--cl-border-light);
}
.order-time {
  font-size: 11px;
  color: var(--cl-text-muted);
}
.order-total {
  font-size: 12px;
  color: var(--cl-text-secondary);
}
.total-amount {
  font-size: 15px;
  font-weight: 700;
  color: var(--cl-red);
  margin-left: 4px;
}

.order-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  padding: 10px 14px 12px;
  border-top: 1px solid var(--cl-border-light);
}
</style>
