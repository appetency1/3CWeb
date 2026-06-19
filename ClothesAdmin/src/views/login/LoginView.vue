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

const cardRef = ref<HTMLElement | null>(null)
let tiltCleanup: (() => void) | null = null

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
    adminStore.setToken(data.token)
    adminStore.setAdminInfo(data.userInfo)
    router.replace('/dashboard')
  } catch (e: any) {
    showFailToast(e?.message || '登录失败')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
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

onUnmounted(() => { tiltCleanup?.() })
</script>

<template>
  <div class="stage">
    <div class="ambient">
      <div class="orb orb--1"></div>
      <div class="orb orb--2"></div>
      <div class="grain"></div>
    </div>

    <div class="login-frame">
      <div class="brand">
        <h1 class="brand__logo">Clothes<span>.</span></h1>
        <div class="brand__tagline">管理后台 · 数据总览</div>
        <p class="brand__desc">为时尚零售场景打造的轻量管理中枢。从商品上架到订单履约，从用户洞察到数据决策，一切尽在掌控。</p>
        <div class="brand__meta">
          <div class="meta-item">
            <div class="meta-num">12.8k</div>
            <div class="meta-label">商品</div>
          </div>
          <div class="meta-item">
            <div class="meta-num">3.2k</div>
            <div class="meta-label">订单</div>
          </div>
          <div class="meta-item">
            <div class="meta-num">98%</div>
            <div class="meta-label">满意度</div>
          </div>
        </div>
      </div>

      <div class="card-wrap">
        <div ref="cardRef" class="login-card">
          <div class="card__header">
            <div class="card__title">欢迎回来</div>
            <div class="card__subtitle">请输入管理员账号继续</div>
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

            <button type="submit" class="login-btn" :class="{ loading }" :disabled="loading">
              <span class="btn__bg"></span>
              <span class="btn__text">登 录</span>
              <span class="btn__spinner"><span class="spinner"></span></span>
            </button>
          </form>

          <div class="card__footer">Clothes 管理后台 v2.0</div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.stage {
  --bg: #f5f3f0;
  --bg-elevated: rgba(255,255,255,0.7);
  --border: #e8e5e0;
  --border-hover: #d0cbc4;
  --text: #1a1a1a;
  --text-secondary: #666;
  --text-muted: #999;
  --accent: #c45c4a;
  --accent-light: #e07a68;
  --gold: #c9a227;
  --ease-out: cubic-bezier(0.22, 1, 0.36, 1);
  --ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1);

  position: relative;
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px;
  background: var(--bg);
  color: var(--text);
  font-family: 'Noto Sans SC', -apple-system, sans-serif;
  overflow: hidden;
  -webkit-font-smoothing: antialiased;
}

/* ── 环境背景 ── */
.ambient {
  position: absolute;
  inset: 0;
  overflow: hidden;
  pointer-events: none;
}

.grain {
  position: absolute;
  inset: 0;
  opacity: 0.025;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.85' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E");
  mix-blend-mode: multiply;
}

.orb {
  position: absolute;
  border-radius: 50%;
  filter: blur(90px);
  opacity: 0.35;
  animation: drift 24s ease-in-out infinite alternate;
}

.orb--1 {
  width: 500px; height: 500px;
  background: radial-gradient(circle, rgba(196,92,74,0.2) 0%, transparent 70%);
  top: -100px; left: -60px;
  animation-duration: 28s;
}

.orb--2 {
  width: 420px; height: 420px;
  background: radial-gradient(circle, rgba(201,162,39,0.15) 0%, transparent 70%);
  bottom: -80px; right: -40px;
  animation-duration: 32s;
  animation-delay: -8s;
}

@keyframes drift {
  0% { transform: translate(0,0) scale(1); }
  100% { transform: translate(60px, 40px) scale(1.12); }
}

@keyframes rise { to { opacity: 1; transform: translateY(0); } }
@keyframes fadeIn { to { opacity: 1; } }

/* ── 主布局 ── */
.login-frame {
  position: relative;
  z-index: 2;
  width: 100%;
  max-width: 1100px;
  display: grid;
  grid-template-columns: 1.1fr 0.9fr;
  gap: 80px;
  align-items: center;
}

/* ── 左侧品牌 ── */
.brand { padding-right: 20px; }

