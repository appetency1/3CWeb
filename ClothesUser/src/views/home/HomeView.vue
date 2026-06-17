<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { publicApi } from '@/api/public'
import { showFailToast } from 'vant'
import { fullImgUrl } from '@/utils/img'

const router = useRouter()
const searchValue = ref('')
const activeBanner = ref(0)
const refreshing = ref(false)
const loading = ref(false)
const finished = ref(false)

const banners = ref<{ id: number; image: string; title?: string; link?: string }[]>([])
const categories = ref<any[]>([])
const hotGoods = ref<any[]>([])
const newGoods = ref<any[]>([])
const page = ref(1)
const size = 10
const goodsList = ref<any[]>([])
const total = ref(0)

function goGoods(id: number) { router.push({ name: 'goodsDetail', params: { id } }) }
function goCategory(id?: number) {
  if (id) router.push({ name: 'categoryGoods', params: { id } })
  else router.push({ name: 'category' })
}

function onSearch() {
  const kw = searchValue.value.trim()
  if (kw) router.push({ name: 'search', query: { keyword: kw } })
  else router.push({ name: 'search' })
}

const isEmpty = computed(() =>
  !banners.value.length && !categories.value.length && !hotGoods.value.length && !newGoods.value.length && !goodsList.value.length
)

async function loadBanners() {
  try {
    const data: any = await publicApi.banners()
    banners.value = (data || []).map((b: any) => ({
      id: b.id,
      image: fullImgUrl(b.image),
      title: b.title,
      link: b.link,
    }))
  } catch (e: any) { showFailToast('轮播图加载失败') }
}

async function loadCategories() {
  try {
    const data: any = await publicApi.categories()
    const cats = (data || []).filter((c: any) => c.parentId === 0)
    categories.value = cats.slice(0, 8)
  } catch (e: any) { showFailToast('分类加载失败') }
}

async function loadHot() {
  try {
    const data: any = await publicApi.hotGoods()
    hotGoods.value = data || []
  } catch (e: any) { /* silent */ }
}

async function loadNew() {
  try {
    const data: any = await publicApi.newGoods()
    newGoods.value = data || []
  } catch (e: any) { /* silent */ }
}

async function loadGoodsList() {
  if (loading.value) return
  loading.value = true
  try {
    const data: any = await publicApi.goodsList({ page: page.value, size })
    const list = data?.list || data || []
    total.value = data?.total || 0
    if (page.value === 1) goodsList.value = list
    else goodsList.value.push(...list)
    finished.value = goodsList.value.length >= total.value
    page.value++
  } catch (e: any) {
    showFailToast('商品列表加载失败')
    finished.value = true
  } finally {
    loading.value = false
    refreshing.value = false
  }
}

async function onRefresh() {
  page.value = 1
  goodsList.value = []
  finished.value = false
  await Promise.all([loadBanners(), loadCategories(), loadHot(), loadNew()])
  await loadGoodsList()
}

onMounted(async () => {
  await Promise.all([loadBanners(), loadCategories(), loadHot(), loadNew()])
  await loadGoodsList()
})
</script>

