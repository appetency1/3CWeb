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

const checkedAll = computed({
  get: () => cartStore.items.length > 0 && cartStore.items.every(i => i.checked),
  set: (val: boolean) => cartStore.toggleAll(val),
})

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
    <div class="desktop-page-title">购物车</div>

    <!-- Empty -->
    <div v-if="!cartStore.items.length" class="desktop-empty">
      <div class="empty-icon"><span>🛒</span></div>
      <p>购物车是空的</p>
      <p style="margin-top:8px;font-size:13px">
        <a href="#" @click.prevent="router.push('/')" style="color:var(--accent);text-decoration:none">去逛逛 →</a>
      </p>
    </div>

    <template v-else>
      <div class="desktop-cart-layout">
        <!-- Cart List -->
        <div class="desktop-cart-list">
          <!-- Header -->
          <div class="desktop-cart-header">
            <div class="desktop-select-all" @click="checkedAll = !checkedAll">
              <div class="desktop-checkbox" :class="{ checked: checkedAll }">
                <span v-if="checkedAll">✓</span>
              </div>
              全选
            </div>
            <div style="flex:1">商品</div>
            <div class="col-price">单价</div>
            <div style="width:110px;text-align:center">数量</div>
            <div style="width:100px;text-align:right">小计</div>
            <div style="width:40px"></div>
          </div>

          <!-- Items -->
          <div
            v-for="item in cartStore.items"
            :key="`${item.goodsId}-${item.sku}`"
            class="desktop-cart-item"
          >
            <div class="desktop-cart-check">
              <div
                class="desktop-checkbox"
                :class="{ checked: item.checked }"
                @click="toggleCheck(item)"
              >
                <span v-if="item.checked">✓</span>
              </div>
            </div>

            <img :src="fullImgUrl(item.image)" class="desktop-cart-img" @click="router.push(`/goods/${item.goodsId}`)" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" />

            <div class="desktop-cart-info" @click="router.push(`/goods/${item.goodsId}`)">
              <p class="desktop-cart-name">{{ item.name }}</p>
              <p v-if="item.sku" class="desktop-cart-sku">{{ item.sku }}</p>
            </div>

            <div class="desktop-cart-price">¥{{ item.price }}</div>

            <div class="desktop-cart-qty">
              <div class="desktop-stepper" style="transform:scale(0.85)">
                <button @click="cartStore.updateCount(item.goodsId, item.sku, Math.max(1, item.count - 1))">−</button>
                <input :value="item.count" type="number" readonly />
                <button @click="cartStore.updateCount(item.goodsId, item.sku, item.count + 1)">+</button>
              </div>
            </div>

            <div class="desktop-cart-subtotal">¥{{ (item.price * item.count).toFixed(2) }}</div>

            <div class="desktop-cart-remove" @click="removeItem(item)">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
              </svg>
            </div>
          </div>
        </div>

        <!-- Summary Panel -->
        <div class="desktop-cart-summary">
          <div class="desktop-cart-summary-title">订单摘要</div>
          <div class="desktop-summary-row">
            <span>已选 {{ cartStore.checkedCount }} 件</span>
          </div>
          <div class="desktop-summary-row total">
            <span>合计</span>
            <span>¥{{ cartStore.totalPrice.toFixed(2) }}</span>
          </div>
          <button
            class="desktop-checkout-btn"
            :disabled="cartStore.checkedCount === 0"
            @click="goCheckout"
          >
            去结算
          </button>
          <div style="margin-top:12px;text-align:center">
            <a href="#" @click.prevent="router.push('/')" style="font-size:12px;color:var(--text-muted);text-decoration:none">继续购物 →</a>
          </div>
        </div>
      </div>
    </template>
  </DesktopLayout>
</template>
