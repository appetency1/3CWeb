<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { showLoadingToast, showFailToast, showToast } from 'vant'
import { orderApi } from '@/api/order'
import { fullImgUrl, IMG_PLACEHOLDER } from '@/utils/img'

const route = useRoute()
const router = useRouter()
const id = Number(route.params.id)
const order = ref<any>(null)
const loading = ref(true)
const actionLoading = ref(false)

const STATUS_MAP: Record<number, any> = {
  0: { label: '待付款', color: '#e67e22' },
  1: { label: '待发货', color: '#3498db' },
  2: { label: '待收货', color: '#1a1a1a' },
  3: { label: '已完成', color: '#27ae60' },
  4: { label: '已取消', color: '#bbb' },
}

async function fetchDetail() {
  loading.value = true
  try { order.value = await orderApi.detail(id) }
  catch (e: any) { showFailToast('加载失败') }
  finally { loading.value = false }
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

async function handleConfirm() {
  actionLoading.value = true
  try {
    await orderApi.confirm(id)
    showToast('确认成功')
    await fetchDetail()
  } catch (e: any) { showFailToast(e?.message || '操作失败') }
  finally { actionLoading.value = false }
}

onMounted(fetchDetail)
</script>

<template>
  <DesktopLayout>
    <div v-if="loading" style="padding:40px;text-align:center;color:#bbb">加载中...</div>

    <template v-else-if="order">
      <!-- Status Banner -->
      <div style="background:#1a1a1a;border-radius:12px;padding:24px 32px;margin-bottom:20px;display:flex;align-items:center;gap:16px">
        <div style="font-size:40px">
          <svg width="40" height="40" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg">
            <template v-if="order.status === 0">
              <circle cx="20" cy="20" r="18" stroke="#F59E0B" stroke-width="2.5" fill="none"/>
              <path d="M20 10 L20 22" stroke="#F59E0B" stroke-width="2.5" stroke-linecap="round"/>
              <path d="M20 26 A6 6 0 1 1 20 14" stroke="#F59E0B" stroke-width="2.5" stroke-linecap="round" fill="none"/>
            </template>
            <template v-else-if="order.status === 1">
              <rect x="6" y="10" width="28" height="24" rx="4" stroke="#3B82F6" stroke-width="2.5" fill="none"/>
              <path d="M6 16 L20 24 L34 16" stroke="#3B82F6" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
            </template>
            <template v-else-if="order.status === 2">
              <path d="M6 8 L34 8 L34 32 L6 32 Z" stroke="#1E2433" stroke-width="2.5" fill="none"/>
              <path d="M6 8 L14 18 L24 12 L34 8" stroke="#1E2433" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
              <circle cx="20" cy="24" r="4" stroke="#1E2433" stroke-width="2"/>
            </template>
            <template v-else-if="order.status === 3">
              <circle cx="20" cy="20" r="16" stroke="#10B981" stroke-width="2.5" fill="none"/>
              <path d="M13 20 L18 25 L27 15" stroke="#10B981" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
            </template>
            <template v-else>
              <circle cx="20" cy="20" r="16" stroke="#9CA3AF" stroke-width="2.5" fill="none"/>
              <path d="M14 14 L26 26 M26 14 L14 26" stroke="#9CA3AF" stroke-width="2.5" stroke-linecap="round"/>
            </template>
          </svg>
        </div>
        <div>
          <div style="font-size:20px;font-weight:700;color:#fff;font-family:Georgia,serif">{{ STATUS_MAP[order.status]?.label }}</div>
          <div style="font-size:13px;color:rgba(255,255,255,0.5);margin-top:4px">
            {{ order.status === 0 ? '请尽快完成支付' : order.status === 1 ? '商家正在准备中' : order.status === 2 ? '包裹配送中' : order.status === 3 ? '交易已完成' : '订单已取消' }}
          </div>
        </div>
      </div>

      <!-- Address -->
      <div v-if="order.address" style="background:#fff;border-radius:12px;padding:20px;margin-bottom:16px;box-shadow:0 1px 4px rgba(0,0,0,0.06);display:flex;align-items:center;gap:12px">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#9CA3AF" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
          <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/>
        </svg>
        <div>
          <div style="font-size:15px;font-weight:700;color:#1a1a1a">{{ order.receiver }} <span style="font-weight:400;color:#888;font-size:13px;margin-left:12px">{{ order.phone }}</span></div>
          <div style="font-size:13px;color:#666;margin-top:4px">{{ order.address }}</div>
        </div>
      </div>

      <!-- Order Items -->
      <div style="background:#fff;border-radius:12px;overflow:hidden;margin-bottom:16px;box-shadow:0 1px 4px rgba(0,0,0,0.06)">
        <div style="padding:14px 20px;border-bottom:1px solid #f5f5f5;font-size:14px;font-weight:700;color:#1a1a1a">商品信息</div>
        <div
          v-for="(item, idx) in order.items"
          :key="item.id || idx"
          style="display:flex;align-items:center;gap:14px;padding:14px 20px;border-bottom:1px solid #f8f8f8;cursor:pointer"
          @click="router.push(`/goods/${item.goodsId}`)"
        >
          <img :src="fullImgUrl(item.goodsCover)" style="width:64px;height:64px;border-radius:6px;object-fit:cover;background:#f5f5f5;flex-shrink:0" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" />
          <div style="flex:1;min-width:0">
            <div style="font-size:13px;color:#333;line-height:1.5;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden">{{ item.goodsName }}</div>
            <div style="font-size:12px;color:#bbb;margin-top:4px">{{ item.spec || '默认规格' }} × {{ item.quantity }}</div>
          </div>
          <div style="text-align:right;flex-shrink:0">
            <div style="font-size:14px;font-weight:700;color:#333">¥{{ item.price }}</div>
            <div style="font-size:12px;color:#bbb">×{{ item.quantity }}</div>
          </div>
        </div>
      </div>

      <!-- Summary -->
      <div style="background:#fff;border-radius:12px;padding:16px 20px;margin-bottom:16px;box-shadow:0 1px 4px rgba(0,0,0,0.06)">
        <div style="display:flex;justify-content:space-between;font-size:13px;color:#888;padding:6px 0">
          <span>商品总价</span><span>¥{{ order.totalAmount }}</span>
        </div>
        <div style="display:flex;justify-content:space-between;font-size:13px;color:#888;padding:6px 0">
          <span>运费</span><span>{{ order.freightAmount > 0 ? `¥${order.freightAmount}` : '免运费' }}</span>
        </div>
        <div style="display:flex;justify-content:space-between;font-size:18px;font-weight:800;padding:12px 0 0;border-top:1px solid #f0f0f0;margin-top:4px;color:#c9a96e">
          <span>实付款</span><span>¥{{ order.payAmount || order.totalAmount }}</span>
        </div>
        <div style="font-size:12px;color:#bbb;margin-top:8px">订单号: {{ order.orderNo }}</div>
        <div v-if="order.createTime" style="font-size:12px;color:#bbb;margin-top:4px">下单时间: {{ order.createTime.substring(0,19) }}</div>
      </div>

      <!-- Actions -->
      <div v-if="order.status !== 4" style="display:flex;justify-content:flex-end;gap:10px">
        <button v-if="order.status === 0" class="desktop-order-action-btn" @click="orderApi.cancel(id).then(() => fetchDetail())">取消订单</button>
        <button v-if="order.status === 0" class="desktop-order-action-btn primary" @click="handlePay" :disabled="actionLoading">去付款</button>
        <button v-if="order.status === 2" class="desktop-order-action-btn primary" @click="handleConfirm" :disabled="actionLoading">确认收货</button>
        <button class="desktop-order-action-btn" @click="router.push('/order')">返回订单列表</button>
      </div>
    </template>
  </DesktopLayout>
</template>
