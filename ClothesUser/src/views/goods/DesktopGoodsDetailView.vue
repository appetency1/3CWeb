<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { showFailToast, showToast, showLoadingToast, showSuccessToast } from 'vant'
import { publicApi } from '@/api/public'
import { cartApi } from '@/api/cart'
import { useUserStore } from '@/stores/user'
import { useCartStore } from '@/stores/cart'
import { fullImgUrl, IMG_PLACEHOLDER } from '@/utils/img'
import { http } from '@/utils/request'
import DesktopLayout from '@/components/desktop/DesktopLayout.vue'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const cartStore = useCartStore()

const id = Number(route.params.id)
const loading = ref(true)
const goods = ref<any>(null)
const skus = ref<any[]>([])
const activeImage = ref(0)
const selectedSku = ref<any>(null)
const count = ref(1)
const favorited = ref(false)
const favoriting = ref(false)

const comments = ref<any[]>([])
const commentsTotal = ref(0)
const commentPage = ref(1)
const commentSize = 8
const commentsLoading = ref(false)
const commentsFinished = ref(false)
const commentTab = ref<'all' | 'good' | 'mid' | 'bad' | 'image'>('all')

const related = ref<any[]>([])   // 猜你喜欢（同分类）

const allImages = computed(() => {
  if (!goods.value) return []
  // 优先用 images 数组
  if (Array.isArray(goods.value.images) && goods.value.images.length) {
    return goods.value.images.map((s: string) => fullImgUrl(s))
  }
  // 兼容字符串 JSON
  if (typeof goods.value.images === 'string' && goods.value.images) {
    try {
      const arr = JSON.parse(goods.value.images)
      if (Array.isArray(arr) && arr.length) return arr.map((s: string) => fullImgUrl(s))
    } catch { /* */ }
  }
  return goods.value.cover ? [fullImgUrl(goods.value.cover)] : []
})

const price = computed(() => {
  if (selectedSku.value?.price != null) return Number(selectedSku.value.price)
  return Number(goods.value?.price || 0)
})
const stock = computed(() => {
  if (selectedSku.value?.stock != null) return Number(selectedSku.value.stock)
  return Number(goods.value?.stock || 0)
})

const ratingAvg = computed(() => {
  if (!comments.value.length) return 0
  const sum = comments.value.reduce((s, c) => s + (Number(c.rating) || 0), 0)
  return Math.round((sum / comments.value.length) * 10) / 10
})
const ratingCount = computed(() => comments.value.length)
const ratingRatio = computed(() => {
  if (!commentsTotal.value) return 0
  return Math.min(1, comments.value.length / commentsTotal.value)
})
const goodCount = computed(() => comments.value.filter((c: any) => Number(c.rating) >= 4).length)
const midCount = computed(() => comments.value.filter((c: any) => Number(c.rating) === 3).length)
const badCount = computed(() => comments.value.filter((c: any) => Number(c.rating) <= 2).length)
const imageCount = computed(() => comments.value.filter((c: any) => c.images && c.images !== '[]').length)

const filteredComments = computed(() => {
  if (commentTab.value === 'all') return comments.value
  if (commentTab.value === 'good') return comments.value.filter((c: any) => Number(c.rating) >= 4)
  if (commentTab.value === 'mid') return comments.value.filter((c: any) => Number(c.rating) === 3)
  if (commentTab.value === 'bad') return comments.value.filter((c: any) => Number(c.rating) <= 2)
  if (commentTab.value === 'image') return comments.value.filter((c: any) => c.images && c.images !== '[]')
  return comments.value
})

function priceFmt(p: any) { return Number(p || 0).toFixed(2) }
function pct(orig: any, cur: any) {
  const o = Number(orig), c = Number(cur)
  if (!o || o <= c) return 0
  return Math.round((1 - c / o) * 100)
}
function specText(s: any) {
  if (!s) return ''
  if (typeof s.spec === 'string') return s.spec
  try { return JSON.stringify(s.spec) } catch { return String(s.spec) }
}
function parseImgs(json: any): string[] {
  if (!json) return []
  if (Array.isArray(json)) return json
  if (typeof json === 'string' && json) {
    try { const a = JSON.parse(json); return Array.isArray(a) ? a : [] } catch { return [] }
  }
  return []
}
function userInitial(c: any) {
  return 'U'
}

