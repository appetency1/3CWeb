<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
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
let bannerTimer: any = null

const categories = ref<any[]>([])
const hotGoods = ref<any[]>([])
const newGoods = ref<any[]>([])
const allGoods = ref<any[]>([])

// 收藏
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
  const id = Number(g.id); const s = new Set(wishlistSet.value); const liked = s.has(id)
  try {
    if (liked) { await favoriteApi.remove(id); s.delete(id) }
    else { await favoriteApi.add(id); s.add(id) }
    wishlistSet.value = s
  } catch { showToast(liked ? '取消收藏失败' : '收藏失败') }
}

// 秒杀
const flashGoods = ref<any[]>([])
const countdown = ref({ h: '02', m: '15', s: '43' })
let countdownTimer: any = null

// 倒计时
function startCountdown() {
  let total = (2 * 60 + 15) * 60 + 43
  countdownTimer = setInterval(() => {
    if (total <= 0) total = (2 * 60 + 15) * 60 + 43
    total--
    const h = Math.floor(total / 3600), m = Math.floor((total % 3600) / 60), s = total % 60
    countdown.value = { h: String(h).padStart(2,'0'), m: String(m).padStart(2,'0'), s: String(s).padStart(2,'0') }
  }, 1000)
}

// 工具函数
function priceFmt(p: any) { return Number(p || 0).toFixed(2) }
function displayPrice(g: any) {
  if (g.min_price && g.max_price && Number(g.min_price) !== Number(g.max_price)) {
    return '¥' + priceFmt(g.min_price) + ' - ¥' + priceFmt(g.max_price)
  }
  return '¥' + priceFmt(g.price || g.min_price)
}
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

// 轮播自动切换
function nextBanner() {
  if (banners.value.length) activeBanner.value = (activeBanner.value + 1) % banners.value.length
}
function startBannerAuto() {
  bannerTimer = setInterval(nextBanner, 4500)
}
function stopBannerAuto() { if (bannerTimer) clearInterval(bannerTimer) }

// 数据加载
async function loadBanners() {
  try { banners.value = (await publicApi.banners()) || [] } catch { /* silent */ }
  if (banners.value.length) bannersLoaded.value = true
}
async function loadCategories() {
  try {
    const data: any = await publicApi.categories()
    categories.value = (data || []).filter((c: any) => Number(c.parentId) === 0).slice(0, 6)
  } catch { /* silent */ }
}
async function loadHot() { try { hotGoods.value = (await publicApi.hotGoods()) || [] } catch { /* silent */ } }
async function loadNew() { try { newGoods.value = (await publicApi.newGoods()) || [] } catch { /* silent */ } }
async function loadAll() {
  try {
    const data: any = await publicApi.goodsList({ page: 1, size: 50, sort: 'sales_desc' })
    allGoods.value = data?.list || data || []
  } catch { /* silent */ }
}

function buildFlash() {
  flashGoods.value = hotGoods.value.filter((g: any) => g.originalPrice && Number(g.originalPrice) > Number(g.min_price || g.price)).slice(0, 5)
  if (flashGoods.value.length < 3) flashGoods.value = hotGoods.value.slice(0, 5)
}

onMounted(async () => {
  await Promise.all([loadBanners(), loadCategories(), loadHot(), loadNew(), loadAll()])
  buildFlash()
  startCountdown()
  loadWishlist()
  startBannerAuto()
})
onUnmounted(() => { clearInterval(countdownTimer); stopBannerAuto() })
</script>

