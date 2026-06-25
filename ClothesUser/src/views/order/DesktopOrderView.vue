<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { showFailToast, showConfirmDialog, showToast } from 'vant'
import { orderApi } from '@/api/order'
import { userApi } from '@/api/user'
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
const allOrdersForStats = ref<any[]>([])
const statsLoaded = ref(false)
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
  const all = allOrdersForStats.value
  return [
    { label: '全部订单', value: all.length, color: '', tabIdx: 0 },
    { label: '待付款', value: all.filter((o: any) => o.status === 0).length, color: 'var(--accent)', tabIdx: 1 },
    { label: '待发货', value: all.filter((o: any) => o.status === 1).length, color: '#3498db', tabIdx: 2 },
    { label: '待收货', value: all.filter((o: any) => o.status === 2).length, color: 'var(--warning)', tabIdx: 3 },
    { label: '已完成', value: all.filter((o: any) => o.status === 3).length, color: 'var(--success)', tabIdx: 4 },
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
  loading.value = true
  orderApi.pay(order.id).then(() => {
    showToast('支付成功')
    router.push(`/order/${order.id}`)
  }).catch((e: any) => {
    showFailToast(e?.message || '支付失败')
  }).finally(() => {
    loading.value = false
  })
}

async function confirmReceive(order: any) {
  try {
    await showConfirmDialog({ title: '确认收货', message: '确定已收到商品吗？', confirmButtonText: '确认收货' })
    await orderApi.confirm(order.id)
    showToast('已确认收货')
    order.status = 3
    loadStats()
  } catch { /* 取消或失败 */ }
}

async function cancelOrder(order: any) {
  try {
    await showConfirmDialog({
      title: '取消订单',
      message: '确定要取消该订单吗？',
      confirmButtonText: '确认取消',
      cancelButtonText: '暂不取消',
    })
    await orderApi.cancel(order.id)
    showToast('订单已取消')
    // 刷新当前页数据 + 统计
    page.value = 1
    orders.value = []
    finished.value = false
    fetchOrders()
    loadStats()
  } catch { /* 用户取消对话框或操作失败 */ }
}

async function loadStats() {
  try {
    const data: any = await orderApi.list({ page: 1, size: 999 })
    allOrdersForStats.value = data?.list || data || []
  } catch { /* 统计不影响主流程 */ }
  finally { statsLoaded.value = true }
}

// 切换 Tab 时重新请求列表，但统计不受影响
const showReview = ref(false)
const reviewRating = ref(5)
const reviewContent = ref('')
const reviewSubmitting = ref(false)
let reviewingOrder: any = null

function openReview(order: any) {
  reviewingOrder = order
  showReview.value = true
  reviewRating.value = 5
  reviewContent.value = ''
}

async function submitReview() {
  if (!reviewContent.value.trim()) { showToast('请填写评价内容'); return }
  if (!reviewingOrder) return
  reviewSubmitting.value = true
  try {
    await userApi.createComment({
      orderId: reviewingOrder.id,
      goodsId: reviewingOrder.items?.[0]?.goodsId || 0,
      content: reviewContent.value,
      rating: reviewRating.value,
    })
    showToast('评价成功')
    showReview.value = false
    reviewingOrder = null
  } catch (e: any) { showFailToast(e?.message || '评价失败') }
  finally { reviewSubmitting.value = false }
}

watch(active, () => { page.value = 1; orders.value = []; finished.value = false; fetchOrders() })