function selectSku(s: any) { selectedSku.value = s }

async function fetchDetail() {
  loading.value = true
  try {
    const data: any = await publicApi.goodsDetail(id)
    goods.value = data.goods
    skus.value = data.skus || []
    if (skus.value.length) selectedSku.value = skus.value[0]
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
    commentsTotal.value = data?.total || 0
    if (commentPage.value === 1) comments.value = list
    else comments.value.push(...list)
    commentsFinished.value = list.length < commentSize
    commentPage.value++
  } catch { /* silent */ }
  finally { commentsLoading.value = false }
}
async function fetchRelated() {
  if (!goods.value?.categoryId) return
  try {
    const data: any = await publicApi.goodsList({
      categoryId: goods.value.categoryId, page: 1, size: 8, sort: 'sales_desc',
    })
    related.value = (data?.list || data || []).filter((g: any) => g.id !== id).slice(0, 5)
  } catch { /* silent */ }
}
async function checkFavorite() {
  if (!userStore.isLoggedIn) return
  try {
    const data: any = await http<{ list: any[]; total: number }>('/user/favorite', { page: 1, size: 100 })
    const ids = (data?.list || []).map((x: any) => Number(x.goodsId))
    favorited.value = ids.includes(id)
  } catch { /* silent */ }
}
async function toggleFavorite() {
  if (!userStore.isLoggedIn) {
    router.push({ name: 'login', query: { redirect: route.fullPath } })
    return
  }
  if (favoriting.value) return
  favoriting.value = true
  try {
    if (favorited.value) {
      await http(`/user/favorite/${id}`, undefined, { method: 'DELETE' })
      favorited.value = false
      showSuccessToast('已取消收藏')
    } else {
      await http('/user/favorite', { goodsId: id }, { method: 'POST' })
      favorited.value = true
      showSuccessToast('已加入收藏')
    }
  } catch (e: any) {
    showFailToast(e?.message || '操作失败')
  } finally {
    favoriting.value = false
  }
}

async function addToCart() {
  if (!userStore.isLoggedIn) {
    router.push({ name: 'login', query: { redirect: route.fullPath } })
    return
  }
  if (!selectedSku.value && skus.value.length) {
    showToast('请选择规格')
    return
  }
  const skuId = selectedSku.value?.id
  if (!skuId) { showToast('暂无可购规格'); return }
  const t = showLoadingToast({ message: '加入中…', forbidClick: true })
  try {
    await cartApi.add({ skuId, quantity: count.value })
    cartStore.addItem({
      id: Date.now(),
      goodsId: goods.value.id,
      name: goods.value.name,
      image: allImages.value[0] || '',
      price: price.value,
      count: count.value,
      sku: specText(selectedSku.value),
      checked: true,
    })
    t.close()
    showToast('已加入购物车')
  } catch (e: any) {
    t.close()
    showFailToast(e?.message || '加入失败')
  }
}

function buyNow() {
  if (!userStore.isLoggedIn) {
    router.push({ name: 'login', query: { redirect: route.fullPath } })
    return
  }
  if (!selectedSku.value && skus.value.length) { showToast('请选择规格'); return }
  addToCart()
  setTimeout(() => router.push('/cart'), 300)
}

function formatDate(s: string) {
  if (!s) return ''
  return s.replace('T', ' ').substring(0, 16)
}
function goGoods(gid: number) {
  if (gid === id) return
  router.push({ name: 'goodsDetail', params: { id: gid } })
}
function loadMoreComments() {
  if (!commentsFinished.value && !commentsLoading.value) fetchComments()
}

onMounted(async () => {
  await fetchDetail()
  await Promise.all([fetchComments(), fetchRelated(), checkFavorite()])
})
</script>

