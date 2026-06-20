<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { showLoadingToast, showFailToast, showToast } from 'vant'
import DOMPurify from 'dompurify'
import { publicApi } from '@/api/public'
import { cartApi } from '@/api/cart'
import { useUserStore } from '@/stores/user'
import { useCartStore } from '@/stores/cart'
import { fullImgUrl } from '@/utils/img'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const cartStore = useCartStore()

const id = Number(route.params.id)
const loading = ref(true)
const goods = ref<any>(null)
const sanitizedDetail = computed(() => goods.value?.detail ? DOMPurify.sanitize(goods.value.detail) : '')
const skus = ref<any[]>([])
const activeImage = ref(0)
const showSku = ref(false)
const selectedSku = ref<any>(null)
const count = ref(1)
const skuError = ref('')
const comments = ref<any[]>([])
const commentsLoading = ref(false)
const commentsFinished = ref(false)
const commentPage = ref(1)
const commentSize = 5

const allImages = computed(() => {
  if (!goods.value) return []
  if (goods.value.images?.length) return goods.value.images.map((img: string) => fullImgUrl(img))
  if (goods.value.covers) {
    try { return JSON.parse(goods.value.covers).map((img: string) => fullImgUrl(img)) } catch { /* */ }
  }
  if (goods.value.cover) return [fullImgUrl(goods.value.cover)]
  return []
})

const formattedPrice = computed(() => {
  if (selectedSku.value) return selectedSku.value.price
  return goods.value?.price || 0
})

const formattedStock = computed(() => {
  if (selectedSku.value) return selectedSku.value.stock
  return goods.value?.stock || 0
})

const canBuy = computed(() => formattedStock.value > 0)

function selectSku(sku: any) {
  selectedSku.value = sku
  skuError.value = ''
}

async function fetchDetail() {
  loading.value = true
  try {
    const data: any = await publicApi.goodsDetail(id)
    goods.value = data.goods
    skus.value = data.skus || []
    if (!selectedSku.value && skus.value.length) {
      selectedSku.value = skus.value[0]
    }
  } catch (e: any) {
    showFailToast('加载失败：' + (e?.message || ''))
  } finally {
    loading.value = false
  }
}

async function fetchComments() {
  commentsLoading.value = true
  try {
    const data: any = await publicApi.comments(id, { page: commentPage.value, size: commentSize })
    const list = data?.list || data || []
    if (commentPage.value === 1) comments.value = list
    else comments.value.push(...list)
    commentsFinished.value = list.length < commentSize
    commentPage.value++
  } catch { /* silent */ }
  finally { commentsLoading.value = false }
}

async function addToCart() {
  if (!userStore.isLoggedIn) {
    router.push({ name: 'login', query: { redirect: route.fullPath } })
    return
  }
  if (!selectedSku.value) {
    skuError.value = '请选择规格'
    showSku.value = true
    return
  }
  const toast = showLoadingToast({ message: '加入中...', forbidClick: true })
  try {
    await cartApi.add({ skuId: selectedSku.value.id, quantity: count.value })
    cartStore.addItem({
      id: Date.now(),
      goodsId: goods.value.id,
      name: goods.value.name,
      image: allImages.value[0] || '',
      price: selectedSku.value.price,
      count: count.value,
      sku: typeof selectedSku.value.spec === 'string' ? selectedSku.value.spec : JSON.stringify(selectedSku.value.spec),
      checked: true,
    })
    toast.close()
    showToast({ message: '已加入购物车', position: 'bottom' })
    showSku.value = false
  } catch (e: any) {
    toast.close()
    showFailToast(e?.message || '加入失败')
  }
}

function buyNow() {
  if (!userStore.isLoggedIn) {
    router.push({ name: 'login', query: { redirect: route.fullPath } })
    return
  }
  if (!selectedSku.value) {
    skuError.value = '请选择规格'
    showSku.value = true
    return
  }
  cartStore.addItem({
    id: Date.now(),
    goodsId: goods.value.id,
    name: goods.value.name,
    image: allImages.value[0] || '',
    price: selectedSku.value.price,
    count: count.value,
    sku: typeof selectedSku.value.spec === 'string' ? selectedSku.value.spec : JSON.stringify(selectedSku.value.spec),
    checked: true,
  })
  router.push('/cart')
}

function formatDate(d: string) {
  if (!d) return ''
  return d.substring(0, 10)
}

