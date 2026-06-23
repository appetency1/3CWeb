<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { useCartStore } from '@/stores/cart'
import { userApi } from '@/api/user'
import { fullImgUrl } from '@/utils/img'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const cartStore = useCartStore()

const searchValue = ref('')

const userAvatar = computed(() => userStore.userInfo?.avatar || '')
const userAvatarLetter = computed(() => {
  const str = userStore.userInfo?.nickname || userStore.userInfo?.username || '?'
  return str[0].toUpperCase()
})
const cartCount = computed(() => cartStore.totalCount)

function goHome() { router.push('/') }
function goCategory(id?: number) {
  if (id) router.push(`/category/${id}`)
  else router.push('/category')
}
function goCart() {
  if (!userStore.isLoggedIn) { router.push({ name: 'login', query: { redirect: '/cart' } }); return }
  router.push('/cart')
}
function goUser() {
  if (!userStore.isLoggedIn) { router.push({ name: 'login' }); return }
  router.push('/user')
}
function goOrder() {
  if (!userStore.isLoggedIn) { router.push({ name: 'login', query: { redirect: '/order' } }); return }
  router.push('/order')
}
function goLogin() { router.push('/login') }
function onSearch() {
  if (searchValue.value.trim()) {
    router.push({ name: 'search', query: { keyword: searchValue.value } })
  }
}

// ── Canvas 粒子连线背景 ──
let canvasCtx: CanvasRenderingContext2D | null = null
let particles: any[] = []
let W = 0, H = 0
let animId = 0

class Particle {
  x: number; y: number; vx: number; vy: number; size: number
  constructor() {
    this.x = Math.random() * W
    this.y = Math.random() * H
    this.vx = (Math.random() - 0.5) * 0.3
    this.vy = (Math.random() - 0.5) * 0.3
    this.size = Math.random() * 1.5 + 0.5
  }
  update() {
    this.x += this.vx; this.y += this.vy
    if (this.x < 0 || this.x > W) this.vx *= -1
    if (this.y < 0 || this.y > H) this.vy *= -1
  }
  draw() {
    if (!canvasCtx) return
    canvasCtx.beginPath()
    canvasCtx.arc(this.x, this.y, this.size, 0, Math.PI * 2)
    canvasCtx.fillStyle = 'rgba(0,240,255,0.15)'
    canvasCtx.fill()
  }
}

function initCanvas() {
  const canvas = document.getElementById('bg-canvas') as HTMLCanvasElement
  if (!canvas) return
  canvasCtx = canvas.getContext('2d')
  if (!canvasCtx) return
  resizeCanvas()
  window.addEventListener('resize', resizeCanvas)
  for (let i = 0; i < 40; i++) particles.push(new Particle())
  animateParticles()
}

function resizeCanvas() {
  const canvas = document.getElementById('bg-canvas') as HTMLCanvasElement
  if (!canvas) return
  W = canvas.width = window.innerWidth
  H = canvas.height = window.innerHeight
}

function drawLines() {
  if (!canvasCtx) return
  for (let i = 0; i < particles.length; i++) {
    for (let j = i + 1; j < particles.length; j++) {
      const dx = particles[i].x - particles[j].x
      const dy = particles[i].y - particles[j].y
      const dist = Math.sqrt(dx * dx + dy * dy)
      if (dist < 150) {
        canvasCtx.beginPath()
        canvasCtx.moveTo(particles[i].x, particles[i].y)
        canvasCtx.lineTo(particles[j].x, particles[j].y)
        canvasCtx.strokeStyle = `rgba(0,240,255,${0.04 * (1 - dist / 150)})`
        canvasCtx.lineWidth = 0.5
        canvasCtx.stroke()
      }
    }
  }
}

function animateParticles() {
  if (!canvasCtx) return
  canvasCtx.clearRect(0, 0, W, H)
  particles.forEach(p => { p.update(); p.draw() })
  drawLines()
  animId = requestAnimationFrame(animateParticles)
}

// ── 滚动显现 IntersectionObserver ──
let revealObserver: IntersectionObserver | null = null

function initReveal() {
  revealObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible')
        revealObserver?.unobserve(entry.target)
      }
    })
  }, { threshold: 0.08 })
  // 观察所有 .reveal 元素
  document.querySelectorAll('.reveal').forEach(el => revealObserver?.observe(el))
  // 用 MutationObserver 监听动态添加的 .reveal
  const mo = new MutationObserver(() => {
    document.querySelectorAll('.reveal:not(._observed)').forEach(el => {
      el.classList.add('_observed')
      revealObserver?.observe(el)
    })
  })
  mo.observe(document.body, { childList: true, subtree: true })
}

onMounted(async () => {
  if (userStore.isLoggedIn && !userStore.userInfo) {
    try { const info: any = await userApi.info(); userStore.setUserInfo(info) } catch { /* 静默 */ }
  }
  initCanvas()
  initReveal()
})