<template>
  <DesktopLayout>
  <div class="detail-page">
    <!-- Loading -->
    <div v-if="loading" class="loading-wrap">
      <div class="skeleton sk-banner" />
      <div class="skeleton sk-line" style="width:60%;height:24px" />
      <div class="skeleton sk-line" style="width:90%;height:14px;margin-top:12px" />
      <div class="skeleton sk-line" style="width:70%;height:14px;margin-top:8px" />
    </div>

    <div v-else-if="goods" class="detail-grid">
      <!-- 左侧 -->
      <div class="gallery-col">
        <div class="gallery">
          <img v-if="allImages.length" :src="allImages[activeImage]" class="gallery-main-img" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" />
          <div v-else class="gallery-empty">暂无图片</div>
          <div v-if="allImages.length > 1" class="thumbs">
            <div
              v-for="(img, i) in allImages"
              :key="i"
              class="thumb"
              :class="{ active: i === activeImage }"
              @click="activeImage = i"
            ><img :src="img" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" /></div>
          </div>
        </div>

        <!-- 猜你喜欢 -->
        <div v-if="related.length" class="related">
          <h3 class="related-h">猜你喜欢</h3>
          <div class="related-row">
            <div v-for="g in related" :key="g.id" class="rel-card" @click="goGoods(g.id)">
              <div class="rel-img-wrap">
                <img :src="fullImgUrl(g.cover)" class="rel-img" loading="lazy" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" />
              </div>
              <p class="rel-name">{{ g.name }}</p>
              <p class="rel-price">¥{{ priceFmt(g.price) }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- 右侧 -->
      <div class="info-col">
        <!-- 1. 价格区 -->
        <div class="info-card">
          <div class="price-row">
            <span class="price">¥{{ priceFmt(price) }}</span>
            <span v-if="goods.originalPrice && Number(goods.originalPrice) > price" class="orig">¥{{ priceFmt(goods.originalPrice) }}</span>
            <span v-if="pct(goods.originalPrice, price) > 0" class="discount-tag">
              立省 {{ pct(goods.originalPrice, price) }}%
            </span>
            <div class="badges">
              <span v-if="goods.isHot" class="tag tag-hot">热卖</span>
              <span v-if="goods.isNew" class="tag tag-new">新品</span>
            </div>
          </div>
          <h1 class="name">{{ goods.name }}</h1>
          <p v-if="goods.description" class="desc">{{ goods.description }}</p>
          <div class="meta">
            <span>销量 {{ goods.sales || 0 }}</span>
            <span>库存 {{ stock }}</span>
            <span v-if="goods.viewCount">浏览 {{ goods.viewCount }}</span>
            <span v-if="goods.brand">品牌 {{ goods.brand }}</span>
          </div>
        </div>

        <!-- 2. 服务保障 -->
        <div class="service-mini">
          <div class="sm-item">🚚 <span>满 ¥299 包邮</span></div>
          <div class="sm-item">🔄 <span>7 天无理由</span></div>
          <div class="sm-item">🛡️ <span>正品保障</span></div>
          <div class="sm-item">⚡ <span>24h 发货</span></div>
        </div>

        <!-- 3. 规格 SKU -->
        <div v-if="skus.length" class="sku-card">
          <h3 class="card-h">规格</h3>
          <div class="sku-list">
            <div
              v-for="s in skus"
              :key="s.id"
              class="sku-item"
              :class="{ active: selectedSku?.id === s.id, disabled: Number(s.stock) <= 0 }"
              @click="Number(s.stock) > 0 && selectSku(s)"
            >
              <span class="sku-spec">{{ specText(s) }}</span>
              <span class="sku-price">¥{{ priceFmt(s.price) }}</span>
              <span v-if="Number(s.stock) <= 0" class="sku-oos">缺货</span>
            </div>
          </div>
        </div>

        <!-- 4. 数量 -->
        <div class="qty-card">
          <h3 class="card-h">数量</h3>
          <div class="qty">
            <button :disabled="count <= 1" @click="count > 1 && count--">−</button>
            <span>{{ count }}</span>
            <button :disabled="count >= stock" @click="count < stock && count++">+</button>
          </div>
          <span class="qty-stock">库存 {{ stock }} 件</span>
        </div>

        <!-- 5. 操作按钮 -->
        <div class="actions">
          <button class="btn-fav" :class="{ on: favorited }" :disabled="favoriting" @click="toggleFavorite">
            {{ favorited ? '♥ 已收藏' : '♡ 收藏' }}
          </button>
          <button class="btn-cart" :disabled="stock <= 0" @click="addToCart">
            🛒 {{ stock > 0 ? '加入购物车' : '暂无库存' }}
          </button>
          <button class="btn-buy" :disabled="stock <= 0" @click="buyNow">
            {{ stock > 0 ? '立即购买' : '暂无库存' }}
          </button>
        </div>

        <!-- 6. 商品详情 -->
        <div v-if="goods.detail" class="detail-card">
          <h3 class="card-h">商品详情</h3>
          <div v-html="goods.detail" class="detail-html" />
        </div>

        <!-- 7. 评价 -->
        <div class="comment-card">
          <h3 class="card-h">用户评价</h3>

          <!-- 评价概览 -->
          <div v-if="ratingCount" class="rating-overview">
            <div class="ro-left">
              <div class="ro-avg">{{ ratingAvg }}</div>
              <div class="ro-stars">
                <span v-for="n in 5" :key="n" :class="n <= Math.round(ratingAvg) ? 'star on' : 'star'">★</span>
              </div>
              <div class="ro-count">共 {{ ratingCount }} 条评价</div>
            </div>
            <div class="ro-tags">
              <span class="ro-tag">好评 {{ goodCount }}</span>
              <span class="ro-tag">中评 {{ midCount }}</span>
              <span class="ro-tag">差评 {{ badCount }}</span>
              <span class="ro-tag">有图 {{ imageCount }}</span>
            </div>
          </div>

          <!-- 评价 tab -->
          <div class="comment-tabs">
            <div class="ct" :class="{ on: commentTab === 'all' }" @click="commentTab = 'all'">全部</div>
            <div class="ct" :class="{ on: commentTab === 'good' }" @click="commentTab = 'good'">好评</div>
            <div class="ct" :class="{ on: commentTab === 'mid' }" @click="commentTab = 'mid'">中评</div>
            <div class="ct" :class="{ on: commentTab === 'bad' }" @click="commentTab = 'bad'">差评</div>
            <div class="ct" :class="{ on: commentTab === 'image' }" @click="commentTab = 'image'">有图</div>
          </div>

          <div v-if="!filteredComments.length" class="empty">暂无评价</div>

          <div v-for="c in filteredComments" :key="c.id" class="comment-item">
            <div class="c-head">
              <div class="c-avatar">{{ userInitial(c) }}</div>
              <div class="c-meta">
                <div class="c-user">用户 #{{ c.userId }}</div>
                <div class="c-date">{{ formatDate(c.createTime) }}</div>
              </div>
              <div class="c-stars">
                <span v-for="n in 5" :key="n" :class="n <= (Number(c.rating) || 5) ? 'star on' : 'star'">★</span>
              </div>
            </div>
            <p class="c-content">{{ c.content }}</p>
            <div v-if="parseImgs(c.images).length" class="c-imgs">
              <img v-for="(img, i) in parseImgs(c.images)" :key="i" :src="fullImgUrl(img)" class="c-img" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" />
            </div>
          </div>

          <button v-if="!commentsFinished && comments.length" class="more-btn" @click="loadMoreComments">
            加载更多评价
          </button>
        </div>
      </div>
    </div>
  </div>
  </DesktopLayout>
</template>

<style scoped>
.detail-page { background: #faf9f7; min-height: auto; padding-bottom: 0; }

.loading-wrap { max-width: 1400px; margin: 24px auto; padding: 0 40px; }
.sk-banner { width: 100%; aspect-ratio: 1; border-radius: 12px; margin-bottom: 16px; }
.sk-line { background: #ece9e3; border-radius: 6px; }
.skeleton { background: #ece9e3; animation: sk 1.4s infinite; }
@keyframes sk { 50% { opacity: 0.5; } }

.detail-grid {
  max-width: 1400px; margin: 24px auto; padding: 0 40px;
  display: grid; grid-template-columns: 1fr 1fr; gap: 32px;
}

/* === Gallery === */
.gallery-col { min-width: 0; }
.gallery { background: #fff; border-radius: 12px; overflow: hidden; border: 1px solid #f0ede8; }
.gallery-main-img { width: 100%; aspect-ratio: 1; object-fit: cover; display: block; }
.gallery-empty { aspect-ratio: 1; display: flex; align-items: center; justify-content: center; color: #999; font-size: 14px; }
.thumbs { display: flex; gap: 8px; padding: 12px; overflow-x: auto; scrollbar-width: none; }
.thumbs::-webkit-scrollbar { display: none; }
.thumb {
  flex-shrink: 0; width: 72px; height: 72px; border-radius: 6px; overflow: hidden;
  border: 2px solid transparent; cursor: pointer; background: #f5f3f0;
}
.thumb img { width: 100%; height: 100%; object-fit: cover; }
.thumb.active { border-color: #c45c4a; }

/* === Related === */
.related { margin-top: 20px; background: #fff; border-radius: 12px; padding: 20px; border: 1px solid #f0ede8; }
.related-h { font-size: 15px; font-weight: 600; color: #1a1a1a; margin-bottom: 14px; padding-left: 10px; border-left: 3px solid #c45c4a; }
.related-row { display: flex; gap: 12px; overflow-x: auto; padding-bottom: 4px; scrollbar-width: none; }
.related-row::-webkit-scrollbar { display: none; }
.rel-card { flex-shrink: 0; width: 130px; cursor: pointer; }
.rel-img-wrap { width: 130px; height: 130px; border-radius: 8px; overflow: hidden; background: #f5f3f0; }
.rel-img { width: 100%; height: 100%; object-fit: cover; }
.rel-name { font-size: 12px; color: #1a1a1a; margin-top: 8px; line-height: 1.4; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.rel-price { font-size: 14px; font-weight: 700; color: #c45c4a; margin-top: 4px; }

/* === Info === */
.info-col { min-width: 0; }
.info-card, .sku-card, .qty-card, .detail-card, .comment-card {
  background: #fff; border-radius: 12px; padding: 24px; margin-bottom: 16px; border: 1px solid #f0ede8;
}

.price-row { display: flex; align-items: baseline; gap: 10px; margin-bottom: 12px; }
.price { font-size: 32px; font-weight: 700; color: #c45c4a; letter-spacing: -0.5px; }
.orig { font-size: 14px; color: #999; text-decoration: line-through; }
.discount-tag { padding: 2px 8px; background: #fdf5f3; color: #c45c4a; font-size: 11px; font-weight: 600; border-radius: 3px; }
.badges { margin-left: auto; display: flex; gap: 4px; }
.tag { padding: 2px 8px; font-size: 11px; font-weight: 600; border-radius: 3px; color: #fff; }
.tag-hot { background: #c45c4a; }
.tag-new { background: #1a1a1a; }
.name { font-size: 22px; font-weight: 600; color: #1a1a1a; line-height: 1.4; margin-bottom: 12px; }
.desc { font-size: 14px; color: #666; line-height: 1.6; margin-bottom: 12px; }
.meta { display: flex; flex-wrap: wrap; gap: 16px; font-size: 12px; color: #999; padding-top: 12px; border-top: 1px solid #f0ede8; }

.service-mini { display: flex; gap: 0; background: #fff; border-radius: 12px; padding: 14px; margin-bottom: 16px; border: 1px solid #f0ede8; }
.sm-item { flex: 1; text-align: center; font-size: 12px; color: #666; }
.sm-item span { margin-left: 4px; }

.card-h { font-size: 15px; font-weight: 600; color: #1a1a1a; margin-bottom: 14px; padding-left: 10px; border-left: 3px solid #c45c4a; }

.sku-list { display: flex; flex-wrap: wrap; gap: 8px; }
.sku-item {
  display: flex; align-items: center; gap: 6px; padding: 8px 14px; border: 1.5px solid #e8e5e0;
  border-radius: 6px; font-size: 13px; color: #1a1a1a; cursor: pointer; transition: all 0.2s; min-width: 100px;
}
.sku-item:hover { border-color: #c45c4a; }
.sku-item.active { border-color: #c45c4a; background: #fdf5f3; color: #c45c4a; }
.sku-item.disabled { opacity: 0.4; cursor: not-allowed; }
.sku-spec { font-size: 13px; }
.sku-price { font-size: 12px; color: #c45c4a; font-weight: 600; }
.sku-oos { font-size: 11px; color: #999; }

.qty-card { display: flex; align-items: center; gap: 20px; }
.qty-card .card-h { margin-bottom: 0; border: none; padding: 0; }
.qty {
  display: flex; align-items: center; border: 1.5px solid #e8e5e0; border-radius: 6px; overflow: hidden;
}
.qty button {
  width: 36px; height: 36px; border: none; background: #faf9f7; font-size: 18px; cursor: pointer; color: #1a1a1a;
}
.qty button:hover:not(:disabled) { background: #f5f3f0; }
.qty button:disabled { opacity: 0.4; cursor: not-allowed; }
.qty span { width: 56px; text-align: center; font-size: 14px; }
.qty-stock { font-size: 12px; color: #999; }

.actions { display: flex; gap: 12px; margin-bottom: 16px; }
.btn-fav, .btn-cart, .btn-buy {
  border: none; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer; transition: all 0.2s;
  height: 48px;
}
.btn-fav { width: 110px; background: #fff; color: #1a1a1a; border: 1.5px solid #e8e5e0; }
.btn-fav.on { color: #c45c4a; border-color: #c45c4a; background: #fdf5f3; }
.btn-cart { flex: 1; background: #1a1a1a; color: #fff; }
.btn-cart:hover:not(:disabled) { background: #333; }
.btn-buy { flex: 1.4; background: #c45c4a; color: #fff; }
.btn-buy:hover:not(:disabled) { background: #8b3a2a; }
.btn-fav:disabled, .btn-cart:disabled, .btn-buy:disabled { opacity: 0.5; cursor: not-allowed; }

.detail-html { font-size: 14px; color: #1a1a1a; line-height: 1.7; word-break: break-word; }
.detail-html :deep(img) { max-width: 100%; height: auto; display: block; margin: 8px 0; border-radius: 6px; }

/* Comments */
.rating-overview { display: flex; align-items: center; justify-content: space-between; padding: 16px 0; border-bottom: 1px solid #f0ede8; margin-bottom: 16px; }
.ro-left { text-align: center; }
.ro-avg { font-size: 36px; font-weight: 700; color: #c45c4a; line-height: 1; }
.ro-stars { margin: 4px 0; font-size: 12px; }
.star { color: #e0dcd5; margin: 0 1px; }
.star.on { color: #c45c4a; }
.ro-count { font-size: 11px; color: #999; }
.ro-tags { display: flex; flex-direction: column; gap: 6px; }
.ro-tag { padding: 4px 10px; background: #faf9f7; border: 1px solid #e8e5e0; border-radius: 12px; font-size: 11px; color: #666; }

.comment-tabs { display: flex; gap: 6px; margin-bottom: 16px; flex-wrap: wrap; }
.ct { padding: 6px 14px; background: #faf9f7; border: 1px solid #e8e5e0; border-radius: 14px; font-size: 12px; color: #666; cursor: pointer; transition: all 0.2s; }
.ct:hover { color: #c45c4a; border-color: #c45c4a; }
.ct.on { background: #1a1a1a; color: #fff; border-color: #1a1a1a; }

.comment-item { padding: 16px 0; border-top: 1px solid #f0ede8; }
.comment-item:first-of-type { border-top: none; padding-top: 0; }
.c-head { display: flex; align-items: center; gap: 10px; margin-bottom: 8px; }
.c-avatar { width: 36px; height: 36px; border-radius: 50%; background: linear-gradient(135deg, #c45c4a, #8b3a2a); color: #fff; display: flex; align-items: center; justify-content: center; font-size: 13px; font-weight: 600; flex-shrink: 0; }
.c-meta { flex: 1; }
.c-user { font-size: 13px; color: #1a1a1a; }
.c-date { font-size: 11px; color: #999; margin-top: 2px; }
.c-stars { font-size: 12px; }
.c-content { font-size: 13px; color: #1a1a1a; line-height: 1.6; }
.c-imgs { display: flex; gap: 8px; margin-top: 8px; flex-wrap: wrap; }
.c-img { width: 80px; height: 80px; object-fit: cover; border-radius: 6px; }

.more-btn {
  display: block; margin: 16px auto 0; padding: 8px 24px; border: 1px solid #e8e5e0;
  background: #faf9f7; color: #666; font-size: 13px; border-radius: 16px; cursor: pointer; transition: all 0.2s;
}
.more-btn:hover { color: #c45c4a; border-color: #c45c4a; }

.empty { text-align: center; padding: 40px 0; color: #999; font-size: 13px; }

@media (max-width: 1024px) {
  .page-header, .detail-grid, .loading-wrap { padding-left: 16px; padding-right: 16px; }
  .detail-grid { grid-template-columns: 1fr; }
}
</style>