<template>
  <DesktopLayout>
  <div class="home">

    <!-- HERO -->
    <section class="hero">
      <div class="hero-slide">
        <div class="hero-info">
          <div class="hero-tag">NEW ARRIVAL</div>
          <h1 class="hero-title">未来科技<br><span>触手可及</span></h1>
          <p class="hero-desc">探索前沿数码，定义数字生活。精选全球优质品牌，为你带来高效智能的科技体验。</p>
          <div class="hero-btns">
            <button class="btn-primary" @click="goCategory()">立即选购</button>
            <button class="btn-secondary" @click="goCategory(1)">新品推荐</button>
          </div>
        </div>
        <div class="hero-img-wrap">
          <div v-if="banners.length" class="banner-slide">
            <img v-for="(b, i) in banners.slice(0, 3)" :key="b.id"
              :src="cover(b)" :alt="b.title"
              :class="['banner-img', { active: i === activeBanner }]"
              @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" />
            <div class="banner-dots">
              <span v-for="(_, i) in banners.slice(0, 3)" :key="i"
                :class="['dot', { active: i === activeBanner }]"
                @click="activeBanner = i" />
            </div>
          </div>
          <div v-else class="hero-placeholder-img">📱</div>
        </div>
      </div>
      <div class="hero-dots-bar">
                <span v-for="i in banners.slice(0, 3).length" :key="i"
          :class="['hdot', { active: i-1 === activeBanner }]"
          @click="activeBanner = i-1" />
      </div>
    </section>

    <!-- 快捷分类 -->
    <section class="cats" v-if="categories.length">
      <div class="cats-grid">
        <div v-for="c in categories" :key="c.id" class="cat-card reveal" @click="goCategory(c.id)">
          <div class="cat-icon">{{ ['💻','📱','🎧','⌚','📷','🎮'][categories.indexOf(c) % 6] }}</div>
          <div class="cat-name">{{ c.name }}</div>
        </div>
      </div>
    </section>

    <!-- 品牌滚动条 -->
    <section class="brand-strip">
      <div class="brand-track">
        <span class="brand-item">APPLE</span><span class="brand-item">SAMSUNG</span><span class="brand-item">SONY</span>
        <span class="brand-item">XIAOMI</span><span class="brand-item">HUAWEI</span><span class="brand-item">BOSE</span>
        <span class="brand-item">META</span><span class="brand-item">GARMIN</span><span class="brand-item">DJI</span>
        <span class="brand-item">LG</span><span class="brand-item">ASUS</span><span class="brand-item">DELL</span>
        <!-- 重复一份实现无缝滚动 -->
        <span class="brand-item">APPLE</span><span class="brand-item">SAMSUNG</span><span class="brand-item">SONY</span>
        <span class="brand-item">XIAOMI</span><span class="brand-item">HUAWEI</span><span class="brand-item">BOSE</span>
        <span class="brand-item">META</span><span class="brand-item">GARMIN</span><span class="brand-item">DJI</span>
        <span class="brand-item">LG</span><span class="brand-item">ASUS</span><span class="brand-item">DELL</span>
      </div>
    </section>

    <!-- 限时秒杀 -->
    <section v-if="flashGoods.length" class="flash reveal">
      <div class="flash-header">
        <div class="flash-title-wrap">
          <div class="flash-title">⚡ FLASH SALE</div>
          <div class="flash-countdown">
            <span class="cd-box">{{ countdown.h }}</span><span class="cd-sep">:</span>
            <span class="cd-box">{{ countdown.m }}</span><span class="cd-sep">:</span>
            <span class="cd-box">{{ countdown.s }}</span>
          </div>
        </div>
        <div class="flash-more" @click="goCategory()">查看全部 →</div>
      </div>
      <div class="flash-grid">
        <div v-for="g in flashGoods" :key="g.id" class="gcard" @click="goGoods(g.id)">
          <div class="gcard-img">
            <img :src="cover(g)" alt="" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" />
            <div class="gcard-badges">
              <span class="gbadge gbadge-discount">-{{ pct(g.originalPrice, g.min_price || g.price) }}%</span>
            </div>
          </div>
          <div class="gcard-body">
            <div class="gcard-brand">{{ g.brand || '' }}</div>
            <div class="gcard-name">{{ g.name }}</div>
            <div class="gcard-price-row">
              <span class="gcard-price">{{ displayPrice(g) }}</span>
              <span class="gcard-orig">¥{{ priceFmt(g.originalPrice) }}</span>
            </div>
            <button class="gcard-btn" @click.stop="toggleWishlist(g)">{{ wishlistSet.has(Number(g.id)) ? '♥ 已收藏' : '♡ 收藏' }}</button>
          </div>
        </div>
      </div>
    </section>

    <!-- BENTO GRID 精选产品 -->
    <section class="bento-section reveal">
      <div class="sec-header">
        <div class="sec-title"><div class="bar"></div>BENTO <span>SELECTION</span></div>
        <div class="sec-more" @click="goCategory()">查看全部 &#8594;</div>
      </div>
      <div class="bento-grid">
        <div class="bento-item large" @click="goGoods(allGoods[0]?.id)">
          <div class="bento-img"><img v-if="allGoods[0]" :src="cover(allGoods[0])" alt="" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" /></div>
          <div class="bento-overlay"></div>
          <div class="bento-content">
            <div class="bento-badge">FLAGSHIP</div>
            <div class="bento-brand">{{ allGoods[0]?.brand || '' }}</div>
            <div class="bento-name">{{ allGoods[0]?.name || '' }}</div>
            <div class="bento-price">{{ allGoods[0] ? displayPrice(allGoods[0]) : '' }}</div>
          </div>
        </div>
        <div class="bento-item tall" @click="goGoods(allGoods[1]?.id)">
          <div class="bento-img"><img v-if="allGoods[1]" :src="cover(allGoods[1])" alt="" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" /></div>
          <div class="bento-overlay"></div>
          <div class="bento-content">
            <div class="bento-badge">BEST</div>
            <div class="bento-brand">{{ allGoods[1]?.brand || '' }}</div>
            <div class="bento-name">{{ allGoods[1]?.name || '' }}</div>
            <div class="bento-price">{{ allGoods[1] ? displayPrice(allGoods[1]) : '' }}</div>
          </div>
        </div>
        <div class="bento-item" @click="goGoods(allGoods[2]?.id)">
          <div class="bento-img"><img v-if="allGoods[2]" :src="cover(allGoods[2])" alt="" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" /></div>
          <div class="bento-overlay"></div>
          <div class="bento-content">
            <div class="bento-badge">NEW</div>
            <div class="bento-brand">{{ allGoods[2]?.brand || '' }}</div>
            <div class="bento-name">{{ allGoods[2]?.name || '' }}</div>
            <div class="bento-price">{{ allGoods[2] ? displayPrice(allGoods[2]) : '' }}</div>
          </div>
        </div>
        <div class="bento-item" @click="goGoods(allGoods[3]?.id)">
          <div class="bento-img"><img v-if="allGoods[3]" :src="cover(allGoods[3])" alt="" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" /></div>
          <div class="bento-overlay"></div>
          <div class="bento-content">
            <div class="bento-badge">HOT</div>
            <div class="bento-brand">{{ allGoods[3]?.brand || '' }}</div>
            <div class="bento-name">{{ allGoods[3]?.name || '' }}</div>
            <div class="bento-price">{{ allGoods[3] ? displayPrice(allGoods[3]) : '' }}</div>
          </div>
        </div>
        <div class="bento-item wide" @click="goGoods(allGoods[4]?.id)">
          <div class="bento-img"><img v-if="allGoods[4]" :src="cover(allGoods[4])" alt="" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" /></div>
          <div class="bento-overlay"></div>
          <div class="bento-content">
            <div class="bento-badge">PRO</div>
            <div class="bento-brand">{{ allGoods[4]?.brand || '' }}</div>
            <div class="bento-name">{{ allGoods[4]?.name || '' }}</div>
            <div class="bento-price">{{ allGoods[4] ? displayPrice(allGoods[4]) : '' }}</div>
          </div>
        </div>
        <div class="bento-item" @click="goGoods(allGoods[5]?.id)">
          <div class="bento-img"><img v-if="allGoods[5]" :src="cover(allGoods[5])" alt="" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" /></div>
          <div class="bento-overlay"></div>
          <div class="bento-content">
            <div class="bento-badge">TABLET</div>
            <div class="bento-brand">{{ allGoods[5]?.brand || '' }}</div>
            <div class="bento-name">{{ allGoods[5]?.name || '' }}</div>
            <div class="bento-price">{{ allGoods[5] ? displayPrice(allGoods[5]) : '' }}</div>
          </div>
        </div>
        <div class="bento-item" @click="goGoods(allGoods[6]?.id)">
          <div class="bento-img"><img v-if="allGoods[6]" :src="cover(allGoods[6])" alt="" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" /></div>
          <div class="bento-overlay"></div>
          <div class="bento-content">
            <div class="bento-badge">VR</div>
            <div class="bento-brand">{{ allGoods[6]?.brand || '' }}</div>
            <div class="bento-name">{{ allGoods[6]?.name || '' }}</div>
            <div class="bento-price">{{ allGoods[6] ? displayPrice(allGoods[6]) : '' }}</div>
          </div>
        </div>
      </div>
    </section>

    <!-- 横向滚动推荐 -->
    <section class="scroll-section" v-if="newGoods.length">
      <div class="scroll-header">
        <div class="scroll-title">NEW ARRIVALS</div>
        <div class="sec-more" @click="goCategory()">查看全部 &#8594;</div>
      </div>
      <div class="scroll-track-wrap">
        <div class="scroll-track">
          <div v-for="g in newGoods" :key="g.id" class="sitem" @click="goGoods(g.id)">
            <div class="sitem-img"><img :src="cover(g)" alt="" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" /></div>
            <div class="sitem-body">
              <div class="sitem-name">{{ g.name }}</div>
              <div class="sitem-price">{{ displayPrice(g) }}</div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- 促销横幅 -->
    <section class="promo">
      <div class="promo-card p1" @click="goCategory(1)">
        <div>
          <h3>数码配件狂欢</h3>
          <p>充电保护 · 一应俱全</p>
          <span class="promo-tag">限时 8 折</span>
        </div>
      </div>
      <div class="promo-card p2" @click="goCategory(4)">
        <div>
          <h3>智能穿戴新品</h3>
          <p>科技随行 · 健康生活</p>
          <span class="promo-tag">满 199 减 30</span>
        </div>
      </div>
    </section>

    <!-- 服务保障 -->
    <section class="service">
      <div class="svc-grid">
        <div class="svc"><div class="svc-icon">🚚</div><div><h4>全场包邮</h4><p>满 ¥299 免运费</p></div></div>
        <div class="svc"><div class="svc-icon">🔄</div><div><h4>7 天无理由</h4><p>不满意随时退换</p></div></div>
        <div class="svc"><div class="svc-icon">🛡️</div><div><h4>正品保障</h4><p>品牌授权 · 假一赔十</p></div></div>
        <div class="svc"><div class="svc-icon">💬</div><div><h4>专属客服</h4><p>24 小时在线服务</p></div></div>
      </div>
    </section>

  </div>
  </DesktopLayout>