onMounted(async () => {
  await fetchDetail()
  await fetchComments()
})
</script>

<template>
  <div class="detail-page">
    <!-- Nav Bar -->
    <van-nav-bar
      title="商品详情"
      left-arrow
      @click-left="router.back()"
      class="detail-nav"
    />

    <!-- Loading Skeleton -->
    <template v-if="loading">
      <div class="detail-skeleton">
        <div class="skeleton detail-skeleton-swipe" />
        <div class="detail-skeleton-info">
          <div class="skeleton" style="height:28px;width:60%;margin-bottom:12px" />
          <div class="skeleton" style="height:20px;width:40%;margin-bottom:16px" />
          <div class="skeleton" style="height:16px;width:80%;margin-bottom:8px" />
          <div class="skeleton" style="height:16px;width:70%;margin-bottom:8px" />
          <div class="skeleton" style="height:16px;width:50%" />
        </div>
      </div>
    </template>

    <template v-else-if="goods">
      <!-- Image Gallery -->
      <div class="gallery-wrap">
        <van-swipe
          :autoplay="5000"
          :initial-swipe="activeImage"
          class="gallery-swipe"
          @change="activeImage = $event"
        >
          <van-swipe-item v-for="(img, idx) in allImages" :key="idx">
            <img :src="img" class="gallery-img" />
          </van-swipe-item>
          <template #indicator>
            <div class="gallery-indicator">
              <span
                v-for="(_, i) in allImages"
                :key="i"
                class="gallery-dot"
                :class="{ active: i === activeImage }"
              />
            </div>
          </template>
        </van-swipe>
        <!-- Image counter -->
        <div class="gallery-counter">{{ activeImage + 1 }} / {{ allImages.length }}</div>
      </div>

      <!-- Goods Info -->
      <div class="goods-info-card">
        <div class="goods-price-row">
          <span class="goods-price">
            <span class="price-unit">¥</span>{{ formattedPrice }}
          </span>
          <span v-if="goods.originalPrice" class="goods-original">¥{{ goods.originalPrice }}</span>
          <span v-if="goods.isHot" class="tag tag-red" style="margin-left:auto">热卖</span>
          <span v-if="goods.isNew" class="tag tag-primary" style="margin-left:4px">新品</span>
        </div>
        <h1 class="goods-name">{{ goods.name }}</h1>
        <div class="goods-meta">
          <span>销量 {{ goods.sales || 0 }}</span>
          <span>库存 {{ formattedStock }}</span>
          <span v-if="goods.brand">{{ goods.brand }}</span>
        </div>
      </div>

      <!-- Description -->
      <div v-if="goods.description" class="goods-desc-card">
        <div class="card-title">商品描述</div>
        <p class="goods-desc-text">{{ goods.description }}</p>
      </div>

      <!-- Detail Images -->
      <div v-if="goods.detail" class="goods-detail-images">
        <div class="card-title" style="padding:16px 16px 8px">商品详情</div>
        <div v-html="sanitizedDetail" class="detail-html" />
      </div>

      <!-- Comments -->
      <div class="goods-comments">
        <div class="section-header" style="padding-left:16px;padding-right:16px">
          <span class="section-title">用户评价</span>
        </div>
        <div v-if="!comments.length && !commentsLoading" class="empty-state" style="padding:32px 16px">
          <p class="empty-state-text">暂无评价</p>
        </div>
        <div
          v-for="c in comments"
          :key="c.id"
          class="comment-item"
        >
          <div class="comment-header">
            <div class="comment-avatar">
              {{ (c.nickname || c.userName || 'U')[0].toUpperCase() }}
            </div>
            <div class="comment-meta">
              <span class="comment-user">{{ c.nickname || c.userName || '匿名用户' }}</span>
              <span class="comment-date">{{ formatDate(c.createTime || c.createTimeStr) }}</span>
            </div>
            <van-rate :model-value="c.rating || 5" size="12" color="#c9a96e" readonly />
          </div>
          <p class="comment-content">{{ c.content }}</p>
        </div>
        <van-list
          v-model:loading="commentsLoading"
          :finished="commentsFinished"
          finished-text="— 没有更多评价 —"
          @load="fetchComments"
        />
      </div>

      <!-- Spacer for bottom bar -->
      <div style="height: 72px" />
    </template>

    <!-- Bottom Action Bar -->
    <van-action-bar class="detail-action-bar">
      <van-action-bar-icon icon="shop-o" text="店铺" @click="router.push('/')" />
      <van-action-bar-icon
        icon="cart-o"
        text="购物车"
        :badge="cartStore.totalCount > 0 ? cartStore.totalCount : ''"
        @click="router.push('/cart')"
      />
      <van-action-bar-icon icon="star-o" text="收藏" @click="showToast('收藏功能开发中')" />
      <van-action-bar-button
        type="warning"
        text="加入购物车"
        class="action-btn-cart"
        @click="addToCart"
      />
      <van-action-bar-button
        type="danger"
        text="立即购买"
        class="action-btn-buy"
        @click="buyNow"
      />
    </van-action-bar>

    <!-- SKU Picker Popup -->
    <van-popup
      v-model:show="showSku"
      position="bottom"
      round
      :style="{ maxHeight: '70vh' }"
    >
      <div class="sku-popup">
        <!-- Header -->
        <div class="sku-header">
          <img :src="allImages[0] || ''" class="sku-thumb" />
          <div class="sku-header-info">
            <p class="sku-price">¥{{ formattedPrice }}</p>
            <p class="sku-stock">库存 {{ formattedStock }}</p>
            <p class="sku-tip">请选择规格</p>
          </div>
          <van-icon name="cross" class="sku-close" @click="showSku = false" />
        </div>

        <!-- SKU Options -->
        <div v-if="skus.length" class="sku-options">
          <div
            v-for="sku in skus"
            :key="sku.id"
            class="sku-option"
            :class="{
              selected: selectedSku?.id === sku.id,
              disabled: sku.stock <= 0,
            }"
            @click="sku.stock > 0 && selectSku(sku)"
          >
            <span class="sku-spec">{{ typeof sku.spec === 'string' ? sku.spec : JSON.stringify(sku.spec) }}</span>
            <span class="sku-price-tag">¥{{ sku.price }}</span>
          </div>
        </div>

        <p v-if="skuError" class="sku-error">{{ skuError }}</p>

        <!-- Count -->
        <div class="sku-count-row">
          <span class="sku-count-label">数量</span>
          <van-stepper
            v-model="count"
            :min="1"
            :max="formattedStock"
            :disabled="formattedStock <= 0"
          />
        </div>

        <!-- Confirm Button -->
        <div class="sku-footer">
          <van-button
            type="primary"
            block
            round
            :disabled="!canBuy"
            @click="addToCart"
          >
            {{ canBuy ? `加入购物车` : '暂无库存' }}
          </van-button>
        </div>
      </div>
    </van-popup>
  </div>
