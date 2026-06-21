<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { orderApi } from '@/api/order'

const router = useRouter()
const userStore = useUserStore()

const recentOrders = ref<any[]>([])
const allOrdersForStats = ref<any[]>([])
const loadingOrders = ref(false)

const orderStats = computed(() => {
  const all = allOrdersForStats.value
  return {
    total: all.length,
    pendingPay: all.filter((o: any) => o.status === 0).length,
    pendingReceive: all.filter((o: any) => o.status === 2).length,
    pendingReview: all.filter((o: any) => o.status === 3).length,
  }
})

async function loadOrders() {
  loadingOrders.value = true
  try {
    const allData: any = await orderApi.list({ page: 1, size: 100 })
    const list = allData?.list || allData || []
    allOrdersForStats.value = list
    recentOrders.value = list.slice(0, 3)
  } catch { /* silent */ }
  finally { loadingOrders.value = false }
}

function orderStatusText(s: number) {
  const map: Record<number, string> = { 0: '待付款', 1: '待发货', 2: '待收货', 3: '已完成', 4: '已取消', 5: '已退款' }
  return map[s] || '未知'
}
function orderStatusClass(s: number) {
  return s === 0 ? 'pending' : s === 2 ? 'shipped' : s === 3 ? 'done' : ''
}

onMounted(() => {
  if (userStore.isLoggedIn) loadOrders()
})
</script>

