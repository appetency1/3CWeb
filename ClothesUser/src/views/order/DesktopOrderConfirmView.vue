<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showLoadingToast, showFailToast, showToast } from 'vant'
import { orderApi } from '@/api/order'
import { addressApi } from '@/api/address'
import { useCartStore } from '@/stores/cart'
import type { Address } from '@/types/model'

const router = useRouter()
const cartStore = useCartStore()
const addresses = ref<Address[]>([])
const selectedAddressId = ref<number | null>(null)
const remark = ref('')
const submitting = ref(false)

const selectedAddress = computed(() =>
  addresses.value.find(a => a.id === selectedAddressId.value) || addresses.value.find(a => a.isDefault === 1)
)

const checkedItems = computed(() => cartStore.items.filter(i => i.checked))
const totalPrice = computed(() => checkedItems.value.reduce((s, i) => s + i.price * i.count, 0))

async function loadAddresses() {
  try {
    const data: any = await addressApi.list()
    addresses.value = data || []
    const def = addresses.value.find(a => a.isDefault === 1)
    if (def) selectedAddressId.value = def.id
    else if (addresses.value.length) selectedAddressId.value = addresses.value[0].id
  } catch { /* silent */ }
}

async function submitOrder() {
  if (!selectedAddressId.value) { showToast('请选择收货地址'); return }
  if (!checkedItems.value.length) { showToast('请选择商品'); return }
  submitting.value = true
  const t = showLoadingToast({ message: '提交中...', forbidClick: true })
  try {
    const result: any = await orderApi.create({
      addressId: selectedAddressId.value,
      cartIds: checkedItems.value.map(i => i.id as number),
      remark: remark.value || undefined,
    })
    cartStore.items = cartStore.items.filter(i => !i.checked)
    t.close()
    showToast('下单成功')
    router.replace({ name: 'orderDetail', params: { id: result.orderId } })
  } catch (e: any) { t.close(); showFailToast(e?.message || '下单失败') }
  finally { submitting.value = false }
}

onMounted(loadAddresses)
</script>

<template>
  <DesktopLayout>
    <div class="desktop-page-title">确认订单</div>

    <!-- Address -->
    <div
      v-if="selectedAddress"
      style="background:#fff;border-radius:12px;padding:20px;margin-bottom:16px;box-shadow:0 1px 4px rgba(0,0,0,0.06);display:flex;align-items:center;gap:12px;cursor:pointer"
      @click="router.push('/address')"
    >
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#9CA3AF" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
        <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/>
      </svg>
      <div style="flex:1">
        <div style="font-size:15px;font-weight:700;color:#1a1a1a">{{ selectedAddress.receiver }} <span style="font-weight:400;color:#888;font-size:13px;margin-left:12px">{{ selectedAddress.phone }}</span></div>
        <div style="font-size:13px;color:#666;margin-top:4px">{{ selectedAddress.province }}{{ selectedAddress.city }}{{ selectedAddress.district }}{{ selectedAddress.detail }}</div>
      </div>
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#D1D5DB" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <polyline points="9 18 15 12 9 6"/>
      </svg>
    </div>

    <!-- Items -->
    <div style="background:#fff;border-radius:12px;overflow:hidden;margin-bottom:16px;box-shadow:0 1px 4px rgba(0,0,0,0.06)">
      <div style="padding:14px 20px;border-bottom:1px solid #f5f5f5;font-size:14px;font-weight:700;color:#1a1a1a">商品信息</div>
      <div
        v-for="item in checkedItems"
        :key="`${item.goodsId}-${item.sku}`"
        style="display:flex;align-items:center;gap:14px;padding:14px 20px;border-bottom:1px solid #f8f8f8"
      >
        <img :src="item.image" style="width:64px;height:64px;border-radius:6px;object-fit:cover;background:#f5f5f5;flex-shrink:0" @error="($event.target as HTMLImageElement).src = '/assets/placeholders/product-placeholder.svg'" />
        <div style="flex:1;min-width:0">
          <div style="font-size:13px;color:#333;line-height:1.4;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden">{{ item.name }}</div>
          <div style="font-size:12px;color:#bbb;margin-top:4px">{{ item.sku || '默认规格' }}</div>
        </div>
        <div style="text-align:right;flex-shrink:0">
          <div style="font-size:15px;font-weight:700;color:#c9a96e">¥{{ item.price }}</div>
          <div style="font-size:12px;color:#bbb">×{{ item.count }}</div>
        </div>
      </div>
    </div>

    <!-- Remark -->
    <div style="background:#fff;border-radius:12px;padding:16px 20px;margin-bottom:16px;box-shadow:0 1px 4px rgba(0,0,0,0.06)">
      <div style="font-size:13px;color:#888;margin-bottom:8px">订单备注</div>
      <input v-model="remark" placeholder="选填，可备注特殊要求" style="width:100%;border:none;outline:none;font-size:14px;color:#333;background:transparent;box-sizing:border-box" />
    </div>

    <!-- Summary + Submit -->
    <div style="background:#fff;border-radius:12px;padding:20px;box-shadow:0 1px 4px rgba(0,0,0,0.06)">
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px">
        <span style="font-size:14px;color:#888">共 {{ checkedItems.length }} 件商品</span>
        <div style="font-size:14px;color:#888">合计: <span style="font-size:24px;font-weight:800;color:#c9a96e;font-family:Georgia,serif;margin-left:4px">¥{{ totalPrice.toFixed(2) }}</span></div>
      </div>
      <button
        class="desktop-checkout-btn"
        :disabled="submitting || !selectedAddressId || !checkedItems.length"
        @click="submitOrder"
      >{{ submitting ? '提交中...' : '提交订单' }}</button>
    </div>
  </DesktopLayout>
</template>
