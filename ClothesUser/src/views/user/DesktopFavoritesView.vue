<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { favoriteApi, type FavoriteItem } from '@/api/favorite'
import { showToast, showConfirmDialog } from 'vant'
import { fullImgUrl, IMG_PLACEHOLDER } from '@/utils/img'
import { useUserStore } from '@/stores/user'
import DesktopLayout from '@/components/desktop/DesktopLayout.vue'

const router = useRouter()
const userStore = useUserStore()

const list = ref<FavoriteItem[]>([])
const loading = ref(false)
const page = ref(1)
const finished = ref(false)
const activePill = ref('all')

const pills = [
  { key: 'all', label: '全部' },
  { key: 'women', label: '女装' },
  { key: 'men', label: '男装' },
  { key: 'accessories', label: '配饰' },
]

const favCount = computed(() => list.value.length)

async function onLoad() {
  if (loading.value || finished.value) return
  loading.value = true
  try {
    const res: any = await favoriteApi.list(page.value)
    const items = res?.list || res || []
    list.value.push(...items)
    if (list.value.length >= (res?.total || 0)) {
      finished.value = true
    }
    page.value++
  } catch {
    showToast('加载失败')
  } finally {
    loading.value = false
  }
}

async function removeFav(goodsId: number, index: number) {
  try {
    await showConfirmDialog({ message: '确定取消收藏？' })
    await favoriteApi.remove(goodsId)
    // 卡片移除动画
    const card = document.querySelectorAll('.fav-card')[index]
    if (card) {
      card.classList.add('removing')
      await new Promise(r => setTimeout(r, 300))
    }
    list.value.splice(index, 1)
    showToast('已取消收藏')
  } catch { /* 取消操作 */ }
}

function goDetail(id: number) {
  router.push(`/goods/${id}`)
}

function addToCart(goodsId: number) {
  // 需要登录
  if (!userStore.isLoggedIn) {
    router.push({ name: 'login', query: { redirect: '/favorites' } })
    return
  }
  // 跳转到商品详情，用户自己选规格加入购物车
  router.push(`/goods/${goodsId}`)
}

onMounted(onLoad)
</script>