.brand__logo {
  font-family: 'Cormorant Garamond', 'Noto Serif SC', Georgia, serif;
  font-size: 72px;
  font-weight: 600;
  letter-spacing: -2px;
  line-height: 1;
  margin-bottom: 20px;
  color: var(--text);
  opacity: 0;
  transform: translateY(30px);
  animation: rise 1s var(--ease-out) 0.1s forwards;
}
.brand__logo span { color: var(--accent); }

.brand__tagline {
  display: flex;
  align-items: center;
  gap: 14px;
  font-size: 15px;
  color: var(--text-secondary);
  font-weight: 300;
  margin-bottom: 36px;
  opacity: 0;
  transform: translateY(20px);
  animation: rise 0.9s var(--ease-out) 0.25s forwards;
}
.brand__tagline::before {
  content: '';
  width: 40px;
  height: 1px;
  background: linear-gradient(90deg, var(--accent), transparent);
}

.brand__desc {
  max-width: 380px;
  font-size: 14px;
  line-height: 1.9;
  color: var(--text-muted);
  font-weight: 300;
  opacity: 0;
  transform: translateY(20px);
  animation: rise 0.9s var(--ease-out) 0.4s forwards;
}

.brand__meta {
  margin-top: 56px;
  display: flex;
  gap: 48px;
  opacity: 0;
  animation: fadeIn 1s var(--ease-out) 0.8s forwards;
}

.meta-item { position: relative; }
.meta-item::after {
  content: '';
  position: absolute;
  right: -24px;
  top: 8px;
  bottom: 8px;
  width: 1px;
  background: var(--border);
}
.meta-item:last-child::after { display: none; }

.meta-num {
  font-family: 'JetBrains Mono', monospace;
  font-size: 28px;
  font-weight: 500;
  color: var(--text);
  margin-bottom: 6px;
}
.meta-label {
  font-size: 12px;
  color: var(--text-muted);
  letter-spacing: 1px;
  text-transform: uppercase;
}

/* ── 右侧卡片 ── */
.card-wrap {
  perspective: 1200px;
  opacity: 0;
  transform: translateY(30px);
  animation: rise 1s var(--ease-out) 0.3s forwards;
}

.login-card {
  position: relative;
  padding: 52px 44px 44px;
  background: var(--bg-elevated);
  border: 1px solid var(--border);
  border-radius: 24px;
  backdrop-filter: blur(24px);
  -webkit-backdrop-filter: blur(24px);
  box-shadow: 0 32px 80px rgba(0,0,0,0.06), inset 0 1px 0 rgba(255,255,255,0.8);
  transform-style: preserve-3d;
  transition: transform 0.15s ease-out, box-shadow 0.4s var(--ease-out);
  will-change: transform;
}

.login-card::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: 24px;
  padding: 1px;
  background: linear-gradient(135deg, rgba(255,255,255,0.9), transparent 40%, transparent 60%, rgba(196,92,74,0.15));
  -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask-composite: exclude;
  pointer-events: none;
}

.login-card:hover {
  box-shadow: 0 40px 100px rgba(0,0,0,0.08);
}

.card__header { margin-bottom: 36px; }
.card__title {
  font-size: 22px;
  font-weight: 500;
  margin-bottom: 8px;
  letter-spacing: 0.5px;
  color: var(--text);
}
.card__subtitle {
  font-size: 13px;
  color: var(--text-secondary);
  font-weight: 300;
}
.card__footer {
  margin-top: 28px;
  text-align: center;
  font-size: 12px;
  color: #ccc;
  letter-spacing: 0.5px;
  opacity: 0;
  animation: fadeIn 0.6s var(--ease-out) 0.85s forwards;
}

/* ── 浮动标签 ── */
.field {
  position: relative;
  margin-bottom: 28px;
  opacity: 0;
  transform: translateY(16px);
  animation: rise 0.7s var(--ease-out) forwards;
}
.field:nth-child(1) { animation-delay: 0.45s; }
.field:nth-child(2) { animation-delay: 0.55s; }

