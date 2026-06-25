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

// ── 背景场景控制 ──
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
  // 加载 Three.js 背景场景
  const script = document.createElement('script')
  script.src = '/bg-scene.js'
  script.type = 'module'
  document.body.appendChild(script)

  const card = cardRef.value
  if (!card) return
  const wrap = card.parentElement
  if (!wrap) return
  const onMove = (e: MouseEvent) => {
    if (window.innerWidth < 960) return
    const rect = wrap.getBoundingClientRect()
    const x = Math.max(0, Math.min(1, (e.clientX - rect.left) / rect.width))
    const y = Math.max(0, Math.min(1, (e.clientY - rect.top) / rect.height))
    card.style.transform = `perspective(800px) rotateX(${(y - 0.5) * -20}deg) rotateY(${(x - 0.5) * 20}deg)`
    const glow = card.querySelector('.card-glow') as HTMLElement
    if (glow) {
      glow.style.background = `radial-gradient(circle at ${x * 100}% ${y * 100}%, rgba(0,240,255,0.12), rgba(184,41,247,0.06) 40%, transparent 70%)`
      glow.style.opacity = '1'
    }
  }
  const onLeave = () => {
    card.style.transform = 'perspective(800px) rotateX(0deg) rotateY(0deg)'
    const glow = card.querySelector('.card-glow') as HTMLElement
    if (glow) { glow.style.background = ''; glow.style.opacity = '0' }
  }
  wrap.addEventListener('mousemove', onMove)
  wrap.addEventListener('mouseleave', onLeave)
  tiltCleanup = () => {
    wrap.removeEventListener('mousemove', onMove)
    wrap.removeEventListener('mouseleave', onLeave)
  }
})

onUnmounted(() => { tiltCleanup?.() })
</script>

<template>
  <div id="three-bg"></div>
  <div class="scanline-overlay"></div>
  <div class="stage">
      <!-- 左侧品牌区 -->
      <div class="hero-side">
        <div class="hero-brand">
          <svg width="48" height="48" viewBox="0 0 32 32" fill="none" stroke="#00f0ff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0">
            <polygon points="16 2 28 8 28 24 16 30 4 24 4 8 16 2"/>
            <line x1="16" y1="2" x2="16" y2="30"/>
            <line x1="4" y1="8" x2="28" y2="24"/>
            <line x1="4" y1="24" x2="28" y2="8"/>
            <circle cx="16" cy="16" r="3" fill="#00f0ff" stroke="none"/>
          </svg>
          <div>
            <div class="name">NEXUS</div>
            <div class="tag">ADMIN PORTAL v4</div>
          </div>
        </div>

        <div class="hero-middle"></div>

        <div class="hero-content">
          <h1 class="hero-title">管理后台<br><span class="gradient">安全登录</span></h1>
          <p class="hero-desc">NEXUS 数码科幻商城管理中心。从商品上架到订单履约，从用户洞察到数据决策，一切尽在掌控。</p>
        </div>
      </div>

      <!-- 右侧表单区 -->
      <div class="form-side">
        <div ref="cardRef" class="login-card">
          <div class="card-glow"></div>
          <div class="card-header">
            <h2>欢迎回来</h2>
            <p>请输入管理员账号和密码</p>
          </div>

          <form @submit.prevent="onLogin">
            <div class="field">
              <input id="f-username" v-model="username" type="text" class="field-input" placeholder=" " autocomplete="username" />
              <label for="f-username" class="field-label">账号</label>
              <div class="field__line"></div>
            </div>

            <div class="field">
              <input id="f-password" v-model="password" :type="showPwd ? 'text' : 'password'" class="field-input" placeholder=" " autocomplete="current-password" />
              <label for="f-password" class="field-label">密码</label>
              <button type="button" class="field-icon" tabindex="-1" @click="showPwd = !showPwd">
                <svg v-if="!showPwd" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                <svg v-else width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>
              </button>
              <div class="field__line"></div>
            </div>

            <button type="submit" class="login-btn">登 录</button>
          </form>

          <div class="card-footer">NEXUS ADMIN v4.0</div>
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
#three-bg {
  position: fixed; inset: 0; z-index: 0;
}
#three-bg canvas {
  display: block; width: 100% !important; height: 100% !important;
}