</template>

<style scoped>
.detail-page {
  background: var(--cl-bg);
  min-height: 100vh;
  padding-bottom: env(safe-area-inset-bottom);
}

.detail-nav {
  position: sticky;
  top: 0;
  z-index: 100;
}

/* Gallery */
.gallery-wrap {
  position: relative;
  background: var(--cl-bg-muted);
}
.gallery-swipe {
  width: 100%;
  aspect-ratio: 1 / 1;
}
.gallery-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.gallery-indicator {
  position: absolute;
  bottom: 12px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 5px;
}
.gallery-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: rgba(255,255,255,0.5);
  transition: all 0.3s;
}
.gallery-dot.active {
  width: 18px;
  border-radius: 3px;
  background: #fff;
}
.gallery-counter {
  position: absolute;
  bottom: 12px;
  right: 16px;
  background: rgba(0,0,0,0.4);
  color: #fff;
  font-size: 11px;
  padding: 2px 8px;
  border-radius: var(--radius-full);
}

/* Skeleton */
.detail-skeleton {
  padding-bottom: 16px;
}
.detail-skeleton-swipe {
  width: 100%;
  aspect-ratio: 1 / 1;
}
.detail-skeleton-info {
  padding: 16px;
}

/* Goods Info */
.goods-info-card {
  background: var(--cl-bg-card);
  padding: 20px 16px 16px;
  border-radius: 0;
}
.goods-price-row {
  display: flex;
  align-items: baseline;
  gap: 8px;
  margin-bottom: 10px;
}
.goods-price {
  font-size: 28px;
  font-weight: 800;
  color: var(--cl-red);
  font-family: var(--font-display);
}
.price-unit {
  font-size: 16px;
  font-weight: 600;
}
.goods-original {
  font-size: 13px;
  color: var(--cl-text-muted);
  text-decoration: line-through;
}
.goods-name {
  font-size: 17px;
  font-weight: 600;
  color: var(--cl-text-primary);
  line-height: 1.5;
  margin-bottom: 10px;
  font-family: var(--font-display);
}
.goods-meta {
  display: flex;
  gap: 16px;
  font-size: 12px;
  color: var(--cl-text-muted);
}

