<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showToast } from 'vant'
import { cartApi } from '@/api/cart'
import { useCartStore } from '@/stores/cart'
import { useUserStore } from '@/stores/user'
import { fullImgUrl, IMG_PLACEHOLDER } from '@/utils/img'

const router = useRouter()
const cartStore = useCartStore()
const userStore = useUserStore()
const loading = ref(false)
const promoCode = ref('')

const checkedAll = computed({
  get: () => cartStore.items.length > 0 && cartStore.items.every(i => i.checked),
  set: (val: boolean) => cartStore.toggleAll(val),
})

const totalPrice = computed(() => cartStore.totalPrice)

function toggleCheck(item: any) { cartStore.toggleCheck(item.goodsId, item.sku) }

async function removeItem(item: any) {
  try {
    await cartApi.remove(item.id)
    cartStore.removeItem(item.goodsId, item.sku)
    showToast('已删除')
  } catch {
    cartStore.removeItem(item.goodsId, item.sku)
  }
}

function updateQty(item: any, delta: number) {
  const newVal = item.count + delta
  if (newVal < 1) return
  cartStore.updateCount(item.goodsId, item.sku, newVal)
}

async function refreshCart() {
  loading.value = true
  try {
    const data: any = await cartApi.list()
    const items = data || []
    cartStore.clear()
    items.forEach((item: any) => {
      cartStore.addItem({
        id: item.id, goodsId: item.goodsId, name: item.goodsName,
        image: fullImgUrl(item.goodsCover), price: item.price,
        count: item.quantity, sku: item.spec || '',
        checked: item.selected === 1,
      })
    })
  } catch { /* silent */ }
  finally { loading.value = false }
}

function goCheckout() {
  if (!userStore.isLoggedIn) { router.push('/login'); return }
  if (cartStore.checkedCount === 0) { showToast('请选择商品'); return }
  router.push('/order/confirm')
}

onMounted(refreshCart)
</script>

<template>
  <DesktopLayout>
    <!-- 面包屑 -->
    <div class="breadcrumb">
      <router-link to="/">首页</router-link>
      <span>/</span>
      <span>购物车</span>
    </div>

    <!-- 页面标题 -->
    <div class="page-header-order">
      <h1 class="page-title">购物车 <span>{{ cartStore.items.length }}件</span></h1>
    </div>

    <!-- 空状态 -->
    <div v-if="!cartStore.items.length" class="cart-container" style="display:block">
      <div class="empty-state">
        <div class="empty-icon">🛒</div>
        <div class="empty-title">购物车是空的</div>
        <div class="empty-desc">去逛逛，发现心仪的商品</div>
        <button class="btn-primary-dark" @click="router.push('/')">去购物</button>
      </div>
    </div>

    <!-- 购物车内容 -->
    <div v-else class="cart-container">
      <!-- 左栏：商品列表 -->
      <div class="cart-main">
        <!-- 全选栏 -->
        <div class="select-all-bar">
          <div class="checkbox-wrap" @click="checkedAll = !checkedAll">
            <div class="custom-checkbox" :class="{ checked: checkedAll }">
              <svg v-if="checkedAll" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="20 6 9 17 4 12"/>
              </svg>
            </div>
            <span>全选</span>
          </div>
        </div>

        <!-- 商品卡片 -->
        <div v-for="item in cartStore.items" :key="`${item.goodsId}-${item.sku}`" class="cart-item">
          <div class="checkbox-wrap" @click="toggleCheck(item)" style="align-self:start;margin-top:8px">
            <div class="custom-checkbox" :class="{ checked: item.checked }">
              <svg v-if="item.checked" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="20 6 9 17 4 12"/>
              </svg>
            </div>
          </div>

          <div class="item-image" @click="router.push(`/goods/${item.goodsId}`)">
            <img :src="item.image" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" />
          </div>

          <div class="item-info">
            <div class="item-name" @click="router.push(`/goods/${item.goodsId}`)">{{ item.name }}</div>
            <div class="item-meta">
              <span v-if="item.sku" class="item-tag">{{ item.sku }}</span>
            </div>
            <div class="item-actions">
              <button class="item-action-btn" @click="router.push(`/goods/${item.goodsId}`)">收藏</button>
              <button class="item-action-btn" @click="removeItem(item)">删除</button>
            </div>
          </div>

          <div class="item-price-wrap">
            <div class="item-price">¥{{ item.price }}</div>
            <div class="quantity-selector">
              <button class="qty-btn" :disabled="item.count <= 1" @click="updateQty(item, -1)">−</button>
              <input class="qty-input" :value="item.count" readonly />
              <button class="qty-btn" @click="updateQty(item, 1)">+</button>
            </div>
            <div class="item-subtotal">¥{{ (item.price * item.count).toFixed(2) }}</div>
          </div>

          <button class="remove-btn" @click="removeItem(item)">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
              <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
            </svg>
          </button>
        </div>
      </div>

      <!-- 右栏：订单摘要 -->
      <div class="cart-sidebar">
        <div class="summary-card">
          <div class="summary-title">订单摘要</div>

          <!-- 优惠码 -->
          <div class="coupon-section">
            <label class="coupon-label">优惠码</label>
            <div class="coupon-input-wrap">
              <input v-model="promoCode" class="coupon-input" placeholder="输入优惠码" />
              <button class="coupon-btn" @click="promoCode && showToast('优惠码已应用')">应用</button>
            </div>
          </div>

          <div class="summary-divider"></div>

          <div class="summary-row">
            <span class="label">已选商品</span>
            <span class="value">{{ cartStore.checkedCount }} 件</span>
          </div>

          <div class="summary-row">
            <span class="label">商品小计</span>
            <span class="value">¥{{ totalPrice.toFixed(2) }}</span>
          </div>

          <div class="summary-row">
            <span class="label">运费</span>
            <span class="value">¥0.00</span>
          </div>

          <div class="summary-divider"></div>

          <div class="summary-row total">
            <span class="label">合计</span>
            <span class="value">¥{{ totalPrice.toFixed(2) }}</span>
          </div>

          <button class="checkout-btn" :disabled="cartStore.checkedCount === 0" @click="goCheckout">
            去结算
          </button>

          <div class="trust-badges">
            <span class="trust-badge">🔒 安全支付</span>
            <span class="trust-badge">🚚 满299包邮</span>
            <span class="trust-badge">🔄 7天退换</span>
          </div>

          <div class="continue-shopping">
            <router-link to="/">← 继续购物</router-link>
          </div>
        </div>
      </div>
    </div>
  </DesktopLayout>