<template>
  <div class="home-page">
    <!-- Search Bar -->
    <div class="search-bar">
      <div class="search-wrap">
        <van-icon name="search" class="search-icon" />
        <input
          v-model="searchValue"
          class="search-input"
          placeholder="搜索你喜欢的时尚单品..."
          @keyup.enter="onSearch"
        />
      </div>
    </div>

    <!-- Banner Carousel -->
    <div class="banner-section">
      <van-swipe
        v-if="banners.length"
        :autoplay="4000"
        :initial-swipe="activeBanner"
        class="banner-swipe"
        @change="activeBanner = $event"
      >
        <van-swipe-item v-for="banner in banners" :key="banner.id">
          <img
            :src="banner.image"
            class="banner-img"
            @click="banner.link && router.push(banner.link)"
          />
        </van-swipe-item>
        <template #indicator>
          <div class="banner-indicators">
            <span
              v-for="(_, i) in banners"
              :key="i"
              class="indicator-dot"
              :class="{ active: i === activeBanner }"
            />
          </div>
        </template>
      </van-swipe>
      <!-- Skeleton -->
      <div v-else class="banner-skeleton skeleton" />
    </div>

    <!-- Category Grid -->
    <div class="category-grid">
      <div
        v-for="(cat, i) in categories"
        :key="cat.id"
        class="cat-item"
        :class="`animate-enter animate-enter-${(i % 4) + 1}`"
        @click="goCategory(cat.id)"
      >
        <div class="cat-icon-wrap">
          <img
            v-if="cat.icon"
            :src="fullImgUrl(cat.icon)"
            class="cat-icon"
            alt=""
          />
          <span v-else class="cat-emoji">{{ ['👗','👔','👟','👜'][i % 4] }}</span>
        </div>
        <span class="cat-name">{{ cat.name }}</span>
      </div>
      <!-- Skeleton -->
      <template v-if="!categories.length">
        <div v-for="i in 8" :key="`sk-${i}`" class="cat-item">
          <div class="cat-icon-wrap skeleton" style="border-radius:50%" />
          <span class="cat-name skeleton" style="width:36px;height:12px" />
        </div>
      </template>
    </div>

    <!-- Hot Products -->
    <div v-if="hotGoods.length" class="goods-section">
      <div class="section-header">
        <span class="section-title">热门推荐</span>
        <span class="section-more" @click="goCategory()">
          查看更多 <van-icon name="arrow" size="12" />
        </span>
      </div>
      <div class="goods-scroll">
        <div
          v-for="(item, i) in hotGoods"
          :key="item.id"
          class="goods-scroll-item animate-enter"
          :class="`animate-enter-${(i % 3) + 1}`"
          @click="goGoods(item.id)"
        >
          <div class="goods-scroll-img-wrap">
            <img :src="fullImgUrl(item.cover)" class="goods-scroll-img" loading="lazy" />
            <span class="goods-scroll-tag">HOT</span>
          </div>
          <div class="goods-scroll-body">
            <p class="goods-scroll-name">{{ item.name }}</p>
            <p class="goods-scroll-price">
              <span class="price-symbol">¥</span>{{ item.price }}
              <span v-if="item.originalPrice" class="price-original">¥{{ item.originalPrice }}</span>
            </p>
          </div>
        </div>
      </div>
    </div>

    <!-- New Products -->
    <div v-if="newGoods.length" class="goods-section">
      <div class="section-header">
        <span class="section-title">新品上市</span>
        <span class="section-more" @click="goCategory()">
          查看更多 <van-icon name="arrow" size="12" />
        </span>
      </div>
      <div class="goods-scroll">
        <div
          v-for="(item, i) in newGoods"
          :key="item.id"
          class="goods-scroll-item animate-enter"
          :class="`animate-enter-${(i % 3) + 1}`"
          @click="goGoods(item.id)"
        >
          <div class="goods-scroll-img-wrap">
            <img :src="fullImgUrl(item.cover)" class="goods-scroll-img" loading="lazy" />
            <span class="goods-scroll-tag goods-scroll-tag-new">NEW</span>
          </div>
          <div class="goods-scroll-body">
            <p class="goods-scroll-name">{{ item.name }}</p>
            <p class="goods-scroll-price">
              <span class="price-symbol">¥</span>{{ item.price }}
              <span v-if="item.originalPrice" class="price-original">¥{{ item.originalPrice }}</span>
            </p>
          </div>
        </div>
      </div>
    </div>

    <!-- All Products Grid -->
    <div class="goods-section">
      <div class="section-header">
        <span class="section-title">精选好物</span>
      </div>
      <van-pull-refresh v-model="refreshing" @refresh="onRefresh">
        <div class="goods-grid">
          <div
            v-for="(item, i) in goodsList"
            :key="item.id"
            class="goods-card animate-enter"
            :class="`animate-enter-${(i % 6) + 1}`"
            @click="goGoods(item.id)"
          >
            <div class="goods-card-img-wrap">
              <img :src="fullImgUrl(item.cover)" class="goods-card-img" loading="lazy" />
            </div>
            <div class="goods-card-body">
              <p class="goods-card-name">{{ item.name }}</p>
              <div class="goods-card-bottom">
                <span class="goods-card-price">¥{{ item.price }}</span>
                <span v-if="item.originalPrice" class="goods-card-original">¥{{ item.originalPrice }}</span>
              </div>
            </div>
          </div>
        </div>
        <van-list
          v-model:loading="loading"
          :finished="finished"
          finished-text="— 没有更多了 —"
          :loading-text="'加载中...'"
          @load="loadGoodsList"
        />
      </van-pull-refresh>
    </div>

    <!-- Empty State -->
    <div v-if="isEmpty && !loading" class="empty-state">
      <div class="empty-icon">👗</div>
      <p class="empty-state-text">暂无商品</p>
    </div>
  </div>
</template>

<style scoped>
/* ---- Search Bar ---- */
.search-bar {
  position: sticky;
  top: 0;
  z-index: 100;
  background: rgba(245,243,240,0.94);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  padding: 10px 16px 8px;
}
.search-wrap {
  display: flex;
  align-items: center;
  background: var(--cl-bg-card);
  border-radius: var(--radius-full);
  padding: 0 16px;
  height: 40px;
  box-shadow: var(--shadow-xs);
  border: 1px solid var(--cl-border-light);
}
.search-icon {
  color: var(--cl-text-muted);
  font-size: 16px;
  flex-shrink: 0;
}
.search-input {
  flex: 1;
  border: none;
  outline: none;
  background: transparent;
  font-size: 14px;
  color: var(--cl-text-primary);
  margin-left: 8px;
}
.search-input::placeholder {
  color: var(--cl-text-muted);
}

