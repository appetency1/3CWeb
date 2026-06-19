<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { publicApi } from '@/api/public'
import { favoriteApi } from '@/api/favorite'
import { fullImgUrl, IMG_PLACEHOLDER } from '@/utils/img'
import { useUserStore } from '@/stores/user'
import DesktopLayout from '@/components/desktop/DesktopLayout.vue'

const router = useRouter()
const userStore = useUserStore()

const banners = ref<any[]>([])
const bannersLoaded = ref(false)
const activeBanner = ref(0)
const swipeRef = ref<any>(null)            // 手动切换轮播
function prevSlide() { swipeRef.value?.swipeTo(activeBanner.value - 1) }
function nextSlide() { swipeRef.value?.swipeTo(activeBanner.value + 1) }
const categories = ref<any[]>([])         // 一级 + children
const hotGoods = ref<any[]>([])
const newGoods = ref<any[]>([])
const allGoods = ref<any[]>([])          // 通用商品
const flashGoods = ref<any[]>([])         // 限时秒杀（从 hot 算折扣）
const brands = ref<string[]>([])          // 品牌矩阵
const countdown = ref({ h: '02', m: '15', s: '43' })
let countdownTimer: any = null

// 收藏状态
const wishlistSet = ref(new Set<number>())

async function loadWishlist() {
  if (!userStore.isLoggedIn) return
  try {
    const data: any = await favoriteApi.list(1, 100)
    const ids = (data?.list || []).map((x: any) => Number(x.goodsId))
    wishlistSet.value = new Set(ids)
  } catch { /* silent */ }
}
async function toggleWishlist(g: any) {
  if (!userStore.isLoggedIn) { router.push({ name: 'login', query: { redirect: '/user/favorites' } }); return }
  const id = Number(g.id)
  const s = new Set(wishlistSet.value)
  if (s.has(id)) { await favoriteApi.remove(id); s.delete(id) }
  else { await favoriteApi.add(id); s.add(id) }
  wishlistSet.value = s
}

// 秒杀自动轮转
const flashOffset = ref(0)
let flashScrollTimer: any = null
let flashItemStep = 0

function calcFlashStep() {
  setTimeout(() => {
    const el = document.querySelector('.flash-item') as HTMLElement | null
    if (el) flashItemStep = el.offsetWidth + 16
  }, 100)
}

function startFlashScroll() {
  if (!flashGoods.value.length || flashGoods.value.length <= 5) return
  stopFlashScroll()
  stopFlashScroll()
  calcFlashStep()
  flashScrollTimer = setInterval(() => {
    const total = flashGoods.value.length
    if (!flashItemStep) calcFlashStep()
    if (!flashItemStep) return
    flashOffset.value += flashItemStep
    if (flashOffset.value >= total * flashItemStep) flashOffset.value = 0
  }, 4000)
}
function stopFlashScroll() { if (flashScrollTimer) { clearInterval(flashScrollTimer); flashScrollTimer = null } }
function pauseFlashScroll() { stopFlashScroll() }
function resumeFlashScroll() { startFlashScroll() }

function priceFmt(p: any) { return Number(p || 0).toFixed(2) }
function pct(orig: any, cur: any) {
  const o = Number(orig), c = Number(cur)
  if (!o || o <= c) return 0
  return Math.round((1 - c / o) * 100)
}
function stockRatio(g: any): number {
  const stock = Number(g.stock || 0)
  const sales = Number(g.sales || 0)
  const total = stock + sales
  if (!total) return 50
  return Math.min(95, Math.round((stock / total) * 100))
}
function cover(g: any) { return fullImgUrl(g.cover) }

function goGoods(id: number) { router.push({ name: 'goodsDetail', params: { id } }) }
function goCategory(id?: number) {
  if (id) router.push({ name: 'categoryGoods', params: { id } })
  else router.push({ name: 'category' })
}
async function loadBanners() {
  try {
    const data: any = await publicApi.banners()
    banners.value = data || []
    // 等所有 SVG 图片加载完成后再显示轮播，避免闪一下空图
    if (banners.value.length > 0) {
      await Promise.all(
        banners.value.map(
          (b: any) => new Promise<void>((resolve) => {
            const img = new Image()
            img.onload = () => resolve()
            img.onerror = () => resolve()
            img.src = fullImgUrl(b.image)
          })
        )
      )
    }
  } catch { /* silent */ }
  bannersLoaded.value = true
}
async function loadCategories() {
  try {
    const data: any = await publicApi.categories()
    // 树结构:取一级
    const top = (data || []).filter((c: any) => Number(c.parentId) === 0)
    categories.value = top.filter((c: any) => c.id !== 501 && c.id !== 502).slice(0, 8) // 8 个一级
  } catch { /* silent */ }
}
async function loadHot() {
  try { hotGoods.value = (await publicApi.hotGoods()) || [] } catch { /* silent */ }
}
async function loadNew() {
  try { newGoods.value = (await publicApi.newGoods()) || [] } catch { /* silent */ }
}
async function loadAll() {
  try {
    const data: any = await publicApi.goodsList({ page: 1, size: 20, sort: 'sales_desc' })
    allGoods.value = data?.list || data || []
  } catch { /* silent */ }
}