onUnmounted(() => {
  cancelAnimationFrame(animId)
})

function isActive(name: string) {
  return route.name === name || route.path.includes('/' + name)
}
function isCategoryActive(id: number) {
  const catId = Number(route.params.id)
  return (route.name === 'category' || route.name === 'categoryGoods') && catId === id
}
</script>

<template>
  <div class="nexus-app">
    <!-- Canvas 粒子背景 -->
    <canvas id="bg-canvas"></canvas>

    <!-- 顶部通知条 -->
    <div class="topbar">
      <span class="topbar-text">新用户首单立减 <strong>¥50</strong> · 全场满 <strong>¥299</strong> 包邮 · 7天无理由退换</span>
    </div>

    <!-- 导航栏 -->
    <header class="navbar">
      <div class="nav-inner">
        <div class="nav-left">
          <div class="logo" @click="goHome">
            <div class="logo-mark">M<div class="logo-shine"></div></div>
            <span class="logo-text">NEXUS</span>
          </div>
          <ul class="nav-menu">
            <li><a :class="{ active: isActive('home') }" @click="goHome">首页</a></li>
            <li><a :class="{ active: isCategoryActive(1) }" @click="goCategory(1)">手机通讯</a></li>
            <li><a :class="{ active: isCategoryActive(2) }" @click="goCategory(2)">电脑办公</a></li>
            <li><a :class="{ active: isCategoryActive(3) }" @click="goCategory(3)">数码影音</a></li>
            <li><a :class="{ active: isCategoryActive(4) }" @click="goCategory(4)">智能穿戴</a></li>
            <li><a :class="{ active: isActive('service') }" @click="router.push('/service')">AI客服</a></li>
          </ul>
        </div>
        <div class="nav-right">
          <div class="search-box">
            <span class="search-glow-tl"></span>
            <span class="search-glow-br"></span>
            <div class="search-inner">
              <span class="search-sweep"></span>
              <span class="search-icon">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                  <circle cx="11" cy="11" r="8"/>
                  <path d="m21 21-4.35-4.35"/>
                </svg>
              </span>
              <input v-model="searchValue" placeholder="搜索数码好物..." @keyup.enter="onSearch" />
              <button class="search-btn" @click="onSearch">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                  <circle cx="11" cy="11" r="8"/>
                  <path d="m21 21-4.35-4.35"/>
                </svg>
              </button>
            </div>
          </div>
          <div class="nav-icon" title="购物车" @click="goCart">
            🛒<span v-if="cartCount > 0" class="badge">{{ cartCount }}</span>
          </div>
          <div class="nav-icon" title="我的订单" @click="goOrder">📋</div>
          <div v-if="userStore.isLoggedIn" class="nav-user" @click="goUser">
            <img v-if="userAvatar" :src="fullImgUrl(userAvatar)" class="nav-avatar-img" />
            <div v-else class="nav-avatar">{{ userAvatarLetter }}</div>
          </div>
          <button v-else class="nav-login-btn" @click="goLogin">登录</button>
        </div>
      </div>
    </header>

    <!-- 主内容 -->
    <main class="nexus-main">
      <slot />
    </main>

    <!-- 页脚 -->
    <footer class="footer">
      <div class="footer-inner">
        <div class="footer-brand">
          <div class="logo" style="margin-bottom:12px">
            <div class="logo-mark">M</div>
            <span class="logo-text">MAISON</span>
          </div>
          <p>探索前沿科技，定义数字生活。精选全球优质数码品牌，为你带来高效智能的科技体验。</p>
          <div class="social"><a>微</a><a>博</a><a>知</a><a>B</a></div>
        </div>
        <div>
          <h4>购物指南</h4>
          <ul><li>购物流程</li><li>会员介绍</li><li>常见问题</li><li>联系客服</li></ul>
        </div>
        <div>
          <h4>配送与售后</h4>
          <ul><li>配送方式</li><li>运费标准</li><li>退换货政策</li><li>退款说明</li></ul>
        </div>
        <div>
          <h4>关于我们</h4>
          <ul><li>品牌故事</li><li>加入我们</li><li>商务合作</li><li>隐私政策</li></ul>
        </div>
      </div>
      <div class="footer-bottom">
        <span class="typewriter">NEXUS &copy; 2026 // ALL SYSTEMS OPERATIONAL</span>
        <span>DESIGNED FOR THE FUTURE</span>
      </div>
    </footer>
  </div>
</template>

<style scoped>
/* ── Canvas 粒子背景 ── */
#bg-canvas {
  position: fixed; inset: 0; z-index: 0; pointer-events: none;
}

.nexus-app { position: relative; z-index: 1; }

