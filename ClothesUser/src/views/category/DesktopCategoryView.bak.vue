<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()

// 左侧分类
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

// 商品数据
const allGoods = ref([
  { id: 1, categoryId: 1, name: '女士法式优雅连衣裙', price: 299, originalPrice: 499, cover: '/assets/products/goods-1-molan-di-mian-t.jpg', sales: 12000, isNew: true,  isHot: true },
  { id: 2, categoryId: 1, name: '商务休闲衬衫 免烫抗皱', price: 199, originalPrice: 299, cover: '/assets/products/goods-2.jpg', sales: 8562, isHot: true },
  { id: 3, categoryId: 2, name: '高腰直筒牛仔裤', price: 259, cover: '/assets/products/goods-3.jpg', sales: 5321, isNew: true },
  { id: 4, categoryId: 3, name: '复古运动休闲鞋', price: 359, cover: '/assets/products/goods-4.jpg', sales: 3210, isHot: true },
  { id: 5, categoryId: 4, name: '真皮单肩包', price: 899, originalPrice: 1299, cover: '/assets/products/goods-5.jpg', sales: 21000, isHot: true },
  { id: 6, categoryId: 5, name: '商务手提公文包', price: 1299, originalPrice: 1599, cover: '/assets/products/goods-6.jpg', sales: 2105 },
  { id: 7, categoryId: 6, name: '精致腕表 商务休闲', price: 1599, originalPrice: 2099, cover: '/assets/products/goods-7.jpg', sales: 1863 },
  { id: 8, categoryId: 1, name: '莫兰迪色系针织衫', price: 239, cover: '/assets/products/goods-8.jpg', sales: 1452, isNew: true },
  { id: 9, categoryId: 1, name: '真丝发带套装 3件装', price: 89, cover: '/assets/products/goods-9.jpg', sales: 1232, isNew: true },
  { id: 10, categoryId: 3, name: '真皮小白鞋 透气舒适', price: 459, cover: '/assets/products/goods-10.jpg', sales: 1100, isHot: true },
  { id: 11, categoryId: 2, name: '轻薄防晒衣 UPF50+', price: 99, originalPrice: 199, cover: '/assets/products/goods-11.jpg', sales: 980 },
  { id: 12, categoryId: 4, name: '复古棒球帽 刺绣字母', price: 79, cover: '/assets/products/goods-12.jpg', sales: 870, isNew: true },
  { id: 13, categoryId: 1, name: '吊带连衣裙 海边度假', price: 229, cover: '/assets/products/goods-1-molan-di-mian-t.jpg', sales: 800, isNew: true },
  { id: 14, categoryId: 5, name: '真丝睡衣套装', price: 599, originalPrice: 899, cover: '/assets/products/goods-2.jpg', sales: 720 },
  { id: 15, categoryId: 6, name: '时尚墨镜 复古圆框', price: 169, cover: '/assets/products/goods-3.jpg', sales: 650, isHot: true },
  { id: 16, categoryId: 2, name: '亚麻直筒休闲裤', price: 289, cover: '/assets/products/goods-4.jpg', sales: 580, isNew: true },
  { id: 17, categoryId: 4, name: '真皮腰带 商务百搭', price: 199, cover: '/assets/products/goods-5.jpg', sales: 510 },
  { id: 18, categoryId: 1, name: '羊绒套头毛衣', price: 459, originalPrice: 699, cover: '/assets/products/goods-6.jpg', sales: 470 },
  { id: 19, categoryId: 3, name: '透气网面跑步鞋', price: 459, cover: '/assets/products/goods-7.jpg', sales: 420, isNew: true },
  { id: 20, categoryId: 5, name: '真丝发圈套装', price: 89, cover: '/assets/products/goods-8.jpg', sales: 380 },
])

const sortType = ref('default')   // default / sales / price_asc / price_desc / new
const currentCategory = ref<number | null>(null)

const filteredGoods = computed(() => {
  let list = allGoods.value
  if (currentCategory.value) list = list.filter(g => g.categoryId === currentCategory.value)
  const arr = [...list]
  if (sortType.value === 'sales') arr.sort((a, b) => b.sales - a.sales)
  else if (sortType.value === 'price_asc') arr.sort((a, b) => a.price - b.price)
  else if (sortType.value === 'price_desc') arr.sort((a, b) => b.price - a.price)
  else if (sortType.value === 'new') arr.sort((a, b) => (b.isNew ? 1 : 0) - (a.isNew ? 1 : 0))
  return arr
})

function selectCategory(id: number | null) {
  currentCategory.value = id
  if (id) router.replace(`/Desktop/category/${id}`)
  else router.replace('/Desktop/category')
}

function goGoods(id: number) {
  router.push(`/Desktop/goods/${id}`)
}

onMounted(() => {
  const id = route.params.id
  if (id) currentCategory.value = Number(id)
})

watch(() => route.params.id, (v) => {
  currentCategory.value = v ? Number(v) : null
})
</script>