function buildFlash() {
  // 取前 6 个 hot + 有折扣的作为秒杀
  flashGoods.value = hotGoods.value
    .filter((g: any) => g.originalPrice && Number(g.originalPrice) > Number(g.price))
    .slice(0, 6)
  if (flashGoods.value.length < 3) {
    flashGoods.value = hotGoods.value.slice(0, 6)
  }
}
function buildBrands() {
  const set = new Set<string>()
  for (const g of allGoods.value) {
    if (g.brand) set.add(String(g.brand))
  }
  brands.value = Array.from(set).slice(0, 12)
}

// 分类专区:每个一级分类挑 4 件
const categoryBlocks = computed(() => {
  return categories.value.map((top: any) => {
    const items = allGoods.value
      .filter((g: any) => Number(g.categoryId) === Number(top.id) ||
        (top.children || []).some((c: any) => Number(c.id) === Number(g.categoryId)))
      .slice(0, 4)
    return { ...top, items }
  }).filter((b: any) => b.items.length > 0).slice(0, 4)
})

function startCountdown() {
  let total = (2 * 60 + 15) * 60 + 43
  countdownTimer = setInterval(() => {
    if (total <= 0) total = (2 * 60 + 15) * 60 + 43
    total--
    const h = Math.floor(total / 3600)
    const m = Math.floor((total % 3600) / 60)
    const s = total % 60
    countdown.value = {
      h: String(h).padStart(2, '0'),
      m: String(m).padStart(2, '0'),
      s: String(s).padStart(2, '0'),
    }
  }, 1000)
}

onMounted(async () => {
  await Promise.all([loadBanners(), loadCategories(), loadHot(), loadNew(), loadAll()])
  buildFlash()
  buildBrands()
  startCountdown()
  loadWishlist()
  startFlashScroll()
})
onUnmounted(() => { clearInterval(countdownTimer) })
</script>