/* Description */
.goods-desc-card {
  background: var(--cl-bg-card);
  margin-top: 8px;
  padding: 16px;
}
.card-title {
  font-size: 15px;
  font-weight: 600;
  color: var(--cl-text-primary);
  margin-bottom: 10px;
  font-family: var(--font-display);
}
.goods-desc-text {
  font-size: 14px;
  color: var(--cl-text-secondary);
  line-height: 1.7;
}

/* Detail HTML */
.goods-detail-images {
  background: var(--cl-bg-card);
  margin-top: 8px;
}
.detail-html {
  padding: 0 16px 16px;
  font-size: 14px;
  color: var(--cl-text-secondary);
  line-height: 1.7;
  word-break: break-word;
}
.detail-html :deep(img) {
  max-width: 100%;
  height: auto;
  display: block;
  margin: 8px 0;
}

/* Comments */
.goods-comments {
  margin-top: 8px;
  background: var(--cl-bg-card);
  padding-bottom: 16px;
}
.comment-item {
  padding: 14px 16px;
  border-bottom: 1px solid var(--cl-border-light);
}
.comment-item:last-child {
  border-bottom: none;
}
.comment-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 8px;
}
.comment-avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: var(--cl-primary);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 600;
  flex-shrink: 0;
}
.comment-meta {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.comment-user {
  font-size: 13px;
  font-weight: 500;
  color: var(--cl-text-primary);
}
.comment-date {
  font-size: 11px;
  color: var(--cl-text-muted);
}
.comment-content {
  font-size: 13px;
  color: var(--cl-text-secondary);
  line-height: 1.6;
}

/* Bottom Action Bar */
.detail-action-bar {
  height: 56px;
}
.action-btn-cart {
  flex: 1;
}
.action-btn-buy {
  flex: 1;
}

/* SKU Popup */
.sku-popup {
  padding: 16px;
}
.sku-header {
  display: flex;
  gap: 12px;
  padding-bottom: 16px;
  border-bottom: 1px solid var(--cl-border-light);
  position: relative;
}
.sku-thumb {
  width: 80px;
  height: 80px;
  border-radius: var(--radius-sm);
  object-fit: cover;
  background: var(--cl-bg-muted);
  flex-shrink: 0;
}
.sku-header-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 4px;
}
.sku-price {
  font-size: 22px;
  font-weight: 700;
  color: var(--cl-red);
}
.sku-stock {
  font-size: 12px;
  color: var(--cl-text-muted);
}
.sku-tip {
  font-size: 12px;
  color: var(--cl-text-secondary);
}
.sku-close {
  position: absolute;
  top: 0;
  right: 0;
  font-size: 20px;
  color: var(--cl-text-muted);
  padding: 4px;
}

.sku-options {
  padding: 16px 0 8px;
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}
.sku-option {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 8px 14px;
  border: 1.5px solid var(--cl-border);
  border-radius: var(--radius-sm);
  cursor: pointer;
  transition: all var(--transition-fast);
  min-width: 80px;
}
.sku-option.selected {
  border-color: var(--cl-primary);
  background: rgba(26,26,46,0.04);
}
.sku-option.disabled {
  opacity: 0.4;
  cursor: not-allowed;
}
.sku-spec {
  font-size: 13px;
  color: var(--cl-text-primary);
  margin-bottom: 2px;
}
.sku-price-tag {
  font-size: 12px;
  color: var(--cl-red);
  font-weight: 600;
}
.sku-error {
  color: var(--cl-red);
  font-size: 12px;
  padding: 4px 0 8px;
}
.sku-count-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 0;
  border-top: 1px solid var(--cl-border-light);
  margin-top: 8px;
}
.sku-count-label {
  font-size: 14px;
  color: var(--cl-text-primary);
  font-weight: 500;
}
.sku-footer {
  padding-top: 8px;
}
</style>
