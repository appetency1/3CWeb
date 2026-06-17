<script setup lang="ts">
import { ref, onMounted, computed, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { publicApi } from '@/api/public'
import { fullImgUrl } from '@/utils/img'
import { showFailToast } from 'vant'
import DesktopLayout from '@/components/desktop/DesktopLayout.vue'

const route = useRoute()
const router = useRouter()

const categories = ref<any[]>([])     // 整棵树
const topCategories = ref<any[]>([])  // 一级
const activeTopId = ref<number | null>(null)
const activeSubId = ref<number | null>(null)

const goodsList = ref<any[]>([])
const total = ref(0)
const page = ref(1)
const size = 20
const loading = ref(false)
const finished = ref(false)

const sortType = ref<'default' | 'sales' | 'price_asc' | 'price_desc' | 'new'>('default')
const priceRange = ref<'all' | '0-100' | '100-300' | '300-500' | '500+'>('all')
const showOnlyStock = ref(false)

const sorts = [
  { key: 'default', label: '综合' },
  { key: 'sales', label: '销量' },
  { key: 'price_asc', label: '价格 ↑' },
  { key: 'price_desc', label: '价格 ↓' },
  { key: 'new', label: '新品' },
] as const

const priceRanges = [
  { key: 'all', label: '全部价格' },
  { key: '0-100', label: '¥0-100' },
  { key: '100-300', label: '¥100-300' },
  { key: '300-500', label: '¥300-500' },
  { key: '500+', label: '¥500+' },
] as const

function priceFmt(p: any) { return Number(p || 0).toFixed(2) }
function pct(orig: any, cur: any) {
  const o = Number(orig), c = Number(cur)
  if (!o || o <= c) return 0
  return Math.round((1 - c / o) * 100)
}

const currentTop = computed(() => topCategories.value.find((c: any) => c.id === activeTopId.value))
const subCategories = computed(() => currentTop.value?.children || [])

const currentTitle = computed(() => {
  if (activeSubId.value) {
    const sub = subCategories.value.find((c: any) => c.id === activeSubId.value)
    if (sub) return sub.name
  }
  return currentTop.value?.name || '全部分类'
})
const isSpecificCategory = computed(() => Number(route.params.id || 0) > 0)

const breadcrumb = computed(() => {
  const top = currentTop.value?.name || ''
  const sub = subCategories.value.find((c: any) => c.id === activeSubId.value)?.name
  return sub ? `${top} / ${sub}` : top
})

function pickTop(id: number) {
  if (activeTopId.value === id) return
  activeTopId.value = id
  activeSubId.value = null
  router.replace({ name: 'categoryGoods', params: { id } })
  resetAndFetch()
}
function pickSub(id: number | null) {
  activeSubId.value = id
  resetAndFetch()
}
function pickSort(k: any) {
  sortType.value = k
  resetAndFetch()
}
function pickPrice(k: any) {
  priceRange.value = k
  resetAndFetch()
}
function toggleStock() {
  showOnlyStock.value = !showOnlyStock.value
  resetAndFetch()
}

function resetAndFetch() {
  goodsList.value = []
  page.value = 1
  finished.value = false
  fetchGoods()
}

async function fetchCategories() {
  try {
    const data: any = await publicApi.categories()
    categories.value = data || []
    topCategories.value = (data || []).filter((c: any) => Number(c.parentId) === 0)
    // 初始激活
    const rid = Number(route.params.id || 0)
    let initTop: any = topCategories.value[0]
    let initSub: number | null = null
    if (rid) {
      // 找一级或二级
      const asTop = topCategories.value.find((c: any) => c.id === rid)
      if (asTop) {
        initTop = asTop
      } else {
        for (const top of topCategories.value) {
          const sub = (top.children || []).find((c: any) => c.id === rid)
          if (sub) { initTop = top; initSub = sub.id; break }
        }
      }
    }
    activeTopId.value = initTop?.id || null
    activeSubId.value = initSub
  } catch { showFailToast('分类加载失败') }
}

async function fetchGoods() {
  if (loading.value || finished.value) return
  loading.value = true
  try {
    const sort = sortType.value === 'default' ? undefined : sortType.value
    // 优先用 route.params.id（从导航栏来的），否则用 activeTopId（从 tab 点击来的）
    const catId = Number(route.params.id) || activeSubId.value || activeTopId.value || undefined
    const data: any = await publicApi.goodsList({
      categoryId: catId,
      page: page.value,
      size,
      sort,
    })
    const list = (data?.list || data || []).filter(filterByPrice).filter(filterByStock)
    total.value = data?.total || 0
    if (page.value === 1) goodsList.value = list
    else goodsList.value.push(...list)
    finished.value = goodsList.value.length >= total.value || list.length === 0
    page.value++
  } catch {
    showFailToast('加载失败')
    finished.value = true
  } finally {
    loading.value = false
  }
}

function filterByPrice(g: any) {
  if (priceRange.value === 'all') return true
  const p = Number(g.price || 0)
  if (priceRange.value === '0-100') return p < 100
  if (priceRange.value === '100-300') return p >= 100 && p < 300
  if (priceRange.value === '300-500') return p >= 300 && p < 500
  if (priceRange.value === '500+') return p >= 500
  return true
}
function filterByStock(g: any) {
  if (!showOnlyStock.value) return true
  return Number(g.stock || 0) > 0
}

function goGoods(id: number) { router.push({ name: 'goodsDetail', params: { id } }) }

watch(() => route.params.id, async (v) => {
  if (!v) return
  await fetchCategories()
  resetAndFetch()
})

onMounted(async () => {
  await fetchCategories()
  await fetchGoods()
})
</script>

<template>
  <DesktopLayout>
  <div class="cat-page">
    <!-- Hero -->
    <section class="cat-hero">
      <div class="cat-hero-inner">
        <div class="cat-hero-text">
          <span class="ch-tag">{{ isSpecificCategory ? currentTop?.name || '分类' : 'CATEGORY' }}</span>
          <h1>{{ currentTitle }}</h1>
          <p>共 {{ total }} 件商品 · {{ breadcrumb }}</p>
        </div>
        <span class="cat-hero-emoji">🛍️</span>
      </div>
    </section>

    <!-- 一级分类 tab (从导航栏跳转时不展示，直接用左侧子分类) -->
    <section v-if="!isSpecificCategory" class="cat-tabs">
      <div class="cat-tabs-inner">
        <div
          v-for="c in topCategories"
          :key="c.id"
          class="cat-tab"
          :class="{ active: activeTopId === c.id }"
          @click="pickTop(c.id)"
        >{{ c.name }}</div>
      </div>
    </section>

    <!-- 二级分类 (子分类) -->
    <section v-if="subCategories.length" class="sub-cats">
      <div class="sub-cats-inner">
        <div
          class="sub-chip"
          :class="{ active: activeSubId === null }"
          @click="pickSub(null)"
        >全部</div>
        <div
          v-for="c in subCategories"
          :key="c.id"
          class="sub-chip"
          :class="{ active: activeSubId === c.id }"
          @click="pickSub(c.id)"
        >{{ c.name }}</div>
      </div>
    </section>

    <div class="cat-body">
      <!-- 左侧 sidebar -->
      <aside class="cat-side">
        <div class="side-block">
          <h3 class="side-h">价格区间</h3>
          <div
            v-for="p in priceRanges"
            :key="p.key"
            class="side-item"
            :class="{ active: priceRange === p.key }"
            @click="pickPrice(p.key)"
          >{{ p.label }}</div>
        </div>

        <div class="side-block">
          <h3 class="side-h">筛选</h3>
          <label class="side-check">
            <input type="checkbox" :checked="showOnlyStock" @change="toggleStock" />
            <span>仅显示有货</span>
          </label>
        </div>

        <div class="side-block side-tip">
          <h3 class="side-h">客服</h3>
          <p class="side-tip-text">7×24 小时在线服务<br />满 ¥299 免邮</p>
        </div>
      </aside>

      <!-- 右侧商品 -->
      <div class="cat-main">
        <!-- 排序 -->
        <div class="sort-bar">
          <div
            v-for="s in sorts"
            :key="s.key"
            class="sort-item"
            :class="{ active: sortType === s.key }"
            @click="pickSort(s.key)"
          >{{ s.label }}</div>
        </div>

        <!-- 空态 -->
        <div v-if="!goodsList.length && !loading" class="empty">
          <div class="empty-icon">📦</div>
          <p>该分类暂无符合条件的商品</p>
        </div>

        <!-- 5 列网格 -->
        <div v-else class="grid-5">
          <div
            v-for="g in goodsList"
            :key="g.id"
            class="card"
            @click="goGoods(g.id)"
          >
            <div class="card-img-wrap">
              <img :src="fullImgUrl(g.cover)" class="card-img" loading="lazy" />
              <div class="card-badges">
                <span v-if="g.isHot" class="badge badge-hot">热卖</span>
                <span v-if="g.isNew" class="badge badge-new">新品</span>
                <span v-if="pct(g.originalPrice, g.price) > 0" class="badge badge-discount">
                  -{{ pct(g.originalPrice, g.price) }}%
                </span>
              </div>
              <div v-if="Number(g.stock) <= 0" class="oos">缺货</div>
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
                <span v-if="g.viewCount">浏览 {{ g.viewCount }}</span>
              </div>
            </div>
          </div>
        </div>

        <div v-if="loading" class="loading">加载中…</div>
        <div v-else-if="finished && goodsList.length" class="finished">— 没有更多了 —</div>
      </div>
    </div>
  </div>
  </DesktopLayout>
</template>

<style scoped>
.cat-page { background: #faf9f7; min-height: auto; padding-bottom: 0; }

/* ===== Hero ===== */
.cat-hero {
  background: linear-gradient(135deg, #f5e6d8 0%, #e8d4c4 100%);
  padding: 40px 0;
}
.cat-hero-inner {
  max-width: 1400px; margin: 0 auto; padding: 0 40px;
  display: flex; align-items: center; justify-content: space-between;
}
.cat-hero-text { color: #1a1a1a; }
.ch-tag {
  display: inline-block; padding: 4px 12px; background: #c45c4a; color: #fff;
  font-size: 11px; font-weight: 700; letter-spacing: 2px; border-radius: 4px; margin-bottom: 12px;
}
.cat-hero-text h1 { font-size: 36px; font-weight: 600; margin-bottom: 8px; letter-spacing: 1px; }
.cat-hero-text p { font-size: 14px; color: #666; }
.cat-hero-emoji { font-size: 80px; opacity: 0.5; }

/* ===== 一级 tab ===== */
.cat-tabs { background: #fff; border-bottom: 1px solid #e8e5e0; }
.cat-tabs-inner {
  max-width: 1400px; margin: 0 auto; padding: 0 40px;
  display: flex; gap: 0; overflow-x: auto; scrollbar-width: none;
}
.cat-tabs-inner::-webkit-scrollbar { display: none; }
.cat-tab {
  padding: 16px 24px; font-size: 14px; font-weight: 500; color: #666; cursor: pointer;
  white-space: nowrap; border-bottom: 2px solid transparent; transition: all 0.2s;
}
.cat-tab:hover { color: #c45c4a; }
.cat-tab.active { color: #c45c4a; border-bottom-color: #c45c4a; font-weight: 600; }

/* ===== 子分类 chip ===== */
.sub-cats { background: #faf9f7; border-bottom: 1px solid #e8e5e0; }
.sub-cats-inner {
  max-width: 1400px; margin: 0 auto; padding: 14px 40px;
  display: flex; flex-wrap: wrap; gap: 8px;
}
.sub-chip {
  padding: 6px 16px; font-size: 13px; color: #666; background: #fff; border: 1px solid #e8e5e0;
  border-radius: 16px; cursor: pointer; transition: all 0.2s;
}
.sub-chip:hover { color: #c45c4a; border-color: #c45c4a; }
.sub-chip.active { background: #1a1a1a; color: #fff; border-color: #1a1a1a; }

/* ===== Body ===== */
.cat-body { max-width: 1400px; margin: 0 auto; padding: 24px 40px; display: grid; grid-template-columns: 200px 1fr; gap: 32px; }

.cat-side { display: flex; flex-direction: column; gap: 16px; }
.side-block { background: #fff; border: 1px solid #e8e5e0; border-radius: 10px; padding: 16px; }
.side-h { font-size: 13px; font-weight: 600; color: #1a1a1a; margin-bottom: 12px; padding-bottom: 8px; border-bottom: 1px solid #f0ede8; }
.side-item {
  display: block; padding: 8px 12px; font-size: 13px; color: #666; cursor: pointer;
  border-radius: 4px; transition: all 0.2s; margin-bottom: 2px;
}
.side-item:hover { background: #f5f3f0; color: #1a1a1a; }
.side-item.active { background: #fdf5f3; color: #c45c4a; font-weight: 500; }
.side-check { display: flex; align-items: center; gap: 8px; font-size: 13px; color: #666; cursor: pointer; }
.side-check input { width: 16px; height: 16px; accent-color: #c45c4a; }
.side-tip-text { font-size: 12px; color: #999; line-height: 1.7; }

.sort-bar {
  display: flex; gap: 8px; background: #fff; border: 1px solid #e8e5e0; border-radius: 8px;
  padding: 8px; margin-bottom: 20px;
}
.sort-item {
  padding: 8px 18px; font-size: 13px; color: #666; cursor: pointer; border-radius: 6px;
  transition: all 0.2s;
}
.sort-item:hover { color: #c45c4a; }
.sort-item.active { background: #1a1a1a; color: #fff; }

.cat-main { min-width: 0; }

.grid-5 { display: grid; grid-template-columns: repeat(5, 1fr); gap: 16px; }
.card {
  background: #fff; border: 1px solid #e8e5e0; border-radius: 10px; overflow: hidden;
  cursor: pointer; transition: all 0.25s;
}
.card:hover { border-color: #c45c4a; box-shadow: 0 8px 20px rgba(0,0,0,0.08); transform: translateY(-2px); }
.card-img-wrap { position: relative; aspect-ratio: 1; background: #f5f3f0; overflow: hidden; }
.card-img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.4s; }
.card:hover .card-img { transform: scale(1.05); }
.card-badges { position: absolute; top: 8px; left: 8px; display: flex; flex-direction: column; gap: 4px; }
.badge { padding: 3px 7px; font-size: 10px; font-weight: 700; border-radius: 3px; color: #fff; }
.badge-discount { background: #c45c4a; }
.badge-hot { background: #d4920a; }
.badge-new { background: #2d8a5e; }
.oos { position: absolute; inset: 0; background: rgba(0,0,0,0.5); color: #fff; display: flex; align-items: center; justify-content: center; font-size: 18px; font-weight: 700; letter-spacing: 4px; }
.card-info { padding: 10px 12px 12px; }
.card-brand { font-size: 11px; font-weight: 600; color: #c45c4a; letter-spacing: 0.5px; margin-bottom: 4px; }
.card-name { font-size: 13px; color: #1a1a1a; line-height: 1.4; margin-bottom: 6px; min-height: 36px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
.card-price-row { display: flex; align-items: baseline; gap: 6px; margin-bottom: 4px; }
.card-price { font-size: 17px; font-weight: 700; color: #c45c4a; }
.card-orig { font-size: 11px; color: #999; text-decoration: line-through; }
.card-meta { display: flex; gap: 8px; font-size: 11px; color: #999; }

.empty { text-align: center; padding: 80px 0; color: #999; }
.empty-icon { font-size: 64px; opacity: 0.4; margin-bottom: 12px; }
.loading, .finished { text-align: center; padding: 30px 0; color: #999; font-size: 13px; }

@media (max-width: 1200px) { .grid-5 { grid-template-columns: repeat(4, 1fr); } }
@media (max-width: 768px) {
  .cat-hero-inner, .cat-tabs-inner, .sub-cats-inner, .cat-body { padding-left: 16px; padding-right: 16px; }
  .cat-body { grid-template-columns: 1fr; }
  .cat-side { flex-direction: row; overflow-x: auto; }
  .side-block { flex-shrink: 0; min-width: 160px; }
  .grid-5 { grid-template-columns: repeat(2, 1fr); }
}
</style>