onMounted(() => {
  loadStats()
  fetchOrders()
})
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
        <div v-for="(s) in stats" :key="s.label"
          class="stat-card"
          :class="{ active: active === s.tabIdx }"
          @click="active = s.tabIdx"
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
            <div class="order-items">
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
                  <span class="order-item-price">¥{{ Number(item.price || 0).toFixed(2) }}</span>
                </div>
              </div>
              <div v-if="(order.items || []).length > 3" class="order-more">
                还有 {{ order.items.length - 3 }} 件商品
              </div>
            </div>
          </div>

          <div class="order-summary">
            <span class="summary-left">
              共 {{ order.items?.length || 0 }} 件
              <template v-if="order.discountAmount > 0">
                ，优惠 <span class="summary-discount">-¥{{ Number(order.discountAmount).toFixed(2) }}</span>
              </template>
            </span>
            <span class="summary-right">
              合计：<span class="summary-amount">¥{{ (order.payAmount || order.totalAmount || 0).toFixed(2) }}</span>
            </span>
          </div>

          <!-- 操作栏 -->
          <div class="order-footer">
            <button class="btn btn-outline" @click="router.push(`/order/${order.id}`)">查看详情</button>
            <span class="footer-right">
              <button v-if="order.status === 0" class="btn btn-cancel" @click="cancelOrder(order)">取消订单</button>
              <button v-if="order.status === 0" class="btn btn-pay" @click="payOrder(order)">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M12 1v22M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
                立即付款
              </button>
              <button v-if="order.status === 2" class="btn btn-primary-order" @click="confirmReceive(order)">确认收货</button>
              <button v-if="order.status === 3" class="btn btn-review" @click="openReview(order)">去评价</button>
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- 评价弹窗 -->
    <div v-if="showReview" class="review-overlay" @click.self="showReview = false">
      <div class="review-modal">
        <div class="review-header">
          <h3>评价商品</h3>
          <button class="review-close" @click="showReview = false">✕</button>
        </div>
        <div class="review-body">
          <div class="review-field">
            <label class="review-label">评分</label>
            <div class="rating">
              <input value="5" name="rating" id="star5" type="radio" v-model="reviewRating" />
              <label for="star5"></label>
              <input value="4" name="rating" id="star4" type="radio" v-model="reviewRating" />
              <label for="star4"></label>
              <input value="3" name="rating" id="star3" type="radio" v-model="reviewRating" />
              <label for="star3"></label>
              <input value="2" name="rating" id="star2" type="radio" v-model="reviewRating" />
              <label for="star2"></label>
              <input value="1" name="rating" id="star1" type="radio" v-model="reviewRating" />
              <label for="star1"></label>
            </div>
          </div>
          <div class="review-field">
            <label class="review-label">评价内容</label>
            <textarea v-model="reviewContent" class="review-textarea" placeholder="分享您的购物体验，对其他买家很有帮助" rows="4" maxlength="500"></textarea>
          </div>
        </div>
        <div class="review-footer">
          <button class="btn btn-outline" @click="showReview = false">取消</button>
          <button class="btn btn-primary" @click="submitReview" :disabled="reviewSubmitting">{{ reviewSubmitting ? '提交中...' : '提交评价' }}</button>
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
  grid-template-columns: repeat(5, 1fr);
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
.stat-card:hover { box-shadow: 0 2px 24px rgba(0,0,0,0.04); border-color: var(--accent, #00f0ff); transform: translateY(-2px); }
.stat-card.active { border-color: var(--accent, #00f0ff); box-shadow: 0 0 0 3px rgba(0,240,255,0.08); }
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
  transition: all 0.2s cubic-bezier(0.22, 1, 0.36, 1);
}
.tab-btn:hover { background: rgba(0,240,255,0.08); color: var(--accent, #00f0ff); }
.tab-btn.active { background: var(--accent, #00f0ff); color: #0a0a0f; }

/* 订单卡片 */
.orders-list { display: flex; flex-direction: column; gap: 20px; }
.order-card {
  background: var(--bg-card, #fff);
  border-radius: 16px;
  border: 1px solid var(--border, #ece9e4);
  overflow: hidden;
}
.order-card:hover { box-shadow: 0 8px 40px rgba(0,0,0,0.06); border-color: var(--accent, #00f0ff); }

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
.status-paid { background: rgba(0,240,255,0.1); color: var(--accent, #00f0ff); }
.status-shipped { background: rgba(255,200,0,0.1); color: #f0c040; }
.status-completed { background: rgba(255,255,255,0.05); color: var(--text-muted, rgba(255,255,255,0.45)); }
.status-pending { background: rgba(255,60,60,0.08); color: #ff6b6b; }
.status-cancelled { background: rgba(255,255,255,0.03); color: rgba(255,255,255,0.25); }

.order-body {
  padding: 20px 28px;
  cursor: pointer;
  transition: background 0.2s;
}
.order-body:hover { background: var(--bg-secondary, rgba(255,255,255,0.03)); }

.order-items { display: flex; flex-direction: column; gap: 16px; }
.order-item { display: flex; align-items: center; gap: 16px; }
.order-item-img {
  width: 72px; height: 72px; border-radius: 12px; object-fit: cover;
  background: var(--bg-secondary, #f5f3f0); flex-shrink: 0;
}
.order-item-info { flex: 1; min-width: 0; }
.order-item-name { font-size: 14px; font-weight: 600; color: var(--text-primary, #1a1a1a); line-height: 1.5; margin-bottom: 6px; }
.order-item-sku { font-size: 12px; color: var(--text-muted, #9a9a9a); }
.order-item-right { flex-shrink: 0; text-align: right; }
.order-item-price { font-size: 14px; font-weight: 700; color: var(--text-primary, #1a1a1a); }
.order-more { font-size: 12px; color: var(--text-muted, #9a9a9a); text-align: right; }

.order-summary {
  padding: 14px 24px;
  display: flex; justify-content: space-between; align-items: center;
  border-top: 1px solid var(--border-light, #f3f1ed);
  font-size: 13px; color: var(--text-secondary, #6b6b6b);
}
.summary-discount { color: var(--success, #2d8a5e); font-weight: 600; margin-left: 4px; }
.summary-amount { font-size: 18px; font-weight: 700; color: var(--accent, #c45c4a); margin-left: 4px; }

/* 操作栏 */
.order-footer {
  padding: 14px 24px;
  background: var(--bg-secondary, #f5f3f0);
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.footer-right { display: flex; gap: 10px; align-items: center; }

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
  background: var(--accent, #00f0ff); color: #0a0a0f;
}
.btn-primary-order:hover { background: var(--accent-hover, #00d8e6); transform: translateY(-1px); box-shadow: 0 4px 16px rgba(0,240,255,0.25); }
.btn-accent {
  background: var(--accent, #c45c4a); color: #0a0a0f;
}
.btn-accent:hover { background: var(--accent-dark, #8b3a2a); transform: translateY(-1px); }
.btn-pay {
  background: linear-gradient(135deg, var(--accent, #c45c4a), var(--accent-dark, #8b3a2a));
  color: #0a0a0f;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  box-shadow: 0 4px 12px rgba(196,92,74,0.25);
  position: relative;
  overflow: hidden;
}
.btn-pay:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(196,92,74,0.35);
}
.btn-pay:active { transform: translateY(0); }
.btn-pay svg { width: 16px; height: 16px; }
.btn-pay::after {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, transparent 40%, rgba(255,255,255,0.15) 50%, transparent 60%);
  transform: translateX(-100%);
  transition: transform 0.6s;
}
.btn-pay:hover::after { transform: translateX(100%); }

.btn-cancel {
  background: transparent; color: var(--text-muted); border: 1px solid #e0ddd8;
}
.btn-cancel:hover { color: #dc3545; border-color: #dc3545; }
.btn-review {
  background: transparent; color: var(--accent, #00f0ff); border: 1px solid var(--accent, #00f0ff);
}
.btn-review:hover { background: var(--accent, #00f0ff); color: #0a0a0f; }

/* 空状态 */
.empty-state { text-align: center; padding: 80px 20px; }
.empty-icon { width: 80px; height: 80px; margin: 0 auto 24px; border-radius: 50%; background: var(--bg-secondary, #f5f3f0); display: flex; align-items: center; justify-content: center; font-size: 32px; }
.empty-title { font-size: 22px; font-weight: 600; margin-bottom: 8px; color: var(--text-primary, #1a1a1a); }
.empty-desc { color: var(--text-muted, #9a9a9a); font-size: 14px; margin-bottom: 24px; }
.btn-primary-dark {
  padding: 14px 36px; border-radius: 16px; border: none;
  background: var(--bg-dark, #1a1a1a); color: #0a0a0f;
  font-size: 14px; font-weight: 600; cursor: pointer;
}
.btn-primary-dark:hover { background: #333; transform: translateY(-2px); box-shadow: 0 8px 24px rgba(0,0,0,0.15); }

/* ===== CSS 星星评分 ===== */
.review-overlay {
  position: fixed; inset: 0; z-index: 1000;
  background: rgba(0,0,0,0.4);
  display: flex; align-items: center; justify-content: center;
}
.review-modal {
  background: var(--bg-card); border-radius: 16px;
  width: 440px; max-width: 90vw;
  box-shadow: 0 24px 64px rgba(0,0,0,0.2);
  overflow: hidden;
}
.review-header {
  padding: 20px 24px;
  display: flex; justify-content: space-between; align-items: center;
  border-bottom: 1px solid #eee;
}
.review-header h3 { font-size: 18px; font-weight: 600; }
.review-close {
  width: 32px; height: 32px; border-radius: 50%; border: none;
  background: #f5f5f5; cursor: pointer; font-size: 16px;
  display: flex; align-items: center; justify-content: center;
}
.review-body { padding: 24px; }
.review-field { margin-bottom: 20px; }
.review-label {
  font-size: 13px; font-weight: 600; color: #333;
  margin-bottom: 10px; display: block;
}
.review-textarea {
  width: 100%; border: 1px solid #e0ddd8; border-radius: 10px;
  padding: 12px 16px; font-size: 14px; line-height: 1.6;
  resize: none; outline: none; font-family: inherit;
}
.review-textarea:focus { border-color: var(--accent, #c45c4a); }
.review-footer {
  padding: 16px 24px;
  display: flex; gap: 12px; justify-content: flex-end;
  border-top: 1px solid #eee;
}

.rating { display: inline-flex; flex-direction: row-reverse; }
.rating input { display: none; }
.rating label {
  cursor: pointer;
  color: var(--text-muted);
  transition: color 0.3s;
  font-size: 32px;
  padding: 0 2px;
}
.rating label:before { content: '\2605'; }
.rating input:checked ~ label,
.rating label:hover,
.rating label:hover ~ label { color: #ff8c00; }

@media (max-width: 768px) {
  .order-page { padding: 16px 20px 40px; }
  .stats-bar { grid-template-columns: repeat(3, 1fr); gap: 12px; }
  .order-body { flex-direction: column; gap: 12px; }
}
</style>
