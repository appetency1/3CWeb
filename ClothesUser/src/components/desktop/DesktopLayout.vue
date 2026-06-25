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
            <div class="logo-mark">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <polygon points="12 2 22 7 22 17 12 22 2 17 2 7 12 2"/>
                <line x1="12" y1="2" x2="12" y2="22"/>
                <line x1="2" y1="7" x2="22" y2="17"/>
                <line x1="2" y1="17" x2="22" y2="7"/>
                <circle cx="12" cy="12" r="2" fill="#000" stroke="none"/>
              </svg>
              <div class="logo-shine"></div>
            </div>
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
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z"/>
                </svg>
              </span>
              <input v-model="searchValue" placeholder="搜索数码好物..." @keyup.enter="onSearch" />
              <button class="search-btn" @click="onSearch">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z"/>
                </svg>
              </button>
            </div>
          </div>
          <div class="nav-icon" title="购物车" @click="goCart">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
              <path d="M2.25 3h1.386c.51 0 .955.343 1.087.835l.383 1.437M7.5 14.25a3 3 0 0 0-3 3h15.75m-12.75-3h11.218c1.121-2.3 2.1-4.684 2.924-7.138a60.114 60.114 0 0 0-16.536-1.84M7.5 14.25 5.106 5.272M6 20.25a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Zm12.75 0a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Z"/>
            </svg>
            <span v-if="cartCount > 0" class="badge">{{ cartCount }}</span>
          </div>
          <div class="nav-icon" title="我的订单" @click="goOrder">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
              <path d="M9 12h3.75M9 15h3.75M9 18h3.75m3 .75H18a2.25 2.25 0 0 0 2.25-2.25V6.108c0-1.135-.845-2.098-1.976-2.192a48.424 48.424 0 0 0-1.123-.08m-5.801 0c-.065.21-.1.433-.1.664 0 .414.336.75.75.75h4.5a.75.75 0 0 0 .75-.75 2.25 2.25 0 0 0-.1-.664m-5.8 0A2.251 2.251 0 0 1 13.5 2.25H15c1.012 0 1.867.668 2.15 1.586m-5.8 0c-.376.023-.75.05-1.124.08C9.095 4.01 8.25 4.973 8.25 6.108V8.25m0 0H4.875c-.621 0-1.125.504-1.125 1.125v11.25c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125V9.375c0-.621-.504-1.125-1.125-1.125H8.25ZM6.75 12h.008v.008H6.75V12Zm0 3h.008v.008H6.75V15Zm0 3h.008v.008H6.75V18Z"/>
            </svg>
          </div>
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
            <div class="logo-mark">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <polygon points="12 2 22 7 22 17 12 22 2 17 2 7 12 2"/>
                <line x1="12" y1="2" x2="12" y2="22"/>
                <line x1="2" y1="7" x2="22" y2="17"/>
                <line x1="2" y1="17" x2="22" y2="7"/>
                <circle cx="12" cy="12" r="2" fill="#000" stroke="none"/>
              </svg>
            </div>
            <span class="logo-text">NEXUS</span>
          </div>
          <p>探索前沿科技，定义数字生活。精选全球优质数码品牌，为你带来高效智能的科技体验。</p>
          <div class="social">
            <a title="微信">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M8.691 2.188C3.891 2.188 0 5.476 0 9.53c0 2.212 1.17 4.203 3.002 5.55a.59.59 0 0 1 .213.665l-.39 1.48c-.019.07-.048.141-.048.213 0 .163.13.295.29.295a.326.326 0 0 0 .167-.054l1.903-1.114a.864.864 0 0 1 .717-.098 10.16 10.16 0 0 0 2.837.403c.276 0 .543-.027.811-.05a6.093 6.093 0 0 1-.305-1.855c0-3.564 3.348-6.456 7.473-6.456.26 0 .515.013.768.037C15.627 4.69 12.47 2.188 8.691 2.188Z"/></svg>
            </a>
            <a title="微博">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M10.098 20.323c-3.977.391-7.414-1.406-7.672-4.02-.259-2.609 2.759-5.047 6.74-5.441 3.979-.394 7.413 1.404 7.671 4.018.259 2.6-2.759 5.049-6.739 5.443zM8.594 12.78c-3.07.528-4.821 2.913-3.91 5.338.903 2.433 4.284 3.947 7.34 3.404 3.074-.545 4.833-2.932 3.935-5.336-.912-2.434-4.29-3.94-7.365-3.406zm5.299 1.084c.266.077.457.349.415.643-.033.296-.287.51-.561.482-.25-.03-.42-.265-.364-.528.058-.256.26-.395.51-.597zm-2.515.49c.284.129.458.37.388.661-.068.29-.32.48-.593.445-.255-.033-.44-.261-.386-.532.055-.273.3-.424.591-.574zm1.21 3.008c-.816.656-2.247.606-3.252.08-.434-.226-.172-.555.067-.682.44-.234 1.085-.277 1.638-.11.555.17.95.452 1.256.293.278-.14.616.116.291.419zm.224-1.33c-.999.558-2.555.52-3.586.08-.318-.135-.15-.517.066-.627.484-.245 1.145-.304 1.767-.165.621.14 1.066.44 1.427.346.351-.09.625.184.326.366z"/></svg>
            </a>
            <a title="知乎">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M17.932 16.242v-7.07h1.248V7.62h-9.14v1.552h1.2v7.07H7.897v1.552h4.775v-1.552h-1.2v-7.07h4.02v7.07h-1.2v1.552h4.775v-1.552zM8.338 3.767c-.046.053-.45.586-.898 1.185L5.413 7.09h1.196l1.288-1.504v5.727h1.294V3.767Z"/></svg>
            </a>
            <a title="B站">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M17.813 4.653h.854c1.51.054 2.769.578 3.773 1.574 1.004.995 1.524 2.249 1.56 3.76v7.36c-.036 1.51-.556 2.769-1.56 3.773s-2.262 1.524-3.773 1.56H5.333c-1.51-.036-2.769-.556-3.773-1.56S.036 18.858 0 17.347v-7.36c.036-1.511.556-2.765 1.56-3.76 1.004-.996 2.262-1.52 3.773-1.574h.774l-1.174-1.12a1.234 1.234 0 0 1-.373-.906c0-.356.124-.658.373-.907l.027-.027c.267-.249.573-.373.92-.373.347 0 .653.124.92.373L9.653 4.44c.071.071.134.142.187.213h4.267a.836.836 0 0 1 .16-.213l2.853-2.747c.267-.249.573-.373.92-.373.347 0 .662.151.929.4.267.249.391.551.391.907 0 .355-.124.657-.373.906zM5.333 7.24c-.746.018-1.373.276-1.88.773-.506.498-.769 1.13-.786 1.894v7.52c.017.764.28 1.395.786 1.893.507.498 1.134.756 1.88.773h13.334c.746-.017 1.373-.275 1.88-.773.506-.498.769-1.129.786-1.893v-7.52c-.017-.765-.28-1.396-.786-1.894-.507-.497-1.134-.755-1.88-.773zM8 11.107c.373 0 .684.124.933.373.25.249.383.569.4.96v2.453c-.017.391-.15.711-.4.96-.249.25-.56.374-.933.374s-.684-.125-.933-.373c-.25-.25-.383-.57-.4-.96V12.44c0-.373.129-.689.386-.947.258-.257.574-.386.947-.386zm8 0c.373 0 .684.124.933.373.25.249.383.569.4.96v2.453c-.017.391-.15.711-.4.96-.249.25-.56.374-.933.374s-.684-.125-.933-.373c-.25-.25-.383-.57-.4-.96V12.44c0-.373.129-.689.386-.947.258-.257.574-.386.947-.386z"/></svg>
            </a>
          </div>
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
.search-glow-tl { top: -18px; left: -18px; background: var(--accent); }
.search-glow-br { bottom: -18px; right: -18px; background: var(--neon-violet, var(--accent-tertiary)); }
.search-box:hover .search-glow-tl {
  top: -28px; left: -4px;
  opacity: 0.7;
  width: 130px; height: 90px;
}
.search-box:hover .search-glow-br {
  bottom: -28px; right: -4px;
  opacity: 0.7;
  width: 130px; height: 90px;
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