/* ── 顶部通知条 ── */
.topbar {
  position: relative; z-index: 10;
  background: linear-gradient(90deg, rgba(0,240,255,0.05), rgba(184,41,247,0.05), rgba(255,42,138,0.05));
  border-bottom: 1px solid var(--border);
  text-align: center; padding: 10px 20px;
  font-size: 12px; color: var(--text-secondary); letter-spacing: 1px;
}
.topbar strong { color: var(--accent); font-weight: 600; }

/* ── 导航栏 ── */
.navbar {
  position: sticky; top: 0; z-index: 1000;
  background: rgba(6,6,10,0.92);
  backdrop-filter: blur(20px);
  border-bottom: 1px solid var(--border);
}
.nav-inner {
  max-width: 1440px; margin: 0 auto; padding: 0 40px; height: 70px;
  display: flex; align-items: center; justify-content: space-between;
}
.nav-left { display: flex; align-items: center; gap: 48px; }
.logo {
  display: flex; align-items: center; gap: 12px; cursor: pointer;
}
.logo-mark {
  width: 42px; height: 42px; border-radius: 12px;
  background: linear-gradient(135deg, var(--accent), var(--accent-tertiary));
  display: flex; align-items: center; justify-content: center;
  font-family: 'Orbitron', sans-serif; font-weight: 700; font-size: 22px; color: #000;
  box-shadow: 0 0 28px var(--accent-glow), inset 0 1px 0 rgba(255,255,255,0.3);
  position: relative; overflow: hidden;
}
.logo-shine {
  position: absolute; inset: 0;
  background: linear-gradient(135deg, transparent 40%, rgba(255,255,255,0.3) 50%, transparent 60%);
  animation: shine 3s infinite;
}
.logo-text {
  font-family: 'Orbitron', sans-serif; font-size: 26px; font-weight: 700;
  letter-spacing: 4px;
  background: linear-gradient(135deg, var(--accent), var(--accent-tertiary), var(--accent-secondary));
  -webkit-background-clip: text; -webkit-text-fill-color: transparent;
  background-clip: text;
}
.nav-menu { display: flex; gap: 36px; list-style: none; }
.nav-menu a {
  color: var(--text-secondary); text-decoration: none; font-size: 14px; font-weight: 500;
  position: relative; padding: 6px 0; transition: color .3s; cursor: pointer;
}
.nav-menu a:hover, .nav-menu a.active { color: var(--accent); }
.nav-menu a::after {
  content: ''; position: absolute; bottom: 0; left: 0; width: 0; height: 2px;
  background: var(--accent); box-shadow: 0 0 6px var(--accent-glow);
  transition: width .3s;
}
.nav-menu a:hover::after, .nav-menu a.active::after { width: 100%; }

