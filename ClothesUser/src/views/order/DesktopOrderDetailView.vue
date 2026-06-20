<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { showLoadingToast, showFailToast, showToast } from 'vant'
import { orderApi } from '@/api/order'
import { userApi } from '@/api/user'
import { fullImgUrl, IMG_PLACEHOLDER } from '@/utils/img'

const route = useRoute()
const router = useRouter()
const id = Number(route.params.id)
const order = ref<any>(null)
const loading = ref(true)
const actionLoading = ref(false)
const countdownStr = ref('')
let countdownTimer: ReturnType<typeof setInterval> | null = null

const STATUS_MAP: Record<number, { label: string; desc: string }> = {
  0: { label: '待付款', desc: '订单已提交，请尽快完成支付以安排发货' },
  1: { label: '待发货', desc: '商家正在准备中' },
  2: { label: '待收货', desc: '包裹配送中' },
  3: { label: '已完成', desc: '交易已完成' },
  4: { label: '已取消', desc: '订单已取消' },
}

const statusInfo = computed(() => STATUS_MAP[Number(order.value?.status)] || { label: '未知', desc: '' })

async function fetchDetail() {
  loading.value = true
  try {
    const data: any = await orderApi.detail(id)
    order.value = data?.order ? { ...data.order, items: data.items || [] } : data
    // 初始化倒计时（距离创建时间24小时）
    startCountdown()
  } catch (e: any) { showFailToast('加载失败') }
  finally { loading.value = false }
}

const countdownExpired = ref(false)

function startCountdown() {
  if (countdownTimer) { clearInterval(countdownTimer); countdownTimer = null }
  if (Number(order.value?.status) !== 0) return
  const raw = order.value?.createTime
  const createMs = raw ? new Date(raw).getTime() : Date.now()
  // 如果时间解析失败或无效，回退到当前时间
  if (isNaN(createMs)) return
  const deadline = createMs + 24 * 60 * 60 * 1000
  function tick() {
    const diff = deadline - Date.now()
    if (diff <= 0) {
      countdownStr.value = '00:00:00'
      countdownExpired.value = true
      if (countdownTimer) clearInterval(countdownTimer)
      return
    }
    countdownExpired.value = false
    const h = Math.floor(diff / 3600000)
    const m = Math.floor((diff % 3600000) / 60000)
    const s = Math.floor((diff % 60000) / 1000)
    countdownStr.value = `${String(h).padStart(2,'0')}:${String(m).padStart(2,'0')}:${String(s).padStart(2,'0')}`
  }
  tick()
  countdownTimer = setInterval(tick, 1000)
}

async function handlePay() {
  actionLoading.value = true
  const t = showLoadingToast({ message: '支付中...', forbidClick: true })
  try {
    await orderApi.pay(id)
    t.close(); showToast('支付成功')
    await fetchDetail()
  } catch (e: any) { t.close(); showFailToast(e?.message || '支付失败') }
  finally { actionLoading.value = false }
}

async function handleCancel() {
  actionLoading.value = true
  try {
    await orderApi.cancel(id)
    showToast('订单已取消')
    await fetchDetail()
  } catch (e: any) { showFailToast(e?.message || '取消失败') }
  finally { actionLoading.value = false }
}

async function handleConfirm() {
  actionLoading.value = true
  try {
    await orderApi.confirm(id)
    showToast('确认成功')
    await fetchDetail()
  } catch (e: any) { showFailToast(e?.message || '操作失败') }
  finally { actionLoading.value = false }
}

// ── 评价 ──
const showReview = ref(false)
const reviewRating = ref(5)
const reviewContent = ref('')
const reviewSubmitting = ref(false)

function openReview() { showReview.value = true; reviewRating.value = 5; reviewContent.value = '' }

