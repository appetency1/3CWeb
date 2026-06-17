<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { showFailToast } from 'vant'
import { publicApi } from '@/api/public'
import { fullImgUrl } from '@/utils/img'

const router = useRouter()
const route = useRoute()

const searchValue = ref((route.query.keyword as string) || '')
const goodsList = ref<any[]>([])
const loading = ref(false)
const finished = ref(false)
const page = ref(1)
const size = 20
const total = ref(0)
const history = ref<string[]>([])
const noResult = ref(false)

const SHOW_HISTORY = computed(() => !searchValue.value && !goodsList.value.length)
const SHOW_RESULTS = computed(() => goodsList.value.length > 0 || loading.value)
const SHOW_EMPTY = computed(() => noResult.value && !loading.value && searchValue.value)

const HISTORY_KEY = 'search_history'
function loadHistory() {
  try {
    const raw = localStorage.getItem(HISTORY_KEY)
    history.value = raw ? JSON.parse(raw) : []
  } catch { history.value = [] }
}
function saveHistory(kw: string) {
  if (!kw.trim()) return
  const filtered = history.value.filter(h => h !== kw)
  history.value = [kw, ...filtered].slice(0, 10)
  localStorage.setItem(HISTORY_KEY, JSON.stringify(history.value))
}
function clearHistory() {
  history.value = []
  localStorage.removeItem(HISTORY_KEY)
}
function useKeyword(kw: string) {
  searchValue.value = kw
}

async function doSearch() {
  const kw = searchValue.value.trim()
  if (!kw) return
  saveHistory(kw)
  noResult.value = false
  goodsList.value = []
  page.value = 1
  finished.value = false
  await fetchResults()
}

async function fetchResults() {
  if (loading.value || finished.value) return
  loading.value = true
  try {
    const data: any = await publicApi.goodsList({ keyword: searchValue.value, page: page.value, size })
    const list = data?.list || data || []
    total.value = data?.total || 0
    if (page.value === 1) goodsList.value = list
    else goodsList.value.push(...list)
    noResult.value = goodsList.value.length === 0 && !loading.value
    finished.value = goodsList.value.length >= total.value
    page.value++
  } catch (e: any) {
    showFailToast('搜索失败')
    finished.value = true
  } finally {
    loading.value = false
  }
}

function goGoods(id: number) {
  router.push({ name: 'goodsDetail', params: { id } })
}

onMounted(() => {
  loadHistory()
  if (searchValue.value) doSearch()
})
</script>

<template>
  <div class="search-page">
    <!-- Search Bar -->
    <div class="search-bar">
      <div class="search-wrap">
        <van-icon name="search" class="search-icon" />
        <input
          v-model="searchValue"
          class="search-input"
          placeholder="搜索商品..."
          autofocus
          @keyup.enter="doSearch"
        />
        <van-icon
          v-if="searchValue"
          name="clear"
          class="search-clear"
          @click="searchValue = ''; goodsList = []; noResult = false"
        />
      </div>
      <span class="search-cancel" @click="router.back()">取消</span>
    </div>

    <!-- Search History -->
    <div v-if="SHOW_HISTORY" class="history-section">
      <div class="history-header">
        <span class="history-title">搜索历史</span>
        <span v-if="history.length" class="history-clear" @click="clearHistory">清空</span>
      </div>
      <div v-if="!history.length" class="empty-state" style="padding:32px 16px">
        <p class="empty-state-text">还没有搜索记录</p>
      </div>
      <div v-else class="history-tags">
        <span
          v-for="kw in history"
          :key="kw"
          class="history-tag"
          @click="useKeyword(kw)"
        >
          {{ kw }}
        </span>
      </div>

      <!-- Hot Keywords -->
      <div class="history-header" style="margin-top:20px">
        <span class="history-title">热门搜索</span>
      </div>
      <div class="history-tags">
        <span
          class="history-tag hot"
          v-for="kw in ['连衣裙', 'T恤', '牛仔裤', '外套', '卫衣', '衬衫']"
          :key="kw"
          @click="searchValue = kw; doSearch()"
        >{{ kw }}</span>
      </div>
    </div>

    <!-- Results -->
    <div v-if="SHOW_RESULTS" class="results-section">
      <div class="results-count" v-if="total">
        找到 {{ total }} 件商品
      </div>
      <div class="goods-grid">
        <div
          v-for="item in goodsList"
          :key="item.id"
          class="goods-card"
          @click="goGoods(item.id)"
        >
          <div class="goods-card-img-wrap">
            <img :src="fullImgUrl(item.cover)" class="goods-card-img" loading="lazy" />
          </div>
          <div class="goods-card-body">
            <p class="goods-card-name">{{ item.name }}</p>
            <div class="goods-card-bottom">
              <span class="goods-card-price">¥{{ item.price }}</span>
            </div>
          </div>
        </div>
      </div>
      <van-list
        v-model:loading="loading"
        :finished="finished"
        finished-text="— 没有更多了 —"
        @load="fetchResults"
      />
    </div>

    <!-- No Result -->
    <div v-if="SHOW_EMPTY" class="empty-search">
      <div class="empty-icon">🔍</div>
      <p class="empty-title">没有找到"{{ searchValue }}"相关商品</p>
      <p class="empty-sub">试试其他关键词吧</p>
    </div>
  </div>
