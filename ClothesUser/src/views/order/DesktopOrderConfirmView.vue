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
const paymentMethod = ref('wechat')
const promoCode = ref('')
const promoApplied = ref(false)

const selectedAddress = computed(() =>
  addresses.value.find(a => a.id === selectedAddressId.value) || addresses.value.find(a => a.isDefault === 1)
)

const checkedItems = computed(() => cartStore.items.filter(i => i.checked))
const itemsTotal = computed(() => checkedItems.value.reduce((s, i) => s + i.price * i.count, 0))
// 满减规则与后端一致: >=500减200, >=299减50
const discount = computed(() => {
  const t = itemsTotal.value
  if (t >= 500) return 200
  if (t >= 299) return 50
  return 0
})
const finalTotal = computed(() => Math.max(0, itemsTotal.value - discount.value))

async function loadAddresses() {
  try {
    const data: any = await addressApi.list()
    addresses.value = data || []
    const def = addresses.value.find(a => a.isDefault === 1)
    if (def) selectedAddressId.value = def.id
    else if (addresses.value.length) selectedAddressId.value = addresses.value[0].id
  } catch { /* silent */ }
}

function applyPromo() {
  if (promoCode.value.trim()) {
    promoApplied.value = true
    showToast('优惠码已应用')
  }
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
    <div class="checkout-page">
      <!-- 左侧：购物车商品 -->
      <div class="cart-section">
        <div class="cart-header">
          <h2>🛒 购物车</h2>
          <span class="cart-count">共 {{ checkedItems.length }} 件商品</span>
        </div>

        <div v-for="item in checkedItems" :key="`${item.goodsId}-${item.sku}`" class="cart-item">
          <img :src="item.image" class="cart-item-img" alt="商品图" @error="($event.target as HTMLImageElement).src = '/assets/placeholders/product-placeholder.svg'" />
          <div class="cart-item-info">
            <h3>{{ item.name }}</h3>
            <div class="cart-item-meta">{{ item.sku || '默认规格' }}</div>
            <div>
              <span class="cart-item-price">¥{{ item.price }}</span>
            </div>
          </div>
          <div class="cart-item-actions">
            <span class="cart-qty">×{{ item.count }}</span>
          </div>
        </div>

        <div v-if="!checkedItems.length" class="cart-empty">购物车暂无选中商品</div>
      </div>

      <!-- 右侧：结算信息 -->
      <div class="checkout-sidebar">
        <!-- 收货地址 -->
        <div class="info-card">
          <div class="info-card-header">📍 收货地址</div>
          <div class="info-card-body">
            <template v-if="selectedAddress">
              <div class="address-row">
                <div class="address-label">收货人</div>
                <div class="address-value">{{ selectedAddress.receiver }} · {{ selectedAddress.phone }}</div>
              </div>
              <div class="address-row">
                <div class="address-label">配送地址</div>
                <div class="address-value">{{ selectedAddress.province }}{{ selectedAddress.city }}{{ selectedAddress.district }}{{ selectedAddress.detail }}</div>
              </div>
            </template>
            <div v-else class="address-value" style="color:#999">请添加收货地址</div>
            <div class="address-edit">
              <router-link to="/address">更换地址 →</router-link>
            </div>
          </div>
        </div>

        <!-- 支付方式 -->
        <div class="info-card">
          <div class="info-card-header">💳 支付方式</div>
          <div class="info-card-body">
            <label class="payment-method">
              <div class="payment-icon">💳</div>
              <div class="payment-info">
                <div class="payment-name">微信支付</div>
                <div class="payment-detail">推荐使用</div>
              </div>
              <input type="radio" name="payment" value="wechat" v-model="paymentMethod" class="payment-radio">
            </label>
            <label class="payment-method">
              <div class="payment-icon">📱</div>
              <div class="payment-info">
                <div class="payment-name">支付宝</div>
                <div class="payment-detail">快捷支付</div>
              </div>
              <input type="radio" name="payment" value="alipay" v-model="paymentMethod" class="payment-radio">
            </label>
            <label class="payment-method">
              <div class="payment-icon">🏦</div>
              <div class="payment-info">
                <div class="payment-name">银行卡</div>
                <div class="payment-detail">在线支付</div>
              </div>
              <input type="radio" name="payment" value="bank" v-model="paymentMethod" class="payment-radio">
            </label>
          </div>
        </div>

        <!-- 备注 -->
        <div class="info-card">
          <div class="info-card-header">📝 订单备注</div>
          <div class="info-card-body">
            <input v-model="remark" placeholder="选填，可备注特殊要求" class="remark-input" />
          </div>
        </div>

        <!-- 优惠码 -->
        <div class="info-card" v-if="false">
          <div class="info-card-header">🎁 优惠码</div>
          <div class="info-card-body">
            <div class="promo-form">
              <input v-model="promoCode" type="text" class="promo-input" placeholder="输入优惠码" :disabled="promoApplied" />
              <button v-if="!promoApplied" class="promo-btn" @click="applyPromo">应用</button>
              <button v-else class="promo-btn applied" disabled>已应用</button>
            </div>
          </div>
        </div>

        <!-- 金额明细 -->
        <div class="info-card">
          <div class="info-card-header">📋 金额明细</div>
          <div class="info-card-body">
            <div class="price-row">
              <span>商品小计</span>
              <span>¥{{ itemsTotal.toFixed(2) }}</span>
            </div>
            <div class="price-row">
              <span>运费</span>
              <span>¥0.00</span>
            </div>
            <div v-if="discount > 0" class="price-row discount">
              <span>满减优惠</span>
              <span>−¥{{ discount.toFixed(2) }}</span>
            </div>
            <div class="price-row total">
              <span>应付总额</span>
              <span>¥{{ finalTotal.toFixed(2) }}</span>
            </div>
            <button class="checkout-btn" :disabled="submitting || !selectedAddressId || !checkedItems.length" @click="submitOrder">
              {{ submitting ? '提交中...' : `立即支付 ¥${finalTotal.toFixed(2)}` }}
            </button>
            <div class="security-note">
              <span>🔒</span> 支付环境安全加密，请放心付款
            </div>
          </div>
        </div>
      </div>
    </div>
  </DesktopLayout>
</template>

<style scoped>
.checkout-page {
  max-width: 1400px;
  margin: 0 auto;
  padding: 24px 40px 60px;
  display: grid;
  grid-template-columns: 1fr 420px;
  gap: 40px;
  align-items: start;
}

/* ===== 左侧：商品列表 ===== */
.cart-section {
  background: var(--bg-card, #fff);
  border: 1px solid var(--border, #e8e5e0);
  border-radius: var(--radius-lg, 12px);
  padding: 32px;
  position: sticky;
  top: 88px;
  align-self: start;
}
.cart-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 24px;
  padding-bottom: 20px;
  border-bottom: 1px solid var(--border, #e8e5e0);
}
.cart-header h2 { font-size: 20px; font-weight: 600; color: var(--text-primary, #1a1a1a); }
.cart-count { font-size: 13px; color: var(--text-muted, #999); }

.cart-item {
  display: grid;
  grid-template-columns: 100px 1fr auto;
  gap: 20px;
  padding: 20px 0;
  border-bottom: 1px solid var(--border, #e8e5e0);
  align-items: center;
}
.cart-item:last-child { border-bottom: none; }
.cart-item-img {
  width: 100px; height: 120px;
  border-radius: var(--radius-md, 8px);
  background: var(--bg-secondary, #f5f3f0);
  object-fit: cover;
}
.cart-item-info h3 {
  font-size: 15px; font-weight: 600; color: var(--text-primary, #1a1a1a);
  margin-bottom: 6px;
}
.cart-item-meta {
  font-size: 13px; color: var(--text-muted, #999);
  margin-bottom: 8px;
}
.cart-item-price {
  font-size: 16px; font-weight: 700; color: var(--accent, #c45c4a);
}
.cart-qty {
  font-size: 14px; color: var(--text-secondary, #666);
  font-weight: 600;
}
.cart-empty {
  text-align: center; padding: 40px; color: var(--text-muted, #999); font-size: 14px;
}

/* ===== 右侧：结算信息 ===== */
.checkout-sidebar {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.info-card {
  background: var(--bg-card, #fff);
  border: 1px solid var(--border, #e8e5e0);
  border-radius: var(--radius-lg, 12px);
  overflow: hidden;
  box-shadow: var(--shadow-sm, 0 1px 3px rgba(0,0,0,0.04));
}
.info-card-header {
  padding: 16px 24px;
  background: var(--bg-secondary, #f5f3f0);
  border-bottom: 1px solid var(--border, #e8e5e0);
  font-size: 13px; font-weight: 600;
  text-transform: uppercase; letter-spacing: 0.5px;
  display: flex; align-items: center; gap: 8px;
  color: var(--text-primary, #1a1a1a);
}
.info-card-body { padding: 20px 24px; }

.address-row { margin-bottom: 12px; }
.address-row:last-child { margin-bottom: 0; }
.address-label {
  font-size: 11px; font-weight: 600; color: var(--text-muted, #999);
  text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px;
}
.address-value {
  font-size: 14px; color: var(--text-primary, #1a1a1a); line-height: 1.5;
}
.address-edit {
  margin-top: 16px; padding-top: 16px; border-top: 1px solid var(--border, #e8e5e0);
  text-align: center;
}
.address-edit a {
  color: var(--accent, #c45c4a); font-size: 13px; font-weight: 500;
  text-decoration: none;
}
.address-edit a:hover { text-decoration: underline; }

/* 支付方式 */
.payment-method {
  display: flex; align-items: center; gap: 12px;
  padding: 14px 0; border-bottom: 1px solid var(--border, #e8e5e0); cursor: pointer;
}
.payment-method:last-child { border-bottom: none; padding-bottom: 0; }
.payment-method:first-child { padding-top: 0; }
.payment-icon {
  width: 40px; height: 40px;
  background: var(--bg-secondary, #f5f3f0);
  border-radius: var(--radius-sm, 4px);
  display: flex; align-items: center; justify-content: center;
  font-size: 20px; flex-shrink: 0;
}
.payment-info { flex: 1; }
.payment-name { font-size: 14px; font-weight: 600; color: var(--text-primary, #1a1a1a); }
.payment-detail { font-size: 12px; color: var(--text-muted, #999); }
.payment-radio { width: 20px; height: 20px; accent-color: var(--accent, #c45c4a); cursor: pointer; }

/* 备注输入框 */
.remark-input {
  width: 100%; height: 44px; padding: 0 16px;
  border: 1.5px solid var(--border, #e8e5e0);
  border-radius: var(--radius-md, 8px);
  background: var(--bg-card, #fff);
  font-size: 14px; outline: none; box-sizing: border-box;
  color: var(--text-primary, #1a1a1a);
}
.remark-input:focus {
  border-color: var(--accent, #c45c4a);
  box-shadow: 0 0 0 3px rgba(196,92,74,0.08);
}
.remark-input::placeholder { color: var(--text-muted, #999); }

/* 优惠码 */
.promo-form { display: flex; gap: 10px; }
.promo-input {
  flex: 1; height: 44px; padding: 0 16px;
  border: 1.5px solid var(--border, #e8e5e0);
  border-radius: var(--radius-md, 8px);
  background: var(--bg-card, #fff);
  font-size: 14px; outline: none; box-sizing: border-box;
  color: var(--text-primary, #1a1a1a);
}
.promo-input:focus {
  border-color: var(--accent, #c45c4a);
  box-shadow: 0 0 0 3px rgba(196,92,74,0.08);
}
.promo-input::placeholder { color: var(--text-muted, #999); }
.promo-btn {
  height: 44px; padding: 0 20px;
  background: var(--accent-bg, #fdf5f3);
  border: 1.5px solid var(--accent, #c45c4a);
  border-radius: var(--radius-md, 8px);
  color: var(--accent, #c45c4a);
  font-size: 13px; font-weight: 600;
  cursor: pointer; white-space: nowrap;
}
.promo-btn:hover { background: var(--accent, #c45c4a); color: #0a0a0f; }
.promo-btn.applied { background: var(--success, #2d8a5e); border-color: var(--success, #2d8a5e); color: #0a0a0f; }

/* 金额明细 */
.price-row {
  display: flex; justify-content: space-between;
  padding: 10px 0; font-size: 14px; color: var(--text-secondary, #666);
}
.price-row.discount { color: var(--success, #2d8a5e); }
.price-row.total {
  padding-top: 16px; margin-top: 10px;
  border-top: 2px solid var(--border, #e8e5e0);
  font-size: 18px; font-weight: 700; color: var(--text-primary, #1a1a1a);
}
.price-row.total span:last-child {
  color: var(--accent, #c45c4a); font-size: 22px;
}

.checkout-btn {
  width: 100%; height: 52px;
  background: var(--accent, #c45c4a);
  color: #0a0a0f; border: none;
  border-radius: var(--radius-md, 8px);
  font-size: 15px; font-weight: 600;
  cursor: pointer; margin-top: 8px;
}
.checkout-btn:hover:not(:disabled) {
  background: var(--accent-dark, #8b3a2a);
  transform: translateY(-1px);
  box-shadow: var(--shadow-md, 0 4px 12px rgba(0,0,0,0.08));
}
.checkout-btn:disabled { opacity: 0.5; cursor: not-allowed; }

.security-note {
  display: flex; align-items: center; justify-content: center;
  gap: 6px; font-size: 12px; color: var(--text-muted, #999); margin-top: 12px;
}

/* ===== 响应式 ===== */
@media (max-width: 992px) {
  .checkout-page {
    grid-template-columns: 1fr;
    padding: 16px 20px 40px;
  }
  .cart-section { position: static; }
}
@media (max-width: 768px) {
  .cart-item {
    grid-template-columns: 80px 1fr;
    gap: 12px;
  }
  .cart-item-img { width: 80px; height: 100px; }
}
</style>