<template>
  <div class="user-home">
    <h1 class="page-title">个人中心</h1>

    <div class="stats-grid">
      <div class="stat-card" @click="router.push({ name: 'userOrders' })">
        <div class="stat-icon orders">📦</div>
        <div class="stat-info">
          <div class="stat-num">{{ orderStats.total }}</div>
          <div class="stat-label">全部订单</div>
        </div>
        <span class="stat-arrow">›</span>
      </div>
      <div class="stat-card" @click="router.push({ name: 'userOrders' })">
        <div class="stat-icon pay">💳</div>
        <div class="stat-info">
          <div class="stat-num">{{ orderStats.pendingPay }}</div>
          <div class="stat-label">待付款</div>
        </div>
        <span class="stat-arrow">›</span>
      </div>
      <div class="stat-card" @click="router.push({ name: 'userOrders' })">
        <div class="stat-icon ship">🚚</div>
        <div class="stat-info">
          <div class="stat-num">{{ orderStats.pendingReceive }}</div>
          <div class="stat-label">待收货</div>
        </div>
        <span class="stat-arrow">›</span>
      </div>
      <div class="stat-card" @click="router.push({ name: 'userOrders' })">
        <div class="stat-icon review">⭐</div>
        <div class="stat-info">
          <div class="stat-num">{{ orderStats.pendingReview }}</div>
          <div class="stat-label">待评价</div>
        </div>
        <span class="stat-arrow">›</span>
      </div>
    </div>

    <div class="content-card">
      <div class="card-header">
        <h3>📦 最近订单</h3>
        <span class="card-link" @click="router.push({ name: 'userOrders' })">查看全部 ›</span>
      </div>
      <div class="card-body">
        <div v-if="!recentOrders.length && !loadingOrders" class="empty-state">暂无订单</div>
        <div v-for="o in recentOrders" :key="o.id" class="order-item" @click="router.push('/order/' + o.id)">
          <div class="order-img">📦</div>
          <div class="order-info">
            <h4>订单 #{{ o.orderNo }}</h4>
            <div class="order-meta">{{ o.createTime?.replace('T', ' ').substring(0, 16) || '' }}</div>
          </div>
          <div class="order-price">¥{{ (o.payAmount || o.totalAmount || 0).toFixed(2) }}</div>
          <span class="order-status" :class="orderStatusClass(o.status)">{{ orderStatusText(o.status) }}</span>
        </div>
      </div>
    </div>

    <div class="content-card">
      <div class="card-header">
        <h3>👤 账户信息</h3>
        <span class="card-link" @click="router.push({ name: 'userProfile' })">编辑资料 ›</span>
      </div>
      <div class="card-body">
        <div class="info-grid">
          <div class="info-item">
            <div class="info-label">用户名</div>
            <div class="info-value">{{ userStore.userInfo?.username }}</div>
          </div>
          <div class="info-item">
            <div class="info-label">昵称</div>
            <div class="info-value">{{ userStore.userInfo?.nickname || '未设置' }}</div>
          </div>
          <div class="info-item">
            <div class="info-label">手机号</div>
            <div class="info-value">{{ userStore.userInfo?.phone || '未绑定' }}</div>
          </div>
          <div class="info-item">
            <div class="info-label">邮箱</div>
            <div class="info-value" :class="{ empty: !userStore.userInfo?.email }">
              {{ userStore.userInfo?.email || '未绑定' }}
              <span v-if="!userStore.userInfo?.email" class="info-action" @click="router.push({ name: 'userProfile' })">去绑定</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="content-card">
      <div class="card-header">
        <h3>✦ 会员权益</h3>
        <span class="card-link">了解更多 ›</span>
      </div>
      <div class="card-body">
        <div class="benefits-row">
          <span class="benefit-tag">🎁 生日礼券</span>
          <span class="benefit-tag">🚚 免邮特权</span>
          <span class="benefit-tag">💰 积分翻倍</span>
          <span class="benefit-tag">🎯 新品优先购</span>
          <span class="benefit-tag">🔧 专属客服</span>
          <span class="benefit-tag">🎫 会员专享价</span>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.user-home {
  display: flex;
  flex-direction: column;
  gap: 24px;
}
.page-title {
  font-size: 24px; font-weight: 600; color: var(--text-primary, #1a1a1a);
  margin-bottom: 8px;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
}
.stat-card {
  background: var(--bg-card, #fff);
  border: 1px solid var(--border, #e8e5e0);
  border-radius: var(--radius-lg, 12px);
  padding: 24px;
  display: flex; align-items: center; gap: 16px;
  cursor: pointer;
  box-shadow: var(--shadow-sm, 0 1px 3px rgba(0,0,0,0.04));
}
.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md, 0 4px 12px rgba(0,0,0,0.08));
  border-color: var(--border-hover, #d0cbc4);
}
.stat-icon {
  width: 48px; height: 48px;
  border-radius: var(--radius-md, 8px);
  display: flex; align-items: center; justify-content: center;
  font-size: 22px; flex-shrink: 0;
}
.stat-icon.orders { background: var(--accent-bg, #fdf5f3); }
.stat-icon.pay { background: #fff8e6; }
.stat-icon.ship { background: #e8f5ee; }
.stat-icon.review { background: #e8f0fa; }
.stat-info { flex: 1; }
.stat-num {
  font-size: 24px; font-weight: 700; color: var(--text-primary, #1a1a1a);
  line-height: 1.2; margin-bottom: 4px;
}
.stat-label { font-size: 13px; color: var(--text-muted, #999); font-weight: 500; }
.stat-arrow { color: var(--text-muted, #999); font-size: 14px; }
.stat-card:hover .stat-arrow { color: var(--accent, #c45c4a); transform: translateX(2px); }

.content-card {
  background: var(--bg-card, #fff);
  border: 1px solid var(--border, #e8e5e0);
  border-radius: var(--radius-lg, 12px);
  overflow: hidden;
  box-shadow: var(--shadow-sm, 0 1px 3px rgba(0,0,0,0.04));
}
.card-header {
  padding: 20px 24px;
  display: flex; align-items: center; justify-content: space-between;
  border-bottom: 1px solid var(--border, #e8e5e0);
}
.card-header h3 { font-size: 16px; font-weight: 600; color: var(--text-primary, #1a1a1a); }
.card-link { font-size: 13px; color: var(--accent, #c45c4a); text-decoration: none; font-weight: 500; cursor: pointer; }
.card-link:hover { text-decoration: underline; }
.card-body { padding: 20px 24px; }
.empty-state { text-align: center; padding: 24px; color: var(--text-muted, #999); font-size: 14px; }

.order-item {
  display: grid;
  grid-template-columns: 60px 1fr auto auto;
  gap: 16px; align-items: center;
  padding: 16px 0;
  border-bottom: 1px solid var(--border, #e8e5e0);
  cursor: pointer;
}
.order-item:last-child { border-bottom: none; padding-bottom: 0; }
.order-img {
  width: 60px; height: 60px; border-radius: var(--radius-sm, 4px);
  background: var(--bg-secondary, #f5f3f0);
  display: flex; align-items: center; justify-content: center; font-size: 24px;
}
.order-info h4 { font-size: 14px; font-weight: 600; color: var(--text-primary, #1a1a1a); margin-bottom: 4px; }
.order-info .order-meta { font-size: 12px; color: var(--text-muted, #999); }
.order-price { font-size: 14px; font-weight: 600; color: var(--text-primary, #1a1a1a); text-align: right; }
.order-status {
  padding: 4px 12px; border-radius: 20px;
  font-size: 12px; font-weight: 600; text-align: center; white-space: nowrap;
}
.order-status.shipped { background: #e8f5ee; color: var(--success, #2d8a5e); }
.order-status.pending { background: #fff8e6; color: var(--warning, #d4920a); }
.order-status.done { background: #e8e8e8; color: #999; }

.info-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; }
.info-item {
  background: var(--bg-secondary, #f5f3f0);
  border-radius: var(--radius-md, 8px);
  padding: 16px 20px;
}
.info-item .info-label {
  font-size: 11px; font-weight: 600; color: var(--text-muted, #999);
  text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 6px;
}
.info-item .info-value {
  font-size: 14px; color: var(--text-primary, #1a1a1a); font-weight: 500;
}
.info-item .info-value.empty { color: var(--text-muted, #999); font-weight: 400; }
.info-action {
  float: right; font-size: 12px; color: var(--accent, #c45c4a);
  cursor: pointer; font-weight: 500;
}

.benefits-row { display: flex; gap: 12px; flex-wrap: wrap; }
.benefit-tag {
  display: inline-flex; align-items: center; gap: 6px;
  background: var(--bg-secondary, #f5f3f0);
  border: 1px solid var(--border, #e8e5e0);
  padding: 8px 14px; border-radius: var(--radius-md, 8px);
  font-size: 13px; color: var(--text-secondary, #666);
}
.benefit-tag:hover {
  border-color: var(--accent-light, #e8a090);
  color: var(--accent, #c45c4a);
  background: var(--accent-bg, #fdf5f3);
}

@media (max-width: 1100px) {
  .stats-grid { grid-template-columns: repeat(2, 1fr); }
}
@media (max-width: 768px) {
  .stats-grid { grid-template-columns: repeat(2, 1fr); gap: 12px; }
  .info-grid { grid-template-columns: 1fr; }
  .order-item { grid-template-columns: 50px 1fr; gap: 10px; }
  .order-price, .order-status { grid-column: 1 / -1; text-align: left; }
}
</style>
