<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { favoriteApi, type FavoriteItem } from '@/api/favorite'
import { showToast, showConfirmDialog } from 'vant'

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
    const items = res.list || []
    list.value.push(...items)
    if (list.value.length >= res.total) {
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
  <div class="favorites-page">
    <van-nav-bar title="我的收藏" left-arrow @click-left="router.back()" />

    <div v-if="list.length === 0 && !loading" class="empty">
      <van-icon name="like-o" size="64" color="#c8c9cc" />
      <p>暂无收藏</p>
    </div>

    <div v-else class="goods-grid">
      <div v-for="(item, idx) in list" :key="item.id" class="goods-card" @click="goDetail(item.goodsId)">
        <div class="img-wrap">
          <img :src="item.cover" :alt="item.name" @error="($event.target as HTMLImageElement).src='/assets/placeholders/product.jpg'" />
          <button class="fav-btn" @click.stop="removeFav(item.goodsId, idx)">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="#ee0a24" stroke="#ee0a24" stroke-width="2"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 000-7.78z"/></svg>
          </button>
        </div>
        <div class="info">
          <p class="name van-multi-ellipsis--l2">{{ item.name }}</p>
          <p class="price">¥{{ item.price }}</p>
        </div>
      </div>
    </div>

    <div v-if="loading" class="loading-more">
      <van-loading size="20">加载中...</van-loading>
    </div>
  </div>
</template>

<style scoped>
.favorites-page {
  min-height: 100vh;
  background: #f7f8fa;
}
.goods-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  padding: 12px;
}
.goods-card {
  background: #fff;
  border-radius: 8px;
  overflow: hidden;
}
.img-wrap {
  position: relative;
  width: 100%;
  aspect-ratio: 0.8;
  background: #f5f5f5;
}
.img-wrap img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.fav-btn {
  position: absolute;
  top: 6px;
  right: 6px;
  width: 32px;
  height: 32px;
  border: none;
  background: rgba(255,255,255,0.85);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}
.info {
  padding: 8px 10px 10px;
}
.name {
  font-size: 13px;
  line-height: 1.4;
  color: #323233;
  margin: 0 0 4px;
}
.price {
  font-size: 15px;
  font-weight: 600;
  color: #ee0a24;
  margin: 0;
}
.empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 0;
  color: #969799;
}
.empty p { margin-top: 12px; font-size: 14px; }
.loading-more {
  text-align: center;
  padding: 16px;
}
</style>
