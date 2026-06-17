<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

// ── 数据状态（全部本地静态数据，参考 demo-new.html） ──
const banners = ref([
  { id: 1, title: '夏季新品 清爽上市', image: '/assets/banners/banner-1.svg', link: '/Desktop/category' },
  { id: 2, title: '精致轻奢 品牌专区', image: '/assets/banners/banner-2.svg', link: '/Desktop/category' },
  { id: 3, title: '自然舒适 棉麻新品', image: '/assets/banners/banner-3.svg', link: '/Desktop/category' },
  { id: 4, title: '优雅穿搭 潮流之选', image: '/assets/banners/banner-4.svg', link: '/Desktop/category' },
  { id: 5, title: 'VIP会员 专属折扣', image: '/assets/banners/banner-5.svg', link: '/Desktop/user' },
])

const categories = ref([
  { id: 1, name: '上衣',   icon: '/assets/icons/cat-tops.svg' },
  { id: 2, name: '裤装',   icon: '/assets/icons/cat-pants.svg' },
  { id: 3, name: '裙装',   icon: '/assets/icons/cat-dress.svg' },
  { id: 4, name: '鞋履',   icon: '/assets/icons/cat-shoes.svg' },
  { id: 5, name: '包袋',   icon: '/assets/icons/cat-bag.svg' },
  { id: 6, name: '配饰',   icon: '/assets/icons/cat-acc.svg' },
  { id: 7, name: '内衣',   icon: '/assets/icons/cat-underwear.svg' },
  { id: 8, name: '家居',   icon: '/assets/icons/cat-home.svg' },
])

const hotGoods = ref([
  { id: 1, categoryId: 1, name: '女士法式优雅连衣裙', price: 299, originalPrice: 499, cover: '/assets/products/goods-1-molan-di-mian-t.jpg', sales: 12000 },
  { id: 2, categoryId: 2, name: '商务休闲衬衫', price: 199, originalPrice: 299, cover: '/assets/products/goods-2.jpg', sales: 8562 },
  { id: 3, categoryId: 3, name: '复古运动休闲鞋', price: 359, cover: '/assets/products/goods-3.jpg', sales: 5321 },
  { id: 4, categoryId: 4, name: '真皮单肩包', price: 899, originalPrice: 1299, cover: '/assets/products/goods-4.jpg', sales: 3210 },
  { id: 5, categoryId: 1, name: '轻薄防晒衣 UPF50+', price: 99, originalPrice: 199, cover: '/assets/products/goods-5.jpg', sales: 21000 },
  { id: 6, categoryId: 6, name: '精致腕表 商务休闲', price: 1599, originalPrice: 2099, cover: '/assets/products/goods-6.jpg', sales: 2105 },
  { id: 7, categoryId: 1, name: '莫兰迪色系针织衫', price: 239, cover: '/assets/products/goods-7.jpg', sales: 1863 },
  { id: 8, categoryId: 2, name: '高腰直筒牛仔裤', price: 259, cover: '/assets/products/goods-8.jpg', sales: 1452 },
  { id: 9, categoryId: 3, name: '真皮小白鞋 透气舒适', price: 459, cover: '/assets/products/goods-9.jpg', sales: 1232 },
  { id: 10, categoryId: 1, name: '吊带连衣裙 海边度假', price: 229, cover: '/assets/products/goods-10.jpg', sales: 1100 },
])

const flashTime = ref({ h: 2, m: 15, s: 43 })
let countdownTimer: number

const currentBanner = ref(0)
let bannerTimer: number

function startCountdown() {
  countdownTimer = window.setInterval(() => {
    let { h, m, s } = flashTime.value
    if (s > 0) s--
    else if (m > 0) { m--; s = 59 }
    else if (h > 0) { h--; m = 59; s = 59 }
    else { h = 2; m = 15; s = 43 }
    flashTime.value = { h, m, s }
  }, 1000)
}

function startBanner() {
  bannerTimer = window.setInterval(() => {
    currentBanner.value = (currentBanner.value + 1) % banners.value.length
  }, 4000)
}