.scanline-overlay {
  position: fixed; inset: 0; z-index: 1; pointer-events: none;
  background: repeating-linear-gradient(0deg, transparent, transparent 2px, rgba(0,240,255,0.012) 2px, rgba(0,240,255,0.012) 4px);
}

.stage {
  position: fixed; inset: 0; z-index: 2;
  display: flex;
  pointer-events: none;
  background: transparent;
  color: var(--text);
  font-family: var(--font-body);
}

/* -- 左右分栏 -- */
.hero-side {
  width: 55%; height: 100vh;
  display: flex; flex-direction: column;
  justify-content: space-between;
  align-items: flex-start;
  padding: 60px 60px 60px 80px;
  opacity: 0;
  transform: translateY(30px);
  animation: rise 1s 0.1s forwards;
  pointer-events: auto;
}
@keyframes rise { to { opacity: 1; transform: translateY(0); } }

.hero-brand { display: flex; align-items: center; gap: 14px; }
.hero-brand .mark {
  width: 44px; height: 44px; border-radius: 14px;
  background: linear-gradient(135deg, var(--neon-blue), var(--neon-violet));
  display: flex; align-items: center; justify-content: center;
  font-family: var(--font-display); font-weight: 800; font-size: 22px; color: #000;
  box-shadow: 0 0 28px var(--neon-blue-glow), inset 0 1px 0 rgba(255,255,255,0.3);
}
.hero-brand .name {
  font-family: var(--font-display); font-size: 28px; font-weight: 700;
  letter-spacing: 5px;
  background: linear-gradient(135deg, var(--neon-blue), var(--neon-violet));
  -webkit-background-clip: text; -webkit-text-fill-color: transparent;
  background-clip: text;
}
.hero-brand .tag {
  font-family: var(--font-display); font-size: 11px; color: var(--text3);
  letter-spacing: 3px; margin-top: 2px;
}

.hero-middle { flex: 1; width: 100%; position: relative; pointer-events: auto; }