async function submitReview() {
  if (!reviewContent.value.trim()) { showToast('请填写评价内容'); return }
  if (!order.value?.items?.length) { showToast('订单商品信息缺失'); return }
  reviewSubmitting.value = true
  try {
    // 为每个商品提交评价
    for (const item of order.value.items) {
      await userApi.createComment({
        orderId: id,
        goodsId: item.goodsId,
        content: reviewContent.value,
        rating: reviewRating.value,
      })
    }
    showToast('评价成功')
    showReview.value = false
  } catch (e: any) { showFailToast(e?.message || '评价失败') }
  finally { reviewSubmitting.value = false }
}

onMounted(fetchDetail)
onUnmounted(() => { if (countdownTimer) clearInterval(countdownTimer) })
</script>

<template>
  <DesktopLayout>
    <div v-if="loading" class="detail-loading">加载中...</div>

    <template v-else-if="order">
      <div class="detail-container">

        <!-- ===== 状态横幅 ===== -->
        <div class="status-banner" :class="'status-' + order.status">
          <div class="status-main">
            <div class="status-icon-wrap">
              <!-- 待付款：时钟图标 -->
              <svg v-if="order.status === 0" class="status-svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>
              </svg>
              <!-- 待发货：包裹 -->
              <svg v-else-if="order.status === 1" class="status-svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <rect x="6" y="6" width="12" height="14" rx="2"/><path d="M6 10h12"/>
              </svg>
              <!-- 待收货：货车 -->
              <svg v-else-if="order.status === 2" class="status-svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <rect x="1" y="3" width="15" height="13"/><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/>
              </svg>
              <!-- 已完成：勾 -->
              <svg v-else-if="order.status === 3" class="status-svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/>
              </svg>
              <!-- 已取消：叉 -->
              <svg v-else class="status-svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/>
              </svg>
            </div>
            <div class="status-text">
              <h1>{{ statusInfo.label }}</h1>
              <p>{{ statusInfo.desc }}</p>
            </div>
          </div>
          <div v-if="order.status === 0" class="countdown-box" :class="{ expired: countdownExpired }">
            <div class="countdown-label">{{ countdownExpired ? '支付已超时' : '支付剩余时间' }}</div>
            <div class="countdown-time">{{ countdownExpired ? '已超时' : countdownStr }}</div>
          </div>
        </div>

        <!-- ===== 双列布局 ===== -->
        <div class="page-layout">
          <!-- 左列 -->
          <div class="left-column">

            <!-- 收货地址 -->
            <div class="card" v-if="order.address">
              <div class="card-header">
                <svg class="card-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/>
                </svg>
                <span class="card-title">收货地址</span>
              </div>
              <div class="card-body">
                <div class="address-block">
                  <div class="address-marker">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/>
                    </svg>
                  </div>
                  <div class="address-info">
                    <div class="addr-name">{{ order.receiver }} <span class="addr-phone">{{ order.phone }}</span></div>
                    <div class="addr-detail">{{ order.address }}</div>
                  </div>
                </div>
              </div>
            </div>

            <!-- 商品信息 -->
            <div class="card">
              <div class="card-header">
                <svg class="card-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/>
                </svg>
                <span class="card-title">商品信息</span>
              </div>
              <div class="card-body">
                <div v-for="(item, idx) in order.items" :key="item.id || idx" class="item-row" @click="router.push(`/goods/${item.goodsId}`)">
                  <img :src="fullImgUrl(item.goodsCover)" class="item-thumb" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" />
                  <div class="item-detail">
                    <div class="item-name">{{ item.goodsName }}</div>
                    <div class="item-spec">{{ item.spec || '默认规格' }}</div>
                    <div class="item-mobile-price">¥{{ item.price }} × {{ item.quantity }}</div>
                  </div>
                  <div class="item-price-col">
                    <div class="item-amount">¥{{ Number(item.price).toFixed(2) }}</div>
                    <div class="item-qty">×{{ item.quantity }}</div>
                  </div>
                </div>
              </div>
            </div>

            <!-- 订单信息 -->
            <div class="card">
              <div class="card-header">
                <svg class="card-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/>
                </svg>
                <span class="card-title">订单信息</span>
              </div>
              <div class="card-body">
                <div class="meta-grid">
                  <div class="meta-item"><span class="meta-label">订单编号</span><span class="meta-value mono">{{ order.orderNo }}</span></div>
                  <div class="meta-item"><span class="meta-label">下单时间</span><span class="meta-value">{{ order.createTime?.substring(0,19) || '' }}</span></div>
                  <div v-if="order.payTime" class="meta-item"><span class="meta-label">支付时间</span><span class="meta-value">{{ order.payTime.substring(0,19) }}</span></div>
                  <div class="meta-item"><span class="meta-label">配送方式</span><span class="meta-value">普通快递</span></div>
                  <div v-if="order.remark" class="meta-item"><span class="meta-label">备注</span><span class="meta-value">{{ order.remark }}</span></div>
                </div>
              </div>
            </div>
          </div>

          <!-- 右列：支付摘要（sticky） -->
          <div class="right-column">
            <div class="card summary-card">
              <div class="card-header">
                <svg class="card-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <rect x="1" y="4" width="22" height="16" rx="2" ry="2"/><line x1="1" y1="10" x2="23" y2="10"/>
                </svg>
                <span class="card-title">支付摘要</span>
              </div>
              <div class="card-body">
                <div class="summary-line">
                  <span>商品总价</span>
                  <span>¥{{ Number(order.totalAmount || 0).toFixed(2) }}</span>
                </div>
                <div class="summary-line">
                  <span>运费</span>
                  <span>{{ order.freetingAmount > 0 ? '¥' + Number(order.freightAmount).toFixed(2) : '免运费' }}</span>
                </div>
                <div v-if="order.discountAmount > 0" class="summary-line discount">
                  <span>优惠</span>
                  <span>-¥{{ Number(order.discountAmount).toFixed(2) }}</span>
                </div>
                <div class="summary-line total">
                  <span>订单总计</span>
                  <span>¥{{ Number(order.totalAmount || 0).toFixed(2) }}</span>
                </div>
                <div class="summary-line pay-line">
                  <span class="pay-label">实付款</span>
                  <span class="pay-amount">¥{{ Number(order.payAmount || order.totalAmount || 0).toFixed(2) }}</span>
                </div>
                <p v-if="order.status === 0" class="pay-note">{{ countdownExpired ? '支付已超时，该订单已无法支付' : '请在倒计时结束前完成支付，超时订单将自动关闭' }}</p>

                <div class="action-bar">
                  <button v-if="order.status === 0" class="btn btn-primary" @click="handlePay" :disabled="actionLoading">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M12 1v22M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
                    立即支付
                  </button>
                  <button v-if="order.status === 0" class="btn btn-outline" @click="handleCancel" :disabled="actionLoading">取消订单</button>
                  <button v-if="order.status === 2" class="btn btn-primary" @click="handleConfirm" :disabled="actionLoading">确认收货</button>
                  <button v-if="order.status === 1" class="btn btn-outline" @click="router.push('/order')">返回订单列表</button>
                  <template v-if="order.status === 3">
                    <button class="btn btn-primary" @click="openReview">去评价</button>
                    <button class="btn btn-outline" @click="router.push('/order')">返回订单列表</button>
                  </template>
                </div>

                <div class="secure-note">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                  </svg>
                  <span>安全加密支付 · 7天无理由退换</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <!-- ===== 评价弹窗 ===== -->
      <div v-if="showReview" class="review-overlay" @click.self="showReview = false">
        <div class="review-modal">
          <div class="review-header">
            <h3>评价商品</h3>
            <button class="review-close" @click="showReview = false">✕</button>
          </div>

          <div class="review-body">
            <div class="review-field">
              <label class="review-label">评分</label>
              <div class="star-group">
                <span v-for="s in 5" :key="s" class="star" :class="{ active: s <= reviewRating }" @click="reviewRating = s">★</span>
              </div>
            </div>

            <div class="review-field">
              <label class="review-label">评价内容</label>
              <textarea v-model="reviewContent" class="review-textarea" placeholder="分享您的购物体验，对其他买家很有帮助" rows="4" maxlength="500"></textarea>
              <div class="review-count">{{ reviewContent.length }}/500</div>
            </div>

            <div class="review-products">
              <div v-for="(item, idx) in order.items" :key="idx" class="review-product-item">
                <img :src="fullImgUrl(item.goodsCover)" class="review-product-img" />
                <span class="review-product-name">{{ item.goodsName }}</span>
              </div>
            </div>
          </div>

          <div class="review-footer">
            <button class="btn btn-outline" @click="showReview = false">取消</button>
            <button class="btn btn-primary" @click="submitReview" :disabled="reviewSubmitting">{{ reviewSubmitting ? '提交中...' : '提交评价' }}</button>
          </div>
        </div>
      </div>
    </template>
  </DesktopLayout>