<template>
  <DesktopLayout>
  <div class="home">
    <!-- 1. Hero 轮播 + 右侧两个促销卡 -->
    <section class="hero">
      <div class="hero-slider">
        <div class="hero-main">
          <template v-if="bannersLoaded">
            <van-swipe
              ref="swipeRef"
              :autoplay="4500"
              :initial-swipe="activeBanner"
              class="hero-swipe"
              :loop="true"
              @change="activeBanner = $event"
            >
              <van-swipe-item v-for="b in banners" :key="b.id" class="hero-slide-item">
                <div class="hero-slide-bg" :style="{ backgroundImage: `url(${fullImgUrl(b.image)})` }">
                  <div class="hero-slide-overlay">
                    <span class="slide-tag">{{ b.title || '新品推荐' }}</span>
                    <h2 class="slide-title">{{ b.title || '精选好物' }}</h2>
                    <p class="slide-desc">探索全球时尚，定义独特风格</p>
                    <a class="slide-btn" @click="b.link && router.push(b.link)">
                      立即查看
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                        <path d="M5 12h14M12 5l7 7-7 7"/>
                      </svg>
                    </a>
                  </div>
                </div>
              </van-swipe-item>
              <template #indicator>
                <div class="hero-dots">
                  <span v-for="(_, i) in banners" :key="i" class="dot" :class="{ on: i === activeBanner }" />
                </div>
              </template>
            </van-swipe>
            <button class="hero-arrow hero-arrow-prev" @click="prevSlide" aria-label="上一张">‹</button>
            <button class="hero-arrow hero-arrow-next" @click="nextSlide" aria-label="下一张">›</button>
          </template>
          <div v-else class="hero-placeholder slide-1">
            <div class="slide-content">
              <span class="slide-tag">夏季新品</span>
              <h2 class="slide-title">轻盈夏日<br />焕新衣橱</h2>
              <p class="slide-desc">精选透气面料，打造舒适夏日穿搭体验</p>
              <a class="slide-btn" @click="goCategory()">
                立即选购
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                  <path d="M5 12h14M12 5l7 7-7 7"/>
                </svg>
              </a>
            </div>
            <div class="slide-image"></div>
          </div>
        </div>

        <div class="hero-side">
          <div class="side-card sc-dark" @click="goCategory(1)">
            <div class="sc-tag">MAN</div>
            <div class="sc-title">潮流男装</div>
            <div class="sc-sub">商务休闲两相宜</div>
            <span class="sc-emoji">👔</span>
          </div>
          <div class="side-card sc-red" @click="goCategory(2)">
            <div class="sc-tag">WOMAN</div>
            <div class="sc-title">精品女装</div>
            <div class="sc-sub">优雅浪漫不重样</div>
            <span class="sc-emoji">👗</span>
          </div>
        </div>
      </div>
    </section>

    <!-- 3. 限时秒杀 -->
    <section v-if="flashGoods.length" class="flash-sale">
      <div class="flash-header">
        <div class="flash-title-group">
          <span class="flash-icon">⚡</span>
          <h3 class="flash-title">限时秒杀</h3>
          <div class="countdown">
            <span class="countdown-label">距结束</span>
            <span class="countdown-box">{{ countdown.h }}</span>
            <span class="countdown-sep">:</span>
            <span class="countdown-box">{{ countdown.m }}</span>
            <span class="countdown-sep">:</span>
            <span class="countdown-box">{{ countdown.s }}</span>
          </div>
        </div>
        <a class="flash-more" @click="goCategory()">更多秒杀 →</a>
      </div>
      <div class="flash-carousel" @mouseenter="pauseFlashScroll" @mouseleave="resumeFlashScroll">
        <div class="flash-track" :style="{ transform: `translateX(-${flashOffset}px)` }">
          <div v-for="g in flashGoods" :key="g.id" class="flash-item" @click="goGoods(g.id)">
            <div class="new-card">
              <div class="new-img-wrapper">
                <img :src="cover(g)" class="flash-img" loading="lazy" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" />
                <div class="new-img-overlay"></div>
                <div class="new-tag-combo">
                  <span v-if="g.isHot" class="new-tag-hot">热卖</span>
                  <span v-if="pct(g.originalPrice, g.price) > 0" class="new-tag-discount">
                    -{{ pct(g.originalPrice, g.price) }}%
                  </span>
                </div>
                <button class="new-fav-btn" :class="{ liked: wishlistSet.has(Number(g.id)) }" @click.stop="toggleWishlist(g)">{{ wishlistSet.has(Number(g.id)) ? '♥' : '♡' }}</button>
              </div>
              <div class="new-info">
                <div v-if="g.brand" class="new-brand-row">
                  <span class="new-brand">{{ g.brand }}</span>
                </div>
                <div class="new-name">{{ g.name }}</div>
                <div class="new-price-block">
                  <span class="new-price">{{ priceFmt(g.price) }}</span>
                  <span v-if="g.originalPrice" class="new-original">¥{{ priceFmt(g.originalPrice) }}</span>
                </div>
                <div v-if="g.sales" class="new-sold">
                  <span class="new-sold-fire">🔥</span>
                  已售 <span class="new-sold-num">{{ g.sales > 999 ? (g.sales/1000).toFixed(1) + 'k' : g.sales }}</span>
                </div>
                <div class="new-stock-bar">
                  <div class="new-stock-fill" :style="{ width: stockRatio(g) + '%' }"></div>
                </div>
                <div v-if="g.stock && stockRatio(g) < 20" class="new-stock-text">库存紧张</div>
              </div>
            </div>
          </div>
          <!-- 克隆首批 5 个用于无缝循环 -->
          <div v-for="g in flashGoods.slice(0, 5)" :key="'c' + g.id" class="flash-item" @click="goGoods(g.id)">
            <div class="new-card">
              <div class="new-img-wrapper">
                <img :src="cover(g)" class="flash-img" loading="lazy" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" />
                <div class="new-img-overlay"></div>
                <div class="new-tag-combo">
                  <span v-if="g.isHot" class="new-tag-hot">热卖</span>
                  <span v-if="pct(g.originalPrice, g.price) > 0" class="new-tag-discount">
                    -{{ pct(g.originalPrice, g.price) }}%
                  </span>
                </div>
                <button class="new-fav-btn" :class="{ liked: wishlistSet.has(Number(g.id)) }" @click.stop="toggleWishlist(g)">{{ wishlistSet.has(Number(g.id)) ? '♥' : '♡' }}</button>
              </div>
              <div class="new-info">
                <div v-if="g.brand" class="new-brand-row">
                  <span class="new-brand">{{ g.brand }}</span>
                </div>
                <div class="new-name">{{ g.name }}</div>
                <div class="new-price-block">
                  <span class="new-price">{{ priceFmt(g.price) }}</span>
                  <span v-if="g.originalPrice" class="new-original">¥{{ priceFmt(g.originalPrice) }}</span>
                </div>
                <div v-if="g.sales" class="new-sold">
                  <span class="new-sold-fire">🔥</span>
                  已售 <span class="new-sold-num">{{ g.sales > 999 ? (g.sales/1000).toFixed(1) + 'k' : g.sales }}</span>
                </div>
                <div class="new-stock-bar">
                  <div class="new-stock-fill" :style="{ width: stockRatio(g) + '%' }"></div>
                </div>
                <div v-if="g.stock && stockRatio(g) < 20" class="new-stock-text">库存紧张</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- 4. 热门品牌（紧凑行） -->
    <section v-if="brands.length" class="brand-strip">
      <span class="bs-label">🏷️ 热门品牌</span>
      <div class="bs-items">
        <span v-for="b in brands" :key="b" class="bs-tag" @click="goCategory()">{{ b }}</span>
      </div>
    </section>

    <!-- 5. 热门推荐 -->
    <section v-if="hotGoods.length" class="section">
      <div class="section-head">
        <div class="section-title">
          <span class="emoji">🔥</span>
          <h2>热门推荐</h2>
        </div>
        <a class="section-more" @click="goCategory()">查看全部 →</a>
      </div>
      <div class="grid-5">
        <div v-for="g in hotGoods.slice(0, 10)" :key="g.id" class="card" @click="goGoods(g.id)">
          <div class="card-img-wrap">
            <img :src="cover(g)" class="card-img" loading="lazy" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" />
            <div class="card-badges">
              <span v-if="g.isHot" class="badge badge-hot">热卖</span>
              <span v-if="pct(g.originalPrice, g.price) > 0" class="badge badge-discount">
                -{{ pct(g.originalPrice, g.price) }}%
              </span>
            </div>
          </div>
          <div class="card-info">
            <div v-if="g.brand" class="card-brand">{{ g.brand }}</div>
            <div class="card-name">{{ g.name }}</div>
            <div class="card-price-row">
              <span class="card-price">¥{{ priceFmt(g.price) }}</span>
              <span v-if="g.originalPrice" class="card-orig">¥{{ priceFmt(g.originalPrice) }}</span>
            </div>
            <div class="card-meta">
              <span v-if="g.sales">已售 {{ g.sales }}</span>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- 6. 新品上市 -->
    <section v-if="newGoods.length" class="section">
      <div class="section-head">
        <div class="section-title">
          <span class="emoji">✨</span>
          <h2>新品上市</h2>
        </div>
        <a class="section-more" @click="goCategory()">查看全部 →</a>
      </div>
      <div class="grid-5">
        <div v-for="g in newGoods.slice(0, 10)" :key="g.id" class="card" @click="goGoods(g.id)">
          <div class="card-img-wrap">
            <img :src="cover(g)" class="card-img" loading="lazy" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" />
            <div class="card-badges">
              <span v-if="g.isNew" class="badge badge-new">新品</span>
            </div>
          </div>
          <div class="card-info">
            <div v-if="g.brand" class="card-brand">{{ g.brand }}</div>
            <div class="card-name">{{ g.name }}</div>
            <div class="card-price-row">
              <span class="card-price">¥{{ priceFmt(g.price) }}</span>
              <span v-if="g.originalPrice" class="card-orig">¥{{ priceFmt(g.originalPrice) }}</span>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- 7. 分类专区 -->
    <section v-for="b in categoryBlocks" :key="b.id" class="section">
      <div class="section-head">
        <div class="section-title">
          <span class="emoji">🛍️</span>
          <h2>{{ b.name }}专区</h2>
        </div>
        <a class="section-more" @click="goCategory(b.id)">查看全部 →</a>
      </div>
      <div class="grid-4">
        <div v-for="g in b.items" :key="g.id" class="card" @click="goGoods(g.id)">
          <div class="card-img-wrap">
            <img :src="cover(g)" class="card-img" loading="lazy" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" />
          </div>
          <div class="card-info">
            <div class="card-name">{{ g.name }}</div>
            <div class="card-price-row">
              <span class="card-price">¥{{ priceFmt(g.price) }}</span>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- 8. 促销横幅 -->
    <section class="promo-banners">
      <div class="promo-banner p-dark" @click="goCategory(1)">
        <div class="pb-content">
          <h3>男装专区</h3>
          <p>商务休闲 · 简约不简单</p>
          <span class="pb-tag">限时 8 折</span>
        </div>
        <span class="pb-emoji">👔</span>
      </div>
      <div class="promo-banner p-light" @click="goCategory(4)">
        <div class="pb-content">
          <h3>配饰专场</h3>
          <p>点睛之笔 · 精致生活</p>
          <span class="pb-tag pb-tag-dark">满 199 减 30</span>
        </div>
        <span class="pb-emoji">⌚</span>
      </div>
    </section>

    <!-- 9. 品牌矩阵 -->
    <section v-if="brands.length" class="brands">
      <div class="brands-inner">
        <h3 class="brands-title">热门品牌</h3>
        <div class="brands-grid">
          <div v-for="b in brands" :key="b" class="brand-item" @click="goCategory()">{{ b }}</div>
        </div>
      </div>
    </section>

    <!-- 10. 服务保障 -->
    <section class="service">
      <div class="service-grid">
        <div class="svc">
          <div class="svc-icon">🚚</div>
          <div class="svc-text">
            <h4>全场包邮</h4>
            <p>满 ¥299 免运费</p>
          </div>
        </div>
        <div class="svc">
          <div class="svc-icon">🔄</div>
          <div class="svc-text">
            <h4>7 天无理由</h4>
            <p>不满意随时退换</p>
          </div>
        </div>
        <div class="svc">
          <div class="svc-icon">🛡️</div>
          <div class="svc-text">
            <h4>正品保障</h4>
            <p>品牌授权 · 假一赔十</p>
          </div>
        </div>
        <div class="svc">
          <div class="svc-icon">💬</div>
          <div class="svc-text">
            <h4>专属客服</h4>
            <p>24 小时在线服务</p>
          </div>
        </div>
      </div>
    </section>
  </div>
  </DesktopLayout>
