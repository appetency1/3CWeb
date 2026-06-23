<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { showToast, showFailToast } from 'vant'
import { useAdminStore } from '@/stores/admin'
import { post, unwrap } from '@/utils/request'

const router = useRouter()
const adminStore = useAdminStore()

const username = ref('')
const password = ref('')
const loading = ref(false)
const showPwd = ref(false)
const successShow = ref(false)

const cardRef = ref<HTMLElement | null>(null)
let tiltCleanup: (() => void) | null = null

// ── Canvas 粒子连线背景 ──
let canvasCtx: CanvasRenderingContext2D | null = null
let particles: any[] = []
let C_W = 0, C_H = 0
let animId = 0

class Particle {
  x: number; y: number; vx: number; vy: number; size: number
  constructor() {
    this.x = Math.random() * C_W
    this.y = Math.random() * C_H
    this.vx = (Math.random() - 0.5) * 0.4
    this.vy = (Math.random() - 0.5) * 0.4
    this.size = Math.random() * 1.5 + 0.5
  }
  update() {
    this.x += this.vx; this.y += this.vy
    if (this.x < 0 || this.x > C_W) this.vx *= -1
    if (this.y < 0 || this.y > C_H) this.vy *= -1
  }
  draw() {
    if (!canvasCtx) return
    canvasCtx.beginPath()
    canvasCtx.arc(this.x, this.y, this.size, 0, Math.PI * 2)
    canvasCtx.fillStyle = 'rgba(0,240,255,0.2)'
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
  for (let i = 0; i < 50; i++) particles.push(new Particle())
  animateParticles()
}

function resizeCanvas() {
  const canvas = document.getElementById('bg-canvas') as HTMLCanvasElement
  if (!canvas) return
  C_W = canvas.width = window.innerWidth
  C_H = canvas.height = window.innerHeight
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
        canvasCtx.strokeStyle = `rgba(0,240,255,${0.06 * (1 - dist / 150)})`
        canvasCtx.lineWidth = 0.5
        canvasCtx.stroke()
      }
    }
  }
}

function animateParticles() {
  if (!canvasCtx) return
  canvasCtx.clearRect(0, 0, C_W, C_H)
  particles.forEach(p => { p.update(); p.draw() })
  drawLines()
  animId = requestAnimationFrame(animateParticles)
}

async function onLogin() {
  if (!username.value || !password.value) {
    showToast('请输入管理员账号和密码')
    return
  }
  loading.value = true
  try {
    const res = await post<any>('/admin/login', {
      username: username.value, password: password.value,
    })
    const data = unwrap(res)
    adminStore.setAdminInfo(data.userInfo)
    successShow.value = true
    setTimeout(() => {
      router.replace('/dashboard')
    }, 1600)
  } catch (e: any) {
    showFailToast(e?.message || '登录失败')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  initCanvas()
  const card = cardRef.value
  if (!card) return
  const wrap = card.parentElement
  if (!wrap) return
  const onMove = (e: MouseEvent) => {
    if (window.innerWidth < 900) return
    const rect = wrap.getBoundingClientRect()
    const cx = rect.left + rect.width / 2
    const cy = rect.top + rect.height / 2
    const dx = (e.clientX - cx) / (rect.width / 2)
    const dy = (e.clientY - cy) / (rect.height / 2)
    card.style.transform = `rotateX(${dy * -4}deg) rotateY(${dx * 4}deg)`
  }
  const onLeave = () => { card.style.transform = '' }
  document.addEventListener('mousemove', onMove)
  document.addEventListener('mouseleave', onLeave)
  tiltCleanup = () => {
    document.removeEventListener('mousemove', onMove)
    document.removeEventListener('mouseleave', onLeave)
  }
})

onUnmounted(() => { tiltCleanup?.(); cancelAnimationFrame(animId) })
</script>