</template>

<style scoped>
.search-page {
  min-height: 100vh;
  background: var(--cl-bg);
}

/* Search Bar */
.search-bar {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 16px;
  background: var(--cl-bg-card);
  border-bottom: 1px solid var(--cl-border-light);
  position: sticky;
  top: 0;
  z-index: 100;
}
.search-wrap {
  flex: 1;
  display: flex;
  align-items: center;
  background: var(--cl-bg-muted);
  border-radius: var(--radius-full);
  padding: 0 14px;
  height: 38px;
  gap: 8px;
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
}
.search-input::placeholder {
  color: var(--cl-text-muted);
}
.search-clear {
  color: var(--cl-text-muted);
  font-size: 14px;
  cursor: pointer;
}
.search-cancel {
  font-size: 14px;
  color: var(--cl-text-secondary);
  cursor: pointer;
  flex-shrink: 0;
}
.search-cancel:active {
  color: var(--cl-primary);
}

/* History */
.history-section {
  padding: 16px;
}
.history-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}
.history-title {
  font-size: 14px;
  font-weight: 600;
  color: var(--cl-text-primary);
}
.history-clear {
  font-size: 12px;
  color: var(--cl-text-muted);
  cursor: pointer;
}
.history-clear:active {
  color: var(--cl-red);
}
.history-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}
.history-tag {
  padding: 6px 14px;
  background: var(--cl-bg-card);
  border-radius: var(--radius-full);
  font-size: 13px;
  color: var(--cl-text-secondary);
  cursor: pointer;
  border: 1px solid var(--cl-border-light);
  transition: all var(--transition-fast);
}
.history-tag:active {
  background: var(--cl-primary);
  color: #fff;
  border-color: var(--cl-primary);
}
.history-tag.hot {
  background: rgba(217,79,79,0.06);
  color: var(--cl-red);
  border-color: rgba(217,79,79,0.2);
}

/* Results */
.results-section {
  padding: 8px;
}
.results-count {
  font-size: 12px;
  color: var(--cl-text-muted);
  padding: 6px 8px 10px;
}
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
  transition: transform var(--transition-fast);
}
.goods-card:active {
  transform: scale(0.97);
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
}
.goods-card-price {
  font-size: 14px;
  font-weight: 700;
  color: var(--cl-red);
}

/* Empty search */
.empty-search {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 80px 24px;
  color: var(--cl-text-muted);
}
.empty-icon {
  font-size: 64px;
  opacity: 0.4;
  margin-bottom: 16px;
}
.empty-title {
  font-size: 15px;
  color: var(--cl-text-secondary);
  margin-bottom: 8px;
  text-align: center;
}
.empty-sub {
  font-size: 13px;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  color: var(--cl-text-muted);
}
.empty-state-text {
  font-size: 14px;
}
</style>