.hero-title {
  font-size: 42px; font-weight: 700; line-height: 1.12; margin-bottom: 20px;
}
.hero-title .gradient {
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
.hero-desc {
  font-size: 14px; color: var(--text3); line-height: 1.8; max-width: 380px;
}

/* -- 右侧表单区 -- */
.form-side {
  width: 45%; height: 100vh;
  display: flex; align-items: center; justify-content: center;
  padding: 48px;
  opacity: 0;
  transform: translateY(30px);
  animation: rise 1s 0.3s forwards;
  pointer-events: auto;
}

.login-card {
  position: relative; z-index: 2;
  width: 100%; max-width: 400px;
  background: linear-gradient(180deg, rgba(14,14,24,0.88), rgba(8,8,14,0.95));
  border: 1px solid var(--border);
  border-radius: 24px;
  padding: 44px 36px 36px;
  backdrop-filter: blur(32px) saturate(1.2);
  box-shadow: 0 32px 96px rgba(0,0,0,0.5), 0 0 60px rgba(0,240,255,0.04), inset 0 1px 0 rgba(255,255,255,0.04);
  transform-style: preserve-3d;
  transition: transform 0.15s ease-out, box-shadow 0.4s;
  will-change: transform;
}
.login-card::before {
  content: ''; position: absolute; top: 0; left: 36px; right: 36px; height: 1px;
  background: linear-gradient(90deg, transparent, var(--neon-blue), var(--neon-violet), transparent);
  opacity: 0.6;
}

.card-glow { position: absolute; inset: 0; border-radius: 24px; pointer-events: none; z-index: 0; opacity: 0; transition: opacity 0.3s ease; }
.login-card > :not(.card-glow) { position: relative; z-index: 1; }

.card-header { margin-bottom: 32px; }
.card-header h2 {
  font-family: var(--font-display); font-size: 22px; font-weight: 700;
  letter-spacing: 2px; margin-bottom: 6px;
}
.card-header p { font-size: 13px; color: var(--text3); }

/* -- 浮动标签输入框 -- */
.field { position: relative; margin-bottom: 18px; }
.field-input {
  width: 100%; height: 54px;
  padding: 20px 46px 8px 16px;
  background: rgba(255,255,255,0.03);
  border: 1.5px solid rgba(0,240,255,0.1);
  border-radius: 14px;
  color: var(--text);
  font-family: var(--font-body);
  font-size: 14px;
  outline: none;
  transition: all 0.3s cubic-bezier(0.22, 1, 0.36, 1);
  box-sizing: border-box;
}
.field-input:hover { border-color: rgba(0,240,255,0.18); }
.field-input:focus {
  border-color: var(--neon-blue);
  background: rgba(0,240,255,0.02);
  box-shadow: 0 0 0 4px rgba(0,240,255,0.06), 0 0 24px rgba(0,240,255,0.08);
}
.field-label {
  position: absolute;
  left: 16px; top: 50%;
  transform: translateY(-50%);
  font-size: 14px; color: var(--text3);
  pointer-events: none;
  transition: all 0.25s cubic-bezier(0.22, 1, 0.36, 1);
  transform-origin: left top;
}
.field-input:focus + .field-label,
.field-input:not(:placeholder-shown) + .field-label {
  top: 10px;
  transform: translateY(0) scale(0.72);
  color: var(--neon-blue);
  font-weight: 600;
}
.field-icon {
  position: absolute;
  right: 14px; top: 50%;
  transform: translateY(-50%);
  background: none; border: none;
  color: var(--text3);
  cursor: pointer;
  padding: 4px;
  display: flex;
  transition: color 0.3s, transform 0.2s cubic-bezier(0.34, 1.56, 0.64, 1);
}
.field-icon:hover { color: var(--neon-blue); transform: translateY(-50%) scale(1.1); }

/* -- 登录按钮 -- */
.login-btn {
  width: 100%; height: 52px;
  border: none; border-radius: 16px;
  font-family: var(--font-body); font-size: 14px; font-weight: 700;
  letter-spacing: 2px; cursor: pointer;
  position: relative; overflow: hidden;
  transition: all 0.4s cubic-bezier(0.22, 1, 0.36, 1);
  color: #000;
  background: linear-gradient(135deg, var(--neon-blue), var(--neon-violet));
  box-shadow: 0 8px 32px rgba(0,240,255,0.2);
  margin-top: 8px;
}
.login-btn::before {
  content: '';
  position: absolute; inset: 0;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
  transform: translateX(-100%);
  transition: transform 0.6s;
}
.login-btn:hover::before { transform: translateX(100%); }
.login-btn:hover {
  box-shadow: 0 14px 48px rgba(0,240,255,0.35), 0 0 20px rgba(184,41,247,0.15);
  transform: translateY(-2px);
}
.login-btn:disabled { opacity: 0.5; cursor: not-allowed; }

.card-footer {
  margin-top: 24px;
  text-align: center;
  font-size: 11px; color: var(--text3);
  font-family: var(--font-display);
  letter-spacing: 2px; text-transform: uppercase;
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
  .stage { flex-direction: column; }
  .hero-side { width: 100%; height: auto; padding: 40px; justify-content: center; gap: 32px; text-align: center; align-items: center; }
  .hero-middle { display: none; }
  .hero-desc { margin: 0 auto; }
  .hero-title { font-size: 36px; }
  .form-side { width: 100%; padding: 0 24px 40px; height: auto; }
}

@media (max-width: 520px) {
  .stage { padding: 0; }
  .hero-side { padding: 32px 20px; }
  .login-card { padding: 40px 28px 32px; }
  .hero-title { font-size: 30px; }
  .hero-brand .name { font-size: 24px; }
}
</style>
