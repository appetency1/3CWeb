<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showFailToast } from 'vant'
import { publicApi } from '@/api/public'
import { fullImgUrl, IMG_PLACEHOLDER } from '@/utils/img'

const router = useRouter()
const searchValue = ref((router.currentRoute.value.query.keyword as string) || '')
const goodsList = ref<any[]>([])
const recommendList = ref<any[]>([])
const loading = ref(false)
const finished = ref(false)
const page = ref(1)
const size = 20
const total = ref(0)
const history = ref<string[]>([])
const HISTORY_KEY = 'search_history'

function loadHistory() {
  try { history.value = JSON.parse(localStorage.getItem(HISTORY_KEY) || '[]') }
  catch { history.value = [] }
}
function saveHistory(kw: string) {
  if (!kw.trim()) return
  history.value = [kw, ...history.value.filter(h => h !== kw)].slice(0, 10)
  localStorage.setItem(HISTORY_KEY, JSON.stringify(history.value))
}
function clearHistory() { history.value = []; localStorage.removeItem(HISTORY_KEY) }

async function doSearch() {
  const kw = searchValue.value.trim()
  if (!kw) return
  saveHistory(kw)
  goodsList.value = []
  recommendList.value = []
  page.value = 1
  finished.value = false
  await loadGoods()
}

async function loadGoods() {
  if (loading.value) return
  loading.value = true
  try {
    const data: any = await publicApi.goodsList({ keyword: searchValue.value, page: page.value, size })
    const list = data?.list || data || []
    total.value = data?.total || 0
    if (page.value === 1) goodsList.value = list
    else goodsList.value.push(...list)
    finished.value = list.length < size
    page.value++
    // 搜索为空时加载热门推荐
    if (page.value === 2 && goodsList.value.length === 0) {
      const hot: any = await publicApi.hotGoods()
      recommendList.value = hot || []
    }
  } catch (e: any) { showFailToast('搜索失败'); finished.value = true }
  finally { loading.value = false }
}

function goGoods(id: number) { router.push({ name: 'goodsDetail', params: { id } }) }

onMounted(() => {
  loadHistory()
  if (searchValue.value) doSearch()
})
</script>

<template>
  <DesktopLayout>
    <div class="desktop-page-title">搜索商品</div>

    <div class="desktop-search-layout">
      <!-- Sidebar: History + Hot -->
      <div class="desktop-search-sidebar">
        <div class="desktop-search-sidebar-title">搜索历史</div>
        <div v-if="history.length" class="desktop-search-history">
          <span
            v-for="kw in history"
            :key="kw"
            class="desktop-search-tag"
            @click="searchValue = kw; doSearch()"
          >{{ kw }}</span>
        </div>
        <div v-else style="font-size:12px;color:#bbb;margin-bottom:16px">暂无搜索记录</div>
        <div v-if="history.length" style="text-align:right">
          <span style="font-size:12px;color:#bbb;cursor:pointer" @click="clearHistory">清空</span>
        </div>

        <div class="desktop-search-sidebar-title" style="margin-top:20px">热门搜索</div>
        <div class="desktop-search-history">
          <span
            v-for="kw in ['手机', '笔记本', '耳机', '平板', '手表', '相机']"
            :key="kw"
            class="desktop-search-tag"
            @click="searchValue = kw; doSearch()"
          >{{ kw }}</span>
        </div>
      </div>

      <!-- Results -->
      <div>
        <div v-if="total" style="font-size:13px;color:#bbb;margin-bottom:16px">
          找到 {{ total }} 件商品
        </div>

        <div v-if="!goodsList.length && !loading && searchValue" class="desktop-empty">
          <div class="empty-icon"><img src="/assets/brand/empty-search.svg" style="width:80px;height:80px" alt="" /></div>
          <p>未找到"{{ searchValue }}"相关商品</p>
          <p style="font-size:13px;color:#999;margin-top:8px">试试其他关键词，或看看下面的推荐</p>
        </div>

        <!-- 空结果推荐 -->
        <div v-if="!goodsList.length && recommendList.length && !loading" style="margin-top:20px">
          <h3 style="font-size:16px;font-weight:600;margin-bottom:16px">热门推荐</h3>
          <div class="desktop-search-results-grid">
            <a v-for="item in recommendList" :key="item.id"
              class="desktop-goods-card" href="#"
              @click.prevent="goGoods(item.id)">
              <img :src="fullImgUrl(item.cover)" class="desktop-goods-img" loading="lazy"
                @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" />
              <div class="desktop-goods-body">
                <p class="desktop-goods-name">{{ item.name }}</p>
                <div class="desktop-goods-price">
                  <span class="unit">¥</span>{{ item.minPrice || item.price }}
                  <span v-if="item.originalPrice" class="desktop-goods-original">¥{{ item.originalPrice }}</span>
                </div>
              </div>
            </a>
          </div>
        </div>

        <div v-if="!searchValue && !goodsList.length" class="desktop-empty">
          <div class="empty-icon"><img src="/assets/brand/empty-search.svg" style="width:80px;height:80px" alt="" /></div><p>输入关键词开始搜索</p>
        </div>

        <div class="desktop-search-results-grid">
          <a
            v-for="item in goodsList"
            :key="item.id"
            class="desktop-goods-card"
            href="#"
            @click.prevent="goGoods(item.id)"
          >
            <img :src="fullImgUrl(item.cover)" class="desktop-goods-img" loading="lazy" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" />
            <div class="desktop-goods-body">
              <p class="desktop-goods-name">{{ item.name }}</p>
              <div class="desktop-goods-price">
                <span class="unit">¥</span>{{ item.minPrice || item.price }}
                <span v-if="item.originalPrice" class="desktop-goods-original">¥{{ item.originalPrice }}</span>
              </div>
            </div>
          </a>
        </div>

        <div v-if="loading" style="text-align:center;padding:20px;color:#bbb;font-size:13px">加载中...</div>
        <div v-if="finished && goodsList.length" style="text-align:center;padding:20px;color:#bbb;font-size:13px">— 没有更多了 —</div>
      </div>
    </div>
  </DesktopLayout>
</template>
