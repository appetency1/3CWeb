<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { showLoadingToast, showFailToast, showToast } from 'vant'
import { orderApi } from '@/api/order'
import { fullImgUrl } from '@/utils/img'

const route = useRoute()
const router = useRouter()
const id = Number(route.params.id)

const order = ref<any>(null)
const loading = ref(true)
const actionLoading = ref(false)

const STATUS_STEPS = [
  { label: '提交订单', icon: '🎉' },
  { label: '支付成功', icon: '💳' },
  { label: '商家发货', icon: '📦' },
  { label: '确认收货', icon: '✨' },
]

function getStatusConf(status: number) {
  const map: Record<number, any> = {
    0: { label: '待付款', color: 'var(--cl-orange)', step: 0 },
    1: { label: '待发货', color: 'var(--cl-blue)', step: 1 },
    2: { label: '待收货', color: 'var(--cl-primary)', step: 2 },
    3: { label: '已完成', color: 'var(--cl-green)', step: 3 },
    4: { label: '已取消', color: 'var(--cl-text-muted)', step: -1 },
  }
  return map[status] || { label: '未知', color: 'var(--cl-text-muted)', step: -1 }
}

async function fetchDetail() {
  loading.value = true
  try {
    const data: any = await orderApi.detail(id)
    order.value = data
  } catch (e: any) {
    showFailToast('加载失败')
  } finally {
    loading.value = false
  }
}

async function handlePay() {
  actionLoading.value = true
  const toast = showLoadingToast({ message: '支付中...', forbidClick: true })
  try {
    await orderApi.pay(id)
    toast.close()
    showToast('支付成功')
    await fetchDetail()
  } catch (e: any) {
    toast.close()
    showFailToast(e?.message || '支付失败')
  } finally {
    actionLoading.value = false
  }
}

async function handleCancel() {
  actionLoading.value = true
  try {
    await orderApi.cancel(id)
    showToast('订单已取消')
    await fetchDetail()
  } catch (e: any) {
    showFailToast(e?.message || '取消失败')
  } finally {
    actionLoading.value = false
  }
}

async function handleConfirm() {
  actionLoading.value = true
  try {
    await orderApi.confirm(id)
    showToast('确认收货成功')
    await fetchDetail()
  } catch (e: any) {
    showFailToast(e?.message || '操作失败')
  } finally {
    actionLoading.value = false
  }
}

onMounted(fetchDetail)
</script>