.field__input {
  width: 100%;
  height: 54px;
  padding: 18px 44px 8px 16px;
  background: rgba(26,26,26,0.02);
  border: 1px solid var(--border);
  border-radius: 12px;
  color: var(--text);
  font-family: inherit;
  font-size: 15px;
  outline: none;
  transition: all 0.3s var(--ease-out);
  box-sizing: border-box;
}
.field__input:hover { border-color: var(--border-hover); }
.field__input:focus {
  border-color: rgba(196,92,74,0.5);
  background: rgba(255,255,255,0.8);
  box-shadow: 0 0 0 4px rgba(196,92,74,0.08);
}

.field__label {
  position: absolute;
  left: 16px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 15px;
  color: var(--text-muted);
  pointer-events: none;
  transition: all 0.25s var(--ease-out);
  transform-origin: left top;
}

.field__input:focus + .field__label,
.field__input:not(:placeholder-shown) + .field__label {
  top: 10px;
  transform: translateY(0) scale(0.72);
  color: var(--accent);
  font-weight: 600;
}

.field__line {
  position: absolute;
  bottom: 0;
  left: 50%;
  width: 0;
  height: 2px;
  background: linear-gradient(90deg, transparent, var(--accent), transparent);
  border-radius: 2px;
  transition: width 0.4s var(--ease-out), left 0.4s var(--ease-out);
  pointer-events: none;
}
.field__input:focus ~ .field__line {
  width: calc(100% - 2px);
  left: 1px;
}

.field__eye {
  position: absolute;
  right: 14px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  color: var(--text-muted);
  cursor: pointer;
  padding: 4px;
  display: flex;
  transition: color 0.3s, transform 0.2s var(--ease-spring);
}
.field__eye:hover { color: var(--text-secondary); transform: translateY(-50%) scale(1.1); }

/* ── 按钮 ── */
.login-btn {
  position: relative;
  width: 100%;
  height: 52px;
  border: none;
  border-radius: 12px;
  font-family: inherit;
  font-size: 15px;
  font-weight: 500;
  letter-spacing: 1px;
  cursor: pointer;
  overflow: hidden;
  background: transparent;
  color: var(--text);
  opacity: 0;
  animation: fadeIn 0.6s var(--ease-out) 0.75s forwards;
}

.btn__bg {
  position: absolute;
  inset: 0;
  background: linear-gradient(90deg, #2a2523, #1a1a1a, #2a2523);
  background-size: 200% 100%;
  transition: background-position 0.6s, transform 0.4s var(--ease-out);
  z-index: 0;
  border-radius: 12px;
}

.login-btn::before {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.1), transparent);
  transform: translateX(-100%);
  transition: transform 0.6s var(--ease-out);
  z-index: 1;
  border-radius: 12px;
}

.login-btn:hover:not(:disabled)::before { transform: translateX(100%); }
.login-btn:hover:not(:disabled) .btn__bg {
  background-position: 100% 0;
  transform: scale(1.02);
}
.login-btn:disabled { cursor: not-allowed; }

.btn__text {
  position: relative;
  z-index: 2;
  color: #f5f3f0;
  transition: opacity 0.3s, transform 0.3s;
  display: inline-flex;
  align-items: center;
  gap: 10px;
}
.login-btn.loading .btn__text { opacity: 0; transform: translateY(-6px); }

.btn__spinner {
  position: absolute;
  left: 50%; top: 50%;
  transform: translate(-50%, -50%) scale(0.8);
  opacity: 0;
  transition: opacity 0.3s, transform 0.3s var(--ease-spring);
  z-index: 2;
}
.login-btn.loading .btn__spinner { opacity: 1; transform: translate(-50%, -50%) scale(1); }

.spinner {
  display: block;
  width: 22px; height: 22px;
  border: 2px solid rgba(255,255,255,0.2);
  border-top-color: #f5f3f0;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }

@media (max-width: 900px) {
  .login-frame { grid-template-columns: 1fr; gap: 40px; text-align: center; }
  .brand { padding-right: 0; }
  .brand__desc { margin: 0 auto; }
  .brand__meta { justify-content: center; }
  .brand__tagline { justify-content: center; }
  .brand__tagline::before { display: none; }
  .card-wrap { max-width: 420px; margin: 0 auto; }
}

@media (max-width: 520px) {
  .stage { padding: 24px; }
  .brand__logo { font-size: 52px; }
  .login-card { padding: 40px 28px 32px; }
  .brand__meta { gap: 32px; }
  .meta-item::after { right: -16px; }
}
</style>
