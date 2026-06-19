<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useCartStore } from '@/stores/cart'

const route = useRoute()
const router = useRouter()
const cartStore = useCartStore()

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
  sparkColor: '#c45c4a',
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
    <router-view />
  </template>

  <!-- Mobile Shell -->
  <template v-else>
    <div class="app-shell">
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
</style>