</template>

<style scoped>
.home { background: #faf9f7; padding-bottom: 0; }

/* ===== 2. Hero ===== */
.hero { max-width: 1400px; margin: 0 auto; padding: 24px 40px 0; }
.hero-slider { display: grid; grid-template-columns: 2fr 1fr; gap: 16px; height: 420px; }
.hero-main {
  position: relative; border-radius: 12px; overflow: hidden;
  background: linear-gradient(135deg, #fff5f0 0%, #ffe4d6 50%, #ffd4c4 100%);
}
.hero-swipe { height: 100%; }
.hero-img { width: 100%; height: 100%; object-fit: cover; display: block; cursor: pointer; }
.hero-dots { position: absolute; bottom: 16px; left: 50%; transform: translateX(-50%); display: flex; gap: 6px; z-index: 2; }
.dot { width: 8px; height: 8px; border-radius: 50%; background: rgba(255,255,255,0.5); transition: all 0.3s; }
.dot.on { width: 24px; border-radius: 4px; background: #fff; }

/* 轮播左右箭头 */
.hero-arrow {
  position: absolute; top: 50%; transform: translateY(-50%); z-index: 3;
  width: 40px; height: 40px; border: none; border-radius: 50%;
  background: rgba(0,0,0,0.25); color: #fff; font-size: 28px; line-height: 1;
  cursor: pointer; opacity: 0; transition: all 0.25s; display: flex;
  align-items: center; justify-content: center; padding-bottom: 4px;
}
.hero-main:hover .hero-arrow { opacity: 0.7; }
.hero-arrow:hover { opacity: 1 !important; background: rgba(0,0,0,0.5); }
.hero-arrow-prev { left: 12px; }
.hero-arrow-next { right: 12px; }

/* 轮播文字覆盖层 */
.hero-slide-item { position: relative; }
.hero-slide-bg {
  width: 100%; height: 100%;
  background-size: cover; background-position: center;
  position: relative;
}
.hero-slide-overlay {
  position: absolute; inset: 0;
  background: linear-gradient(135deg, rgba(255,255,255,0.88) 0%, rgba(255,245,240,0.5) 50%, transparent 70%);
  padding: 48px;
  display: flex; flex-direction: column; justify-content: center;
  max-width: 55%;
}

/* ===== Hero 占位（demo3 风格） ===== */
.slide-1 {
  background: linear-gradient(135deg, #fff5f0 0%, #ffe4d6 50%, #ffd4c4 100%);
  position: relative;
}
.slide-1::before {
  content: '';
  position: absolute;
  right: -100px;
  top: -100px;
  width: 500px;
  height: 500px;
  background: radial-gradient(circle, rgba(184,84,80,0.08) 0%, transparent 70%);
  border-radius: 50%;
  pointer-events: none;
}
.slide-1::after {
  content: '';
  position: absolute;
  left: -50px;
  bottom: -50px;
  width: 300px;
  height: 300px;
  background: radial-gradient(circle, rgba(184,84,80,0.06) 0%, transparent 70%);
  border-radius: 50%;
  pointer-events: none;
}
.hero-placeholder {
  position: absolute; inset: 0; padding: 48px 60px;
  display: flex; align-items: center;
}
.slide-content {
  position: relative; z-index: 2; max-width: 50%;
}
.slide-tag {
  display: inline-block; background: var(--accent, #c45c4a); color: #fff;
  padding: 6px 16px; border-radius: 20px; font-size: 12px; font-weight: 600;
  margin-bottom: 16px; letter-spacing: 1px;
}
.slide-title {
  font-size: 42px; font-weight: 700; color: #1a1a1a;
  line-height: 1.2; margin-bottom: 12px;
}
.slide-desc {
  font-size: 16px; color: #666; margin-bottom: 28px; line-height: 1.6;
}
.slide-btn {
  display: inline-flex; align-items: center; gap: 8px;
  padding: 14px 32px; background: #1a1a1a; color: #fff;
  text-decoration: none; border-radius: 30px; font-size: 15px; font-weight: 600;
  cursor: pointer; transition: all 0.3s;
}
.slide-btn:hover {
  background: var(--accent, #c45c4a); transform: translateX(4px);
}
.slide-image {
  position: absolute; right: 60px; top: 50%;
  transform: translateY(-50%);
  width: 320px; height: 320px;
  background: linear-gradient(145deg, #e8ddd6, #d4c4b8);
  border-radius: 20px;
  display: flex; align-items: center; justify-content: center;
  box-shadow: 0 20px 60px rgba(0,0,0,0.1);
}
.slide-image::after {
  content: '👗';
  font-size: 80px;
  opacity: 0.3;
}

.hero-side { display: grid; grid-template-rows: 1fr 1fr; gap: 16px; }
.side-card {
  position: relative; border-radius: 12px; padding: 24px; cursor: pointer; overflow: hidden;
  transition: transform 0.25s;
}
.side-card:hover { transform: translateY(-2px); }
.sc-dark { background: linear-gradient(135deg, #2d2a2a 0%, #1a1a1a 100%); color: #fff; }
.sc-red { background: linear-gradient(135deg, #c45c4a 0%, #8b3a2a 100%); color: #fff; }
.sc-tag {
  display: inline-block; padding: 4px 10px; background: rgba(255,255,255,0.2);
  font-size: 10px; font-weight: 700; letter-spacing: 1px; border-radius: 3px; margin-bottom: 12px;
}
.sc-title { font-size: 24px; font-weight: 600; margin-bottom: 6px; letter-spacing: 1px; }
.sc-sub { font-size: 12px; opacity: 0.7; letter-spacing: 0.5px; }
.sc-emoji { position: absolute; right: 20px; bottom: 16px; font-size: 64px; opacity: 0.5; }

/* ===== 3. Flash Sale（demo3 风格 + 自动轮转） ===== */
.flash-sale {
  background: #fff;
  border-radius: 16px;
  max-width: 1400px;
  margin: 32px auto 0;
  padding: 28px 32px;
}
.flash-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20px;
}
.flash-title-group {
  display: flex;
  align-items: center;
  gap: 16px;
}
.flash-icon { font-size: 24px; }
.flash-title { font-size: 22px; font-weight: 700; color: #1a1a1a; }
.countdown {
  display: flex;
  align-items: center;
  gap: 6px;
}
.countdown-label {
  font-size: 13px;
  color: #999;
  margin-right: 4px;
}
.countdown-box {
  background: #1a1a1a;
  color: #fff;
  padding: 6px 10px;
  border-radius: 6px;
  font-size: 18px;
  font-weight: 700;
  font-variant-numeric: tabular-nums;
  min-width: 36px;
  text-align: center;
}
.countdown-sep {
  font-size: 18px;
  font-weight: 700;
  color: #1a1a1a;
}
.flash-more {
  color: var(--accent, #c45c4a);
  text-decoration: none;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 4px;
  transition: gap 0.3s;
}
.flash-more:hover { gap: 8px; }

/* 商品网格 + 自动轮转 */
.flash-carousel {
  overflow: hidden;
}
.flash-track {
  display: flex;
  gap: 16px;
  transition: transform 0.6s ease;
}
.flash-item { flex-shrink: 0; width: calc((100% - 64px) / 5); min-width: 200px; cursor: pointer; }
.flash-img { width: 100%; height: 100%; object-fit: cover; }

/* ===== 新版卡片（demo3 优化版） ===== */
.new-card {
  background: #fff;
  border-radius: 16px;
  overflow: hidden;
  border: 1px solid #f0f0f0;
  cursor: pointer;
  transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
}
.new-card:hover {
  transform: translateY(-6px);
  box-shadow: 0 16px 40px rgba(0,0,0,0.12);
  border-color: transparent;
}
.new-img-wrapper {
  position: relative;
  width: 100%;
  aspect-ratio: 1;
  background: linear-gradient(145deg, #f0e8e0, #e5dbd2);
  overflow: hidden;
}
.new-img-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 60px;
  background: linear-gradient(to top, rgba(0,0,0,0.06), transparent);
  pointer-events: none;
}
.new-tag-combo {
  position: absolute;
  top: 12px;
  left: 12px;
  display: flex;
  align-items: center;
  background: var(--accent, #c45c4a);
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(196,92,74,0.3);
}
.new-tag-hot {
  background: #e6a23c;
  color: #fff;
  padding: 4px 8px;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.5px;
}
.new-tag-discount {
  color: #fff;
  padding: 4px 10px;
  font-size: 12px;
  font-weight: 700;
}
.new-fav-btn {
  position: absolute;
  top: 12px;
  right: 12px;
  width: 32px;
  height: 32px;
  background: rgba(255,255,255,0.9);
  backdrop-filter: blur(8px);
  border: none;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  opacity: 0;
  transform: scale(0.8);
  transition: all 0.3s ease;
  color: #999;
  font-size: 16px;
}
.new-card:hover .new-fav-btn {
  opacity: 1;
  transform: scale(1);
}
.new-fav-btn:hover {
  background: #fff;
  color: var(--accent, #c45c4a);
}
.new-fav-btn.liked {
  opacity: 1;
  transform: scale(1);
  color: var(--accent, #c45c4a);
  background: rgba(255,255,255,0.95);
}
.new-info { padding: 14px; }
.new-brand-row {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-bottom: 6px;
}
.new-brand {
  font-size: 12px;
  color: var(--accent, #c45c4a);
  font-weight: 600;
}
.new-name {
  font-size: 14px;
  color: #1a1a1a;
  font-weight: 500;
  line-height: 1.5;
  margin-bottom: 10px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  min-height: 42px;
}
.new-price-block {
  display: flex;
  align-items: baseline;
  gap: 8px;
  margin-bottom: 8px;
}
.new-price {
  font-size: 20px;
  font-weight: 700;
  color: var(--accent, #c45c4a);
  letter-spacing: -0.5px;
}
.new-price::before {
  content: '¥';
  font-size: 14px;
  margin-right: 1px;
}
.new-original {
  font-size: 12px;
  color: #bbb;
  text-decoration: line-through;
}
.new-sold {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  color: #999;
  font-weight: 500;
}
.new-sold-fire { font-size: 11px; }
.new-sold-num {
  color: #e6a23c;
  font-weight: 700;
}
.new-stock-bar {
  margin-top: 10px;
  height: 4px;
  background: #f0f0f0;
  border-radius: 2px;
  overflow: hidden;
}
.new-stock-fill {
  height: 100%;
  transition: width 0.3s ease;
  background: linear-gradient(90deg, var(--accent, #c45c4a), #e6a23c);
  border-radius: 2px;
}
.new-stock-text {
  font-size: 11px;
  color: var(--accent, #c45c4a);
  margin-top: 4px;
  font-weight: 500;
}

.price-current {
  font-size: 18px;
  font-weight: 700;
  color: var(--accent, #c45c4a);
}
.price-original {
  font-size: 12px;
  color: #999;
  text-decoration: line-through;
}

/* ===== 4. 热门品牌（紧凑行） ===== */
.brand-strip {
  max-width: 1400px; margin: 28px auto 0; padding: 0 40px;
  display: flex; align-items: center; gap: 16px;
  overflow-x: auto; scrollbar-width: none;
}
.brand-strip::-webkit-scrollbar { display: none; }
.bs-label {
  flex-shrink: 0; font-size: 13px; font-weight: 600; color: #1a1a1a; white-space: nowrap;
}
.bs-items {
  display: flex; gap: 10px;
}
.bs-tag {
  flex-shrink: 0; padding: 6px 16px; background: #fff; border: 1px solid #e8e5e0;
  border-radius: 16px; font-size: 12px; font-weight: 600; color: #666;
  cursor: pointer; transition: all 0.2s; white-space: nowrap;
}
.bs-tag:hover { border-color: var(--accent, #c45c4a); color: var(--accent, #c45c4a); background: #fdf5f3; }

/* ===== Section 通用 ===== */
.section { max-width: 1400px; margin: 40px auto 0; padding: 0 40px; }
.section-head { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; }
.section-title { display: flex; align-items: center; gap: 12px; }
.section-title h2 { font-size: 22px; font-weight: 600; }
.section-title .emoji { font-size: 24px; }
.section-more { font-size: 13px; color: #999; cursor: pointer; transition: color 0.2s; }
.section-more:hover { color: #c45c4a; }

/* ===== 5 列网格 ===== */
.grid-5 { display: grid; grid-template-columns: repeat(5, 1fr); gap: 20px; }
.grid-4 { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; }

.card {
  background: #fff; border: 1px solid #e8e5e0; border-radius: 10px; overflow: hidden;
  cursor: pointer; transition: all 0.25s;
}
.card:hover { border-color: #c45c4a; box-shadow: 0 8px 24px rgba(0,0,0,0.08); transform: translateY(-2px); }
.card-img-wrap { position: relative; aspect-ratio: 1; background: #f5f3f0; overflow: hidden; }
.card-img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.4s; }
.card:hover .card-img { transform: scale(1.05); }
.card-badges { position: absolute; top: 8px; left: 8px; display: flex; flex-direction: column; gap: 4px; }
.badge { padding: 3px 8px; font-size: 10px; font-weight: 700; border-radius: 3px; color: #fff; }
.badge-discount { background: #c45c4a; }
.badge-hot { background: #d4920a; }
.badge-new { background: #2d8a5e; }
.card-info { padding: 12px 14px 14px; }
.card-brand { font-size: 11px; font-weight: 600; color: #c45c4a; letter-spacing: 0.5px; margin-bottom: 4px; }
.card-name {
  font-size: 13px; color: #1a1a1a; line-height: 1.4; margin-bottom: 8px; min-height: 36px;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
}
.card-price-row { display: flex; align-items: baseline; gap: 8px; margin-bottom: 4px; }
.card-price { font-size: 18px; font-weight: 700; color: #c45c4a; }
.card-orig { font-size: 12px; color: #999; text-decoration: line-through; }
.card-meta { font-size: 11px; color: #999; }

/* ===== 7. 促销横幅 ===== */
.promo-banners {
  max-width: 1400px; margin: 40px auto 0; padding: 0 40px;
  display: grid; grid-template-columns: 1fr 1fr; gap: 20px;
}
.promo-banner {
  position: relative; height: 200px; border-radius: 12px; overflow: hidden; cursor: pointer;
  display: flex; align-items: center; padding: 32px; transition: transform 0.25s;
}
.promo-banner:hover { transform: translateY(-2px); }
.p-dark { background: linear-gradient(135deg, #2d2a2a 0%, #1a1a1a 100%); color: #fff; }
.p-light { background: linear-gradient(135deg, #f5e6d8 0%, #e8d4c4 100%); color: #1a1a1a; }
.pb-content h3 { font-size: 24px; font-weight: 600; margin-bottom: 8px; }
.pb-content p { font-size: 14px; opacity: 0.8; margin-bottom: 16px; }
.pb-tag { display: inline-block; padding: 6px 14px; background: #c45c4a; color: #fff; font-size: 12px; font-weight: 600; border-radius: 6px; }
.pb-tag-dark { background: #1a1a1a; }
.pb-emoji { position: absolute; right: 32px; bottom: 20px; font-size: 100px; opacity: 0.3; }

/* ===== 9. 品牌墙 ===== */
.brands { background: #f5f3f0; padding: 40px 0; margin: 40px 0 0; }
.brands-inner { max-width: 1400px; margin: 0 auto; padding: 0 40px; }
.brands-title { text-align: center; font-size: 12px; font-weight: 600; color: #999; letter-spacing: 2px; margin-bottom: 24px; }
.brands-grid { display: flex; justify-content: center; flex-wrap: wrap; gap: 16px; }
.brand-item {
  padding: 10px 24px; background: #fff; border: 1px solid #e8e5e0; border-radius: 8px;
  font-size: 12px; font-weight: 700; color: #666; letter-spacing: 1px; cursor: pointer; transition: all 0.2s;
}
.brand-item:hover { border-color: #c45c4a; color: #c45c4a; }

/* ===== 10. 服务保障 ===== */
.service { max-width: 1400px; margin: 40px auto 0; padding: 0 40px; }
.service-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; }
.svc {
  display: flex; align-items: center; gap: 14px; padding: 20px; background: #fff;
  border: 1px solid #e8e5e0; border-radius: 12px; transition: all 0.2s;
}
.svc:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.06); }
.svc-icon { font-size: 28px; }
.svc-text h4 { font-size: 14px; font-weight: 600; margin-bottom: 2px; }
.svc-text p { font-size: 12px; color: #666; }

/* ===== 响应式 ===== */
@media (max-width: 1200px) {
  .hero-slider { grid-template-columns: 1fr; height: auto; }
  .hero-main { height: 320px; }
  .hero-side { flex-direction: row; }
  .side-card { flex: 1; }
  .grid-5 { grid-template-columns: repeat(4, 1fr); }
  .flash-item { width: calc((100% - 48px) / 4); min-width: 160px; }
}
@media (max-width: 768px) {
  .hero, .section, .flash-sale, .brand-strip, .promo-banners, .service { padding-left: 16px; padding-right: 16px; }
  .flash-item { width: calc((100% - 32px) / 3); min-width: 130px; }
  .grid-5, .grid-4 { grid-template-columns: repeat(2, 1fr); gap: 12px; }
  .service-grid { grid-template-columns: repeat(2, 1fr); }
  .promo-banners { grid-template-columns: 1fr; }
}
</style>