</template>

<style scoped>
/* ── HERO ── */
.hero { max-width: 1440px; margin: 24px auto 0; padding: 0 40px; }
.hero-slide {
  position: relative; height: 460px; border-radius: 20px; overflow: hidden;
  display: grid; grid-template-columns: 1fr 1.3fr;
  border: 1px solid var(--border);
}
.hero-info {
  padding: 60px 50px;
  background: linear-gradient(135deg, rgba(0,240,255,0.06), rgba(170,102,255,0.04));
  display: flex; flex-direction: column; justify-content: center; position: relative; z-index: 2;
}
.hero-tag {
  display: inline-flex; align-items: center; gap: 8px; width: fit-content;
  padding: 6px 14px; border-radius: 6px;
  background: rgba(0,240,255,0.1); border: 1px solid rgba(0,240,255,0.25);
  color: var(--accent); font-size: 12px; font-weight: 600;
  letter-spacing: 1px; margin-bottom: 20px;
}
.hero-title { font-size: 44px; font-weight: 700; line-height: 1.15; margin-bottom: 16px; }
.hero-title span {
  background: linear-gradient(135deg, var(--accent), var(--accent-tertiary), var(--accent-secondary));
  -webkit-background-clip: text; -webkit-text-fill-color: transparent;
  background-clip: text;
}
.hero-desc { font-size: 15px; color: var(--text-secondary); line-height: 1.7; margin-bottom: 32px; max-width: 380px; }
.hero-btns { display: flex; gap: 14px; }
.btn-primary {
  padding: 14px 32px; border-radius: 10px;
  background: linear-gradient(135deg, var(--accent), var(--accent-tertiary));
  color: #000; font-size: 14px; font-weight: 700; border: none;
  cursor: pointer; transition: all .3s;
  box-shadow: 0 0 24px var(--accent-glow);
}
.btn-primary:hover { transform: translateY(-2px); box-shadow: 0 8px 32px var(--accent-glow); }
.btn-secondary {
  padding: 14px 32px; border-radius: 10px;
  border: 1px solid var(--border); background: transparent;
  color: var(--text-primary); font-size: 14px; font-weight: 600;
  cursor: pointer; transition: all .3s;
}
.btn-secondary:hover { border-color: var(--accent); color: var(--accent); }
.hero-img-wrap {
  position: relative; background: linear-gradient(145deg, #0a0a14, #121220);
  display: flex; align-items: center; justify-content: center; overflow: hidden;
}
.banner-slide { width: 100%; height: 100%; position: relative; }
.banner-img {
  position: absolute; inset: 0; width: 100%; height: 100%; object-fit: contain;
  opacity: 0; transition: opacity 0.6s; filter: drop-shadow(0 20px 60px rgba(0,240,255,0.15));
  padding: 20px;
}
.banner-img.active { opacity: 1; }
.banner-dots { position: absolute; bottom: 16px; left: 50%; transform: translateX(-50%); display: flex; gap: 6px; z-index: 2; }
.banner-dots .dot { width: 8px; height: 8px; border-radius: 50%; background: rgba(255,255,255,0.3); cursor: pointer; transition: all .3s; }
.banner-dots .dot.active { background: var(--accent); box-shadow: 0 0 8px var(--accent-glow); width: 24px; border-radius: 4px; }
.hero-placeholder-img { font-size: 120px; opacity: 0.15; }
.hero-dots-bar { display: flex; gap: 8px; justify-content: center; margin-top: 16px; }
.hdot { width: 32px; height: 4px; border-radius: 2px; background: var(--text-muted); cursor: pointer; transition: all .3s; }
.hdot.active { background: var(--accent); box-shadow: 0 0 8px var(--accent-glow); }

/* ── 快捷分类 ── */
.cats { max-width: 1440px; margin: 32px auto 0; padding: 0 40px; }
.cats-grid { display: grid; grid-template-columns: repeat(6, 1fr); gap: 16px; }
.cat-card {
  background: var(--bg-card); border: 1px solid var(--border);
  border-radius: 16px; padding: 24px 16px;
  display: flex; flex-direction: column; align-items: center; gap: 10px;
  cursor: pointer; transition: all .35s;
}
.cat-card:hover {
  transform: translateY(-4px); border-color: var(--accent);
  box-shadow: 0 8px 24px rgba(0,240,255,0.1);
}
.cat-icon {
  width: 52px; height: 52px; border-radius: 14px;
  background: linear-gradient(135deg, rgba(0,240,255,0.1), rgba(170,102,255,0.08));
  border: 1px solid rgba(0,240,255,0.15);
  display: flex; align-items: center; justify-content: center; font-size: 24px;
}
.cat-card:hover .cat-icon { background: linear-gradient(135deg, var(--accent), var(--accent-tertiary)); box-shadow: 0 0 16px var(--accent-glow); }
.cat-name { font-size: 14px; font-weight: 500; color: var(--text-primary); }

/* ── 品牌滚动条 ── */
.brand-strip {
  max-width: 1440px; margin: 40px auto 0; padding: 0 40px;
  overflow: hidden; position: relative;
}
.brand-strip::before, .brand-strip::after {
  content: ''; position: absolute; top: 0; bottom: 0; width: 60px; z-index: 2; pointer-events: none;
}
.brand-strip::before { left: 0; background: linear-gradient(90deg, var(--bg-primary), transparent); }
.brand-strip::after { right: 0; background: linear-gradient(-90deg, var(--bg-primary), transparent); }
.brand-track {
  display: flex; gap: 60px; align-items: center;
  animation: brand-scroll 35s linear infinite;
  width: max-content; padding: 20px 0;
}
.brand-track:hover { animation-play-state: paused; }
.brand-item {
  font-family: 'Orbitron', sans-serif; font-size: 18px; font-weight: 700;
  color: var(--text-muted); letter-spacing: 3px; white-space: nowrap;
  opacity: 0.5; transition: all .3s; cursor: default;
}
.brand-item:hover { opacity: 1; color: var(--accent); text-shadow: 0 0 20px var(--accent-glow); }

/* ── 限时秒杀 ── */
.flash { max-width: 1440px; margin: 40px auto 0; padding: 0 40px; }
.flash-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; }
.flash-title-wrap { display: flex; align-items: center; gap: 16px; }
.flash-title { font-family: 'Orbitron', sans-serif; font-size: 24px; font-weight: 700; letter-spacing: 2px; background: linear-gradient(135deg, var(--accent), var(--accent-secondary)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; }
.flash-countdown { display: flex; align-items: center; gap: 6px; }
.cd-box { background: var(--bg-card); border: 1px solid var(--border); color: var(--accent); padding: 6px 10px; border-radius: 6px; font-size: 18px; font-weight: 700; min-width: 36px; text-align: center; box-shadow: 0 0 8px rgba(0,240,255,0.08); }
.cd-sep { color: var(--text-muted); font-size: 16px; }
.flash-more { font-size: 13px; color: var(--text-secondary); cursor: pointer; transition: color .2s; }
.flash-more:hover { color: var(--accent); }
.flash-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 16px; }

