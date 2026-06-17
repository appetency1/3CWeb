<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showLoadingToast, showFailToast, showToast } from 'vant'
import { orderApi } from '@/api/order'
import type { CreateOrderParams } from '@/api/order'
import { addressApi } from '@/api/address'
import { useCartStore } from '@/stores/cart'
import type { Address } from '@/types/model'

const router = useRouter()
const cartStore = useCartStore()

const addresses = ref<Address[]>([])
const selectedAddressId = ref<number | null>(null)
const remark = ref('')
const loading = ref(false)
const submitting = ref(false)

const selectedAddress = computed(() =>
  addresses.value.find(a => a.id === selectedAddressId.value) || addresses.value.find(a => a.isDefault === 1)
)

const checkedItems = computed(() =>
  cartStore.items.filter(i => i.checked)
)

const totalPrice = computed(() =>
  checkedItems.value.reduce((sum, i) => sum + i.price * i.count, 0)
)

async function loadAddresses() {
  loading.value = true
  try {
    const data: any = await addressApi.list()
    addresses.value = data || []
    const def = addresses.value.find(a => a.isDefault === 1)
    if (def) selectedAddressId.value = def.id
    else if (addresses.value.length) selectedAddressId.value = addresses.value[0].id
  } catch (e: any) {
    showFailToast('加载失败')
  } finally {
    loading.value = false
  }
}

async function submitOrder() {
  if (!selectedAddressId.value) {
    showToast('请选择收货地址')
    return
  }
  if (!checkedItems.value.length) {
    showToast('请选择商品')
    return
  }
  submitting.value = true
  const toast = showLoadingToast({ message: '提交中...', forbidClick: true })
  try {
    const cartIds = checkedItems.value.map(i => i.id as number)
    const params: CreateOrderParams = {
      addressId: selectedAddressId.value,
      cartIds,
      remark: remark.value || undefined,
    }
    const result: any = await orderApi.create(params)
    cartStore.items = cartStore.items.filter(i => !i.checked)
    toast.close()
    showToast('下单成功')
    router.replace({ name: 'orderDetail', params: { id: result.orderId } })
  } catch (e: any) {
    toast.close()
    showFailToast(e?.message || '下单失败')
  } finally {
    submitting.value = false
  }
}

onMounted(loadAddresses)
</script>

