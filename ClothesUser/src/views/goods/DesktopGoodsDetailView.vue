<script setup lang="ts">
import { ref, onMounted, computed, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { showFailToast, showToast, showLoadingToast, showSuccessToast } from 'vant'
import { publicApi } from '@/api/public'
import { cartApi } from '@/api/cart'
import { useUserStore } from '@/stores/user'
import { useCartStore } from '@/stores/cart'
import { fullImgUrl, IMG_PLACEHOLDER } from '@/utils/img'
import { http } from '@/utils/request'
import DesktopLayout from '@/components/desktop/DesktopLayout.vue'
import DOMPurify from 'dompurify'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const cartStore = useCartStore()

const loading = ref(true)
const goods = ref<any>(null)
const sanitizedDetail = computed(() => goods.value?.detail ? DOMPurify.sanitize(goods.value.detail) : '')
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
function parseSpec(spec: any): Record<string, string> {
  if (spec == null) return {}
  if (typeof spec === 'object') return spec
  try { return JSON.parse(spec) } catch { return {} }
}

/** 常见颜色名称 → 色值映射 */
function colorMap(name: string): string {
  const map: Record<string, string> = {
    '红色': '#d43d3d', '奶茶色': '#c8a882', '白色': '#f0f0f0', '黑色': '#2a2a2a',
    '粉色': '#f5a0b0', '蓝色': '#4a7db4', '绿色': '#5a9e6f', '黄色': '#e8c84a',
    '灰色': '#8a8a8a', '紫色': '#8a5a9e', '棕色': '#8b6b4a', '米色': '#e8dcc8',
    '卡其': '#c3a87a', '深蓝': '#1a3a5c', '杏色': '#e8b88a', '花色': '#d4a0a0',
    '咖色': '#8a6a4a', '浅灰': '#c8c8c8', '深灰': '#5a5a5a', '藏青': '#1a2a4a',
    '天蓝': '#87ceeb', '军绿': '#4a6a3a', '驼色': '#b88a5a', '酒红': '#6a2a3a',
  }
  return map[name] || '#ddd'
}

function specText(s: any) {
  const obj = parseSpec(s.spec)
  return Object.values(obj).join(' / ') || '默认规格'
}
function parseImgs(json: any): string[] {
  if (!json) return []
  if (Array.isArray(json)) return json
  if (typeof json === 'string' && json) {
    try { const a = JSON.parse(json); return Array.isArray(a) ? a : [] } catch { return [] }
  }
  return []
}
function userInitial(_c: any) {
  return 'U'
}

function selectSku(s: any) { selectedSku.value = s }

async function fetchDetail() {
  const gid = Number(route.params.id)
  if (!gid) return
  loading.value = true
  try {
    const data: any = await publicApi.goodsDetail(gid)
    goods.value = data
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
    const data: any = await publicApi.comments(Number(route.params.id), { page: commentPage.value, size: commentSize })
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
    related.value = (data?.list || data || []).filter((g: any) => Number(g.id) !== Number(route.params.id)).slice(0, 5)
  } catch { /* silent */ }
}
async function checkFavorite() {
  if (!userStore.isLoggedIn) return
  try {
    const data: any = await http<{ list: any[]; total: number }>('/user/favorite', { page: 1, size: 100 })
    const ids = (data?.list || []).map((x: any) => Number(x.goodsId))
    favorited.value = ids.includes(Number(route.params.id))
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
    const gid = Number(route.params.id)
    if (favorited.value) {
      await http(`/user/favorite/${gid}`, undefined, { method: 'DELETE' })
      favorited.value = false
      showSuccessToast('已取消收藏')
    } else {
      await http('/user/favorite', { goodsId: gid }, { method: 'POST' })
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

function loadMoreComments() {
  if (!commentsFinished.value && !commentsLoading.value) fetchComments()
}

async function loadAll() {
  loading.value = true
  goods.value = null
  skus.value = []
  related.value = []
  comments.value = []
  commentPage.value = 1
  commentsFinished.value = false
  activeImage.value = 0
  selectedSku.value = null
  favorited.value = false
  await fetchDetail()
  await Promise.all([fetchComments(), fetchRelated(), checkFavorite()])
}

onMounted(loadAll)

watch(() => route.params.id, () => { loadAll() })
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
              @click="activeImage = +i"
            ><img :src="img" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" /></div>
          </div>
        </div>

        <!-- 猜你喜欢 -->
        <div v-if="related.length" class="related">
          <h3 class="related-h">猜你喜欢</h3>
          <div class="related-row">
            <router-link v-for="g in related" :key="g.id" :to="'/goods/' + g.id" class="rc-card">
              <div class="rc-img-wrap">
                <img :src="fullImgUrl(g.cover)" loading="lazy" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" />
              </div>
              <div class="rc-body">
                <p class="rc-name">{{ g.name }}</p>
                <p class="rc-price">¥{{ priceFmt(g.minPrice || g.price) }}</p>
              </div>
            </router-link>
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
              <div class="sku-specs">
                <template v-for="(v, k) in parseSpec(s.spec)" :key="k">
                  <span v-if="k === '颜色' || k === '颜色分类'" class="color-chip">
                    <span class="color-dot" :style="{ background: colorMap(v) }"></span>
                    {{ v }}
                  </span>
                  <span v-else class="spec-tag">{{ k }}: {{ v }}</span>
                </template>
                <span v-if="!s.spec || Object.keys(parseSpec(s.spec)).length === 0" class="sku-spec-text">默认规格</span>
              </div>
              <div class="sku-meta">
                <span class="sku-price">¥{{ priceFmt(s.price) }}</span>
                <span v-if="Number(s.stock) > 0" class="sku-stock">库存 {{ s.stock }}</span>
                <span v-else class="sku-oos">缺货</span>
              </div>
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
          <div v-html="sanitizedDetail" class="detail-html" />
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
.detail-page { background: transparent; min-height: auto; padding-bottom: 0; }

.loading-wrap { max-width: 1440px; margin: 24px auto; padding: 0 40px; }
.sk-banner { width: 100%; aspect-ratio: 1; border-radius: 16px; margin-bottom: 16px; }
.sk-line { background: var(--bg-card); border-radius: 6px; }
.skeleton { background: var(--bg-card); animation: sk 1.4s infinite; border: 1px solid var(--border); }
@keyframes sk { 50% { opacity: 0.5; } }

.detail-grid {
  max-width: 1440px; margin: 24px auto; padding: 0 40px;
  display: grid; grid-template-columns: 1fr 1fr; gap: 32px;
}

/* === Gallery === */
.gallery-col { min-width: 0; }
.gallery {
  background: var(--bg-card); border-radius: 16px; overflow: hidden;
  border: 1px solid var(--border); position: relative;
}
.gallery::before {
  content: ''; position: absolute; inset: 0; z-index: 0;
  background: linear-gradient(135deg, rgba(0,240,255,0.02), transparent 50%);
  pointer-events: none;
}
.gallery-main-img { width: 100%; aspect-ratio: 1; object-fit: cover; display: block; position: relative; z-index: 1; }
.gallery-empty { aspect-ratio: 1; display: flex; align-items: center; justify-content: center; color: var(--text-muted); font-size: 14px; }
.thumbs { display: flex; gap: 8px; padding: 12px; overflow-x: auto; scrollbar-width: none; position: relative; z-index: 1; }
.thumbs::-webkit-scrollbar { display: none; }
.thumb {
  flex-shrink: 0; width: 72px; height: 72px; border-radius: 8px; overflow: hidden;
  border: 2px solid transparent; cursor: pointer; background: var(--bg-dark);
  transition: all .3s;
}
.thumb img { width: 100%; height: 100%; object-fit: cover; }
.thumb.active { border-color: var(--accent); box-shadow: 0 0 12px var(--accent-glow); }

/* === 猜你喜欢 === */
.related {
  margin-top: 20px;
  background: var(--bg-card);
  border-radius: 16px;
  padding: 20px;
  border: 1px solid var(--border);
}
.related-h {
  font-size: 15px; font-weight: 600; color: var(--text-primary);
  margin-bottom: 16px; padding-left: 10px;
  border-left: 3px solid var(--accent);
  font-family: var(--font-display, 'Orbitron', sans-serif); letter-spacing: 1px;
}
.related-row { display: flex; gap: 14px; overflow-x: auto; padding-bottom: 4px; scrollbar-width: none; }
.related-row::-webkit-scrollbar { display: none; }
.rc-card {
  flex-shrink: 0; width: 150px; display: block; text-decoration: none;
  color: inherit; cursor: pointer; transition: transform 0.3s;
}
.rc-card:hover { transform: translateY(-4px); }
.rc-img-wrap {
  width: 150px; height: 150px; border-radius: 12px; overflow: hidden;
  background: linear-gradient(145deg, #0a0a16, #131326);
  margin-bottom: 10px; border: 1px solid var(--border);
}
.rc-img-wrap img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.4s; }
.rc-card:hover .rc-img-wrap img { transform: scale(1.06); }
.rc-body { padding: 0 2px; }
.rc-name { font-size: 13px; color: var(--text-primary); line-height: 1.4; margin-bottom: 6px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; min-height: 36px; }
.rc-price { font-family: 'Orbitron', sans-serif; font-size: 16px; font-weight: 700; color: var(--accent); }

/* === Info === */
.info-col { min-width: 0; }
.info-card, .sku-card, .qty-card, .detail-card, .comment-card {
  background: var(--bg-card); border-radius: 16px; padding: 24px; margin-bottom: 16px;
  border: 1px solid var(--border);
}

.price-row { display: flex; align-items: baseline; gap: 10px; margin-bottom: 12px; }
.price { font-size: 32px; font-weight: 700; color: var(--accent); font-family: 'Orbitron', sans-serif; text-shadow: 0 0 16px var(--accent-glow); letter-spacing: -0.5px; }
.orig { font-size: 14px; color: var(--text-muted); text-decoration: line-through; }
.discount-tag { padding: 2px 10px; background: rgba(0,240,255,0.1); color: var(--accent); font-size: 11px; font-weight: 600; border-radius: 4px; border: 1px solid rgba(0,240,255,0.2); }
.badges { margin-left: auto; display: flex; gap: 4px; }
.tag { padding: 3px 10px; font-size: 11px; font-weight: 700; border-radius: 4px; color: #000; }
.tag-hot { background: linear-gradient(135deg, var(--accent), var(--accent-tertiary)); }
.tag-new { background: linear-gradient(135deg, var(--accent-secondary), var(--neon-pink, #ff2a8a)); color: #fff; }
.name { font-size: 22px; font-weight: 600; color: var(--text-primary); line-height: 1.4; margin-bottom: 12px; }
.desc { font-size: 14px; color: var(--text-secondary); line-height: 1.6; margin-bottom: 12px; }
.meta { display: flex; flex-wrap: wrap; gap: 16px; font-size: 12px; color: var(--text-muted); padding-top: 12px; border-top: 1px solid var(--border); }

.service-mini { display: flex; gap: 0; background: var(--bg-card); border-radius: 14px; padding: 14px; margin-bottom: 16px; border: 1px solid var(--border); }
.sm-item { flex: 1; text-align: center; font-size: 12px; color: var(--text-secondary); }
.sm-item span { margin-left: 4px; }

.card-h { font-size: 15px; font-weight: 600; color: var(--text-primary); margin-bottom: 14px; padding-left: 10px; border-left: 3px solid var(--accent); font-family: var(--font-display, 'Orbitron', sans-serif); letter-spacing: 1px; }

.sku-list { display: flex; flex-wrap: wrap; gap: 8px; }
.sku-item {
  display: flex; flex-direction: column; gap: 6px; padding: 10px 14px; border: 1.5px solid var(--border);
  border-radius: 10px; font-size: 13px; color: var(--text-primary); cursor: pointer; transition: all 0.3s; min-width: 120px;
  background: rgba(255,255,255,0.02);
}
.sku-item:hover { border-color: var(--accent); }
.sku-item.active { border-color: var(--accent); background: rgba(0,240,255,0.05); box-shadow: 0 0 16px rgba(0,240,255,0.08); }
.sku-item.disabled { opacity: 0.4; cursor: not-allowed; }
.sku-specs { display: flex; flex-wrap: wrap; gap: 4px; align-items: center; }
.sku-spec-text { font-size: 13px; color: var(--text-muted); }
.sku-meta { display: flex; align-items: center; gap: 8px; }
.sku-price { font-size: 14px; color: var(--accent); font-weight: 600; font-family: 'Orbitron', sans-serif; }
.sku-stock { font-size: 11px; color: var(--text-muted); }
.sku-oos { font-size: 11px; color: var(--text-muted); }
.color-chip { display: inline-flex; align-items: center; gap: 4px; font-size: 12px; color: var(--text-secondary); }
.color-dot { display: inline-block; width: 12px; height: 12px; border-radius: 50%; border: 1px solid rgba(255,255,255,0.1); flex-shrink: 0; }
.spec-tag { display: inline-block; font-size: 11px; color: var(--text-secondary); background: rgba(255,255,255,0.03); padding: 1px 6px; border-radius: 4px; }

.qty-card { display: flex; align-items: center; gap: 20px; }
.qty-card .card-h { margin-bottom: 0; border: none; padding: 0; }
.qty { display: flex; align-items: center; border: 1.5px solid var(--border); border-radius: 8px; overflow: hidden; }
.qty button {
  width: 36px; height: 36px; border: none; background: rgba(255,255,255,0.02); font-size: 18px;
  cursor: pointer; color: var(--text-primary); transition: background .2s;
}
.qty button:hover:not(:disabled) { background: rgba(0,240,255,0.05); }
.qty button:disabled { opacity: 0.4; cursor: not-allowed; }
.qty span { width: 56px; text-align: center; font-size: 14px; color: var(--text-primary); }
.qty-stock { font-size: 12px; color: var(--text-muted); }

.actions { display: flex; gap: 12px; margin-bottom: 16px; }
.btn-fav, .btn-cart, .btn-buy {
  border: none; border-radius: 10px; font-size: 14px; font-weight: 600; cursor: pointer;
  transition: all 0.3s; height: 48px; font-family: var(--font-body);
}
.btn-fav {
  width: 110px; background: rgba(255,255,255,0.03); color: var(--text-secondary);
  border: 1.5px solid var(--border);
}
.btn-fav.on { color: var(--accent-secondary); border-color: var(--accent-secondary); background: rgba(255,0,170,0.06); }
.btn-fav:hover:not(:disabled) { border-color: var(--accent); color: var(--accent); }
.btn-cart {
  flex: 1; background: linear-gradient(135deg, var(--accent), var(--accent-tertiary)); color: #000;
  box-shadow: 0 0 20px rgba(0,240,255,0.2);
}
.btn-cart:hover:not(:disabled) { box-shadow: 0 8px 32px rgba(0,240,255,0.35); transform: translateY(-1px); }
.btn-buy {
  flex: 1.4; border: 1px solid var(--border); background: rgba(255,255,255,0.03); color: var(--text-primary);
}
.btn-buy:hover:not(:disabled) { border-color: var(--accent); color: var(--accent); background: rgba(0,240,255,0.03); }
.btn-fav:disabled, .btn-cart:disabled, .btn-buy:disabled { opacity: 0.5; cursor: not-allowed; transform: none !important; }

.detail-html { font-size: 14px; color: var(--text-primary); line-height: 1.7; word-break: break-word; }
.detail-html :deep(img) { max-width: 100%; height: auto; display: block; margin: 8px 0; border-radius: 8px; }
.detail-html :deep(p) { color: var(--text-secondary); }

/* Comments */
.rating-overview { display: flex; align-items: center; justify-content: space-between; padding: 16px 0; border-bottom: 1px solid var(--border); margin-bottom: 16px; }
.ro-left { text-align: center; }
.ro-avg { font-size: 36px; font-weight: 700; color: var(--accent); line-height: 1; font-family: 'Orbitron', sans-serif; text-shadow: 0 0 16px var(--accent-glow); }
.ro-stars { margin: 4px 0; font-size: 12px; }
.star { color: var(--text-muted); margin: 0 1px; }
.star.on { color: var(--accent); text-shadow: 0 0 6px var(--accent-glow); }
.ro-count { font-size: 11px; color: var(--text-muted); }
.ro-tags { display: flex; flex-direction: column; gap: 6px; }
.ro-tag { padding: 4px 10px; background: rgba(255,255,255,0.03); border: 1px solid var(--border); border-radius: 12px; font-size: 11px; color: var(--text-secondary); }

.comment-tabs { display: flex; gap: 6px; margin-bottom: 16px; flex-wrap: wrap; }
.ct { padding: 6px 14px; background: rgba(255,255,255,0.03); border: 1px solid var(--border); border-radius: 14px; font-size: 12px; color: var(--text-muted); cursor: pointer; transition: all 0.3s; }
.ct:hover { color: var(--accent); border-color: var(--accent); }
.ct.on { background: linear-gradient(135deg, var(--accent), var(--accent-tertiary)); color: #000; border-color: transparent; font-weight: 600; box-shadow: 0 0 12px rgba(0,240,255,0.15); }

.comment-item { padding: 16px 0; border-top: 1px solid var(--border); }
.comment-item:first-of-type { border-top: none; padding-top: 0; }
.c-head { display: flex; align-items: center; gap: 10px; margin-bottom: 8px; }
.c-avatar {
  width: 36px; height: 36px; border-radius: 50%;
  background: linear-gradient(135deg, var(--accent), var(--accent-tertiary));
  color: #000; display: flex; align-items: center; justify-content: center;
  font-size: 13px; font-weight: 700; flex-shrink: 0;
}
.c-meta { flex: 1; }
.c-user { font-size: 13px; color: var(--text-primary); }
.c-date { font-size: 11px; color: var(--text-muted); margin-top: 2px; }
.c-stars { font-size: 12px; }
.c-content { font-size: 13px; color: var(--text-primary); line-height: 1.6; }
.c-imgs { display: flex; gap: 8px; margin-top: 8px; flex-wrap: wrap; }
.c-img { width: 80px; height: 80px; object-fit: cover; border-radius: 8px; border: 1px solid var(--border); }

.more-btn {
  display: block; margin: 16px auto 0; padding: 8px 24px; border: 1px solid var(--border);
  background: rgba(255,255,255,0.02); color: var(--text-secondary); font-size: 13px;
  border-radius: 16px; cursor: pointer; transition: all 0.3s;
}
.more-btn:hover { color: var(--accent); border-color: var(--accent); }

.empty { text-align: center; padding: 40px 0; color: var(--text-muted); font-size: 13px; }

@media (max-width: 1024px) {
  .page-header, .detail-grid, .loading-wrap { padding-left: 16px; padding-right: 16px; }
  .detail-grid { grid-template-columns: 1fr; }
}
</style>
