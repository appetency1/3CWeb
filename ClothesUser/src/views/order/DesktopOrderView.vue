<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
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
  3: { label: '已完成', cls: 'completed' },
  4: { label: '已取消', cls: 'cancelled' },
}

const stats = computed(() => {
  const all = orders.value.length
  const pending = orders.value.filter((o: any) => o.status === 0).length
  const shipped = orders.value.filter((o: any) => o.status === 2).length
  const done = orders.value.filter((o: any) => o.status === 3).length
  return [
    { label: '全部订单', value: all, color: '' },
    { label: '待付款', value: pending, color: 'var(--accent)' },
    { label: '待收货', value: shipped, color: 'var(--warning)' },
    { label: '已完成', value: done, color: 'var(--success)' },
  ]
})

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
  } catch { showFailToast('加载失败'); finished.value = true }
  finally { loading.value = false }
}

function payOrder(order: any) {
  // Simulate payment
  router.push(`/order/${order.id}`)
}

function confirmReceive(order: any) {
  router.push(`/order/${order.id}`)
}

watch(active, () => { page.value = 1; orders.value = []; finished.value = false; fetchOrders() })
onMounted(fetchOrders)
</script>

<template>
  <DesktopLayout>
    <div class="order-page">
      <div class="page-header-order">
        <h1 class="page-title">我的订单</h1>
        <p class="page-subtitle">查看和管理您的所有订单</p>
      </div>

      <!-- 统计卡片 -->
      <div class="stats-bar">
        <div v-for="(s, i) in stats" :key="s.label"
          class="stat-card"
          :class="{ active: i === 0 }"
          @click="active = 0"
        >
          <div class="stat-value" :style="s.color ? { color: s.color } : {}">{{ s.value }}</div>
          <div class="stat-label">{{ s.label }}</div>
        </div>
      </div>

      <!-- 筛选标签 -->
      <div class="filter-tabs">
        <button v-for="(tab, idx) in tabs" :key="tab.title"
          class="tab-btn"
          :class="{ active: active === idx }"
          @click="active = idx"
        >
          {{ tab.title }}
        </button>
      </div>

      <!-- 空状态 -->
      <div v-if="!orders.length && !loading" class="empty-state">
        <div class="empty-icon">📋</div>
        <div class="empty-title">暂无订单</div>
        <div class="empty-desc">去逛逛，发现心仪的商品</div>
        <button class="btn-primary-dark" @click="router.push('/')">去购物</button>
      </div>

      <!-- 订单列表 -->
      <div v-else class="orders-list">
        <div v-for="order in orders" :key="order.id" class="order-card">
          <div class="order-header">
            <div class="order-meta">
              <span class="order-id">#{{ order.orderNo }}</span>
              <span class="order-date">{{ order.createTime?.replace('T', ' ')?.substring(0, 16) || '' }}</span>
            </div>
            <span class="status-badge" :class="'status-' + (STATUS_MAP[Number(order.status)]?.cls || 'pending')">
              {{ STATUS_MAP[Number(order.status)]?.label || '未知' }}
            </span>
          </div>

          <div class="order-body" @click="router.push(`/order/${order.id}`)">
            <div class="items-preview">
              <img v-for="(item, idx) in (order.items || []).slice(0, 3)" :key="idx"
                :src="fullImgUrl(item.goodsCover)" class="item-thumb"
                @error="($event.target as HTMLImageElement).src = '/assets/placeholders/product-placeholder.svg'"
              />
              <div v-if="(order.items || []).length > 3" class="item-more">+{{ order.items.length - 3 }}</div>
            </div>
            <div class="order-summary">
              <div class="order-total-label">订单金额</div>
              <div class="order-total">¥{{ (order.payAmount || order.totalAmount || 0).toFixed(2) }}</div>
              <div class="order-items-count">共{{ order.items?.length || 0 }}件商品</div>
            </div>
          </div>

          <div class="order-footer">
            <button class="btn btn-outline" @click="router.push(`/order/${order.id}`)">查看详情</button>
            <button v-if="order.status === 0" class="btn btn-accent" @click="payOrder(order)">立即付款</button>
            <button v-if="order.status === 2" class="btn btn-primary-order" @click="confirmReceive(order)">确认收货</button>
          </div>
        </div>
      </div>
    </div>
  </DesktopLayout>
</template>

<style scoped>
.order-page {
  max-width: 1000px;
  margin: 0 auto;
  padding: 24px 40px 60px;
}

