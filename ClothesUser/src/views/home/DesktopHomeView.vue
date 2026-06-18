<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { publicApi } from '@/api/public'
import { fullImgUrl, IMG_PLACEHOLDER } from '@/utils/img'
import { showFailToast } from 'vant'
import DesktopLayout from '@/components/desktop/DesktopLayout.vue'

const router = useRouter()

const banners = ref<any[]>([])
const bannersLoaded = ref(false)
const activeBanner = ref(0)
const categories = ref<any[]>([])         // 一级 + children
const hotGoods = ref<any[]>([])
const newGoods = ref<any[]>([])
const allGoods = ref<any[]>([])          // 通用商品
const flashGoods = ref<any[]>([])         // 限时秒杀（从 hot 算折扣）
const brands = ref<string[]>([])          // 品牌矩阵
const countdown = ref({ h: '02', m: '15', s: '43' })
let countdownTimer: any = null

function priceFmt(p: any) { return Number(p || 0).toFixed(2) }
function pct(orig: any, cur: any) {
  const o = Number(orig), c = Number(cur)
  if (!o || o <= c) return 0
  return Math.round((1 - c / o) * 100)
}
function cover(g: any) { return fullImgUrl(g.cover) }

function goGoods(id: number) { router.push({ name: 'goodsDetail', params: { id } }) }
function goCategory(id?: number) {
  if (id) router.push({ name: 'categoryGoods', params: { id } })
  else router.push({ name: 'category' })
}
function goSub(parentId: number, subId?: number) {
  if (subId) router.push({ name: 'categoryGoods', params: { id: subId } })
  else router.push({ name: 'categoryGoods', params: { id: parentId } })
}
function onSearch() {
  router.push({ name: 'search' })
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
    categories.value = top.slice(0, 8) // 8 个一级
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
          <Transition name="banner-fade" appear>
            <van-swipe
              v-if="bannersLoaded"
              :autoplay="4500"
              :initial-swipe="activeBanner"
              class="hero-swipe"
              @change="activeBanner = $event"
            >
              <van-swipe-item v-for="b in banners" :key="b.id">
                <img :src="fullImgUrl(b.image)" class="hero-img" @click="b.link && router.push(b.link)" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" />
              </van-swipe-item>
              <template #indicator>
                <div class="hero-dots">
                  <span v-for="(_, i) in banners" :key="i" class="dot" :class="{ on: i === activeBanner }" />
                </div>
              </template>
            </van-swipe>
            <div v-else class="hero-placeholder">
            <div class="hp-tag">夏季新品</div>
            <h2>轻盈夏日<br />优雅出行</h2>
            <p>精选棉麻材质 · 邂逅法式浪漫</p>
            <a class="hp-btn" @click="goCategory()">立即选购 →</a>
            <span class="hp-emoji">👗</span>
          </div>
          </Transition>
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
    <section v-if="flashGoods.length" class="flash">
      <div class="flash-card">
        <div class="flash-head">
          <div class="flash-title">
            <span class="flash-icon">⚡</span>
            <h3>限时秒杀</h3>
            <div class="countdown">
              距结束 <span>{{ countdown.h }}</span>:<span>{{ countdown.m }}</span>:<span>{{ countdown.s }}</span>
            </div>
          </div>
          <button class="flash-more" @click="goCategory()">更多秒杀 →</button>
        </div>
        <div class="flash-row">
          <div v-for="g in flashGoods" :key="g.id" class="flash-item" @click="goGoods(g.id)">
            <div class="flash-img-wrap">
              <img :src="cover(g)" class="flash-img" loading="lazy" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" />
              <span v-if="pct(g.originalPrice, g.price) > 0" class="discount">
                -{{ pct(g.originalPrice, g.price) }}%
              </span>
            </div>
            <div class="flash-price">¥{{ priceFmt(g.price) }}</div>
            <div v-if="g.originalPrice" class="flash-orig">¥{{ priceFmt(g.originalPrice) }}</div>
            <div class="flash-name">{{ g.name }}</div>
          </div>
        </div>
      </div>
    </section>

    <!-- 4. 分类快捷入口 -->
    <section v-if="categories.length" class="cat-nav">
      <div class="cat-grid">
        <div v-for="c in categories" :key="c.id" class="cat-item" @click="goCategory(c.id)">
          <div class="cat-icon-wrap">
            <img v-if="c.icon" :src="fullImgUrl(c.icon)" class="cat-icon" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" />
            <span v-else class="cat-emoji">🛍️</span>
          </div>
          <div class="cat-name">{{ c.name }}</div>
        </div>
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

    <!-- 6. 分类专区 -->
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

    <!-- 7. 促销横幅 -->
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

    <!-- 8. 新品上市 -->
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
  background: linear-gradient(135deg, #f5e6d8 0%, #e8d4c4 100%);
}
.hero-swipe { height: 100%; }
.hero-img { width: 100%; height: 100%; object-fit: cover; display: block; cursor: pointer; }
.hero-dots { position: absolute; bottom: 16px; left: 50%; transform: translateX(-50%); display: flex; gap: 6px; z-index: 2; }
.dot { width: 8px; height: 8px; border-radius: 50%; background: rgba(255,255,255,0.5); transition: all 0.3s; }
.dot.on { width: 24px; border-radius: 4px; background: #fff; }

.hero-placeholder {
  position: absolute; inset: 0; padding: 48px;
  display: flex; flex-direction: column; justify-content: center; max-width: 480px;
}

/* 轮播图加载过渡动画 */
.banner-fade-enter-active,
.banner-fade-leave-active {
  transition: opacity 0.35s ease;
}
.banner-fade-enter-from,
.banner-fade-leave-to {
  opacity: 0;
}
.hp-tag {
  display: inline-block; padding: 6px 14px; background: #c45c4a; color: #fff;
  font-size: 11px; font-weight: 700; letter-spacing: 1px; border-radius: 4px; margin-bottom: 16px;
  align-self: flex-start;
}
.hero-placeholder h2 { font-size: 36px; font-weight: 600; line-height: 1.2; color: #1a1a1a; margin-bottom: 12px; }
.hero-placeholder p { font-size: 14px; color: #666; margin-bottom: 24px; }
.hp-btn {
  display: inline-block; padding: 12px 28px; background: #1a1a1a; color: #fff;
  font-size: 13px; font-weight: 600; border-radius: 8px; cursor: pointer; align-self: flex-start;
  transition: background 0.25s;
}
.hp-btn:hover { background: #c45c4a; }
.hp-emoji { position: absolute; right: 48px; bottom: 40px; font-size: 140px; opacity: 0.6; }

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

/* ===== 3. Flash Sale ===== */
.flash { max-width: 1400px; margin: 32px auto 0; padding: 0 40px; }
.flash-card { background: #fff; border: 1px solid #e8e5e0; border-radius: 12px; padding: 24px; }
.flash-head { display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; }
.flash-title { display: flex; align-items: center; gap: 12px; }
.flash-title h3 { font-size: 18px; font-weight: 600; }
.flash-icon { font-size: 24px; }
.countdown { display: flex; align-items: center; gap: 4px; font-size: 13px; color: #666; }
.countdown span {
  padding: 4px 8px; background: #1a1a1a; color: #fff; font-weight: 600; border-radius: 4px;
  font-variant-numeric: tabular-nums; min-width: 26px; text-align: center;
}
.flash-more {
  padding: 8px 16px; background: #fdf5f3; color: #c45c4a; font-size: 12px; font-weight: 600;
  border: none; border-radius: 8px; cursor: pointer; transition: all 0.2s;
}
.flash-more:hover { background: #c45c4a; color: #fff; }
.flash-row { display: flex; gap: 16px; overflow-x: auto; padding-bottom: 8px; scrollbar-width: none; }
.flash-row::-webkit-scrollbar { display: none; }
.flash-item { flex-shrink: 0; width: 160px; cursor: pointer; }
.flash-img-wrap {
  position: relative; width: 160px; height: 160px; border-radius: 8px; background: #f5f3f0;
  overflow: hidden; margin-bottom: 12px;
}
.flash-img { width: 100%; height: 100%; object-fit: cover; }
.discount {
  position: absolute; top: 8px; left: 8px; padding: 4px 8px; background: #c45c4a; color: #fff;
  font-size: 10px; font-weight: 700; border-radius: 3px;
}
.flash-price { font-size: 16px; font-weight: 700; color: #c45c4a; }
.flash-orig { font-size: 12px; color: #999; text-decoration: line-through; }
.flash-name {
  font-size: 13px; color: #1a1a1a; margin-top: 4px; line-height: 1.4;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
}

/* ===== 4. Cat Nav ===== */
.cat-nav { max-width: 1400px; margin: 40px auto 0; padding: 0 40px; }
.cat-grid { display: flex; justify-content: space-between; gap: 8px; }
.cat-item { flex: 1; text-align: center; cursor: pointer; }
.cat-icon-wrap {
  width: 80px; height: 80px; margin: 0 auto 10px; background: #fff; border: 1px solid #e8e5e0;
  border-radius: 50%; display: flex; align-items: center; justify-content: center; overflow: hidden;
  transition: all 0.25s;
}
.cat-item:hover .cat-icon-wrap { border-color: #c45c4a; box-shadow: 0 4px 12px rgba(0,0,0,0.08); }
.cat-icon { width: 100%; height: 100%; object-fit: cover; }
.cat-emoji { font-size: 36px; }
.cat-name { font-size: 12px; color: #666; transition: color 0.2s; }
.cat-item:hover .cat-name { color: #c45c4a; }

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
}
@media (max-width: 768px) {
  .hero, .section, .flash, .cat-nav, .promo-banners, .service { padding-left: 16px; padding-right: 16px; }
  .grid-5, .grid-4 { grid-template-columns: repeat(2, 1fr); gap: 12px; }
  .service-grid { grid-template-columns: repeat(2, 1fr); }
  .promo-banners { grid-template-columns: 1fr; }
  .cat-grid { flex-wrap: wrap; }
  .cat-item { flex: 0 0 25%; margin-bottom: 16px; }
}
</style>