</template>

<style scoped>
.detail-loading { padding: 80px 40px; text-align: center; color: #999; font-size: 15px; }

.detail-container {
  max-width: 1040px;
  margin: 0 auto;
  padding: 32px 32px 80px;
}

/* ===== 状态横幅 ===== */
.status-banner {
  background: #1a1a1a;
  border-radius: 16px;
  padding: 32px 40px;
  margin-bottom: 28px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  position: relative;
  overflow: hidden;
  animation: fadeSlideDown 0.5s ease-out;
}
@keyframes fadeSlideDown {
  from { opacity: 0; transform: translateY(-16px); }
  to { opacity: 1; transform: translateY(0); }
}
.status-banner::before {
  content: '';
  position: absolute;
  top: 0; right: 0;
  width: 300px; height: 100%;
  background: radial-gradient(circle at 80% 50%, rgba(196,92,74,0.15) 0%, transparent 70%);
  pointer-events: none;
}
.status-main {
  display: flex; align-items: center; gap: 20px;
  position: relative; z-index: 1;
}
.status-icon-wrap {
  width: 56px; height: 56px;
  border-radius: 50%;
  background: rgba(255,255,255,0.08);
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.status-0 .status-icon-wrap { background: rgba(236,169,62,0.12); }
.status-0 .status-svg { color: #eca93e; }
.status-1 .status-icon-wrap { background: rgba(59,130,246,0.12); }
.status-1 .status-svg { color: #3b82f6; }
.status-2 .status-icon-wrap { background: rgba(255,255,255,0.08); }
.status-2 .status-svg { color: #d0cbc4; }
.status-3 .status-icon-wrap { background: rgba(16,185,129,0.12); }
.status-3 .status-svg { color: #10b981; }
.status-banner.status-4 .status-icon-wrap { background: rgba(255,255,255,0.05); }
.status-banner.status-4 .status-svg { color: #666; }

.status-svg { width: 28px; height: 28px; }
.status-text h1 {
  font-size: 24px; font-weight: 600; color: #fff;
  margin-bottom: 4px; letter-spacing: 0.5px;
}
.status-text p { font-size: 14px; color: rgba(255,255,255,0.5); }

.countdown-box { text-align: right; position: relative; z-index: 1; flex-shrink: 0; }
.countdown-label { font-size: 12px; color: rgba(255,255,255,0.4); letter-spacing: 1px; margin-bottom: 6px; }
.countdown-time {
  font-size: 28px; font-weight: 600;
  font-variant-numeric: tabular-nums;
  color: #eca93e;
  letter-spacing: 2px;
}
.countdown-box.expired .countdown-label { color: rgba(255,100,100,0.6); }
.countdown-box.expired .countdown-time { color: #ff6b6b; font-size: 20px; letter-spacing: 0; }

/* ===== 双列布局 ===== */
.page-layout {
  display: grid;
  grid-template-columns: 1fr 320px;
  gap: 24px;
  align-items: start;
}

/* ===== 卡片 ===== */
.card {
  background: #fff;
  border-radius: 16px;
  border: 1px solid #ece9e4;
  overflow: hidden;
  margin-bottom: 20px;
}
.card-header {
  padding: 18px 24px;
  border-bottom: 1px solid #f3f1ed;
  display: flex; align-items: center; gap: 10px;
}
.card-icon { width: 18px; height: 18px; color: #9a9a9a; }
.card-title { font-size: 14px; font-weight: 600; color: #1a1a1a; letter-spacing: 0.5px; }
.card-body { padding: 24px; }

/* ===== 地址 ===== */
.address-block { display: flex; gap: 16px; align-items: flex-start; }
.address-marker {
  width: 40px; height: 40px; border-radius: 50%;
  background: #f3f1ed;
  display: flex; align-items: center; justify-content: center;
  color: #c45c4a; flex-shrink: 0;
}
.addr-name { font-size: 15px; font-weight: 600; color: #1a1a1a; margin-bottom: 4px; }
.addr-phone { font-size: 13px; color: #9a9a9a; font-weight: 400; margin-left: 8px; }
.addr-detail { font-size: 14px; color: #6b6b6b; line-height: 1.6; }

/* ===== 商品列表 ===== */
.item-row {
  display: flex; gap: 18px; padding: 18px 0;
  border-bottom: 1px solid #f3f1ed; cursor: pointer;
}
.item-row:last-child { border-bottom: none; padding-bottom: 0; }
.item-row:first-child { padding-top: 0; }
.item-thumb {
  width: 80px; height: 80px; border-radius: 10px; object-fit: cover;
  background: #f3f1ed; border: 1px solid #ece9e4; flex-shrink: 0;
}
.item-row:hover .item-thumb { transform: scale(1.03); }
.item-detail { flex: 1; min-width: 0; display: flex; flex-direction: column; justify-content: center; }
.item-name {
  font-size: 14px; font-weight: 500; color: #1a1a1a;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
  line-height: 1.5; margin-bottom: 6px;
}
.item-spec { font-size: 12px; color: #9a9a9a; }
.item-mobile-price { display: none; font-size: 13px; font-weight: 600; color: #c45c4a; margin-top: 4px; }
.item-price-col { text-align: right; flex-shrink: 0; display: flex; flex-direction: column; justify-content: center; }
.item-amount { font-size: 15px; font-weight: 600; color: #1a1a1a; }
.item-qty { font-size: 12px; color: #9a9a9a; margin-top: 2px; }

/* ===== 订单元信息 ===== */
.meta-grid { display: flex; flex-direction: column; gap: 14px; }
.meta-item { display: flex; justify-content: space-between; font-size: 13px; }
.meta-label { color: #9a9a9a; }
.meta-value { color: #1a1a1a; font-weight: 500; text-align: right; max-width: 60%; word-break: break-all; }
.meta-value.mono { letter-spacing: 0.5px; font-size: 12px; }

/* ===== 右栏 - 支付摘要 ===== */
.right-column { position: sticky; top: 96px; }
.summary-card .card-body { padding: 28px; }
.summary-line {
  display: flex; justify-content: space-between;
  font-size: 14px; padding: 8px 0;
  color: #6b6b6b;
}
.summary-line.total {
  font-size: 15px; font-weight: 600; color: #1a1a1a;
  padding-top: 16px; margin-top: 12px;
  border-top: 1px solid #ece9e4;
}
.summary-line.discount span:last-child { color: #2d8a5e; font-weight: 600; }
.pay-line {
  padding-top: 18px; margin-top: 6px;
  border-top: 1px solid #ece9e4;
}
.pay-label { font-size: 14px; font-weight: 600; color: #1a1a1a; }
.pay-amount { font-size: 28px; font-weight: 700; color: #c45c4a; letter-spacing: 0.5px; }
.pay-note { font-size: 12px; color: #9a9a9a; margin-top: 10px; }

.action-bar { display: flex; flex-direction: column; gap: 12px; margin-top: 24px; }
.btn {
  padding: 14px 24px; border-radius: 100px;
  font-family: inherit; font-size: 14px; font-weight: 600;
  cursor: pointer; border: none; letter-spacing: 0.5px;
  text-align: center; display: inline-flex; align-items: center;
  justify-content: center; gap: 8px;
  transition: all 0.3s cubic-bezier(0.4,0,0.2,1);
}
.btn-primary {
  background: #c45c4a; color: white;
}
.btn-primary:hover {
  background: #8b3a2a; transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(196,92,74,0.28);
}
.btn-primary:disabled { opacity: 0.6; cursor: not-allowed; transform: none; box-shadow: none; }
.btn-outline {
  background: transparent; border: 1px solid #ece9e4; color: #6b6b6b;
}
.btn-outline:hover { border-color: #1a1a1a; color: #1a1a1a; }
.btn-outline:disabled { opacity: 0.5; cursor: not-allowed; }

.secure-note {
  display: flex; align-items: center; justify-content: center;
  gap: 6px; margin-top: 20px;
  font-size: 11px; color: #9a9a9a;
}
.secure-note svg { width: 14px; height: 14px; }

/* ===== 评价弹窗 ===== */
.review-overlay {
  position: fixed; inset: 0; z-index: 1000;
  background: rgba(0,0,0,0.4);
  display: flex; align-items: center; justify-content: center;
  padding: 20px;
  animation: fadeIn 0.2s ease-out;
}
@keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
.review-modal {
  background: #fff; border-radius: 20px; width: 100%; max-width: 480px;
  max-height: 90vh; overflow-y: auto;
  animation: slideUpModal 0.3s ease-out;
}
@keyframes slideUpModal { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
.review-header {
  display: flex; align-items: center; justify-content: space-between;
  padding: 20px 24px; border-bottom: 1px solid #f3f1ed;
}
.review-header h3 { font-size: 17px; font-weight: 600; color: #1a1a1a; }
.review-close { background: none; border: none; font-size: 20px; color: #999; cursor: pointer; padding: 4px; }
.review-body { padding: 24px; }
.review-field { margin-bottom: 20px; }
.review-label { font-size: 13px; font-weight: 600; color: #1a1a1a; margin-bottom: 8px; display: block; }
.star-group { display: flex; gap: 8px; }
.star { font-size: 32px; color: #e0ddd8; cursor: pointer; transition: color 0.2s, transform 0.2s; }
.star:hover { transform: scale(1.2); }
.star.active { color: #f5a623; }
.review-textarea {
  width: 100%; padding: 14px; border: 1.5px solid #ece9e4; border-radius: 12px;
  font-family: inherit; font-size: 14px; color: #1a1a1a; resize: vertical;
  outline: none; transition: border-color 0.2s; box-sizing: border-box;
}
.review-textarea:focus { border-color: #c45c4a; }
.review-count { text-align: right; font-size: 12px; color: #9a9a9a; margin-top: 4px; }
.review-products { display: flex; flex-wrap: wrap; gap: 8px; }
.review-product-item {
  display: flex; align-items: center; gap: 8px;
  background: #faf8f6; border-radius: 8px; padding: 6px 10px;
}
.review-product-img { width: 32px; height: 32px; border-radius: 6px; object-fit: cover; }
.review-product-name { font-size: 12px; color: #6b6b6b; }
.review-footer {
  display: flex; gap: 12px; padding: 20px 24px;
  border-top: 1px solid #f3f1ed;
}
.review-footer .btn { flex: 1; }

/* ===== 响应式 ===== */
@media (max-width: 900px) {
  .page-layout { grid-template-columns: 1fr; }
  .right-column { position: static; }
  .status-banner { flex-direction: column; align-items: flex-start; gap: 20px; }
  .countdown-box { text-align: left; }
}
@media (max-width: 768px) {
  .detail-container { padding: 20px 16px 60px; }
  .status-banner { padding: 24px; border-radius: 12px; }
  .status-text h1 { font-size: 20px; }
  .countdown-time { font-size: 22px; }
  .item-price-col { display: none; }
  .item-mobile-price { display: block; }
  .pay-amount { font-size: 24px; }
}
</style>