/* ---- Banner ---- */
.banner-section {
  position: relative;
  margin: 12px 16px;
  border-radius: var(--radius-lg);
  overflow: hidden;
}
.banner-swipe {
  border-radius: var(--radius-lg);
}
.banner-img {
  width: 100%;
  height: 180px;
  object-fit: cover;
  display: block;
}
.banner-skeleton {
  height: 180px;
  border-radius: var(--radius-lg);
}
.banner-indicators {
  position: absolute;
  bottom: 10px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 5px;
}
.indicator-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: rgba(255,255,255,0.5);
  transition: all 0.3s;
}
.indicator-dot.active {
  width: 18px;
  border-radius: 3px;
  background: #fff;
}

/* ---- Category Grid ---- */
.category-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px 8px;
  padding: 8px 16px 4px;
}
.cat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
}
.cat-item:active .cat-icon-wrap {
  transform: scale(0.92);
}
.cat-icon-wrap {
  width: 52px;
  height: 52px;
  border-radius: 50%;
  background: var(--cl-bg-card);
  box-shadow: var(--shadow-xs);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform var(--transition-fast);
  overflow: hidden;
}
.cat-icon {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 50%;
}
.cat-emoji {
  font-size: 24px;
  line-height: 1;
}
.cat-name {
  font-size: 11px;
  color: var(--cl-text-secondary);
  text-align: center;
  max-width: 60px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* ---- Goods Section ---- */
.goods-section {
  margin-top: 16px;
}
.goods-scroll {
  display: flex;
  gap: 10px;
  overflow-x: auto;
  padding: 4px 16px 12px;
  scrollbar-width: none;
  -ms-overflow-style: none;
}
.goods-scroll::-webkit-scrollbar {
  display: none;
}
.gs-item-w {
  flex-shrink: 0;
  width: 120px;
}
.goods-scroll-item {
  flex-shrink: 0;
  width: 120px;
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
}
.goods-scroll-img-wrap {
  position: relative;
  border-radius: var(--radius-md);
  overflow: hidden;
  background: var(--cl-bg-muted);
  aspect-ratio: 3 / 4;
}
.goods-scroll-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.goods-scroll-tag {
  position: absolute;
  top: 6px;
  left: 6px;
  background: var(--cl-red);
  color: #fff;
  font-size: 9px;
  font-weight: 700;
  padding: 2px 5px;
  border-radius: 3px;
  letter-spacing: 0.5px;
}
.goods-scroll-tag-new {
  background: var(--cl-primary);
}
.goods-scroll-body {
  padding: 8px 2px 4px;
}
.goods-scroll-name {
  font-size: 12px;
  color: var(--cl-text-primary);
  line-height: 1.3;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  margin-bottom: 4px;
}
.goods-scroll-price {
  font-size: 14px;
  font-weight: 700;
  color: var(--cl-red);
}
.price-symbol {
  font-size: 10px;
  font-weight: 600;
}
.price-original {
  font-size: 10px;
  color: var(--cl-text-muted);
  text-decoration: line-through;
  margin-left: 3px;
  font-weight: 400;
}

/* ---- Goods Grid ---- */
.goods-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
  padding: 4px 16px 16px;
}
.goods-card {
  background: var(--cl-bg-card);
  border-radius: var(--radius-md);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
  transition: transform var(--transition-fast), box-shadow var(--transition-fast);
}
.goods-card:active {
  transform: scale(0.96);
  box-shadow: var(--shadow-xs);
}
.goods-card-img-wrap {
  width: 100%;
  aspect-ratio: 1 / 1;
  background: var(--cl-bg-muted);
  overflow: hidden;
}
.goods-card-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.4s ease;
}
.goods-card:active .goods-card-img {
  transform: scale(1.03);
}
.goods-card-body {
  padding: 10px 12px 12px;
}
.goods-card-name {
  font-size: 13px;
  color: var(--cl-text-primary);
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  margin-bottom: 8px;
}
.goods-card-bottom {
  display: flex;
  align-items: baseline;
  gap: 4px;
}
.goods-card-price {
  font-size: 15px;
  font-weight: 700;
  color: var(--cl-red);
}
.goods-card-original {
  font-size: 10px;
  color: var(--cl-text-muted);
  text-decoration: line-through;
}

/* ---- Empty ---- */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 64px 16px;
  color: var(--cl-text-muted);
}
.empty-icon {
  font-size: 64px;
  opacity: 0.4;
  margin-bottom: 12px;
}
</style>