function goCategory(id: number) {
  router.push(`/Desktop/category/${id}`)
}
function goGoods(id: number) {
  router.push(`/Desktop/goods/${id}`)
}
function goBanner(link?: string) {
  if (link) router.push(link)
}

onMounted(() => { startCountdown(); startBanner() })
onUnmounted(() => { clearInterval(countdownTimer); clearInterval(bannerTimer) })

const pad = (n: number) => n.toString().padStart(2, '0')
</script>

<template>
  <div class="desktop-home">
    <!-- 顶部欢迎条 -->
    <div class="welcome-bar">
      <div class="welcome-left">
        <h1>欢迎来到 MAISON</h1>
        <p>精选时尚 · 优雅生活 · 此刻启程</p>
      </div>
      <div class="welcome-right">
        <div class="flash-deal">
          <div class="flash-title">
            <span class="flash-icon">⚡</span>
            <span>限时秒杀</span>
          </div>
          <div class="flash-time">
            <span class="time-block">{{ pad(flashTime.h) }}</span>
            <span class="time-sep">:</span>
            <span class="time-block">{{ pad(flashTime.m) }}</span>
            <span class="time-sep">:</span>
            <span class="time-block">{{ pad(flashTime.s) }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 轮播图 -->
    <div class="banner-section">
      <div class="banner-track" :style="{ transform: `translateX(-${currentBanner * 100}%)` }">
        <div v-for="b in banners" :key="b.id" class="banner-slide" @click="goBanner(b.link)">
          <img :src="b.image" :alt="b.title" />
          <div class="banner-mask">
            <h2>{{ b.title }}</h2>
          </div>
        </div>
      </div>
      <div class="banner-dots">
        <span
          v-for="(b, idx) in banners"
          :key="b.id"
          :class="['dot', { active: idx === currentBanner }]"
          @click="currentBanner = idx"
        />
      </div>
    </div>

    <!-- 分类入口 -->
    <div class="category-grid">
      <div
        v-for="c in categories"
        :key="c.id"
        class="category-item"
        @click="goCategory(c.id)"
      >
        <div class="category-icon">
          <img :src="c.icon" :alt="c.name" />
        </div>
        <div class="category-name">{{ c.name }}</div>
      </div>
    </div>

    <!-- 热销推荐 -->
    <div class="section-header">
      <h2>热销推荐</h2>
      <span class="section-sub">本周大家都在买</span>
    </div>
    <div class="goods-grid">
      <div
        v-for="g in hotGoods.slice(0, 5)"
        :key="g.id"
        class="goods-card"
        @click="goGoods(g.id)"
      >
        <div class="goods-cover">
          <img :src="g.cover" :alt="g.name" />
          <span v-if="g.originalPrice" class="discount-tag">
            {{ Math.round((1 - g.price / g.originalPrice) * 10) }}折
          </span>
        </div>
        <div class="goods-info">
          <h3 class="goods-name">{{ g.name }}</h3>
          <div class="goods-price-row">
            <span class="price-now">¥{{ g.price }}</span>
            <span v-if="g.originalPrice" class="price-old">¥{{ g.originalPrice }}</span>
          </div>
          <div class="goods-sales">已售 {{ g.sales }}</div>
        </div>
      </div>
    </div>

    <!-- 为你精选 -->
    <div class="section-header">
      <h2>为你精选</h2>
      <span class="section-sub">编辑严选 · 每周更新</span>
    </div>
    <div class="goods-grid">
      <div
        v-for="g in hotGoods.slice(5, 10)"
        :key="g.id"
        class="goods-card"
        @click="goGoods(g.id)"
      >
        <div class="goods-cover">
          <img :src="g.cover" :alt="g.name" />
        </div>
        <div class="goods-info">
          <h3 class="goods-name">{{ g.name }}</h3>
          <div class="goods-price-row">
            <span class="price-now">¥{{ g.price }}</span>
          </div>
          <div class="goods-sales">已售 {{ g.sales }}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.desktop-home { padding: 0; }

.welcome-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: linear-gradient(135deg, #1a1a1a 0%, #2d2d2d 100%);
  color: #fff;
  padding: 24px 32px;
  border-radius: 12px;
  margin-bottom: 20px;
}
.welcome-left h1 { font-size: 24px; font-weight: 700; margin-bottom: 6px; }
.welcome-left p { color: #c0c0c0; font-size: 13px; }
.flash-deal { display: flex; flex-direction: column; align-items: flex-end; gap: 8px; }
.flash-title { display: flex; align-items: center; gap: 6px; font-size: 14px; font-weight: 600; }
.flash-icon { color: #ff4757; font-size: 18px; }
.flash-time { display: flex; align-items: center; gap: 4px; font-size: 14px; font-weight: 600; }
.time-block {
  background: #c45c4a;
  color: #fff;
  padding: 4px 8px;
  border-radius: 4px;
  min-width: 28px;
  text-align: center;
}
.time-sep { color: #c45c4a; font-weight: 700; }

.banner-section {
  position: relative;
  height: 360px;
  border-radius: 12px;
  overflow: hidden;
  margin-bottom: 24px;
  background: #f0ede8;
}
.banner-track {
  display: flex;
  height: 100%;
  transition: transform 0.6s ease;
}
.banner-slide {
  flex: 0 0 100%;
  height: 100%;
  position: relative;
  cursor: pointer;
}
.banner-slide img { width: 100%; height: 100%; object-fit: cover; }
.banner-mask {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: flex-end;
  padding: 40px;
  background: linear-gradient(to top, rgba(0,0,0,0.5), transparent);
}
.banner-mask h2 { color: #fff; font-size: 28px; font-weight: 700; }
.banner-dots {
  position: absolute;
  bottom: 16px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 8px;
}
.dot {
  width: 24px;
  height: 4px;
  border-radius: 2px;
  background: rgba(255,255,255,0.5);
  cursor: pointer;
  transition: all 0.3s;
}
.dot.active { background: #fff; width: 32px; }

.category-grid {
  display: grid;
  grid-template-columns: repeat(8, 1fr);
  gap: 16px;
  background: #fff;
  border-radius: 12px;
  padding: 24px;
  margin-bottom: 24px;
  border: 1px solid #e8e5e0;
}
.category-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  transition: all 0.25s;
  padding: 12px 8px;
  border-radius: 8px;
}
.category-item:hover { background: #faf9f7; transform: translateY(-2px); }
.category-icon {
  width: 56px;
  height: 56px;
  background: #fdf5f3;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}
.category-icon img { width: 32px; height: 32px; }
.category-name { font-size: 13px; color: #1a1a1a; font-weight: 500; }

.section-header {
  display: flex;
  align-items: baseline;
  gap: 12px;
  margin: 32px 0 16px;
}
.section-header h2 { font-size: 22px; font-weight: 700; color: #1a1a1a; }
.section-sub { font-size: 13px; color: #999; }

.goods-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 16px;
}
.goods-card {
  background: #fff;
  border: 1px solid #e8e5e0;
  border-radius: 12px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.25s;
}
.goods-card:hover { transform: translateY(-4px); box-shadow: 0 8px 24px rgba(0,0,0,0.12); }
.goods-cover { position: relative; aspect-ratio: 1/1; background: #f5f3f0; overflow: hidden; }
.goods-cover img { width: 100%; height: 100%; object-fit: cover; }
.discount-tag {
  position: absolute;
  top: 8px;
  right: 8px;
  background: #c45c4a;
  color: #fff;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 600;
}
.goods-info { padding: 12px; }
.goods-name {
  font-size: 13px;
  color: #1a1a1a;
  line-height: 1.4;
  height: 36px;
  overflow: hidden;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  margin-bottom: 8px;
}
.goods-price-row { display: flex; align-items: baseline; gap: 8px; margin-bottom: 6px; }
.price-now { font-size: 18px; font-weight: 700; color: #c45c4a; }
.price-old { font-size: 12px; color: #999; text-decoration: line-through; }
.goods-sales { font-size: 11px; color: #999; }
</style>
