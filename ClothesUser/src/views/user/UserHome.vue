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
        <div class="stat-icon orders">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M9 12h3.75M9 15h3.75M9 18h3.75m3 .75H18a2.25 2.25 0 0 0 2.25-2.25V6.108c0-1.135-.845-2.098-1.976-2.192a48.424 48.424 0 0 0-1.123-.08m-5.801 0c-.065.21-.1.433-.1.664 0 .414.336.75.75.75h4.5a.75.75 0 0 0 .75-.75 2.25 2.25 0 0 0-.1-.664m-5.8 0A2.251 2.251 0 0 1 13.5 2.25H15c1.012 0 1.867.668 2.15 1.586m-5.8 0c-.376.023-.75.05-1.124.08C9.095 4.01 8.25 4.973 8.25 6.108V8.25m0 0H4.875c-.621 0-1.125.504-1.125 1.125v11.25c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125V9.375c0-.621-.504-1.125-1.125-1.125H8.25ZM6.75 12h.008v.008H6.75V12Zm0 3h.008v.008H6.75V15Zm0 3h.008v.008H6.75V18Z"/></svg>
        </div>
        <div class="stat-info">
          <div class="stat-num">{{ orderStats.total }}</div>
          <div class="stat-label">全部订单</div>
        </div>
        <span class="stat-arrow">›</span>
      </div>
      <div class="stat-card" @click="router.push({ name: 'userOrders' })">
        <div class="stat-icon pay">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M2.25 8.25h19.5M2.25 9h19.5m-16.5 5.25h6m-6 2.25h3m-3.75 3h15a2.25 2.25 0 0 0 2.25-2.25V6.75A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25v10.5A2.25 2.25 0 0 0 4.5 19.5Z"/></svg>
        </div>
        <div class="stat-info">
          <div class="stat-num">{{ orderStats.pendingPay }}</div>
          <div class="stat-label">待付款</div>
        </div>
        <span class="stat-arrow">›</span>
      </div>
      <div class="stat-card" @click="router.push({ name: 'userOrders' })">
        <div class="stat-icon ship">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M8.25 18.75a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h6m-9 0H3.375a1.125 1.125 0 0 1-1.125-1.125V14.25m17.25 4.5a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h1.125c.621 0 1.129-.504 1.09-1.124a17.902 17.902 0 0 0-3.213-9.193 2.056 2.056 0 0 0-1.58-.86H14.25M16.5 18.75h-2.25m0-11.177v-.958c0-.568-.422-1.048-.987-1.106a48.554 48.554 0 0 0-10.026 0 1.106 1.106 0 0 0-.987 1.106v7.635m12-6.677v6.677m0 4.5v-4.5m0 0h-12"/></svg>
        </div>
        <div class="stat-info">
          <div class="stat-num">{{ orderStats.pendingReceive }}</div>
          <div class="stat-label">待收货</div>
        </div>
        <span class="stat-arrow">›</span>
      </div>
      <div class="stat-card" @click="router.push({ name: 'userOrders' })">
        <div class="stat-icon review">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M11.48 3.499a.562.562 0 0 1 1.04 0l2.125 5.111a.563.563 0 0 0 .475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 0 0-.182.557l1.285 5.385a.562.562 0 0 1-.84.61l-4.725-2.885a.562.562 0 0 0-.586 0L6.982 20.54a.562.562 0 0 1-.84-.61l1.285-5.386a.562.562 0 0 0-.182-.557l-4.204-3.602a.562.562 0 0 1 .321-.988l5.518-.442a.563.563 0 0 0 .475-.345L11.48 3.5Z"/></svg>
        </div>
        <div class="stat-info">
          <div class="stat-num">{{ orderStats.pendingReview }}</div>
          <div class="stat-label">待评价</div>
        </div>
        <span class="stat-arrow">›</span>
      </div>
    </div>

    <div class="content-card">
      <div class="card-header">
        <h3><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:middle;margin-right:6px"><path d="M9 12h3.75M9 15h3.75M9 18h3.75m3 .75H18a2.25 2.25 0 0 0 2.25-2.25V6.108c0-1.135-.845-2.098-1.976-2.192a48.424 48.424 0 0 0-1.123-.08m-5.801 0c-.065.21-.1.433-.1.664 0 .414.336.75.75.75h4.5a.75.75 0 0 0 .75-.75 2.25 2.25 0 0 0-.1-.664m-5.8 0A2.251 2.251 0 0 1 13.5 2.25H15c1.012 0 1.867.668 2.15 1.586m-5.8 0c-.376.023-.75.05-1.124.08C9.095 4.01 8.25 4.973 8.25 6.108V8.25m0 0H4.875c-.621 0-1.125.504-1.125 1.125v11.25c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125V9.375c0-.621-.504-1.125-1.125-1.125H8.25ZM6.75 12h.008v.008H6.75V12Zm0 3h.008v.008H6.75V15Zm0 3h.008v.008H6.75V18Z"/></svg> 最近订单</h3>
        <span class="card-link" @click="router.push({ name: 'userOrders' })">查看全部 ›</span>
      </div>
      <div class="card-body">
        <div v-if="!recentOrders.length && !loadingOrders" class="empty-state">暂无订单</div>
        <div v-for="o in recentOrders" :key="o.id" class="order-item" @click="router.push('/order/' + o.id)">
          <div class="order-img"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M20.625 11.505v8.25a1.5 1.5 0 0 1-1.5 1.5H4.875a1.5 1.5 0 0 1-1.5-1.5v-8.25m8.25-6.375A2.625 2.625 0 1 0 9 7.755h2.625m0-2.625v2.625m0-2.625a2.625 2.625 0 1 1 2.625 2.625h-2.625m0 0v13.5M3 11.505h18c.621 0 1.125-.504 1.125-1.125v-1.5c0-.622-.504-1.125-1.125-1.125H3c-.621 0-1.125.503-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125Z"/></svg></div>
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
        <h3><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:middle;margin-right:6px"><path d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z"/></svg> 账户信息</h3>
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
          <span class="benefit-tag"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:middle;margin-right:3px"><path d="M20.625 11.505v8.25a1.5 1.5 0 0 1-1.5 1.5H4.875a1.5 1.5 0 0 1-1.5-1.5v-8.25m8.25-6.375A2.625 2.625 0 1 0 9 7.755h2.625m0-2.625v2.625m0-2.625a2.625 2.625 0 1 1 2.625 2.625h-2.625m0 0v13.5M3 11.505h18c.621 0 1.125-.504 1.125-1.125v-1.5c0-.622-.504-1.125-1.125-1.125H3c-.621 0-1.125.503-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125Z"/></svg> 生日礼券</span>
          <span class="benefit-tag"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:middle;margin-right:3px"><path d="M8.25 18.75a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h6m-9 0H3.375a1.125 1.125 0 0 1-1.125-1.125V14.25m17.25 4.5a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h1.125c.621 0 1.129-.504 1.09-1.124a17.902 17.902 0 0 0-3.213-9.193 2.056 2.056 0 0 0-1.58-.86H14.25M16.5 18.75h-2.25m0-11.177v-.958c0-.568-.422-1.048-.987-1.106a48.554 48.554 0 0 0-10.026 0 1.106 1.106 0 0 0-.987 1.106v7.635m12-6.677v6.677m0 4.5v-4.5m0 0h-12"/></svg> 免邮特权</span>
          <span class="benefit-tag">💰 积分翻倍</span>
          <span class="benefit-tag">🎯 新品优先购</span>
          <span class="benefit-tag"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:middle;margin-right:3px"><path d="M21.75 6.75a4.5 4.5 0 0 1-4.884 4.484c-1.076-.091-2.264.071-2.95.904l-7.152 8.684a2.548 2.548 0 1 1-3.586-3.586l8.684-7.152c.833-.686.995-1.874.904-2.95a4.5 4.5 0 0 1 6.336-4.486l-3.276 3.276a3.004 3.004 0 0 0 2.25 2.25l3.276-3.276c.256.565.398 1.192.398 1.852Z"/><path d="M4.867 19.125h.008v.008h-.008v-.008Z"/></svg> 专属客服</span>
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
  background: var(--bg-card, #1a1a2e);
  border: 1px solid var(--border, rgba(255,255,255,0.1));
  border-radius: var(--radius-lg, 12px);
  padding: 24px;
  display: flex; align-items: center; gap: 16px;
  cursor: pointer;
  box-shadow: var(--shadow-sm, 0 1px 3px rgba(0,0,0,0.04));
}
.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 20px rgba(0,240,255,0.08);
  border-color: var(--accent, #00f0ff);
}
.stat-icon {
  width: 48px; height: 48px;
  border-radius: var(--radius-md, 8px);
  display: flex; align-items: center; justify-content: center;
  font-size: 22px; flex-shrink: 0;
}
.stat-icon.orders { background: rgba(0,240,255,0.08); }
.stat-icon.pay { background: rgba(0,240,255,0.12); }
.stat-icon.ship { background: rgba(0,240,255,0.08); }
.stat-icon.review { background: rgba(255,200,0,0.08); }
.stat-info { flex: 1; }
.stat-num {
  font-size: 24px; font-weight: 700; color: var(--text-primary, #e8e8f0);
  line-height: 1.2; margin-bottom: 4px;
}
.stat-label { font-size: 13px; color: var(--text-muted, rgba(255,255,255,0.45)); font-weight: 500; }
.stat-arrow { color: var(--text-muted, #999); font-size: 14px; }
.stat-card:hover .stat-arrow { color: var(--accent, #00f0ff); transform: translateX(2px); }
.stat-card:active .stat-arrow { color: var(--accent, #00f0ff); }
.stat-card:active .stat-label { color: var(--text-muted, rgba(255,255,255,0.45)); }
.stat-card:active .stat-num { color: var(--text-primary, #e8e8f0); }

.content-card {
  background: var(--bg-card, #1a1a2e);
  border: 1px solid var(--border, rgba(255,255,255,0.1));
  border-radius: var(--radius-lg, 12px);
  overflow: hidden;
  box-shadow: var(--shadow-sm, 0 1px 3px rgba(0,0,0,0.04));
}
.card-header {
  padding: 20px 24px;
  display: flex; align-items: center; justify-content: space-between;
  border-bottom: 1px solid var(--border, #e8e5e0);
}
.card-header h3 { font-size: 16px; font-weight: 600; color: var(--text-primary, #e8e8f0); }
.card-link { font-size: 13px; color: var(--accent, #00f0ff); text-decoration: none; font-weight: 500; cursor: pointer; }
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
.order-info h4 { font-size: 14px; font-weight: 600; color: var(--text-primary, #e8e8f0); margin-bottom: 4px; }
.order-info .order-meta { font-size: 12px; color: var(--text-muted, rgba(255,255,255,0.45)); }
.order-price { font-size: 14px; font-weight: 600; color: var(--text-primary, #e8e8f0); text-align: right; }
.order-status {
  padding: 4px 12px; border-radius: 20px;
  font-size: 12px; font-weight: 600; text-align: center; white-space: nowrap;
}
.order-status.shipped { background: rgba(0,240,255,0.12); color: var(--accent, #00f0ff); }
.order-status.pending { background: rgba(255,200,0,0.12); color: #f0c040; }
.order-status.done { background: var(--bg-secondary, rgba(255,255,255,0.05)); color: var(--text-muted, rgba(255,255,255,0.45)); }

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