.page-header-order { margin-bottom: 32px; }
.page-title {
  font-size: 28px; font-weight: 700; color: var(--text-primary, #1a1a1a); letter-spacing: 0.5px;
}
.page-subtitle { color: var(--text-muted, #9a9a9a); font-size: 14px; margin-top: 4px; }

/* 统计卡片 */
.stats-bar {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  margin-bottom: 28px;
}
.stat-card {
  background: var(--bg-card, #fff);
  border-radius: 16px;
  padding: 24px;
  border: 1px solid var(--border, #ece9e4);
  cursor: pointer;
}
.stat-card:hover { box-shadow: 0 2px 24px rgba(0,0,0,0.04); border-color: #d0cbc4; transform: translateY(-2px); }
.stat-card.active { border-color: var(--accent, #c45c4a); box-shadow: 0 0 0 3px rgba(196,92,74,0.08); }
.stat-value { font-size: 28px; font-weight: 700; margin-bottom: 4px; }
.stat-label { font-size: 13px; color: var(--text-secondary, #6b6b6b); font-weight: 500; }

/* 筛选标签 */
.filter-tabs {
  display: flex;
  gap: 8px;
  margin-bottom: 28px;
  border-bottom: 1px solid var(--border, #ece9e4);
  padding-bottom: 16px;
}
.tab-btn {
  padding: 10px 20px;
  border-radius: 100px;
  border: 1px solid transparent;
  background: transparent;
  font-size: 13px;
  font-weight: 500;
  color: var(--text-secondary, #6b6b6b);
  cursor: pointer;
  font-family: inherit;
}
.tab-btn:hover { background: var(--bg-secondary, #f5f3f0); color: var(--text-primary, #1a1a1a); }
.tab-btn.active { background: var(--bg-dark, #1a1a1a); color: white; }

/* 订单卡片 */
.orders-list { display: flex; flex-direction: column; gap: 20px; }
.order-card {
  background: var(--bg-card, #fff);
  border-radius: 16px;
  border: 1px solid var(--border, #ece9e4);
  overflow: hidden;
}
.order-card:hover { box-shadow: 0 8px 40px rgba(0,0,0,0.06); border-color: #d0cbc4; }

.order-header {
  padding: 20px 24px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid var(--border-light, #f3f1ed);
}
.order-meta { display: flex; align-items: center; gap: 20px; }
.order-id { font-size: 14px; font-weight: 600; color: var(--text-primary, #1a1a1a); }
.order-date { font-size: 13px; color: var(--text-muted, #9a9a9a); }

.status-badge {
  padding: 6px 14px;
  border-radius: 100px;
  font-size: 12px;
  font-weight: 600;
}
.status-paid { background: #eef4ef; color: var(--success, #5a8c6f); }
.status-shipped { background: #f0ebe4; color: var(--warning, #c4953b); }
.status-completed { background: #e8e8e8; color: var(--text-secondary, #6b6b6b); }
.status-pending { background: #fdf0ed; color: var(--accent, #c45c4a); }
.status-cancelled { background: #f5f5f5; color: #bbb; }

.order-body { padding: 24px; display: flex; gap: 24px; cursor: pointer; }
.items-preview { display: flex; gap: 12px; flex: 1; }
.item-thumb {
  width: 80px; height: 80px; border-radius: 10px; object-fit: cover;
  border: 1px solid var(--border, #ece9e4);
}
.item-thumb:hover { transform: scale(1.05); }
.item-more {
  width: 80px; height: 80px; border-radius: 10px;
  background: var(--bg-secondary, #f5f3f0);
  border: 1px dashed var(--border, #ece9e4);
  display: flex; align-items: center; justify-content: center;
  font-size: 12px; color: var(--text-muted, #9a9a9a);
  font-weight: 500;
}

.order-summary { text-align: right; display: flex; flex-direction: column; justify-content: center; gap: 4px; }
.order-total-label { font-size: 12px; color: var(--text-muted, #9a9a9a); }
.order-total { font-size: 22px; font-weight: 700; color: var(--accent, #c45c4a); }
.order-items-count { font-size: 12px; color: var(--text-secondary, #6b6b6b); }

.order-footer {
  padding: 16px 24px;
  background: var(--bg-secondary, #f5f3f0);
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.btn {
  padding: 10px 24px;
  border-radius: 100px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  border: none;
  font-family: inherit;
}
.btn-outline {
  background: transparent;
  border: 1px solid var(--border, #ece9e4);
  color: var(--text-secondary, #6b6b6b);
}
.btn-outline:hover { border-color: var(--text-primary, #1a1a1a); color: var(--text-primary, #1a1a1a); }
.btn-primary-order {
  background: var(--bg-dark, #1a1a1a); color: white;
}
.btn-primary-order:hover { background: #333; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
.btn-accent {
  background: var(--accent, #c45c4a); color: white;
}
.btn-accent:hover { background: var(--accent-dark, #8b3a2a); transform: translateY(-1px); }

/* 空状态 */
.empty-state { text-align: center; padding: 80px 20px; }
.empty-icon { width: 80px; height: 80px; margin: 0 auto 24px; border-radius: 50%; background: var(--bg-secondary, #f5f3f0); display: flex; align-items: center; justify-content: center; font-size: 32px; }
.empty-title { font-size: 22px; font-weight: 600; margin-bottom: 8px; color: var(--text-primary, #1a1a1a); }
.empty-desc { color: var(--text-muted, #9a9a9a); font-size: 14px; margin-bottom: 24px; }
.btn-primary-dark {
  padding: 14px 36px; border-radius: 16px; border: none;
  background: var(--bg-dark, #1a1a1a); color: white;
  font-size: 14px; font-weight: 600; cursor: pointer;
}
.btn-primary-dark:hover { background: #333; transform: translateY(-2px); box-shadow: 0 8px 24px rgba(0,0,0,0.15); }

@media (max-width: 768px) {
  .order-page { padding: 16px 20px 40px; }
  .stats-bar { grid-template-columns: repeat(2, 1fr); gap: 12px; }
  .order-body { flex-direction: column; gap: 16px; }
  .order-summary { text-align: left; flex-direction: row; align-items: center; justify-content: space-between; }
}
</style>
