<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()

// 商品数据（参考 demo-new.html）
const allGoods: Record<number, any> = {
  1: {
    id: 1, name: '女士法式优雅连衣裙', price: 299, originalPrice: 499,
    cover: '/assets/products/goods-1-molan-di-mian-t.jpg',
    images: [
      '/assets/products/goods-1-molan-di-mian-t.jpg',
      '/assets/products/goods-1-molan-di-mian-t-2.jpg',
      '/assets/products/goods-1-molan-di-mian-t-3.jpg',
    ],
    sales: 12000, stock: 128, rating: 4.8,
    desc: '法式优雅设计，莫兰迪色系，2026夏季新款。',
    detail: '精选优质面料，垂感柔顺，显瘦收腰，适合通勤、约会、聚会等多种场合。',
    skus: [
      { id: 11, spec: 'S 码 · 雾霾蓝', price: 299, stock: 32, image: '/assets/products/goods-1-molan-di-mian-t.jpg' },
      { id: 12, spec: 'M 码 · 雾霾蓝', price: 299, stock: 28, image: '/assets/products/goods-1-molan-di-mian-t-2.jpg' },
      { id: 13, spec: 'L 码 · 雾霾蓝', price: 319, stock: 18, image: '/assets/products/goods-1-molan-di-mian-t-3.jpg' },
      { id: 14, spec: 'S 码 · 樱花粉', price: 299, stock: 25, image: '/assets/products/goods-1-molan-di-mian-t.jpg' },
      { id: 15, spec: 'M 码 · 樱花粉', price: 299, stock: 25, image: '/assets/products/goods-1-molan-di-mian-t-2.jpg' },
    ],
    comments: [
      { id: 1, user: '张***', avatar: '张', rating: 5, content: '面料很好，版型修身，朋友都说好看！', date: '2026-06-10', spec: 'M 码 · 雾霾蓝' },
      { id: 2, user: '李***', avatar: '李', rating: 5, content: '颜色很高级，穿上很有气质，强烈推荐。', date: '2026-06-08', spec: 'S 码 · 樱花粉' },
      { id: 3, user: '王***', avatar: '王', rating: 4, content: '尺码标准，做工精细，物流也快。', date: '2026-06-05', spec: 'L 码 · 雾霾蓝' },
    ],
  },
}

const goods = ref<any>(null)
const selectedSku = ref<any>(null)
const quantity = ref(1)
const activeTab = ref('detail')  // detail / comments / service
const currentImg = ref(0)

function load(id: number) {
  const g = allGoods[id]
  if (g) {
    goods.value = g
    selectedSku.value = g.skus[0]
  } else {
    // fallback for unknown ids - show the first one
    goods.value = allGoods[1]
    selectedSku.value = goods.value.skus[0]
  }
  quantity.value = 1
  currentImg.value = 0
}

onMounted(() => {
  const id = Number(route.params.id) || 1
  load(id)
})

watch(() => route.params.id, (v) => {
  if (v) load(Number(v))
})

const currentPrice = computed(() => selectedSku.value?.price ?? goods.value?.price)
const totalPrice = computed(() => (currentPrice.value || 0) * quantity.value)

function buyNow() {
  router.push('/Desktop/order/confirm')
}
function addCart() {
  alert('已加入购物车')
  router.push('/Desktop/cart')
}
</script>

