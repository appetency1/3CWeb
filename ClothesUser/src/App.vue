<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useCartStore } from '@/stores/cart'

const route = useRoute()
const router = useRouter()
const cartStore = useCartStore()

// 路由转场 key，每次导航递增保证组件重建
const routeKey = ref(0)
router.afterEach(() => { routeKey.value++ })

const isDesktop = ref(window.innerWidth >= 768)

function onResize() {
  isDesktop.value = window.innerWidth >= 768
}

onMounted(() => window.addEventListener('resize', onResize))
onUnmounted(() => window.removeEventListener('resize', onResize))

// ── ClickSpark ──
let sparkCanvas: HTMLCanvasElement | null = null
let sparkCtx: CanvasRenderingContext2D | null = null
let sparkW = 0, sparkH = 0
let sparks: any[] = []
let sparkAnimId: number | null = null

const sparkConfig = {
  sparkColor: '#00f0ff',
  sparkCount: 10,
  sparkRadius: 40,
  sparkSize: 14,
  duration: 500,
}

function easeOut(t: number) {
  return t * (2 - t)
}

function sparkResize() {
  if (!sparkCanvas) return
  sparkW = window.innerWidth
  sparkH = window.innerHeight
  sparkCanvas.width = sparkW * devicePixelRatio
  sparkCanvas.height = sparkH * devicePixelRatio
  sparkCtx = sparkCanvas.getContext('2d')
  if (sparkCtx) {
    sparkCtx.scale(devicePixelRatio, devicePixelRatio)
  }
}

function sparkDraw() {
  if (!sparkCtx) return
  sparkCtx.clearRect(0, 0, sparkW, sparkH)
  const now = performance.now()
  sparks = sparks.filter(spark => {
    const elapsed = now - spark.startTime
    if (elapsed >= sparkConfig.duration) return false

    const progress = elapsed / sparkConfig.duration
    const eased = easeOut(progress)
    const distance = eased * sparkConfig.sparkRadius
    const lineLength = sparkConfig.sparkSize * (1 - eased)

    const x1 = spark.x + distance * Math.cos(spark.angle)
    const y1 = spark.y + distance * Math.sin(spark.angle)
    const x2 = spark.x + (distance + lineLength) * Math.cos(spark.angle)
    const y2 = spark.y + (distance + lineLength) * Math.sin(spark.angle)

    sparkCtx!.strokeStyle = sparkConfig.sparkColor
    sparkCtx!.lineWidth = 2
    sparkCtx!.lineCap = 'round'
    sparkCtx!.beginPath()
    sparkCtx!.moveTo(x1, y1)
    sparkCtx!.lineTo(x2, y2)
    sparkCtx!.stroke()

    return true
  })

  if (sparks.length > 0) {
    sparkAnimId = requestAnimationFrame(sparkDraw)
  } else {
    sparkAnimId = null
  }
}

function triggerSparks(x: number, y: number) {
  if (!sparkCanvas) return
  const now = performance.now()
  for (let i = 0; i < sparkConfig.sparkCount; i++) {
    sparks.push({
      x, y,
      angle: (2 * Math.PI * i) / sparkConfig.sparkCount,
      startTime: now,
    })
  }
  if (!sparkAnimId) {
    sparkAnimId = requestAnimationFrame(sparkDraw)
  }
}

function onSparkClick(e: MouseEvent) {
  triggerSparks(e.clientX, e.clientY)
}

function initSpark() {
  sparkCanvas = document.getElementById('spark-canvas') as HTMLCanvasElement
  if (!sparkCanvas) return
  sparkResize()
  window.addEventListener('resize', sparkResize)
  document.addEventListener('click', onSparkClick)
}

function cleanupSpark() {
  if (sparkAnimId) cancelAnimationFrame(sparkAnimId)
  window.removeEventListener('resize', sparkResize)
  document.removeEventListener('click', onSparkClick)
  sparkAnimId = null
  sparks = []
}

onMounted(() => {
  window.addEventListener('resize', onResize)
  if (isDesktop.value) initSpark()
})

onUnmounted(() => {
  window.removeEventListener('resize', onResize)
  cleanupSpark()
})
</script>

<template>
  <!-- ClickSpark 画布层 -->
  <canvas id="spark-canvas" class="spark-canvas"></canvas>

  <!-- Desktop Shell -->
  <template v-if="isDesktop">
    <router-view v-slot="{ Component, route }">
      <Transition name="page" mode="out-in">
        <component :is="Component" :key="routeKey" />
      </Transition>
    </router-view>
  </template>

  <!-- Mobile Shell -->
  <template v-else>
    <div class="app-shell">>
      <router-view />
      <van-tabbar
        :model-value="(['home','category','cart','user'].indexOf(String(route.name)))"
        class="app-tabbar"
        @change="(idx: number) => router.push({ name: ['home','category','cart','user'][idx] })"
      >
        <van-tabbar-item name="home" icon="home-o">首页</van-tabbar-item>
        <van-tabbar-item name="category" icon="apps-o">分类</van-tabbar-item>
        <van-tabbar-item
          name="cart"
          icon="shopping-cart-o"
          :badge="cartStore.totalCount > 0 ? cartStore.totalCount : undefined"
        >购物车</van-tabbar-item>
        <van-tabbar-item name="user" icon="user-o">我的</van-tabbar-item>
      </van-tabbar>
    </div>
  </template>