<template>
  <div class="order-detail-page">
    <van-nav-bar title="订单详情" left-arrow @click-left="router.back()" />

    <!-- Loading -->
    <template v-if="loading">
      <div style="padding: 16px">
        <div class="skeleton" style="height: 80px; border-radius: 12px; margin-bottom: 12px" />
        <div class="skeleton" style="height: 120px; border-radius: 12px; margin-bottom: 12px" />
        <div class="skeleton" style="height: 60px; border-radius: 12px" />
      </div>
    </template>

    <template v-else-if="order">
      <!-- Status Banner -->
      <div class="status-banner" :style="{ background: getStatusConf(order.status).color }">
        <div class="status-icon">{{ order.status === 4 ? '❌' : ['⏳', '📦', '🚚', '✅'][order.status] || '❓' }}</div>
        <div class="status-info">
          <p class="status-label">{{ getStatusConf(order.status).label }}</p>
          <p class="status-tip">
            {{ order.status === 0 ? '请尽快完成支付' : order.status === 1 ? '商家正在准备中' : order.status === 2 ? '包裹正在配送中' : order.status === 3 ? '交易已完成' : '订单已取消' }}
          </p>
        </div>
      </div>

      <!-- Address -->
      <div class="address-card" v-if="order.address">
        <div class="address-icon">📍</div>
        <div class="address-info">
          <p class="address-receiver">{{ order.receiver }} <span>{{ order.phone }}</span></p>
          <p class="address-detail">{{ order.address }}</p>
        </div>
      </div>

      <!-- Progress Steps -->
      <div class="progress-card" v-if="order.status !== 4">
        <div class="progress-steps">
          <div
            v-for="(step, idx) in STATUS_STEPS"
            :key="idx"
            class="progress-step"
            :class="{
              active: idx < getStatusConf(order.status).step,
              current: idx === getStatusConf(order.status).step,
            }"
          >
            <div class="step-icon">{{ step.icon }}</div>
            <div class="step-label">{{ step.label }}</div>
            <div v-if="idx < STATUS_STEPS.length - 1" class="step-line" />
          </div>
        </div>
      </div>

      <!-- Order Items -->
      <div class="items-card">
        <div class="items-header">
          <span class="items-title">商品信息</span>
          <span class="items-no">订单号: {{ order.orderNo }}</span>
        </div>
        <div
          v-for="(item, idx) in order.items"
          :key="item.id || idx"
          class="order-item"
          @click="router.push(`/goods/${item.goodsId}`)"
        >
          <img :src="fullImgUrl(item.goodsCover)" class="item-img" />
          <div class="item-info">
            <p class="item-name">{{ item.goodsName }}</p>
            <p class="item-sku">{{ item.spec || '默认规格' }}</p>
          </div>
          <div class="item-right">
            <span class="item-price">¥{{ item.price }}</span>
            <span class="item-qty">x{{ item.quantity }}</span>
          </div>
        </div>
      </div>

      <!-- Order Summary -->
      <div class="summary-card">
        <div class="summary-row">
          <span>商品总价</span>
          <span>¥{{ order.totalAmount }}</span>
        </div>
        <div class="summary-row">
          <span>运费</span>
          <span>{{ order.freightAmount > 0 ? `¥${order.freightAmount}` : '免运费' }}</span>
        </div>
        <div class="summary-row" v-if="order.discountAmount > 0">
          <span>优惠</span>
          <span class="text-red">-¥{{ order.discountAmount }}</span>
        </div>
        <div class="summary-row total">
          <span>实付款</span>
          <span class="total-price">¥{{ order.payAmount || order.totalAmount }}</span>
        </div>
        <div class="summary-row" v-if="order.remark">
          <span>备注</span>
          <span class="remark">{{ order.remark }}</span>
        </div>
      </div>

      <!-- Time Info -->
      <div class="time-card">
        <div class="time-row" v-if="order.createTime">
          <span>下单时间</span>
          <span>{{ order.createTime.substring(0, 19) }}</span>
        </div>
        <div class="time-row" v-if="order.payTime">
          <span>支付时间</span>
          <span>{{ order.payTime.substring(0, 19) }}</span>
        </div>
        <div class="time-row" v-if="order.shipTime">
          <span>发货时间</span>
          <span>{{ order.shipTime.substring(0, 19) }}</span>
        </div>
        <div class="time-row" v-if="order.finishTime">
          <span>完成时间</span>
          <span>{{ order.finishTime.substring(0, 19) }}</span>
        </div>
      </div>

      <!-- Spacer -->
      <div style="height: 80px" />

      <!-- Bottom Action Bar -->
      <div class="detail-action-bar" v-if="order.status !== 4">
        <div class="action-left">
          合计: <span class="action-total">¥{{ order.payAmount || order.totalAmount }}</span>
        </div>
        <div class="action-btns">
          <van-button
            v-if="order.status === 0"
            size="small"
            plain
            round
            @click="handleCancel"
            :loading="actionLoading"
          >取消订单</van-button>
          <van-button
            v-if="order.status === 0"
            type="danger"
            size="small"
            round
            @click="handlePay"
            :loading="actionLoading"
          >去付款</van-button>
          <van-button
            v-if="order.status === 2"
            type="primary"
            size="small"
            round
            @click="handleConfirm"
            :loading="actionLoading"
          >确认收货</van-button>
        </div>
      </div>
    </template>
  </div>
</template>

<style scoped>
.order-detail-page {
  min-height: 100vh;
  background: var(--cl-bg);
  padding-bottom: env(safe-area-inset-bottom);
}

/* Status Banner */
.status-banner {
  padding: 24px 20px;
  display: flex;
  align-items: center;
  gap: 14px;
  color: #fff;
}
.status-icon { font-size: 40px; }
.status-label {
  font-size: 20px;
  font-weight: 700;
  font-family: var(--font-display);
  margin-bottom: 4px;
}
.status-tip { font-size: 13px; opacity: 0.8; }

/* Address */
.address-card {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  background: var(--cl-bg-card);
  padding: 16px;
  margin: 12px;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-xs);
}
.address-icon { font-size: 20px; flex-shrink: 0; margin-top: 2px; }
.address-receiver {
  font-size: 15px;
  font-weight: 600;
  color: var(--cl-text-primary);
  margin-bottom: 4px;
}
.address-receiver span {
  font-size: 13px;
  font-weight: 400;
  color: var(--cl-text-secondary);
  margin-left: 10px;
}
.address-detail {
  font-size: 13px;
  color: var(--cl-text-secondary);
  line-height: 1.5;
}

