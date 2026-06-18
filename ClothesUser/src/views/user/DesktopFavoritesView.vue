<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { favoriteApi, type FavoriteItem } from '@/api/favorite'
import { showToast, showConfirmDialog } from 'vant'
import { fullImgUrl, IMG_PLACEHOLDER } from '@/utils/img'
import DesktopLayout from '@/components/desktop/DesktopLayout.vue'

const router = useRouter()
const loading = ref(false)
const finished = ref(false)
const list = ref<FavoriteItem[]>([])
const page = ref(1)

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
    list.value.splice(index, 1)
    showToast('已取消收藏')
  } catch { /* 取消操作 */ }
}

function goDetail(id: number) {
  router.push(`/goods/${id}`)
}

onMounted(onLoad)
</script>

<template>
  <DesktopLayout>
    <div class="desktop-page-title">我的收藏</div>

    <div v-if="list.length === 0 && !loading" class="desktop-empty">
      <div class="empty-icon"><span>♡</span></div>
      <p>暂无收藏</p>
    </div>

    <div v-else class="fav-grid">
      <div v-for="(item, idx) in list" :key="item.id" class="fav-card" @click="goDetail(item.goodsId)">
        <div class="fav-img-wrap">
          <img :src="fullImgUrl(item.cover)" :alt="item.name" loading="lazy"
               @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" />
          <button class="fav-remove" @click.stop="removeFav(item.goodsId, idx)" title="取消收藏">✕</button>
        </div>
        <div class="fav-info">
          <p class="fav-name">{{ item.name }}</p>
          <p class="fav-price">¥{{ item.price }}</p>
        </div>
      </div>
    </div>

    <div v-if="loading" style="text-align:center;padding:40px;color:#999">加载中...</div>
  </DesktopLayout>
</template>

<style scoped>
.fav-grid {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 40px 40px;
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 20px;
}
.fav-card {
  background: #fff;
  border: 1px solid #e8e5e0;
  border-radius: 10px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.25s;
}
.fav-card:hover {
  border-color: #c45c4a;
  box-shadow: 0 8px 24px rgba(0,0,0,0.08);
  transform: translateY(-2px);
}
.fav-img-wrap {
  position: relative;
  aspect-ratio: 1;
  background: #f5f3f0;
}
.fav-img-wrap img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.fav-remove {
  position: absolute;
  top: 8px;
  right: 8px;
  width: 28px;
  height: 28px;
  border: none;
  background: rgba(0,0,0,0.5);
  color: #fff;
  border-radius: 50%;
  font-size: 13px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.2s;
}
.fav-card:hover .fav-remove {
  opacity: 1;
}
.fav-info {
  padding: 12px 14px 14px;
}
.fav-name {
  font-size: 13px;
  color: #1a1a1a;
  line-height: 1.4;
  margin: 0 0 8px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
.fav-price {
  font-size: 18px;
  font-weight: 700;
  color: #c45c4a;
  margin: 0;
}
</style>