</template>

<style scoped>
.breadcrumb {
  max-width: 1320px; margin: 20px auto 0; padding: 0 40px;
  display: flex; align-items: center; gap: 8px;
  font-size: 13px; color: var(--text-muted, #9a9a9a);
}
.breadcrumb a { color: var(--text-secondary, #6b6b6b); text-decoration: none; }
.breadcrumb a:hover { color: var(--accent, #c45c4a); }

.page-header-order {
  max-width: 1320px; margin: 0 auto;
  padding: 24px 40px 28px;
}
.page-title {
  font-size: 32px; font-weight: 700; color: var(--text-primary, #1a1a1a); letter-spacing: 0.5px;
}
.page-title span {
  color: var(--text-muted, #9a9a9a); font-size: 16px; font-weight: 400; margin-left: 12px;
}

.cart-container {
  max-width: 1320px; margin: 0 auto;
  padding: 0 40px 80px;
  display: grid;
  grid-template-columns: 1fr 380px;
  gap: 40px;
  align-items: start;
}

/* 全选栏 */
.select-all-bar {
  display: flex; align-items: center; justify-content: space-between;
  padding: 0 4px; margin-bottom: 8px;
}
.checkbox-wrap {
  display: flex; align-items: center; gap: 10px;
  cursor: pointer; font-size: 14px;
  color: var(--text-secondary, #6b6b6b); font-weight: 500; user-select: none;
}
.custom-checkbox {
  width: 20px; height: 20px;
  border: 2px solid var(--border, #ece9e4);
  border-radius: 6px;
  display: flex; align-items: center; justify-content: center;
  background: var(--bg-card, #1a1a2e);
  flex-shrink: 0;
}
.custom-checkbox.checked { background: var(--accent, #c45c4a); border-color: var(--accent, #c45c4a); }
.custom-checkbox svg { opacity: 0; transform: scale(0.5); transition: all 0.2s; }
.custom-checkbox.checked svg { opacity: 1; transform: scale(1); }

/* 商品卡片 */
.cart-main { display: flex; flex-direction: column; gap: 16px; }
.cart-item {
  background: var(--bg-card, #fff);
  border-radius: 20px;
  border: 1px solid var(--border, #ece9e4);
  padding: 24px;
  display: grid;
  grid-template-columns: auto 140px 1fr auto;
  gap: 24px;
  align-items: center;
  position: relative;
  overflow: hidden;
}
.cart-item::before {
  content: ''; position: absolute; left: 0; top: 0; bottom: 0;
  width: 3px; background: var(--accent, #c45c4a); opacity: 0;
}
.cart-item:hover { box-shadow: 0 8px 40px rgba(0,0,0,0.06); border-color: var(--accent, #00f0ff); }
.cart-item:hover::before { opacity: 1; }

.item-image {
  width: 140px; height: 170px; border-radius: 12px; overflow: hidden;
  background: var(--bg-secondary, #f5f3f0); cursor: pointer;
}
.item-image img { width: 100%; height: 100%; object-fit: cover; }
.cart-item:hover .item-image img { transform: scale(1.08); }

.item-info { display: flex; flex-direction: column; gap: 10px; min-width: 0; }
.item-name {
  font-size: 16px; font-weight: 600; color: var(--text-primary, #1a1a1a);
  line-height: 1.4; cursor: pointer;
}
.item-meta { display: flex; flex-wrap: wrap; gap: 8px; }
.item-tag {
  padding: 4px 12px; background: var(--bg-secondary, #f5f3f0);
  border-radius: 100px; font-size: 12px; color: var(--text-secondary, #6b6b6b);
  border: 1px solid var(--border, #ece9e4);
}
.item-actions { display: flex; gap: 16px; margin-top: 4px; }
.item-action-btn {
  font-size: 12px; color: var(--text-muted, #9a9a9a);
  background: none; border: none; cursor: pointer; padding: 0; font-family: inherit;
}
.item-action-btn:hover { color: var(--accent, #c45c4a); }

.item-price-wrap {
  display: flex; flex-direction: column;
  align-items: flex-end; gap: 12px; min-width: 120px;
}
.item-price { font-size: 20px; font-weight: 700; color: var(--accent, #c45c4a); }

.quantity-selector {
  display: flex; align-items: center;
  border: 1px solid var(--border, #ece9e4);
  border-radius: 100px; overflow: hidden; background: var(--bg-card, #1a1a2e);
}
.qty-btn {
  width: 32px; height: 32px; border: none; background: transparent;
  cursor: pointer; font-size: 16px; color: var(--text-secondary, #6b6b6b);
}
.qty-btn:hover { background: var(--bg-secondary, #f5f3f0); color: var(--text-primary, #1a1a1a); }
.qty-btn:disabled { opacity: 0.3; cursor: not-allowed; }
.qty-input {
  width: 40px; height: 32px; border: none; text-align: center;
  font-size: 13px; font-weight: 600; color: var(--text-primary, #1a1a1a);
  outline: none; background: transparent; font-family: inherit;
}
.item-subtotal { font-size: 22px; font-weight: 700; color: var(--accent, #c45c4a); }

.remove-btn {
  position: absolute; top: 16px; right: 16px;
  width: 32px; height: 32px; border-radius: 50%; border: none;
  background: transparent; color: var(--text-muted, #9a9a9a);
  cursor: pointer; display: flex; align-items: center; justify-content: center;
  opacity: 0; transform: scale(0.8);
}
.cart-item:hover .remove-btn { opacity: 1; transform: scale(1); }
.remove-btn:hover { background: var(--accent-bg, #fdf0ed); color: var(--accent, #c45c4a); }

/* 右栏摘要 */
.cart-sidebar { position: sticky; top: 100px; display: flex; flex-direction: column; gap: 20px; }
.summary-card {
  background: var(--bg-card, #fff);
  border-radius: 20px;
  border: 1px solid var(--border, #ece9e4);
  padding: 28px;
}
.summary-title {
  font-size: 22px; font-weight: 700;
  margin-bottom: 24px; color: var(--text-primary, #1a1a1a);
}

.coupon-section { margin-bottom: 24px; }
.coupon-label {
  font-size: 13px; font-weight: 600; color: var(--text-secondary, #6b6b6b);
  margin-bottom: 10px; display: block;
}
.coupon-input-wrap { display: flex; gap: 8px; }
.coupon-input {
  flex: 1; height: 44px;
  border: 1px solid var(--border, #ece9e4);
  border-radius: 12px; padding: 0 16px;
  font-size: 13px; outline: none; background: var(--bg-secondary, #f5f3f0);
  font-family: inherit;
}
.coupon-input:focus { border-color: var(--accent, #c45c4a); background: var(--bg-card, #1a1a2e); }
.coupon-btn {
  height: 44px; padding: 0 20px; border-radius: 12px;
  border: 1px solid var(--bg-dark, #1a1a1a);
  background: var(--bg-dark, #1a1a1a); color: #0a0a0f;
  font-size: 13px; font-weight: 600; cursor: pointer; white-space: nowrap; font-family: inherit;
}
.coupon-btn:hover { background: #333; transform: translateY(-1px); }

.summary-divider { height: 1px; background: var(--border, #ece9e4); margin: 20px 0; }
.summary-row {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 14px; font-size: 14px;
}
.summary-row .label { color: var(--text-secondary, #6b6b6b); }
.summary-row .value { font-weight: 500; color: var(--text-primary, #1a1a1a); }
.summary-row.discount .value { color: var(--success, #5a8c6f); }

.summary-row.total { margin-top: 4px; padding-top: 16px; border-top: 1px solid var(--border, #ece9e4); }
.summary-row.total .label { font-size: 16px; font-weight: 600; color: var(--text-primary, #1a1a1a); }
.summary-row.total .value { font-size: 28px; font-weight: 700; color: var(--accent, #c45c4a); }

.checkout-btn {
  width: 100%; height: 56px;
  border-radius: 16px; border: none;
  background: var(--accent, #c45c4a); color: #0a0a0f;
  font-size: 15px; font-weight: 600; cursor: pointer;
  margin-top: 12px; font-family: inherit;
}
.checkout-btn:hover:not(:disabled) { background: var(--accent-dark, #8b3a2a); transform: translateY(-2px); box-shadow: 0 8px 24px rgba(196,92,74,0.3); }
.checkout-btn:disabled { opacity: 0.5; cursor: not-allowed; }

.trust-badges {
  display: flex; justify-content: center; gap: 16px;
  margin-top: 16px; padding: 16px; background: var(--bg-secondary, #f5f3f0);
  border-radius: 12px;
}
.trust-badge { font-size: 11px; color: var(--text-muted, #9a9a9a); }

.continue-shopping { text-align: center; margin-top: 16px; }
.continue-shopping a {
  font-size: 13px; color: var(--text-muted, #9a9a9a);
  text-decoration: none; display: inline-flex; align-items: center; gap: 6px;
}
.continue-shopping a:hover { color: var(--accent, #c45c4a); }

/* 空状态 */
.empty-state { text-align: center; padding: 100px 20px; }
.empty-icon { width: 100px; height: 100px; margin: 0 auto 28px; border-radius: 50%; background: var(--bg-secondary, #f5f3f0); display: flex; align-items: center; justify-content: center; font-size: 40px; }
.empty-title { font-size: 24px; font-weight: 600; margin-bottom: 8px; color: var(--text-primary, #1a1a1a); }
.empty-desc { color: var(--text-muted, #9a9a9a); font-size: 14px; margin-bottom: 28px; }
.btn-primary-dark { padding: 14px 36px; border-radius: 16px; border: none; background: var(--bg-dark, #1a1a1a); color: #0a0a0f; font-size: 14px; font-weight: 600; cursor: pointer; }
.btn-primary-dark:hover { background: #333; transform: translateY(-2px); box-shadow: 0 8px 24px rgba(0,0,0,0.15); }

@media (max-width: 1024px) {
  .cart-container { grid-template-columns: 1fr; }
  .cart-sidebar { position: static; max-width: 480px; margin: 0 auto; width: 100%; }
}
@media (max-width: 768px) {
  .breadcrumb, .page-header-order { padding-left: 20px; padding-right: 20px; }
  .cart-container { padding: 0 20px 60px; }
  .cart-item {
    grid-template-columns: auto 100px 1fr;
    gap: 16px; padding: 16px;
  }
  .item-image { width: 100px; height: 120px; }
  .item-price-wrap {
    grid-column: 1 / -1;
    flex-direction: row; justify-content: space-between; align-items: center;
    border-top: 1px solid var(--border-light, #f3f1ed);
    padding-top: 12px; margin-top: 4px;
  }
  .remove-btn { opacity: 1; transform: scale(1); top: 12px; right: 12px; }
}
</style>