/* Progress */
.progress-card {
  background: var(--cl-bg-card);
  margin: 0 12px 12px;
  border-radius: var(--radius-lg);
  padding: 16px;
  box-shadow: var(--shadow-xs);
}
.progress-steps {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.progress-step {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  position: relative;
  flex: 1;
}
.step-icon {
  font-size: 24px;
  opacity: 0.3;
  transition: opacity 0.3s;
}
.progress-step.active .step-icon,
.progress-step.current .step-icon {
  opacity: 1;
}
.step-label {
  font-size: 11px;
  color: var(--cl-text-muted);
  text-align: center;
}
.progress-step.active .step-label,
.progress-step.current .step-label {
  color: var(--cl-text-secondary);
  font-weight: 500;
}
.step-line {
  position: absolute;
  top: 12px;
  left: 60%;
  width: 100%;
  height: 2px;
  background: var(--cl-border-light);
  z-index: 0;
}
.progress-step.active .step-line {
  background: var(--cl-green);
}

/* Items Card */
.items-card {
  background: var(--cl-bg-card);
  margin: 0 12px 12px;
  border-radius: var(--radius-lg);
  overflow: hidden;
  box-shadow: var(--shadow-xs);
}
.items-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 14px;
  border-bottom: 1px solid var(--cl-border-light);
}
.items-title {
  font-size: 14px;
  font-weight: 600;
  color: var(--cl-text-primary);
}
.items-no {
  font-size: 11px;
  color: var(--cl-text-muted);
}
.order-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px 14px;
  border-bottom: 1px solid var(--cl-border-light);
  cursor: pointer;
  transition: background var(--transition-fast);
}
.order-item:last-child { border-bottom: none; }
.order-item:active { background: var(--cl-bg-muted); }
.item-img {
  width: 56px;
  height: 56px;
  border-radius: var(--radius-sm);
  object-fit: cover;
  background: var(--cl-bg-muted);
  flex-shrink: 0;
}
.item-info { flex: 1; min-width: 0; }
.item-name {
  font-size: 13px;
  color: var(--cl-text-primary);
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  margin-bottom: 4px;
}
.item-sku { font-size: 11px; color: var(--cl-text-muted); }
.item-right {
  flex-shrink: 0;
  text-align: right;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 4px;
}
.item-price { font-size: 13px; font-weight: 600; color: var(--cl-text-primary); }
.item-qty { font-size: 11px; color: var(--cl-text-muted); }

/* Summary */
.summary-card {
  background: var(--cl-bg-card);
  margin: 0 12px 12px;
  border-radius: var(--radius-lg);
  padding: 12px 14px;
  box-shadow: var(--shadow-xs);
}
.summary-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  font-size: 13px;
  color: var(--cl-text-secondary);
  border-bottom: 1px solid var(--cl-border-light);
}
.summary-row:last-child { border-bottom: none; }
.summary-row.total { font-weight: 600; color: var(--cl-text-primary); }
.total-price { font-size: 18px; font-weight: 700; color: var(--cl-red); }
.text-red { color: var(--cl-red); }
.remark { color: var(--cl-text-muted); font-size: 12px; max-width: 60%; text-align: right; }

/* Time */
.time-card {
  background: var(--cl-bg-card);
  margin: 0 12px 12px;
  border-radius: var(--radius-lg);
  padding: 8px 14px;
  box-shadow: var(--shadow-xs);
}
.time-row {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  font-size: 12px;
  color: var(--cl-text-muted);
  border-bottom: 1px solid var(--cl-border-light);
}
.time-row:last-child { border-bottom: none; }

/* Bottom Action */
.detail-action-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  height: 60px;
  background: var(--cl-bg-card);
  border-top: 1px solid var(--cl-border-light);
  box-shadow: 0 -2px 12px rgba(26,26,46,0.06);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16px;
  padding-bottom: env(safe-area-inset-bottom);
  z-index: 100;
}
.action-left {
  font-size: 13px;
  color: var(--cl-text-secondary);
}
.action-total {
  font-size: 18px;
  font-weight: 700;
  color: var(--cl-red);
  margin-left: 4px;
}
.action-btns {
  display: flex;
  gap: 8px;
}
</style>
