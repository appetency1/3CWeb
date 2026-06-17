<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showToast } from 'vant'
import { cartApi } from '@/api/cart'
import { useCartStore } from '@/stores/cart'
import { fullImgUrl } from '@/utils/img'

const router = useRouter()
const cartStore = useCartStore()

const loading = ref(false)
const refreshing = ref(false)
const deleting = ref<number | null>(null)

const checkedAll = computed({
  get: () => cartStore.items.length > 0 && cartStore.items.every(i => i.checked),
  set: (val: boolean) => cartStore.toggleAll(val),
})

function onCheck(item: any) {
  cartStore.toggleCheck(item.goodsId, item.sku)
}

async function onDelete(item: any) {
  deleting.value = item.id
  try {
    await cartApi.remove(item.id)
    cartStore.removeItem(item.goodsId, item.sku)
    showToast('已删除')
  } catch (e: any) {
    cartStore.removeItem(item.goodsId, item.sku)
  } finally {
    deleting.value = null
  }
}

async function onRefresh() {
  refreshing.value = true
  await loadCart()
  refreshing.value = false
}

async function loadCart() {
  loading.value = true
  try {
    const data: any = await cartApi.list()
    const items = data || []
    cartStore.clear()
    items.forEach((item: any) => {
      cartStore.addItem({
        id: item.id,
        goodsId: item.goodsId,
        name: item.goodsName,
        image: fullImgUrl(item.goodsCover),
        price: item.price,
        count: item.quantity,
        sku: item.spec || '',
        checked: item.selected === 1,
      })
    })
  } catch (e: any) {
    // 静默失败，使用本地store数据
  } finally {
    loading.value = false
  }
}

async function submitOrder() {
  if (cartStore.checkedCount === 0) {
    showToast('请选择商品')
    return
  }
  router.push('/order/confirm')
}

onMounted(loadCart)
</script>

<template>
  <div class="cart-page">
    <van-nav-bar title="购物车" />

    <van-pull-refresh v-model="refreshing" @refresh="onRefresh">
      <!-- Empty -->
      <div v-if="!cartStore.items.length && !loading" class="empty-cart">
        <div class="empty-icon">🛒</div>
        <p class="empty-title">购物车是空的</p>
        <p class="empty-sub">快去挑选心仪的时尚单品吧</p>
        <van-button type="primary" round size="small" class="empty-btn" @click="router.push('/')">
          逛逛商城
        </van-button>
      </div>

      <!-- Cart List -->
      <div v-else class="cart-list">
        <van-swipe-cell
          v-for="item in cartStore.items"
          :key="`${item.goodsId}-${item.sku}`"
        >
          <div class="cart-item" :class="{ checked: item.checked }">
            <!-- Checkbox -->
            <div class="cart-check">
              <van-checkbox
                :model-value="item.checked"
                @click="onCheck(item)"
                checked-color="var(--cl-primary)"
              />
            </div>

            <!-- Image -->
            <div class="cart-img-wrap" @click="router.push(`/goods/${item.goodsId}`)">
              <img :src="fullImgUrl(item.image)" class="cart-img" />
            </div>

            <!-- Info -->
            <div class="cart-info" @click="router.push(`/goods/${item.goodsId}`)">
              <p class="cart-name">{{ item.name }}</p>
              <p v-if="item.sku" class="cart-sku">{{ item.sku }}</p>
              <div class="cart-bottom">
                <span class="cart-price">¥{{ item.price }}</span>
                <span class="cart-count">x{{ item.count }}</span>
              </div>
            </div>
          </div>

          <template #right>
            <van-button
              square
              text="删除"
              type="danger"
              class="delete-btn"
              :loading="deleting === item.id"
              @click="onDelete(item)"
            />
          </template>
        </van-swipe-cell>
      </div>
    </van-pull-refresh>

    <!-- Bottom Bar -->
    <van-submit-bar
      v-if="cartStore.items.length > 0"
      class="submit-bar"
      :price="Math.round(cartStore.totalPrice * 100)"
      button-text="结算"
      :disabled="cartStore.checkedCount === 0"
      @submit="submitOrder"
    >
      <van-checkbox v-model="checkedAll" checked-color="var(--cl-primary)">
        全选
      </van-checkbox>
    </van-submit-bar>
  </div>
</template>

<style scoped>
.cart-page {
  min-height: 100vh;
  background: var(--cl-bg);
  padding-bottom: env(safe-area-inset-bottom);
}

/* Empty */
.empty-cart {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 80px 24px 40px;
}
.empty-icon {
  font-size: 80px;
  margin-bottom: 20px;
  opacity: 0.5;
}
.empty-title {
  font-size: 18px;
  font-weight: 600;
  color: var(--cl-text-primary);
  margin-bottom: 8px;
  font-family: var(--font-display);
}
.empty-sub {
  font-size: 13px;
  color: var(--cl-text-muted);
  margin-bottom: 24px;
}
.empty-btn {
  background: var(--cl-primary) !important;
  border-color: var(--cl-primary) !important;
}

/* Cart List */
.cart-list {
  padding: 8px 0;
}
.cart-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 16px;
  background: var(--cl-bg-card);
  margin: 0 12px 8px;
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-xs);
  transition: background var(--transition-fast);
}
.cart-item.checked {
  background: var(--cl-bg-card);
}
.cart-check {
  flex-shrink: 0;
}
.cart-img-wrap {
  width: 72px;
  height: 72px;
  border-radius: var(--radius-sm);
  overflow: hidden;
  flex-shrink: 0;
  background: var(--cl-bg-muted);
  cursor: pointer;
}
.cart-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.cart-info {
  flex: 1;
  min-width: 0;
  cursor: pointer;
}
.cart-name {
  font-size: 14px;
  color: var(--cl-text-primary);
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  margin-bottom: 6px;
}
.cart-sku {
  font-size: 11px;
  color: var(--cl-text-muted);
  margin-bottom: 6px;
}
.cart-bottom {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
}
.cart-price {
  font-size: 15px;
  font-weight: 700;
  color: var(--cl-red);
}
.cart-count {
  font-size: 12px;
  color: var(--cl-text-muted);
}
.delete-btn {
  height: 100%;
  border-radius: 0 var(--radius-md) var(--radius-md) 0;
}

/* Bottom Bar */
.submit-bar {
  border-top: 1px solid var(--cl-border-light);
  box-shadow: 0 -2px 12px rgba(26,26,46,0.06);
}
</style>