<template>
  <DesktopLayout>
    <div class="fav-page">
      <!-- Page Header -->
      <div class="page-header">
        <div class="page-title-group">
          <h1>我的收藏</h1>
          <p class="page-count">你一共收藏了 <span>{{ favCount }}</span> 件心仪单品</p>
        </div>
        <div class="toolbar">
          <div class="filter-pills">
            <button
              v-for="p in pills"
              :key="p.key"
              :class="['pill', { active: activePill === p.key }]"
              @click="activePill = p.key"
            >{{ p.label }}</button>
          </div>
          <select class="sort-select">
            <option>最近收藏</option>
            <option>价格从低到高</option>
            <option>价格从高到低</option>
          </select>
        </div>
      </div>

      <!-- Empty State -->
      <div v-if="!loading && list.length === 0" class="empty-state">
        <div class="empty-heart">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
            <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>
          </svg>
        </div>
        <h2>暂无收藏</h2>
        <p>你还没有收藏任何心仪单品。浏览商城，发现属于你的风格灵感。</p>
        <button class="btn-primary" @click="router.push('/')">去发现好物</button>
      </div>

      <!-- Favorites Grid -->
      <section v-else class="fav-section">
        <div class="fav-grid">
          <div
            v-for="(item, idx) in list"
            :key="item.id"
            class="fav-card"
            :style="{ animationDelay: (idx % 4) * 0.06 + 's' }"
            @click="goDetail(item.goodsId)"
          >
            <div class="fav-visual">
              <img
                :src="fullImgUrl(item.cover)"
                :alt="item.name"
                loading="lazy"
                @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER"
              />
              <div class="fav-actions">
                <button class="action-btn" title="加入购物车" @click.stop="addToCart(item.goodsId)">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4Z"/>
                    <path d="M3 6h18"/><path d="M16 10a4 4 0 0 1-8 0"/>
                  </svg>
                </button>
                <button class="action-btn remove" title="取消收藏" @click.stop="removeFav(item.goodsId, idx)">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>
                  </svg>
                </button>
              </div>
            </div>
            <div class="fav-info">
              <div v-if="item.brand" class="fav-brand">{{ item.brand }}</div>
              <h3 class="fav-name">{{ item.name }}</h3>
              <div class="fav-meta">
                <div>
                  <span class="fav-price">¥{{ Number(item.price).toFixed(2) }}</span>
                  <span v-if="item.originalPrice" class="fav-original">¥{{ Number(item.originalPrice).toFixed(2) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div v-if="loading" class="loading-more">加载中...</div>
      </section>
    </div>
  </DesktopLayout>
</template>

<style scoped>
.fav-page {
  min-height: 100vh;
  background: #f7f5f2;
}

/* ── Page Header ── */
.page-header {
  max-width: 1400px;
  margin: 0 auto;
  padding: 48px 40px 32px;
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 40px;
}

.page-title-group h1 {
  font-family: 'Cormorant Garamond', 'Noto Serif SC', Georgia, serif;
  font-size: clamp(36px, 4vw, 52px);
  font-weight: 600;
  line-height: 1.1;
  letter-spacing: -0.5px;
  margin-bottom: 12px;
  color: #1a1a1a;
}

.page-count {
  font-size: 14px;
  color: #999;
}

.page-count span {
  color: #c45c4a;
  font-weight: 600;
}

.toolbar {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-shrink: 0;
}

.filter-pills {
  display: flex;
  gap: 10px;
}

.pill {
  padding: 10px 20px;
  border-radius: 999px;
  border: 1px solid #e8e5e0;
  background: #fff;
  color: #666;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.25s ease;
}

.pill:hover { border-color: #1a1a1a; color: #1a1a1a; }
.pill.active { background: #1a1a1a; color: #fff; border-color: #1a1a1a; }

.sort-select {
  padding: 10px 18px;
  border-radius: 999px;
  border: 1px solid #e8e5e0;
  background: #fff;
  color: #666;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  outline: none;
}

.sort-select:hover { border-color: #1a1a1a; }

/* ── Favorites Grid ── */
.fav-section {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 40px 80px;
}

.fav-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 28px;
}

.fav-card {
  background: #fff;
  border-radius: 16px;
  overflow: hidden;
  cursor: pointer;
  box-shadow: 0 4px 20px rgba(26, 26, 26, 0.04);
  border: 1px solid #e8e5e0;
  transition: transform 0.5s cubic-bezier(0.22, 1, 0.36, 1), box-shadow 0.5s cubic-bezier(0.22, 1, 0.36, 1);
  opacity: 0;
  transform: translateY(24px);
  animation: cardEnter 0.7s cubic-bezier(0.22, 1, 0.36, 1) forwards;
}

.fav-card.removing {
  transform: translateX(60px) scale(0.9);
  opacity: 0;
  transition: all 0.3s ease;
}

@keyframes cardEnter {
  to { opacity: 1; transform: translateY(0); }
}

.fav-card:hover {
  transform: translateY(-6px);
  box-shadow: 0 20px 48px rgba(26, 26, 26, 0.1);
}

/* ── Visual ── */
.fav-visual {
  position: relative;
  aspect-ratio: 3 / 4;
  overflow: hidden;
  background: #efeae4;
}

.fav-visual img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.8s cubic-bezier(0.22, 1, 0.36, 1);
}

.fav-card:hover .fav-visual img { transform: scale(1.06); }

/* ── Actions (hover reveal) ── */
.fav-actions {
  position: absolute;
  top: 14px;
  right: 14px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  transform: translateX(20px);
  opacity: 0;
  transition: all 0.35s cubic-bezier(0.22, 1, 0.36, 1);
}

.fav-card:hover .fav-actions {
  transform: translateX(0);
  opacity: 1;
}

.action-btn {
  width: 38px;
  height: 38px;
  border-radius: 50%;
  border: none;
  background: rgba(255, 255, 255, 0.95);
  color: #666;
  display: grid;
  place-items: center;
  cursor: pointer;
  box-shadow: 0 2px 12px rgba(0,0,0,0.1);
  transition: all 0.25s cubic-bezier(0.22, 1, 0.36, 1);
}

.action-btn:hover { background: #c45c4a; color: #fff; transform: scale(1.1); }
.action-btn.remove:hover { background: #c0392b; }

.action-btn svg { width: 16px; height: 16px; }

/* ── Info ── */
.fav-info { padding: 20px; }

.fav-brand {
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 1.5px;
  text-transform: uppercase;
  color: #999;
  margin-bottom: 6px;
}

.fav-name {
  font-family: 'Noto Serif SC', 'Cormorant Garamond', Georgia, serif;
  font-size: 15px;
  font-weight: 500;
  color: #1a1a1a;
  line-height: 1.5;
  margin-bottom: 14px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.fav-meta {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 12px;
}

.fav-price {
  font-size: 18px;
  font-weight: 600;
  color: #c45c4a;
  letter-spacing: -0.3px;
}

.fav-original {
  font-size: 13px;
  color: #999;
  text-decoration: line-through;
  margin-left: 8px;
}

/* ── Empty State ── */
.empty-state {
  max-width: 500px;
  margin: 60px auto 80px;
  text-align: center;
  padding: 0 24px;
}

.empty-heart {
  width: 100px;
  height: 100px;
  margin: 0 auto 28px;
  border-radius: 50%;
  background: #fdf2f0;
  display: grid;
  place-items: center;
  position: relative;
}

.empty-heart::before {
  content: '';
  position: absolute;
  inset: -14px;
  border-radius: 50%;
  border: 1px solid #fdf2f0;
  animation: pulseRing 2.5s ease-out infinite;
}

@keyframes pulseRing {
  0% { transform: scale(1); opacity: 1; }
  100% { transform: scale(1.25); opacity: 0; }
}

.empty-heart svg {
  width: 42px;
  height: 42px;
  stroke: #c45c4a;
}

.empty-state h2 {
  font-family: 'Cormorant Garamond', 'Noto Serif SC', Georgia, serif;
  font-size: 32px;
  font-weight: 600;
  margin-bottom: 10px;
  color: #1a1a1a;
}

.empty-state p {
  color: #999;
  font-size: 15px;
  margin-bottom: 28px;
  line-height: 1.8;
}

.btn-primary {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  padding: 14px 32px;
  background: #1a1a1a;
  color: #fff;
  border-radius: 999px;
  font-size: 14px;
  font-weight: 500;
  letter-spacing: 0.5px;
  transition: all 0.3s ease;
  border: none;
  cursor: pointer;
}

.btn-primary:hover {
  background: #c45c4a;
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(196, 92, 74, 0.3);
}

.loading-more {
  text-align: center;
  padding: 40px;
  color: #999;
  font-size: 14px;
}

/* ── Responsive ── */
@media (max-width: 1200px) {
  .fav-grid { grid-template-columns: repeat(3, 1fr); }
}

@media (max-width: 900px) {
  .page-header { flex-direction: column; align-items: flex-start; }
  .fav-grid { grid-template-columns: repeat(2, 1fr); gap: 20px; }
}

@media (max-width: 540px) {
  .fav-grid { grid-template-columns: 1fr; }
  .toolbar { flex-wrap: wrap; }
  .filter-pills { overflow-x: auto; width: 100%; }
}
</style>