/* ── 商品卡片 ── */
.gcard { background: var(--bg-card); border-radius: 16px; border: 1px solid var(--border); overflow: hidden; cursor: pointer; transition: all .4s; position: relative; }
.gcard::before { content: ''; position: absolute; inset: 0; z-index: 1; pointer-events: none; background: linear-gradient(135deg, rgba(0,240,255,0.05) 0%, transparent 50%, rgba(170,102,255,0.03) 100%); opacity: 0; transition: opacity .3s; }
.gcard:hover::before { opacity: 1; }
.gcard:hover { transform: translateY(-6px); border-color: var(--border-hover); box-shadow: 0 16px 40px rgba(0,0,0,0.5), 0 0 20px rgba(0,240,255,0.08); }
.gcard-img { position: relative; width: 100%; aspect-ratio: 1; background: linear-gradient(145deg, #0a0a16, #131326); overflow: hidden; }
.gcard-img img { width: 100%; height: 100%; object-fit: cover; transition: transform .4s; }
.gcard:hover .gcard-img img { transform: scale(1.06); }
.gcard-badges { position: absolute; top: 10px; left: 10px; display: flex; flex-direction: column; gap: 4px; z-index: 2; }
.gbadge { padding: 4px 10px; font-size: 11px; font-weight: 700; border-radius: 6px; }
.gbadge-hot { background: linear-gradient(135deg, #ff6b35, var(--accent-secondary)); color: #fff; box-shadow: 0 2px 8px rgba(255,42,138,0.3); }
.gbadge-discount { background: linear-gradient(135deg, var(--accent), var(--accent-tertiary)); color: #000; }
.gcard-fav { position: absolute; top: 10px; right: 10px; width: 32px; height: 32px; border-radius: 50%; border: none; background: rgba(0,0,0,0.4); color: #fff; font-size: 14px; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: all .3s; z-index: 2; }
.gcard-fav:hover, .gcard-fav.liked { background: var(--accent-secondary); color: #fff; box-shadow: 0 0 12px var(--accent-secondary-glow); }
.gcard-body { padding: 16px; position: relative; z-index: 2; }
.gcard-brand { font-family: 'Orbitron', sans-serif; font-size: 12px; font-weight: 600; color: var(--accent); letter-spacing: 1px; margin-bottom: 6px; }
.gcard-name { font-size: 14px; color: var(--text-primary); line-height: 1.5; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; margin-bottom: 12px; min-height: 42px; }
.gcard-price-row { display: flex; align-items: baseline; gap: 8px; margin-bottom: 12px; }
.gcard-price { font-family: 'Orbitron', sans-serif; font-size: 20px; font-weight: 700; color: var(--accent); text-shadow: 0 0 10px rgba(0,240,255,0.2); }
.gcard-price::before { content: '¥'; font-size: 13px; margin-right: 2px; }
.gcard-orig { font-size: 12px; color: var(--text-muted); text-decoration: line-through; }
.gcard-sold { font-size: 11px; color: var(--text-muted); margin-top: 4px; }
.gcard-btn { width: 100%; padding: 10px; border-radius: 8px; border: 1px solid var(--border); background: transparent; color: var(--text-secondary); font-size: 13px; font-weight: 600; cursor: pointer; transition: all .3s; }
.gcard:hover .gcard-btn { background: linear-gradient(135deg, var(--accent), var(--accent-tertiary)); border-color: transparent; color: #000; box-shadow: 0 4px 16px rgba(0,240,255,0.2); }

/* ── 通用区块 ── */
.section { max-width: 1440px; margin: 48px auto 0; padding: 0 40px; }
.sec-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 28px; }
.sec-title { font-family: 'Orbitron', sans-serif; font-size: 22px; font-weight: 700; letter-spacing: 2px; display: flex; align-items: center; gap: 12px; }
.sec-title .bar { width: 4px; height: 24px; border-radius: 2px; background: linear-gradient(180deg, var(--accent), var(--accent-tertiary)); box-shadow: 0 0 8px var(--accent-glow); }
.sec-title span { background: linear-gradient(135deg, var(--text-primary), var(--text-secondary)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; }
.sec-more { font-size: 13px; color: var(--text-secondary); cursor: pointer; display: flex; align-items: center; gap: 4px; transition: color .2s; }
.sec-more:hover { color: var(--accent); }
.pgrid-5 { display: grid; grid-template-columns: repeat(5, 1fr); gap: 16px; }

/* ── 促销横幅 ── */
.promo { max-width: 1440px; margin: 48px auto 0; padding: 0 40px; display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
.promo-card { position: relative; height: 200px; border-radius: 20px; overflow: hidden; cursor: pointer; display: flex; align-items: center; padding: 36px; border: 1px solid var(--border); transition: all .3s; }
.promo-card:hover { transform: translateY(-4px); box-shadow: var(--shadow-glow); }
.promo-card h3 { font-size: 24px; font-weight: 700; margin-bottom: 8px; position: relative; z-index: 2; }
.promo-card p { font-size: 14px; opacity: 0.7; position: relative; z-index: 2; }
.promo-tag { display: inline-block; padding: 6px 14px; border-radius: 6px; font-size: 12px; font-weight: 700; margin-top: 16px; position: relative; z-index: 2; }
.p1 { background: linear-gradient(135deg, #0f0c29, #302b63); }
.p1 h3, .p1 .promo-tag { color: var(--accent); }
.p1 .promo-tag { background: rgba(0,240,255,0.12); border: 1px solid rgba(0,240,255,0.25); }
.p2 { background: linear-gradient(135deg, #1a1a2e, #16213e); }
.p2 h3, .p2 .promo-tag { color: var(--accent-secondary); }
.p2 .promo-tag { background: rgba(255,42,138,0.12); border: 1px solid rgba(255,42,138,0.25); }

/* ── 服务保障 ── */
.service { max-width: 1440px; margin: 48px auto 0; padding: 0 40px 60px; }
.svc-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }
.svc { background: var(--bg-card); border: 1px solid var(--border); border-radius: 16px; padding: 24px; display: flex; align-items: center; gap: 16px; }
.svc-icon { font-size: 32px; }
.svc h4 { font-size: 14px; font-weight: 700; color: var(--text-primary); margin-bottom: 4px; }
.svc p { font-size: 12px; color: var(--text-muted); }

/* ── Bento Grid ── */
.bento-section { max-width: 1440px; margin: 48px auto 0; padding: 0 40px; }
.bento-grid {
  display: grid; grid-template-columns: repeat(4, 1fr);
  grid-auto-rows: 240px; gap: 16px;
}
.bento-item {
  position: relative; border-radius: 20px; overflow: hidden;
  cursor: pointer; border: 1px solid var(--border);
  transition: all .4s; background: var(--bg-card);
}
.bento-item:hover { border-color: var(--border-hover); box-shadow: 0 12px 40px rgba(0,0,0,0.4), 0 0 30px rgba(0,240,255,0.05); transform: translateY(-2px); }
.bento-item.large { grid-column: span 2; grid-row: span 2; }
.bento-item.tall { grid-row: span 2; }
.bento-item.wide { grid-column: span 2; }
.bento-img { position: absolute; inset: 0; }
.bento-img img { width: 100%; height: 100%; object-fit: cover; transition: transform .5s; }
.bento-item:hover .bento-img img { transform: scale(1.08); }
.bento-overlay {
  position: absolute; inset: 0;
  background: linear-gradient(180deg, transparent 40%, rgba(5,5,8,0.85) 100%);
  z-index: 1;
}
.bento-content {
  position: absolute; bottom: 0; left: 0; right: 0; padding: 24px; z-index: 2;
}
.bento-badge {
  display: inline-block; padding: 4px 10px; border-radius: 6px;
  font-family: 'Orbitron', sans-serif; font-size: 10px; font-weight: 700;
  letter-spacing: 1px; margin-bottom: 8px;
  background: rgba(0,240,255,0.15); color: var(--accent);
  border: 1px solid rgba(0,240,255,0.25);
}
.bento-brand { font-family: 'Orbitron', sans-serif; font-size: 11px; color: var(--text2); letter-spacing: 1px; margin-bottom: 4px; }
.bento-name { font-size: 15px; font-weight: 600; color: var(--text-primary); margin-bottom: 8px; line-height: 1.4; }
.bento-price { font-family: 'Orbitron', sans-serif; font-size: 20px; font-weight: 700; color: var(--accent); text-shadow: 0 0 10px rgba(0,240,255,0.2); }
.bento-price::before { content: '¥'; font-size: 14px; margin-right: 2px; }

/* ── 横向滚动推荐 ── */
.scroll-section { max-width: 1440px; margin: 48px auto 0; padding: 0 40px; }
.scroll-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; }
.scroll-title { font-family: 'Orbitron', sans-serif; font-size: 22px; font-weight: 700; letter-spacing: 2px; }
.scroll-track-wrap { overflow-x: auto; padding-bottom: 12px; -webkit-overflow-scrolling: touch; }
.scroll-track-wrap::-webkit-scrollbar { height: 4px; }
.scroll-track-wrap::-webkit-scrollbar-thumb { background: var(--text3); border-radius: 2px; }
.scroll-track { display: flex; gap: 16px; width: max-content; }
.sitem {
  width: 220px; border-radius: 16px; overflow: hidden;
  border: 1px solid var(--border); background: var(--bg-card);
  cursor: pointer; transition: all .3s; flex-shrink: 0;
}
.sitem:hover { border-color: var(--border-hover); transform: translateY(-4px); box-shadow: 0 8px 24px rgba(0,0,0,0.3); }
.sitem-img { width: 100%; height: 220px; background: linear-gradient(145deg, #0a0a16, #131326); }
.sitem-img img { width: 100%; height: 100%; object-fit: cover; }
.sitem-body { padding: 14px; }
.sitem-name { font-size: 13px; color: var(--text-primary); line-height: 1.4; margin-bottom: 8px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
.sitem-price { font-family: 'Orbitron', sans-serif; font-size: 17px; font-weight: 700; color: var(--accent); text-shadow: 0 0 8px rgba(0,240,255,0.15); }
.sitem-price::before { content: '¥'; font-size: 12px; margin-right: 2px; }

@media (max-width: 1200px) {
  .pgrid-5 { grid-template-columns: repeat(4, 1fr); }
  .flash-grid { grid-template-columns: repeat(4, 1fr); }
  .bento-grid { grid-template-columns: repeat(2, 1fr); grid-auto-rows: 200px; }
  .bento-item.large, .bento-item.wide { grid-column: span 2; }
  .bento-item.tall { grid-row: span 2; }
}
@media (max-width: 900px) {
  .hero-slide { grid-template-columns: 1fr; height: auto; }
  .hero-info { padding: 36px; }
  .hero-img-wrap { min-height: 300px; }
  .cats-grid { grid-template-columns: repeat(3, 1fr); }
  .flash-grid { grid-template-columns: repeat(2, 1fr); }
  .pgrid-5 { grid-template-columns: repeat(2, 1fr); }
  .promo { grid-template-columns: 1fr; }
  .svc-grid { grid-template-columns: repeat(2, 1fr); }
  .bento-grid { grid-template-columns: repeat(2, 1fr); grid-auto-rows: 180px; }
  .bento-item.large, .bento-item.tall { grid-column: span 2; grid-row: span 1; }
}
</style>