<template>
  <div class="stage">
    <canvas id="bg-canvas"></canvas>

    <div class="login-frame">
      <div class="brand">
        <div class="brand__logo">
          <div class="logo-mark">N<div class="logo-shine"></div></div>
          <div class="logo-text">NEXUS</div>
        </div>
        <div class="brand__tagline">ADMIN PORTAL v4</div>
        <h1 class="brand__title">管理后台<br><span class="gradient">安全登录</span></h1>
        <p class="brand__desc">NEXUS 数码科幻商城管理中心。从商品上架到订单履约，从用户洞察到数据决策，一切尽在掌控。</p>
      </div>

      <div class="card-wrap">
        <div ref="cardRef" class="login-card">
          <div class="card__header">
            <div class="card__title">欢迎回来</div>
            <div class="card__subtitle">请输入管理员账号和密码</div>
          </div>

          <form @submit.prevent="onLogin">
            <div class="field">
              <input id="f-username" v-model="username" type="text" class="field__input" placeholder=" " autocomplete="username" />
              <label for="f-username" class="field__label">账号</label>
              <div class="field__line"></div>
            </div>

            <div class="field">
              <input id="f-password" v-model="password" :type="showPwd ? 'text' : 'password'" class="field__input" placeholder=" " autocomplete="current-password" />
              <label for="f-password" class="field__label">密码</label>
              <button type="button" class="field__eye" tabindex="-1" @click="showPwd = !showPwd">
                <svg v-if="!showPwd" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                <svg v-else width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>
              </button>
              <div class="field__line"></div>
            </div>

            <button type="submit" class="login-btn">登 录</button>
          </form>

          <div class="card__footer">NEXUS ADMIN v4.0</div>
        </div>
      </div>
    </div>
  </div>

  <!-- 登录成功等待层 -->
  <div class="success" :class="{ show: successShow }">
    <div class="loader-group">
      <div class="loader">
        <svg viewBox="0 0 80 80">
          <circle r="32" cy="40" cx="40"></circle>
        </svg>
      </div>

      <div class="loader triangle">
        <svg viewBox="0 0 86 80">
          <polygon points="43 8 79 72 7 72"></polygon>
        </svg>
      </div>

      <div class="loader">
        <svg viewBox="0 0 80 80">
          <rect height="64" width="64" y="8" x="8"></rect>
        </svg>
      </div>
    </div>

    <div class="success__text">登录成功，正在进入管理后台…</div>
  </div>
</template>


<style scoped>
/* ── Canvas 粒子背景 ── */
#bg-canvas {
  position: fixed; inset: 0; z-index: 0; pointer-events: none;
}

.stage {
  position: relative; z-index: 2;
  width: 100%; height: 100%;
  display: flex; align-items: center; justify-content: center;
  padding: 40px;
  background: var(--bg);
  color: var(--text);
  font-family: var(--font-body);
  overflow: hidden;
  -webkit-font-smoothing: antialiased;
}

.login-frame {
  position: relative;
  width: 100%; max-width: 1100px;
  display: grid;
  grid-template-columns: 1.1fr 0.9fr;
  gap: 80px;
  align-items: center;
}

/* -- 左侧品牌 -- */
.brand {
  opacity: 0;
  transform: translateY(30px);
  animation: rise 1s var(--ease-out) 0.1s forwards;
}

.brand__logo {
  display: flex; align-items: center; gap: 16px;
  margin-bottom: 28px;
}
.logo-mark {
  width: 52px; height: 52px; border-radius: 14px;
  background: linear-gradient(135deg, var(--neon-blue), var(--neon-violet));
  display: flex; align-items: center; justify-content: center;
  font-family: var(--font-display); font-weight: 800; font-size: 28px; color: #000;
  box-shadow: 0 0 28px var(--neon-blue-glow), inset 0 1px 0 rgba(255,255,255,0.3);
  position: relative; overflow: hidden;
}
.logo-shine {
  position: absolute; inset: 0;
  background: linear-gradient(135deg, transparent 40%, rgba(255,255,255,0.3) 50%, transparent 60%);
  animation: shine 3s infinite;
}
@keyframes shine {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}
.logo-text {
  font-family: var(--font-display); font-size: 38px; font-weight: 700;
  letter-spacing: 6px;
  background: linear-gradient(135deg, var(--neon-blue), var(--neon-violet), var(--neon-pink));
  -webkit-background-clip: text; -webkit-text-fill-color: transparent;
  background-clip: text;
}

.brand__tagline {
  font-family: var(--font-display); font-size: 13px; color: var(--text2);
  letter-spacing: 3px; margin-bottom: 20px;
}
.brand__title {
  font-size: 46px; font-weight: 700; line-height: 1.12; margin-bottom: 20px;
}
.brand__title .gradient {
  background: linear-gradient(135deg, var(--neon-blue), var(--neon-violet), var(--neon-pink), var(--neon-blue));
  background-size: 300% 300%;
  -webkit-background-clip: text; -webkit-text-fill-color: transparent;
  background-clip: text;
  animation: gradient-flow 6s ease infinite;
}
@keyframes gradient-flow {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}
.brand__desc {
  font-size: 14px; color: var(--text3); line-height: 1.8; max-width: 380px;
}