<template>
  <div v-if="goods" class="desktop-detail">
    <!-- 面包屑 -->
    <div class="breadcrumb">
      <span @click="router.push('/Desktop')">首页</span>
      <span class="sep">/</span>
      <span @click="router.push('/Desktop/category')">商品</span>
      <span class="sep">/</span>
      <span class="current">{{ goods.name }}</span>
    </div>

    <!-- 主体 -->
    <div class="detail-main">
      <!-- 左：图片 -->
      <div class="detail-gallery">
        <div class="gallery-main">
          <img :src="goods.images[currentImg]" :alt="goods.name" />
        </div>
        <div class="gallery-thumbs">
          <div
            v-for="(img, idx) in goods.images"
            :key="idx"
            :class="['thumb', { active: idx === currentImg }]"
            @click="currentImg = idx"
          >
            <img :src="img" :alt="`图${idx + 1}`" />
          </div>
        </div>
      </div>

      <!-- 右：信息 -->
      <div class="detail-info">
        <h1 class="detail-name">{{ goods.name }}</h1>
        <div class="detail-rating">
          <span class="stars">★★★★★</span>
          <span class="rating-num">{{ goods.rating }}</span>
          <span class="sales">已售 {{ goods.sales }}</span>
        </div>

        <div class="detail-price-box">
          <div class="price-row">
            <span class="price-now">¥{{ currentPrice }}</span>
            <span v-if="goods.originalPrice" class="price-old">¥{{ goods.originalPrice }}</span>
            <span v-if="goods.originalPrice" class="discount">
              立省 ¥{{ goods.originalPrice - currentPrice }}
            </span>
          </div>
        </div>

        <div class="detail-sku">
          <div class="sku-label">规格：</div>
          <div class="sku-list">
            <div
              v-for="s in goods.skus"
              :key="s.id"
              :class="['sku-item', { active: selectedSku?.id === s.id }]"
              @click="selectedSku = s"
            >
              {{ s.spec }}
            </div>
          </div>
        </div>

        <div class="detail-qty">
          <div class="qty-label">数量：</div>
          <div class="qty-control">
            <button @click="quantity = Math.max(1, quantity - 1)">−</button>
            <input v-model.number="quantity" type="number" min="1" :max="selectedSku?.stock || 99" />
            <button @click="quantity = Math.min(selectedSku?.stock || 99, quantity + 1)">+</button>
          </div>
          <span class="stock">库存 {{ selectedSku?.stock }} 件</span>
        </div>

        <div class="detail-actions">
          <button class="btn-cart" @click="addCart">加入购物车</button>
          <button class="btn-buy" @click="buyNow">立即购买</button>
        </div>

        <div class="detail-services">
          <span>✓ 正品保证</span>
          <span>✓ 顺丰包邮</span>
          <span>✓ 7天无理由</span>
        </div>
      </div>
    </div>

    <!-- 详情区 -->
    <div class="detail-tabs">
      <div class="tabs-nav">
        <div :class="['tab', { active: activeTab === 'detail' }]" @click="activeTab = 'detail'">商品详情</div>
        <div :class="['tab', { active: activeTab === 'comments' }]" @click="activeTab = 'comments'">用户评价 ({{ goods.comments.length }})</div>
        <div :class="['tab', { active: activeTab === 'service' }]" @click="activeTab = 'service'">售后服务</div>
      </div>

      <div v-if="activeTab === 'detail'" class="tab-panel detail-panel">
        <p class="detail-intro">{{ goods.desc }}</p>
        <p class="detail-intro">{{ goods.detail }}</p>
        <div class="detail-images">
          <img v-for="(img, idx) in goods.images" :key="idx" :src="img" :alt="`详情${idx + 1}`" />
        </div>
      </div>

      <div v-if="activeTab === 'comments'" class="tab-panel">
        <div v-for="c in goods.comments" :key="c.id" class="comment-item">
          <div class="comment-head">
            <div class="comment-avatar">{{ c.avatar }}</div>
            <div>
              <div class="comment-user">{{ c.user }}</div>
              <div class="comment-meta">
                <span class="stars">★★★★★</span>
                <span class="comment-date">{{ c.date }}</span>
              </div>
            </div>
          </div>
          <div class="comment-spec">规格：{{ c.spec }}</div>
          <div class="comment-content">{{ c.content }}</div>
        </div>
      </div>

      <div v-if="activeTab === 'service'" class="tab-panel">
        <div class="service-item">
          <h4>退换货政策</h4>
          <p>支持 7 天无理由退换货，商品需保持吊牌完好。</p>
        </div>
        <div class="service-item">
          <h4>配送方式</h4>
          <p>全国大部分地区顺丰包邮，新疆/西藏等偏远地区需联系客服。</p>
        </div>
        <div class="service-item">
          <h4>品质保障</h4>
          <p>所有商品经过严格质检，确保正品。</p>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.desktop-detail { padding: 0; }

