<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { showFailToast } from 'vant'
import { publicApi } from '@/api/public'
import { fullImgUrl } from '@/utils/img'

const route = useRoute()
const router = useRouter()

const categories = ref<any[]>([])
const activeCategoryId = ref<number | null>(null)
const goodsList = ref<any[]>([])
const loading = ref(false)
const finished = ref(false)
const page = ref(1)
const size = 20
const total = ref(0)
const sortType = ref('default')
const sorts = [
  { label: '综合', value: 'default' },
  { label: '销量', value: 'sales' },
  { label: '价格', value: 'price_asc' },
  { label: '新品', value: 'new' },
]

const currentCategoryName = computed(() => {
  const cat = categories.value.find(c => c.id === activeCategoryId.value)
  return cat?.name || '全部分类'
})

function selectCategory(id: number) {
  activeCategoryId.value = id
  goodsList.value = []
  page.value = 1
  finished.value = false
  fetchGoods()
}

function selectSort(sort: string) {
  sortType.value = sort
  goodsList.value = []
  page.value = 1
  finished.value = false
  fetchGoods()
}

async function fetchCategories() {
  try {
    const data: any = await publicApi.categories()
    categories.value = data || []
    const routeId = route.params.id
    if (routeId && !Array.isArray(routeId)) {
      const id = Number(routeId)
      const cat = (data || []).find((c: any) => c.id === id)
      if (cat) activeCategoryId.value = id
    }
    if (!activeCategoryId.value && categories.value.length) {
      activeCategoryId.value = categories.value[0]?.id || null
    }
  } catch (e: any) {
    showFailToast('分类加载失败')
  }
}

async function fetchGoods() {
  if (loading.value) return
  loading.value = true
  try {
    let sort: string | undefined
    if (sortType.value === 'price_asc') sort = 'price_asc'
    else if (sortType.value === 'sales') sort = 'sales'
    else if (sortType.value === 'new') sort = 'new'
    const data: any = await publicApi.goodsList({
      categoryId: activeCategoryId.value || undefined,
      page: page.value,
      size,
      sort,
    })
    const list = data?.list || data || []
    total.value = data?.total || 0
    if (page.value === 1) goodsList.value = list
    else goodsList.value.push(...list)
    finished.value = goodsList.value.length >= total.value
    page.value++
  } catch (e: any) {
    showFailToast('加载失败')
    finished.value = true
  } finally {
    loading.value = false
  }
}

function goGoods(id: number) {
  router.push({ name: 'goodsDetail', params: { id } })
}

onMounted(async () => {
  await fetchCategories()
  await fetchGoods()
})
</script>

<template>
  <div class="category-page">
    <!-- Header -->
    <van-nav-bar
      :title="currentCategoryName"
      left-arrow
      @click-left="router.back()"
    />

    <!-- Sort Tabs -->
    <div class="sort-bar">
      <div
        v-for="s in sorts"
        :key="s.value"
        class="sort-item"
        :class="{ active: sortType === s.value }"
        @click="selectSort(s.value)"
      >
        {{ s.label }}
        <span v-if="sortType === s.value" class="sort-arrow" />
      </div>
    </div>

    <div class="category-body">
      <!-- Left Sidebar: Categories -->
      <div class="sidebar">
        <div
          v-for="cat in categories"
          :key="cat.id"
          class="sidebar-item"
          :class="{ active: activeCategoryId === cat.id }"
          @click="selectCategory(cat.id)"
        >
          <span class="sidebar-dot" />
          {{ cat.name }}
        </div>
      </div>

      <!-- Right Content: Goods Grid -->
      <div class="content">
        <!-- Result count -->
        <div class="content-header">
          <span class="content-count">共 {{ total }} 件商品</span>
        </div>

        <!-- Empty -->
        <div v-if="!goodsList.length && !loading" class="empty-state" style="padding:48px 16px">
          <div class="empty-icon">👗</div>
          <p class="empty-state-text">该分类暂无商品</p>
        </div>

        <!-- Goods Grid -->
        <div class="goods-grid">
          <div
            v-for="(item, i) in goodsList"
            :key="item.id"
            class="goods-card animate-enter"
            :class="`animate-enter-${(i % 4) + 1}`"
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
          @load="fetchGoods"
        />
      </div>
    </div>
  </div>
</template>

<style scoped>
.category-page {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: var(--cl-bg);
}

/* Sort Bar */
.sort-bar {
  display: flex;
  background: var(--cl-bg-card);
  border-bottom: 1px solid var(--cl-border-light);
  position: sticky;
  top: 46px;
  z-index: 10;
}
.sort-item {
  flex: 1;
  text-align: center;
  font-size: 13px;
  color: var(--cl-text-secondary);
  padding: 12px 0;
  cursor: pointer;
  transition: color var(--transition-fast);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 3px;
  -webkit-tap-highlight-color: transparent;
}
.sort-item.active {
  color: var(--cl-primary);
  font-weight: 600;
}
.sort-arrow {
  width: 0;
  height: 0;
  border-left: 3px solid transparent;
  border-right: 3px solid transparent;
  border-bottom: 4px solid currentColor;
  display: inline-block;
}

/* Body */
.category-body {
  flex: 1;
  display: flex;
  overflow: hidden;
}

/* Sidebar */
.sidebar {
  width: 88px;
  flex-shrink: 0;
  background: var(--cl-bg-muted);
  overflow-y: auto;
  border-right: 1px solid var(--cl-border-light);
}
.sidebar-item {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 14px 12px;
  font-size: 13px;
  color: var(--cl-text-secondary);
  cursor: pointer;
  transition: all var(--transition-fast);
  border-left: 3px solid transparent;
  line-height: 1.3;
}
.sidebar-item.active {
  background: var(--cl-bg-card);
  color: var(--cl-primary);
  font-weight: 600;
  border-left-color: var(--cl-primary);
}
.sidebar-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: currentColor;
  opacity: 0.5;
  flex-shrink: 0;
}
.sidebar-item.active .sidebar-dot {
  opacity: 1;
}

/* Content */
.content {
  flex: 1;
  overflow-y: auto;
  padding: 8px;
}
.content-header {
  padding: 4px 4px 8px;
  display: flex;
  justify-content: flex-end;
}
.content-count {
  font-size: 11px;
  color: var(--cl-text-muted);
}

/* Goods Grid */
.goods-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 10px;
}
.goods-card {
  background: var(--cl-bg-card);
  border-radius: var(--radius-md);
  overflow: hidden;
  box-shadow: var(--shadow-xs);
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
}
.goods-card-body {
  padding: 10px;
}
.goods-card-name {
  font-size: 12px;
  color: var(--cl-text-primary);
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  margin-bottom: 6px;
}
.goods-card-bottom {
  display: flex;
  align-items: baseline;
  gap: 4px;
}
.goods-card-price {
  font-size: 14px;
  font-weight: 700;
  color: var(--cl-red);
}
.goods-card-original {
  font-size: 10px;
  color: var(--cl-text-muted);
  text-decoration: line-through;
}

/* Empty */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: var(--cl-text-muted);
}
.empty-icon {
  font-size: 48px;
  opacity: 0.4;
  margin-bottom: 12px;
}
.empty-state-text {
  font-size: 14px;
}
</style>