/* -- 右侧卡片 -- */
.card-wrap {
  perspective: 1200px;
  opacity: 0;
  transform: translateY(30px);
  animation: rise 1s var(--ease-out) 0.3s forwards;
}
.login-card {
  position: relative;
  padding: 52px 44px 44px;
  background: var(--bg-glass);
  border: 1px solid var(--border);
  border-radius: 24px;
  backdrop-filter: blur(24px);
  -webkit-backdrop-filter: blur(24px);
  box-shadow: 0 32px 80px rgba(0,0,0,0.4), 0 0 40px rgba(0,240,255,0.03);
  transform-style: preserve-3d;
  transition: transform 0.15s ease-out, box-shadow 0.4s var(--ease-out);
  will-change: transform;
}
.login-card::before {
  content: '';
  position: absolute; inset: 0; border-radius: 24px; padding: 1px;
  background: linear-gradient(135deg, rgba(0,240,255,0.3), transparent 40%, transparent 60%, rgba(184,41,247,0.2));
  -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask-composite: exclude;
  pointer-events: none;
}
.login-card:hover {
  box-shadow: 0 40px 100px rgba(0,0,0,0.5), 0 0 50px rgba(0,240,255,0.05);
}

.card__header { margin-bottom: 36px; }
.card__title {
  font-family: var(--font-display); font-size: 22px; font-weight: 600;
  letter-spacing: 1px; margin-bottom: 8px; color: var(--text);
}
.card__subtitle { font-size: 13px; color: var(--text2); font-weight: 300; }

/* -- 浮动标签输入框 -- */
.field { position: relative; margin-bottom: 28px; }
.field__input {
  width: 100%; height: 54px;
  padding: 18px 44px 8px 16px;
  background: rgba(255,255,255,0.03);
  border: 1px solid var(--border);
  border-radius: 12px;
  color: var(--text); font-family: inherit; font-size: 15px;
  outline: none; transition: all 0.3s var(--ease-out);
  box-sizing: border-box;
}
.field__input:hover { border-color: var(--border-hover); }
.field__input:focus {
  border-color: var(--neon-blue);
  background: rgba(0,240,255,0.04);
  box-shadow: 0 0 0 4px rgba(0,240,255,0.08);
}

.field__label {
  position: absolute; left: 16px; top: 50%; transform: translateY(-50%);
  font-size: 15px; color: var(--text3); pointer-events: none;
  transition: all 0.25s var(--ease-out); transform-origin: left top;
}
.field__input:focus + .field__label,
.field__input:not(:placeholder-shown) + .field__label {
  top: 10px; transform: translateY(0) scale(0.72);
  color: var(--neon-blue); font-weight: 600;
}

.field__line {
  position: absolute; bottom: 0; left: 50%; width: 0; height: 2px;
  background: linear-gradient(90deg, transparent, var(--neon-blue), transparent);
  border-radius: 2px;
  transition: width 0.4s var(--ease-out), left 0.4s var(--ease-out);
  pointer-events: none;
}
.field__input:focus ~ .field__line { width: calc(100% - 2px); left: 1px; }

.field__eye {
  position: absolute; right: 14px; top: 50%; transform: translateY(-50%);
  background: none; border: none; color: var(--text3); cursor: pointer;
  padding: 4px; display: flex;
  transition: color 0.3s, transform 0.2s;
}
.field__eye:hover { color: var(--text2); transform: translateY(-50%) scale(1.1); }

/* -- 登录按钮 -- */
.login-btn {
  position: relative; width: 100%; height: 52px;
  border: none; border-radius: 12px;
  font-family: inherit; font-size: 15px; font-weight: 700;
  letter-spacing: 2px; cursor: pointer; overflow: hidden;
  background: linear-gradient(135deg, var(--neon-blue), var(--neon-violet));
  color: #000;
  box-shadow: 0 0 32px rgba(0,240,255,0.25);
  transition: all .3s;
}
.login-btn::before {
  content: ''; position: absolute; top: 0; left: -100%; width: 100%; height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
  transition: left .5s;
}
.login-btn:hover::before { left: 100%; }
.login-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 48px rgba(0,240,255,0.4);
}
.login-btn:disabled { opacity: 0.5; cursor: not-allowed; }

.card__footer {
  margin-top: 28px; text-align: center;
  font-family: var(--font-display); font-size: 11px;
  color: var(--text3); letter-spacing: 2px;
}

