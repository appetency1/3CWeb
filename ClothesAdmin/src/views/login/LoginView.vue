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
      username: username.value,
      password: password.value,
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
    <div class="bg-glow"></div>
    <div class="login-frame">
      <div class="brand">
        <h1 class="brand-logo">Clothes<span>.</span></h1>
        <div class="brand-tagline">管理后台 · 数据总览</div>
        <p class="brand-desc">为时尚零售场景打造的轻量管理中枢。<br>从商品上架到订单履约，从数据决策到用户洞察。</p>
        <div class="brand-meta">
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
          <div class="card-header">
            <div class="card-title">欢迎回来</div>
            <div class="card-subtitle">请输入管理员账号继续</div>
          </div>

          <form @submit.prevent="onLogin">
            <div class="field">
              <input id="f-username" v-model="username" type="text" class="field-input" placeholder=" " autocomplete="username" />
              <label for="f-username" class="field-label">账号</label>
              <div class="field-line"></div>
            </div>

            <div class="field">
              <input id="f-password" v-model="password" :type="showPwd ? 'text' : 'password'" class="field-input" placeholder=" " autocomplete="current-password" />
              <label for="f-password" class="field-label">密码</label>
              <button type="button" class="field-eye" tabindex="-1" @click="showPwd = !showPwd">
                <svg v-if="!showPwd" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                <svg v-else width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>
              </button>
              <div class="field-line"></div>
            </div>

            <button type="submit" class="login-btn" :class="{ loading }" :disabled="loading">
              <span class="btn-bg"></span>
              <span class="btn-text">登 录</span>
              <span class="btn-spinner"><span class="spinner"></span></span>
            </button>
          </form>

          <div class="card-footer">Clothes 管理后台 v2.0</div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.stage {
  --bg: #f5f3f0;
  --surface: #ffffff;
  --text: #1a1a1a;
  --text-secondary: #666;
  --text-muted: #999;
  --accent: #c45c4a;
  --accent-light: #e07a68;
  --gold: #b8963f;
  --border: #e8e5e0;
  --border-hover: #d0cbc4;
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

.bg-glow {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(ellipse at 25% 40%, rgba(196,92,74,0.07) 0%, transparent 60%),
    radial-gradient(ellipse at 75% 70%, rgba(184,150,63,0.05) 0%, transparent 50%);
  pointer-events: none;
}

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

.brand-logo {
  font-family: 'Cormorant Garamond', 'Noto Serif SC', Georgia, serif;
  font-size: 64px;
  font-weight: 600;
  letter-spacing: -2px;
  line-height: 1;
  margin-bottom: 20px;
  color: var(--text);
  opacity: 0;
  transform: translateY(24px);
  animation: rise 0.9s var(--ease-out) 0.1s forwards;
}
.brand-logo span { color: var(--accent); }

.brand-tagline {
  display: flex;
  align-items: center;
  gap: 14px;
  font-size: 14px;
  color: var(--text-secondary);
  font-weight: 300;
  margin-bottom: 32px;
  opacity: 0;
  transform: translateY(20px);
  animation: rise 0.8s var(--ease-out) 0.25s forwards;
}
.brand-tagline::before {
  content: '';
  width: 40px;
  height: 1px;
  background: linear-gradient(90deg, var(--accent), transparent);
}

.brand-desc {
  max-width: 380px;
  font-size: 14px;
  line-height: 1.9;
  color: var(--text-muted);
  font-weight: 300;
  opacity: 0;
  transform: translateY(20px);
  animation: rise 0.8s var(--ease-out) 0.4s forwards;
}

.brand-meta {
  margin-top: 56px;
  display: flex;
  gap: 48px;
  opacity: 0;
  animation: fadeIn 0.8s var(--ease-out) 0.7s forwards;
}

@keyframes fadeIn { to { opacity: 1; } }
@keyframes rise { to { opacity: 1; transform: translateY(0); } }

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
  font-size: 26px;
  font-weight: 500;
  color: var(--text);
  margin-bottom: 4px;
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
  transform: translateY(24px);
  animation: rise 0.9s var(--ease-out) 0.3s forwards;
}

.login-card {
  position: relative;
  padding: 48px 44px 40px;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 20px;
  box-shadow: 0 4px 24px rgba(0,0,0,0.04);
  transform-style: preserve-3d;
  transition: transform 0.15s ease-out, box-shadow 0.4s var(--ease-out);
  will-change: transform;
}
.login-card:hover { box-shadow: 0 12px 48px rgba(0,0,0,0.07); }

.login-card::before {
  content: '';
  position: absolute;
  left: 0;
  top: 40px;
  bottom: 40px;
  width: 2px;
  background: linear-gradient(to bottom, transparent, var(--accent) 30%, var(--gold) 70%, transparent);
}