<template>
  <div class="desktop-category">
    <!-- 左侧分类 -->
    <aside class="cat-sidebar">
      <div class="sidebar-title">商品分类</div>
      <div
        :class="['cat-row', { active: currentCategory === null }]"
        @click="selectCategory(null)"
      >
        <div class="cat-row-icon"><img src="/assets/icons/cat-all.svg" alt="全部" /></div>
        <span>全部商品</span>
      </div>
      <div
        v-for="c in categories"
        :key="c.id"
        :class="['cat-row', { active: currentCategory === c.id }]"
        @click="selectCategory(c.id)"
      >
        <div class="cat-row-icon"><img :src="c.icon" :alt="c.name" /></div>
        <span>{{ c.name }}</span>
      </div>
    </aside>

    <!-- 右侧商品 -->
    <div class="cat-main">
      <div class="cat-toolbar">
        <div class="sort-list">
          <span :class="['sort-item', { active: sortType === 'default' }]" @click="sortType = 'default'">综合</span>
          <span :class="['sort-item', { active: sortType === 'sales' }]" @click="sortType = 'sales'">销量</span>
          <span :class="['sort-item', { active: sortType === 'new' }]" @click="sortType = 'new'">新品</span>
          <span :class="['sort-item', { active: sortType === 'price_asc' }]" @click="sortType = 'price_asc'">价格 ↑</span>
          <span :class="['sort-item', { active: sortType === 'price_desc' }]" @click="sortType = 'price_desc'">价格 ↓</span>
        </div>
        <div class="result-count">共 {{ filteredGoods.length }} 件商品</div>
      </div>

      <div v-if="filteredGoods.length === 0" class="empty-state">
        <div class="empty-icon">📦</div>
        <p>该分类暂无商品</p>
      </div>
      <div v-else class="cat-grid">
        <div
          v-for="g in filteredGoods"
          :key="g.id"
          class="cat-card"
          @click="goGoods(g.id)"
        >
          <div class="cat-cover">
            <img :src="g.cover" :alt="g.name" />
            <span v-if="g.isNew" class="badge new">NEW</span>
            <span v-else-if="g.isHot" class="badge hot">HOT</span>
            <span v-if="g.originalPrice" class="discount">
              {{ Math.round((1 - g.price / g.originalPrice) * 10) }}折
            </span>
          </div>
          <div class="cat-info">
            <h3 class="cat-name">{{ g.name }}</h3>
            <div class="cat-price-row">
              <span class="price-now">¥{{ g.price }}</span>
              <span v-if="g.originalPrice" class="price-old">¥{{ g.originalPrice }}</span>
            </div>
            <div class="cat-sales">已售 {{ g.sales }}</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.desktop-category {
  display: grid;
  grid-template-columns: 220px 1fr;
  gap: 20px;
}

.cat-sidebar {
  background: #fff;
  border: 1px solid #e8e5e0;
  border-radius: 12px;
  padding: 16px 12px;
  height: fit-content;
  position: sticky;
  top: 80px;
}
.sidebar-title {
  font-size: 15px;
  font-weight: 700;
  color: #1a1a1a;
  padding: 0 8px 12px;
  border-bottom: 1px solid #e8e5e0;
  margin-bottom: 8px;
}
.cat-row {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 8px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  color: #1a1a1a;
  transition: all 0.2s;
}
.cat-row:hover { background: #faf9f7; }
.cat-row.active { background: #fdf5f3; color: #c45c4a; font-weight: 600; }
.cat-row-icon {
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.cat-row-icon img { width: 22px; height: 22px; }

.cat-toolbar {
  background: #fff;
  border: 1px solid #e8e5e0;
  border-radius: 12px;
  padding: 12px 20px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}
.sort-list { display: flex; gap: 4px; }
.sort-item {
  padding: 6px 16px;
  border-radius: 6px;
  font-size: 13px;
  color: #666;
  cursor: pointer;
  transition: all 0.2s;
}
.sort-item:hover { color: #1a1a1a; }
.sort-item.active { background: #c45c4a; color: #fff; font-weight: 600; }
.result-count { font-size: 13px; color: #999; }

.empty-state { text-align: center; padding: 80px 0; color: #999; }
.empty-icon { font-size: 48px; opacity: 0.4; margin-bottom: 12px; }

.cat-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
}
.cat-card {
  background: #fff;
  border: 1px solid #e8e5e0;
  border-radius: 12px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.25s;
}
.cat-card:hover { transform: translateY(-4px); box-shadow: 0 8px 24px rgba(0,0,0,0.12); }
.cat-cover { position: relative; aspect-ratio: 1/1; background: #f5f3f0; overflow: hidden; }
.cat-cover img { width: 100%; height: 100%; object-fit: cover; }
.badge {
  position: absolute;
  top: 8px;
  left: 8px;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 10px;
  font-weight: 700;
  color: #fff;
}
.badge.new { background: #c45c4a; }
.badge.hot { background: #dc3545; }
.discount {
  position: absolute;
  top: 8px;
  right: 8px;
  background: rgba(0,0,0,0.6);
  color: #fff;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 600;
}
.cat-info { padding: 12px; }
.cat-name {
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
.cat-price-row { display: flex; align-items: baseline; gap: 8px; margin-bottom: 6px; }
.price-now { font-size: 18px; font-weight: 700; color: #c45c4a; }
.price-old { font-size: 12px; color: #999; text-decoration: line-through; }
.cat-sales { font-size: 11px; color: #999; }
</style>