.breadcrumb {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: #999;
  margin-bottom: 16px;
}
.breadcrumb span { cursor: pointer; }
.breadcrumb span:hover { color: #c45c4a; }
.breadcrumb .sep { cursor: default; }
.breadcrumb .current { color: #1a1a1a; cursor: default; }

.detail-main {
  display: grid;
  grid-template-columns: 480px 1fr;
  gap: 32px;
  background: #fff;
  border: 1px solid #e8e5e0;
  border-radius: 12px;
  padding: 24px;
}

.gallery-main {
  width: 100%;
  aspect-ratio: 1/1;
  background: #f5f3f0;
  border-radius: 8px;
  overflow: hidden;
  margin-bottom: 12px;
}
.gallery-main img { width: 100%; height: 100%; object-fit: cover; }
.gallery-thumbs { display: flex; gap: 8px; }
.thumb {
  width: 80px;
  height: 80px;
  border-radius: 6px;
  overflow: hidden;
  border: 2px solid transparent;
  cursor: pointer;
  background: #f5f3f0;
}
.thumb img { width: 100%; height: 100%; object-fit: cover; }
.thumb.active { border-color: #c45c4a; }

.detail-name {
  font-size: 22px;
  font-weight: 700;
  color: #1a1a1a;
  line-height: 1.4;
  margin-bottom: 12px;
}
.detail-rating { display: flex; align-items: center; gap: 12px; margin-bottom: 16px; font-size: 13px; color: #999; }
.stars { color: #f5b50a; letter-spacing: 1px; }
.rating-num { color: #c45c4a; font-weight: 600; }

.detail-price-box {
  background: #fdf5f3;
  border-radius: 8px;
  padding: 16px 20px;
  margin-bottom: 20px;
}
.price-row { display: flex; align-items: baseline; gap: 12px; }
.price-now { font-size: 32px; font-weight: 700; color: #c45c4a; }
.price-old { font-size: 14px; color: #999; text-decoration: line-through; }
.discount { background: #c45c4a; color: #fff; padding: 2px 8px; border-radius: 4px; font-size: 12px; }

.detail-sku { margin-bottom: 20px; }
.sku-label, .qty-label { font-size: 13px; color: #666; margin-bottom: 8px; }
.sku-list { display: flex; flex-wrap: wrap; gap: 8px; }
.sku-item {
  padding: 8px 16px;
  border: 1px solid #e8e5e0;
  border-radius: 6px;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.2s;
}
.sku-item:hover { border-color: #c45c4a; }
.sku-item.active { border-color: #c45c4a; background: #fdf5f3; color: #c45c4a; }

.detail-qty { display: flex; align-items: center; gap: 16px; margin-bottom: 24px; }
.qty-control { display: flex; align-items: center; border: 1px solid #e8e5e0; border-radius: 6px; overflow: hidden; }
.qty-control button {
  width: 36px;
  height: 36px;
  background: #faf9f7;
  border: none;
  cursor: pointer;
  font-size: 18px;
  color: #1a1a1a;
}
.qty-control button:hover { background: #f5f3f0; }
.qty-control input {
  width: 60px;
  height: 36px;
  border: none;
  text-align: center;
  font-size: 14px;
  outline: none;
}
.stock { font-size: 12px; color: #999; }

.detail-actions { display: flex; gap: 12px; margin-bottom: 20px; }
.btn-cart, .btn-buy {
  flex: 1;
  height: 48px;
  border-radius: 8px;
  border: none;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}
.btn-cart { background: #fff5f3; color: #c45c4a; border: 1px solid #c45c4a; }
.btn-cart:hover { background: #fde8e3; }
.btn-buy { background: #c45c4a; color: #fff; }
.btn-buy:hover { background: #b04d3d; }

.detail-services { display: flex; gap: 16px; font-size: 12px; color: #999; padding-top: 16px; border-top: 1px solid #e8e5e0; }

.detail-tabs {
  background: #fff;
  border: 1px solid #e8e5e0;
  border-radius: 12px;
  margin-top: 20px;
  overflow: hidden;
}
.tabs-nav { display: flex; border-bottom: 1px solid #e8e5e0; }
.tab {
  padding: 16px 32px;
  font-size: 14px;
  color: #666;
  cursor: pointer;
  border-bottom: 2px solid transparent;
  transition: all 0.2s;
}
.tab:hover { color: #1a1a1a; }
.tab.active { color: #c45c4a; border-bottom-color: #c45c4a; font-weight: 600; }
.tab-panel { padding: 24px; }

.detail-intro { font-size: 14px; color: #1a1a1a; line-height: 1.8; margin-bottom: 12px; }
.detail-images { display: flex; flex-direction: column; gap: 8px; }
.detail-images img { width: 100%; border-radius: 8px; }

.comment-item { padding: 16px 0; border-bottom: 1px solid #e8e5e0; }
.comment-item:last-child { border-bottom: none; }
.comment-head { display: flex; gap: 12px; margin-bottom: 8px; }
.comment-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: #f5f3f0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  color: #666;
  font-weight: 600;
}
.comment-user { font-size: 13px; color: #1a1a1a; font-weight: 600; }
.comment-meta { display: flex; gap: 8px; align-items: center; margin-top: 2px; font-size: 12px; }
.comment-date { color: #999; }
.comment-spec { font-size: 12px; color: #999; margin-bottom: 6px; }
.comment-content { font-size: 14px; color: #1a1a1a; line-height: 1.6; }

.service-item { margin-bottom: 20px; }
.service-item h4 { font-size: 14px; font-weight: 600; color: #1a1a1a; margin-bottom: 6px; }
.service-item p { font-size: 13px; color: #666; line-height: 1.7; }
</style>