@keyframes rise { to { opacity: 1; transform: translateY(0); } }

/* -- 登录成功等待层 -- */
.success {
  position: fixed; inset: 0; z-index: 100;
  display: flex; flex-direction: column;
  align-items: center; justify-content: center;
  background: rgba(5,5,8,0.95);
  backdrop-filter: blur(12px);
  opacity: 0; pointer-events: none;
  transition: opacity 0.5s cubic-bezier(0.22, 1, 0.36, 1);
}
.success.show { opacity: 1; pointer-events: auto; }

.success__text {
  margin-top: 80px;
  font-family: var(--font-display);
  font-size: 14px; color: var(--neon-blue);
  letter-spacing: 2px; font-weight: 500;
}

.loader-group {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 32px;
  margin-bottom: 40px;
  transform: scale(1.6);
}

.loader {
  --path: rgba(0,240,255,0.5);
  --dot: var(--neon-blue);
  --duration: 3s;
  width: 44px;
  height: 44px;
  position: relative;
  display: inline-block;
  filter: drop-shadow(0 0 6px var(--neon-blue-glow));
}

.loader:before {
  content: "";
  width: 6px;
  height: 6px;
  border-radius: 50%;
  position: absolute;
  display: block;
  background: var(--dot);
  box-shadow: 0 0 8px var(--neon-blue-glow);
  top: 37px;
  left: 19px;
  transform: translate(-18px, -18px);
  animation: dotRect var(--duration) cubic-bezier(0.785, 0.135, 0.15, 0.86) infinite;
}

.loader svg {
  display: block;
  width: 100%;
  height: 100%;
}

.loader svg rect,
.loader svg polygon,
.loader svg circle {
  fill: none;
  stroke: var(--path);
  stroke-width: 10px;
  stroke-linejoin: round;
  stroke-linecap: round;
  filter: drop-shadow(0 0 4px var(--neon-blue-glow));
}

.loader svg polygon {
  stroke-dasharray: 145 76 145 76;
  stroke-dashoffset: 0;
  animation: pathTriangle var(--duration) cubic-bezier(0.785, 0.135, 0.15, 0.86) infinite;
}

.loader svg rect {
  stroke-dasharray: 192 64 192 64;
  stroke-dashoffset: 0;
  animation: pathRect 3s cubic-bezier(0.785, 0.135, 0.15, 0.86) infinite;
}

.loader svg circle {
  stroke-dasharray: 150 50 150 50;
  stroke-dashoffset: 75;
  animation: pathCircle var(--duration) cubic-bezier(0.785, 0.135, 0.15, 0.86) infinite;
}

.loader.triangle {
  width: 48px;
}

.loader.triangle:before {
  left: 21px;
  transform: translate(-10px, -18px);
  animation: dotTriangle var(--duration) cubic-bezier(0.785, 0.135, 0.15, 0.86) infinite;
}

@keyframes pathTriangle {
  33% { stroke-dashoffset: 74; }
  66% { stroke-dashoffset: 147; }
  100% { stroke-dashoffset: 221; }
}

@keyframes dotTriangle {
  33% { transform: translate(0, 0); }
  66% { transform: translate(10px, -18px); }
  100% { transform: translate(-10px, -18px); }
}

@keyframes pathRect {
  25% { stroke-dashoffset: 64; }
  50% { stroke-dashoffset: 128; }
  75% { stroke-dashoffset: 192; }
  100% { stroke-dashoffset: 256; }
}

@keyframes dotRect {
  25% { transform: translate(0, 0); }
  50% { transform: translate(18px, -18px); }
  75% { transform: translate(0, -36px); }
  100% { transform: translate(-18px, -18px); }
}

@keyframes pathCircle {
  25% { stroke-dashoffset: 125; }
  50% { stroke-dashoffset: 175; }
  75% { stroke-dashoffset: 225; }
  100% { stroke-dashoffset: 275; }
}

@media (max-width: 900px) {
  .login-frame { grid-template-columns: 1fr; gap: 48px; text-align: center; }
  .brand__desc { margin: 0 auto; }
  .brand__title { font-size: 36px; }
  .card-wrap { max-width: 420px; margin: 0 auto; }
}

@media (max-width: 520px) {
  .stage { padding: 24px; }
  .login-card { padding: 40px 28px 32px; }
  .brand__title { font-size: 30px; }
  .logo-text { font-size: 30px; }
}
</style>