.card-header { margin-bottom: 32px; padding-left: 4px; }
.card-title {
  font-size: 22px;
  font-weight: 600;
  color: var(--text);
  margin-bottom: 8px;
  letter-spacing: -0.3px;
}
.card-subtitle {
  font-size: 13px;
  color: var(--text-muted);
  font-weight: 300;
}
.card-footer {
  margin-top: 24px;
  text-align: center;
  font-size: 12px;
  color: #ccc;
  letter-spacing: 0.5px;
}

/* ── 浮动标签输入框 ── */
.field {
  position: relative;
  margin-bottom: 28px;
  padding-left: 4px;
  opacity: 0;
  transform: translateY(12px);
  animation: rise 0.6s var(--ease-out) forwards;
}
.field:nth-child(1) { animation-delay: 0.4s; }
.field:nth-child(2) { animation-delay: 0.5s; }

.field-input {
  width: 100%;
  height: 54px;
  padding: 20px 40px 8px 0;
  background: transparent;
  border: none;
  border-bottom: 1px solid var(--border);
  color: var(--text);
  font-family: inherit;
  font-size: 15px;
  outline: none;
  transition: border-color 0.3s var(--ease-out);
  box-sizing: border-box;
}
.field-input:focus { border-bottom-color: transparent; }

.field-label {
  position: absolute;
  left: 4px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 14px;
  color: var(--text-muted);
  pointer-events: none;
  transition: all 0.25s var(--ease-out);
  transform-origin: left top;
}

.field-input:focus + .field-label,
.field-input:not(:placeholder-shown) + .field-label {
  top: 8px;
  transform: translateY(0) scale(0.75);
  color: var(--accent);
}

.field-line {
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
.field-input:focus ~ .field-line {
  width: 100%;
  left: 0;
}

.field-eye {
  position: absolute;
  right: 2px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  color: #ccc;
  cursor: pointer;
  padding: 4px;
  display: flex;
  transition: color 0.25s, transform 0.2s var(--ease-spring);
}
.field-eye:hover { color: var(--text-secondary); transform: translateY(-50%) scale(1.1); }

/* ── 按钮 ── */
.login-btn {
  position: relative;
  width: 100%;
  height: 52px;
  border: none;
  border-radius: 10px;
  font-family: inherit;
  font-size: 14px;
  font-weight: 500;
  letter-spacing: 1px;
  cursor: pointer;
  overflow: hidden;
  background: transparent;
  color: var(--text);
  opacity: 0;
  animation: fadeIn 0.6s ease 0.65s forwards;
  margin-top: 8px;
}

.btn-bg {
  position: absolute;
  inset: 0;
  background: linear-gradient(90deg, #1a1a1a, #2a2523, #1a1a1a);
  background-size: 200% 100%;
  transition: background-position 0.6s, transform 0.4s var(--ease-out);
  z-index: 0;
  border-radius: 10px;
}

.login-btn::before {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.12), transparent);
  transform: translateX(-100%);
  transition: transform 0.6s var(--ease-out);
  z-index: 1;
  border-radius: 10px;
}

.login-btn:hover:not(:disabled)::before { transform: translateX(100%); }
.login-btn:hover:not(:disabled) .btn-bg {
  background-position: 100% 0;
  transform: scale(1.02);
}
.login-btn:disabled { cursor: not-allowed; }

.btn-text {
  position: relative;
  z-index: 2;
  color: #f5f3f0;
  transition: opacity 0.3s, transform 0.3s;
  display: inline-flex;
  align-items: center;
  gap: 10px;
}
.login-btn.loading .btn-text { opacity: 0; transform: translateY(-6px); }

.btn-spinner {
  position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%) scale(0.8);
  opacity: 0;
  transition: opacity 0.3s, transform 0.3s var(--ease-spring);
  z-index: 2;
}
.login-btn.loading .btn-spinner { opacity: 1; transform: translate(-50%, -50%) scale(1); }

.spinner {
  display: block;
  width: 22px;
  height: 22px;
  border: 2px solid rgba(255,255,255,0.2);
  border-top-color: #f5f3f0;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }

:deep(.ripple) {
  position: absolute;
  border-radius: 50%;
  background: rgba(255,255,255,0.25);
  transform: scale(0);
  animation: rippleAnim 0.6s linear;
  pointer-events: none;
  z-index: 1;
}
@keyframes rippleAnim { to { transform: scale(4); opacity: 0; } }

@media (max-width: 900px) {
  .login-frame {
    grid-template-columns: 1fr;
    gap: 40px;
    text-align: center;
  }
  .brand { padding-right: 0; }
  .brand-desc { margin: 0 auto; }
  .brand-meta { justify-content: center; }
  .brand-tagline { justify-content: center; }
  .brand-tagline::before { display: none; }
  .card-wrap { max-width: 420px; margin: 0 auto; }
}

@media (max-width: 520px) {
  .stage { padding: 24px; }
  .brand-logo { font-size: 48px; }
  .login-card { padding: 40px 28px 32px; }
  .brand-meta { gap: 32px; }
}
</style>