<template>
  <div class="confirm-page">
    <van-nav-bar title="确认订单" left-arrow @click-left="router.back()" />

    <!-- Address Section -->
    <div class="section-card address-section" @click="router.push('/address')">
      <div v-if="selectedAddress" class="addr-content">
        <div class="addr-row">
          <span class="addr-name">{{ selectedAddress.receiver }}</span>
          <span class="addr-phone">{{ selectedAddress.phone }}</span>
        </div>
        <p class="addr-full">
          {{ selectedAddress.province }}{{ selectedAddress.city }}{{ selectedAddress.district }}{{ selectedAddress.detail }}
        </p>
      </div>
      <div v-else class="addr-empty">
        <van-icon name="plus" size="20" />
        <span>添加收货地址</span>
      </div>
      <van-icon name="arrow" class="addr-arrow" />
    </div>

    <!-- Goods Items -->
    <div class="section-card goods-section">
      <div class="section-title">商品信息</div>
      <div
        v-for="item in checkedItems"
        :key="`${item.goodsId}-${item.sku}`"
        class="goods-item"
      >
        <img :src="item.image" class="goods-img" />
        <div class="goods-info">
          <p class="goods-name">{{ item.name }}</p>
          <p class="goods-sku">{{ item.sku || '默认规格' }}</p>
          <div class="goods-bottom">
            <span class="goods-price">¥{{ item.price }}</span>
            <span class="goods-qty">x{{ item.count }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Remark -->
    <div class="section-card">
      <div class="remark-row">
        <span class="remark-label">订单备注</span>
        <van-field
          v-model="remark"
          placeholder="选填，可备注特殊要求"
          :border="false"
          input-align="right"
          class="remark-input"
        />
      </div>
    </div>

    <!-- Price Summary -->
    <div class="section-card price-section">
      <div class="price-row">
        <span>商品总价</span>
        <span>¥{{ totalPrice }}</span>
      </div>
      <div class="price-row">
        <span>运费</span>
        <span class="free">免运费</span>
      </div>
      <div class="price-divider" />
      <div class="price-row total">
        <span>实付款</span>
        <span class="total-price">¥{{ totalPrice }}</span>
      </div>
    </div>

    <!-- Spacer -->
    <div style="height: 80px" />

    <!-- Bottom Submit Bar -->
    <div class="submit-bar">
      <div class="submit-left">
        <span class="submit-label">合计:</span>
        <span class="submit-total">¥{{ totalPrice }}</span>
      </div>
      <van-button
        type="danger"
        round
        class="submit-btn"
        :loading="submitting"
        :disabled="!selectedAddressId || !checkedItems.length"
        @click="submitOrder"
      >
        提交订单
      </van-button>
    </div>
  </div>
</template>

<style scoped>
.confirm-page {
  min-height: 100vh;
  background: var(--cl-bg);
  padding-bottom: env(safe-area-inset-bottom);
}

/* Section Card */
.section-card {
  background: var(--cl-bg-card);
  margin: 12px;
  border-radius: var(--radius-lg);
  padding: 14px 16px;
  box-shadow: var(--shadow-xs);
}

/* Address */
.address-section {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
}
.addr-content { flex: 1; }
.addr-row {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 6px;
}
.addr-name {
  font-size: 16px;
  font-weight: 600;
  color: var(--cl-text-primary);
}
.addr-phone {
  font-size: 13px;
  color: var(--cl-text-secondary);
}
.addr-full {
  font-size: 13px;
  color: var(--cl-text-secondary);
  line-height: 1.5;
}
.addr-empty {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: var(--cl-text-muted);
}
.addr-arrow { color: var(--cl-text-muted); }

/* Goods */
.section-title {
  font-size: 14px;
  font-weight: 600;
  color: var(--cl-text-primary);
  margin-bottom: 12px;
}
.goods-item {
  display: flex;
  gap: 12px;
  padding: 10px 0;
  border-bottom: 1px solid var(--cl-border-light);
}
.goods-item:last-child { border-bottom: none; }
.goods-img {
  width: 64px;
  height: 64px;
  border-radius: var(--radius-sm);
  object-fit: cover;
  background: var(--cl-bg-muted);
  flex-shrink: 0;
}
.goods-info { flex: 1; min-width: 0; }
.goods-name {
  font-size: 13px;
  color: var(--cl-text-primary);
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  margin-bottom: 4px;
}
.goods-sku { font-size: 11px; color: var(--cl-text-muted); margin-bottom: 4px; }
.goods-bottom {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
}
.goods-price { font-size: 14px; font-weight: 700; color: var(--cl-red); }
.goods-qty { font-size: 12px; color: var(--cl-text-muted); }

/* Remark */
.remark-row {
  display: flex;
  align-items: center;
}
.remark-label {
  font-size: 14px;
  color: var(--cl-text-primary);
  font-weight: 500;
  width: 80px;
  flex-shrink: 0;
}
.remark-input {
  flex: 1;
  padding: 0;
  background: transparent;
}
.remark-input :deep(.van-field__control) {
  text-align: right;
  font-size: 13px;
  color: var(--cl-text-secondary);
}

/* Price */
.price-section {}
.price-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  font-size: 13px;
  color: var(--cl-text-secondary);
}
.price-row.total {
  font-weight: 600;
  color: var(--cl-text-primary);
}
.free { color: var(--cl-green); font-size: 12px; }
.total-price { font-size: 20px; font-weight: 800; color: var(--cl-red); }
.price-divider { height: 1px; background: var(--cl-border-light); margin: 4px 0; }

/* Bottom Bar */
.submit-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  height: 64px;
  background: var(--cl-bg-card);
  border-top: 1px solid var(--cl-border-light);
  box-shadow: 0 -4px 16px rgba(26,26,46,0.06);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16px;
  padding-bottom: env(safe-area-inset-bottom);
  z-index: 100;
}
.submit-left {
  display: flex;
  align-items: baseline;
  gap: 4px;
}
.submit-label {
  font-size: 13px;
  color: var(--cl-text-secondary);
}
.submit-total {
  font-size: 20px;
  font-weight: 800;
  color: var(--cl-red);
  font-family: var(--font-display);
}
.submit-btn {
  height: 44px;
  padding: 0 28px;
  font-size: 15px;
  font-weight: 600;
  letter-spacing: 1px;
}
</style>