.nav-right { display: flex; align-items: center; gap: 20px; }
.search-box {
  position: relative;
  width: 320px;
  height: 48px;
}
.search-glow-tl, .search-glow-br {
  position: absolute;
  width: 110px; height: 90px;
  border-radius: 50%;
  filter: blur(22px);
  opacity: 0.45;
  transition: all 0.4s ease;
  pointer-events: none;
  z-index: 0;
}
.search-glow-tl { top: -14px; left: -14px; background: var(--accent-secondary); }
.search-glow-br { bottom: -14px; right: -14px; background: var(--accent-tertiary); }
.search-box:hover .search-glow-tl {
  top: 10px; left: 60px;
  opacity: 0.6;
  width: 100px; height: 70px;
}
.search-box:hover .search-glow-br {
  bottom: 10px; right: 60px;
  opacity: 0.6;
  width: 100px; height: 70px;
}
.search-inner {
  position: relative;
  width: 100%; height: 100%;
  border-radius: 12px;
  background: linear-gradient(180deg, rgba(10,10,18,0.95), rgba(5,5,8,0.98));
  border: 1px solid rgba(0,240,255,0.12);
  overflow: hidden;
  z-index: 2;
  display: flex;
  align-items: center;
  transition: all 0.3s;
}
.search-box:hover .search-inner {
  border-color: rgba(0,240,255,0.35);
  box-shadow: 0 0 40px rgba(0,240,255,0.1), inset 0 1px 0 rgba(255,255,255,0.04);
}
.search-sweep {
  position: absolute;
  top: 0; left: -140px;
  width: 100px; height: 100%;
  background: linear-gradient(90deg, transparent, rgba(0,240,255,0.18), transparent);
  transform: skewX(-20deg);
  transition: left 0.7s ease;
  pointer-events: none;
  z-index: 5;
}
.search-box:hover .search-sweep { left: calc(100% + 40px); }
.search-icon {
  position: absolute;
  left: 14px;
  color: var(--text-muted);
  font-size: 18px;
  z-index: 3;
  pointer-events: none;
  transition: color 0.3s;
}
.search-box:hover .search-icon { color: var(--accent); }
.search-inner input {
  width: 100%; height: 100%;
  background: transparent;
  border: none;
  outline: none;
  color: var(--text-primary);
  font-size: 14px;
  padding: 0 50px 0 44px;
  font-family: var(--font-body);
  position: relative;
  z-index: 3;
}
.search-inner input::placeholder { color: var(--text-muted); }
.search-btn {
  position: absolute;
  right: 6px; top: 50%; transform: translateY(-50%);
  width: 36px; height: 36px;
  border-radius: 10px;
  border: none;
  background: linear-gradient(135deg, var(--accent), var(--accent-tertiary));
  display: flex; align-items: center; justify-content: center;
  color: #000;
  cursor: pointer;
  z-index: 4;
  overflow: hidden;
  box-shadow: 0 0 16px rgba(0,240,255,0.2);
  transition: box-shadow 0.3s;
}
.search-box:hover .search-btn {
  box-shadow: 0 0 28px rgba(0,240,255,0.4), 0 0 8px var(--accent-tertiary-glow, rgba(170,136,255,0.5));
}
.search-btn::before {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.35), transparent);
  transform: translateX(-100%);
  transition: transform 0.5s;
}
.search-box:hover .search-btn::before { transform: translateX(100%); }
.nav-icon {
  width: 40px; height: 40px; border-radius: 10px;
  border: 1px solid var(--border); background: var(--bg-card);
  display: flex; align-items: center; justify-content: center;
  color: var(--text-secondary); font-size: 18px; cursor: pointer;
  transition: all .3s; position: relative;
}
.nav-icon:hover { border-color: var(--accent); color: var(--accent); box-shadow: 0 0 12px rgba(0,240,255,0.1); }
.nav-icon .badge {
  position: absolute; top: -4px; right: -4px;
  width: 18px; height: 18px; border-radius: 50%;
  background: var(--accent-secondary); color: #fff; font-size: 10px; font-weight: 700;
  display: flex; align-items: center; justify-content: center;
  box-shadow: 0 0 8px var(--accent-secondary-glow);
}
.nav-user { cursor: pointer; }
.nav-avatar, .nav-avatar-img {
  width: 36px; height: 36px; border-radius: 50%; object-fit: cover;
  border: 2px solid var(--border); transition: var(--transition);
}
.nav-avatar {
  background: linear-gradient(135deg, var(--accent), var(--accent-secondary));
  display: flex; align-items: center; justify-content: center;
  font-size: 14px; font-weight: 700; color: #000;
}
.nav-user:hover .nav-avatar, .nav-user:hover .nav-avatar-img { border-color: var(--accent); box-shadow: 0 0 10px var(--accent-glow); }
.nav-login-btn {
  padding: 8px 20px; border-radius: 8px; border: 1px solid var(--accent);
  background: transparent; color: var(--accent); font-size: 13px; font-weight: 600;
  cursor: pointer; transition: all .3s;
}
.nav-login-btn:hover { background: rgba(0,240,255,0.1); box-shadow: 0 0 12px rgba(0,240,255,0.2); }

/* ── 主内容 ── */
.nexus-main { min-height: calc(100vh - 140px); }

/* ── 页脚 ── */
.footer {
  border-top: 1px solid var(--border);
  background: var(--bg-dark);
  margin-top: 60px;
}
.footer-inner {
  max-width: 1440px; margin: 0 auto; padding: 48px 40px 32px;
  display: grid; grid-template-columns: 2fr 1fr 1fr 1fr; gap: 40px;
}
.footer-brand p { font-size: 13px; color: var(--text-muted); line-height: 1.7; max-width: 300px; }
.footer h4 { font-size: 14px; font-weight: 700; color: var(--text-primary); margin-bottom: 16px; letter-spacing: 1px; }
.footer ul { list-style: none; }
.footer ul li { font-size: 13px; color: var(--text-muted); padding: 6px 0; cursor: pointer; transition: color .2s; }
.footer ul li:hover { color: var(--accent); }
.social { display: flex; gap: 10px; margin-top: 16px; }
.social a {
  width: 34px; height: 34px; border-radius: 8px; border: 1px solid var(--border);
  display: flex; align-items: center; justify-content: center;
  font-size: 12px; color: var(--text-muted); cursor: pointer; transition: all .3s; text-decoration: none;
}
.social a:hover { border-color: var(--accent); color: var(--accent); background: rgba(0,240,255,0.05); }
.footer-bottom {
  max-width: 1440px; margin: 0 auto; padding: 16px 40px;
  border-top: 1px solid var(--border);
  display: flex; justify-content: space-between;
  font-size: 11px; color: var(--text-muted);
  font-family: 'Orbitron', sans-serif; letter-spacing: 2px;
}
.typewriter { letter-spacing: 3px; }
</style>