</template>

<style scoped>
.app-shell {
  min-height: 100vh;
  background: var(--cl-bg);
}
.app-tabbar {
  --van-tabbar-height: 56px;
}
</style>

<style>
/* 全局样式 — Canvas 覆盖层 */
.spark-canvas {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 9999;
}


/* 页面转场动画 */
.page-enter-active,
.page-leave-active {
  transition: all 0.3s cubic-bezier(0.22, 1, 0.36, 1);
}
.page-enter-from {
  opacity: 0;
  transform: translateY(12px);
}
.page-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}


/* 卡片点击缩放 */
.desktop-goods-card:active,
.rc-card:active,
.order-card:active,
.address-card:active,
.add-address-card:active,
.stat-card:active,
.goods-card:active {
  transform: scale(0.97) !important;
  transition: transform 0.15s cubic-bezier(0.22, 1, 0.36, 1) !important;
}

.desktop-goods-card,
.rc-card,
.order-card,
.address-card,
.add-address-card,
.stat-card,
.goods-card {
  transition: transform 0.15s cubic-bezier(0.22, 1, 0.36, 1);
  cursor: pointer;
}


/* 列表交错入场 */
@keyframes fadeSlideUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

.address-list > .address-card,
.orders-list > .order-card,
.desktop-search-results-grid > .desktop-goods-card,
.goods-grid > .goods-card,
.related-row > .rc-card {
  animation: fadeSlideUp 0.4s cubic-bezier(0.22, 1, 0.36, 1) both;
}

.address-list > .address-card:nth-child(1),
.orders-list > .order-card:nth-child(1),
.desktop-search-results-grid > .desktop-goods-card:nth-child(1),
.goods-grid > .goods-card:nth-child(1),
.related-row > .rc-card:nth-child(1) { animation-delay: 0.02s; }
.address-list > .address-card:nth-child(2),
.orders-list > .order-card:nth-child(2),
.desktop-search-results-grid > .desktop-goods-card:nth-child(2),
.goods-grid > .goods-card:nth-child(2),
.related-row > .rc-card:nth-child(2) { animation-delay: 0.06s; }
.address-list > .address-card:nth-child(3),
.orders-list > .order-card:nth-child(3),
.desktop-search-results-grid > .desktop-goods-card:nth-child(3),
.goods-grid > .goods-card:nth-child(3),
.related-row > .rc-card:nth-child(3) { animation-delay: 0.10s; }
.address-list > .address-card:nth-child(4),
.orders-list > .order-card:nth-child(4),
.desktop-search-results-grid > .desktop-goods-card:nth-child(4),
.goods-grid > .goods-card:nth-child(4),
.related-row > .rc-card:nth-child(4) { animation-delay: 0.14s; }
.address-list > .address-card:nth-child(5),
.orders-list > .order-card:nth-child(5),
.desktop-search-results-grid > .desktop-goods-card:nth-child(5),
.goods-grid > .goods-card:nth-child(5),
.related-row > .rc-card:nth-child(5) { animation-delay: 0.18s; }
.address-list > .address-card:nth-child(6),
.orders-list > .order-card:nth-child(6),
.desktop-search-results-grid > .desktop-goods-card:nth-child(6),
.goods-grid > .goods-card:nth-child(6),
.related-row > .rc-card:nth-child(6) { animation-delay: 0.22s; }
.address-list > .address-card:nth-child(7),
.orders-list > .order-card:nth-child(7),
.desktop-search-results-grid > .desktop-goods-card:nth-child(7),
.goods-grid > .goods-card:nth-child(7),
.related-row > .rc-card:nth-child(7) { animation-delay: 0.26s; }
.address-list > .address-card:nth-child(8),
.orders-list > .order-card:nth-child(8),
.desktop-search-results-grid > .desktop-goods-card:nth-child(8),
.goods-grid > .goods-card:nth-child(8),
.related-row > .rc-card:nth-child(8) { animation-delay: 0.30s; }
.address-list > .address-card:nth-child(n+9),
.orders-list > .order-card:nth-child(n+9),
.desktop-search-results-grid > .desktop-goods-card:nth-child(n+9),
.goods-grid > .goods-card:nth-child(n+9),
.related-row > .rc-card:nth-child(n+9) { animation-delay: 0.34s; }
</style>
