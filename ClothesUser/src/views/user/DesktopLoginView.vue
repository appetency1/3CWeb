<script setup lang="ts">
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { showFailToast, showToast } from 'vant'
import { userApi } from '@/api/user'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const isLogin = ref(true)
const loading = ref(false)
const showPwd = ref(false)
const showRegPwd = ref(false)
const successShow = ref(false)

// 3D tilt
const cardRef = ref<HTMLElement | null>(null)
let tiltCleanup: (() => void) | null = null

// Tab pill — 用 CSS transition 实现，不用 JS 计算位置


// Login form
const login = reactive({ username: '', password: '' })

// Register form
const reg = reactive({ username: '', password: '', confirmPwd: '', phone: '', nickname: '' })

function onRipple(e: MouseEvent) {
  const btn = e.currentTarget as HTMLElement
  if (btn.classList.contains('loading')) return
  const ripple = document.createElement('span')
  ripple.className = 'btn__ripple'
  const rect = btn.getBoundingClientRect()
  const size = Math.max(rect.width, rect.height)
  ripple.style.width = ripple.style.height = size + 'px'
  ripple.style.left = (e.clientX - rect.left - size / 2) + 'px'
  ripple.style.top = (e.clientY - rect.top - size / 2) + 'px'
  btn.appendChild(ripple)
  setTimeout(() => ripple.remove(), 600)
}

// ── Login ──
async function handleLogin() {
  if (!login.username.trim() || !login.password) { showToast('请输入用户名和密码'); return }
  loading.value = true
  try {
    const data: any = await userApi.login({ username: login.username, password: login.password })
    userStore.setToken(data.token)
    userStore.setUserInfo(data.userInfo)
    successShow.value = true
    loading.value = false
    setTimeout(() => {
      const redirect = (route.query.redirect as string) || '/'
      router.replace(redirect)
    }, 1400)
  } catch (e: any) { showFailToast(e?.message || '登录失败'); loading.value = false }
}

// ── Register ──
async function handleRegister() {
  if (!reg.username.trim()) { showToast('请设置用户名'); return }
  if (reg.username.trim().length < 3) { showToast('用户名至少3个字符'); return }
  if (!reg.password || reg.password.length < 6) { showToast('密码至少6位'); return }
  if (reg.confirmPwd !== reg.password) { showToast('两次密码不一致'); return }
  if (reg.phone && !/^1[3-9]\d{9}$/.test(reg.phone)) { showToast('手机号格式不正确'); return }
  loading.value = true
  try {
    await userApi.register({ username: reg.username, password: reg.password, phone: reg.phone || undefined, nickname: reg.nickname || undefined })
    showToast('注册成功，请登录')
    Object.assign(reg, { username: '', password: '', confirmPwd: '', phone: '', nickname: '' })
    isLogin.value = true
    // watch 会自动处理 pill 动画
  } catch (e: any) { showFailToast(e?.message || '注册失败') }
  finally { loading.value = false }
}

function switchTo(target: 'login' | 'register') {
  isLogin.value = target === 'login'
}

onMounted(() => {
  const card = cardRef.value
  if (!card) return
  const wrap = card.parentElement
  if (!wrap) return
  const onMove = (e: MouseEvent) => {
    if (window.innerWidth < 960) return
    const rect = wrap.getBoundingClientRect()
    const dx = (e.clientX - rect.left) / rect.width - 0.5
    const dy = (e.clientY - rect.top) / rect.height - 0.5
    card.style.transform = `rotateX(${dy * -6}deg) rotateY(${dx * 6}deg)`
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
  <div class="page">
    <!-- 左侧 -->
    <div class="hero">
      <div class="hero__media">
        <img src="https://images.unsplash.com/photo-1558171813-4c088753af8f?q=80&w=2835&auto=format&fit=crop" alt="MAISON" />
      </div>
      <div class="hero__grain"></div>
      <div class="hero__content">
        <div class="hero__brand">
          <div class="hero__mark">M</div>
          <div class="hero__name">MAISON</div>
        </div>
        <div class="reveal-line"><h1 class="hero__headline">发现属于你的<span>独特风格</span></h1></div>
        <div class="reveal-line"><p class="hero__desc">精选全球时尚单品，从日常穿搭到特别场合，为你的每一刻注入品质与优雅。</p></div>
      </div>
    </div>

    <!-- 右侧 -->
    <div class="panel">
      <div class="panel__deco">
        <div class="panel__circle panel__circle--1"></div>
        <div class="panel__circle panel__circle--2"></div>
      </div>

      <div class="card-wrap">
        <div ref="cardRef" class="card">
          <div class="brand">
            <div class="brand__mark">M</div>
            <div class="brand__name">MAISON</div>
            <div class="brand__tagline">精选时尚 · 品质生活</div>
          </div>

          <div class="tabs" :class="{ 'tab-login': isLogin, 'tab-register': !isLogin }">
            <div class="tab__pill"></div>
            <button class="tab" :class="{ active: isLogin }" @click="switchTo('login')">登录</button>
            <button class="tab" :class="{ active: !isLogin }" @click="switchTo('register')">注册</button>
          </div>

          <!-- 登录 -->
          <form class="form" :class="{ active: isLogin }" @submit.prevent="handleLogin">
            <div class="field">
              <input v-model="login.username" type="text" class="field__input" placeholder=" " autocomplete="username" />
              <label class="field__label">用户名 / 手机号</label>
            </div>
            <div class="field">
              <input v-model="login.password" :type="showPwd ? 'text' : 'password'" class="field__input" placeholder=" " autocomplete="current-password" />
              <label class="field__label">密码</label>
              <button type="button" class="field__icon" tabindex="-1" @click="showPwd = !showPwd">
                <svg v-if="!showPwd" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                <svg v-else width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>
              </button>
            </div>
            <div class="options">
              <label class="checkbox"><input type="checkbox" checked /><span>记住我</span></label>
              <a href="#" class="link" @click.prevent>忘记密码？</a>
            </div>
            <button type="submit" class="btn" :class="{ loading }" :disabled="loading" @click="onRipple">
              <span class="btn__text">登 录</span>
              <span class="btn__spinner"><span class="spinner"></span></span>
            </button>
          </form>

          <!-- 注册 -->
          <form class="form" :class="{ active: !isLogin }" @submit.prevent="handleRegister">
            <div class="field">
              <input v-model="reg.username" type="text" class="field__input" placeholder=" " autocomplete="username" />
              <label class="field__label">用户名</label>
            </div>
            <div class="field">
              <input v-model="reg.nickname" type="text" class="field__input" placeholder=" " autocomplete="name" />
              <label class="field__label">昵称（选填）</label>
            </div>
            <div class="field">
              <input v-model="reg.phone" type="tel" class="field__input" placeholder=" " autocomplete="tel" />
              <label class="field__label">手机号（选填）</label>
            </div>
            <div class="field">
              <input v-model="reg.password" :type="showRegPwd ? 'text' : 'password'" class="field__input" placeholder=" " autocomplete="new-password" />
              <label class="field__label">密码</label>
              <button type="button" class="field__icon" tabindex="-1" @click="showRegPwd = !showRegPwd">
                <svg v-if="!showRegPwd" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                <svg v-else width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>
              </button>
            </div>
            <div class="field">
              <input v-model="reg.confirmPwd" :type="showRegPwd ? 'text' : 'password'" class="field__input" placeholder=" " autocomplete="new-password" />
              <label class="field__label">确认密码</label>
            </div>
            <div class="options" style="margin-bottom:18px">
              <label class="checkbox"><input type="checkbox" /><span>我已阅读并同意</span></label>
            </div>
            <p class="terms"><a href="#" class="link" @click.prevent>用户协议</a> 和 <a href="#" class="link" @click.prevent>隐私政策</a></p>
            <button type="submit" class="btn" style="margin-top:18px" :class="{ loading }" :disabled="loading" @click="onRipple">
              <span class="btn__text">注 册</span>
              <span class="btn__spinner"><span class="spinner"></span></span>
            </button>
          </form>

          <div class="divider">或使用以下方式</div>
          <div class="social">
            <button class="social__btn" type="button">
              <svg viewBox="0 0 24 24" fill="currentColor"><path d="M8.691 2.188C3.891 2.188 0 5.476 0 9.53c0 2.212 1.17 4.203 3.002 5.55a.59.59 0 01.213.665l-.39 1.48c-.019.07-.048.141-.048.213 0 .163.13.295.29.295a.326.326 0 00.167-.054l1.903-1.114a.864.864 0 01.717-.098 10.16 10.16 0 002.837.403c.276 0 .543-.027.811-.05a6.093 6.093 0 01-.305-1.855c0-3.564 3.348-6.456 7.473-6.456.26 0 .515.013.768.037C15.627 4.69 12.47 2.188 8.691 2.188z"/></svg>
              微信
            </button>
            <button class="social__btn" type="button">
              <svg viewBox="0 0 24 24" fill="currentColor"><path d="M12.48 10.92v3.28h7.84c-.24 1.84-.853 3.187-1.787 4.133-1.147 1.147-2.933 2.4-6.053 2.4-4.827 0-8.6-3.893-8.6-8.72s3.773-8.72 12.173 12c3.573 0 6.267-1.173 8.373-3.36 2.16-2.16 2.84-5.213 2.84-7.667 0-.76-.053-1.467-.173-2.053H12.48z"/></svg>
              Google
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- 成功覆盖层 -->
  <Teleport to="body">
    <div class="success" :class="{ show: successShow }">
      <div class="success__ring">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="20 6 9 17 4 12"/></svg>
      </div>
      <div class="success__text">登录成功，正在跳转…</div>
    </div>
  </Teleport>
</template>

<style scoped>
.page {
  width: 100%;
  height: 100vh;
  display: flex;
  position: relative;
  font-family: 'Montserrat', -apple-system, sans-serif;
  color: #1a1816;
  background: #f3f0ec;
  -webkit-font-smoothing: antialiased;
}

/* ===== 左侧大片 ===== */
.hero {
  position: relative;
  width: 58%;
  height: 100%;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  padding: 72px;
}

.hero__media {
  position: absolute;
  inset: -30px;
  transform: scale(1.12);
  animation: slowZoom 30s cubic-bezier(0.4, 0, 0.2, 1) infinite alternate;
}

.hero__media::after {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(165deg, rgba(26,24,22,0.18) 0%, rgba(26,24,22,0.05) 45%, rgba(26,24,22,0.72) 100%);
}

.hero__media img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  filter: saturate(0.92) contrast(1.02);
}

@keyframes slowZoom {
  0% { transform: scale(1.12) translate(0, 0); }
  100% { transform: scale(1.22) translate(-1.5%, -1%); }
}

.hero__grain {
  position: absolute;
  inset: 0;
  opacity: 0.04;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.85' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E");
  mix-blend-mode: overlay;
  pointer-events: none;
  z-index: 2;
}

.hero__content {
  position: relative;
  z-index: 3;
  color: white;
  max-width: 480px;
}

.hero__brand {
  display: inline-flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 36px;
  opacity: 0;
  transform: translateY(18px);
  animation: rise 1s cubic-bezier(0.22, 1, 0.36, 1) 0.5s forwards;
}

.hero__mark {
  width: 38px; height: 38px;
  background: white;
  border-radius: 10px;
  display: flex; align-items: center; justify-content: center;
  color: #b05c4f;
  font-family: 'Cormorant Garamond', serif;
  font-size: 17px;
  font-weight: 700;
  letter-spacing: 2px;
}

.hero__name {
  font-family: 'Cormorant Garamond', serif;
  font-size: 24px;
  font-weight: 500;
  letter-spacing: 5px;
}

.hero__headline {
  font-family: 'Cormorant Garamond', serif;
  font-size: 62px;
  font-weight: 400;
  line-height: 1.05;
  margin-bottom: 22px;
  letter-spacing: -0.5px;
}

.hero__headline span {
  display: block;
  font-style: italic;
  font-weight: 500;
  color: rgba(255,255,255,0.9);
}

.hero__desc {
  font-size: 14px;
  line-height: 1.85;
  opacity: 0.75;
  font-weight: 300;
  max-width: 360px;
}

.reveal-line { overflow: hidden; }
.reveal-line > * {
  display: block;
  transform: translateY(100%);
  animation: reveal 1s cubic-bezier(0.22, 1, 0.36, 1) forwards;
}
.reveal-line:nth-child(1) > * { animation-delay: 0.6s; }
.reveal-line:nth-child(2) > * { animation-delay: 0.72s; }

@keyframes reveal { to { transform: translateY(0); } }
@keyframes rise { to { opacity: 1; transform: translateY(0); } }

/* ===== 右侧 ===== */
.panel {
  width: 42%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 48px;
  position: relative;
}

.panel__deco {
  position: absolute;
  inset: 0;
  pointer-events: none;
  overflow: hidden;
}

.panel__circle {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  opacity: 0;
  animation: fadeIn 1.4s cubic-bezier(0.22, 1, 0.36, 1) 0.4s forwards;
}

.panel__circle--1 {
  width: 340px; height: 340px;
  background: rgba(176,92,79,0.11);
  top: -120px; right: -80px;
}
.panel__circle--2 {
  width: 260px; height: 260px;
  background: rgba(191,166,124,0.1);
  bottom: -80px; left: -60px;
  animation-delay: 0.6s;
}

@keyframes fadeIn { to { opacity: 1; } }

.card-wrap {
  width: 100%;
  max-width: 400px;
  perspective: 1200px;
  opacity: 0;
  transform: translateX(36px);
  animation: slideIn 1s cubic-bezier(0.22, 1, 0.36, 1) 0.3s forwards;
}

@keyframes slideIn { to { opacity: 1; transform: translateX(0); } }

.card {
  position: relative;
  background: #ffffff;
  border-radius: 32px;
  padding: 46px 40px 38px;
  box-shadow: 0 32px 96px rgba(26,24,22,0.1);
  border: 1px solid rgba(230,225,220,0.65);
  transform-style: preserve-3d;
  transition: transform 0.15s ease-out, box-shadow 0.4s cubic-bezier(0.22, 1, 0.36, 1);
  will-change: transform;
}
.card:hover { box-shadow: 0 40px 110px rgba(26,24,22,0.12); }

/* ── Brand ── */
.brand { text-align: center; margin-bottom: 34px; }

.brand__mark {
  width: 54px; height: 54px;
  background: #b05c4f;
  border-radius: 18px;
  display: flex; align-items: center; justify-content: center;
  color: white;
  font-family: 'Cormorant Garamond', serif;
  font-size: 22px;
  font-weight: 700;
  letter-spacing: 2px;
  margin: 0 auto 16px;
  box-shadow: 0 10px 32px rgba(176,92,79,0.25);
  animation: markFloat 4s ease-in-out infinite;
}

@keyframes markFloat {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-4px); }
}

.brand__name {
  font-family: 'Cormorant Garamond', serif;
  font-size: 30px;
  font-weight: 600;
  letter-spacing: 6px;
  margin-bottom: 5px;
}

.brand__tagline {
  font-size: 11px;
  color: #a9a39d;
  letter-spacing: 1.5px;
  text-transform: uppercase;
  font-weight: 500;
}

/* ── Tabs ── */
.tabs {
  position: relative;
  display: flex;
  gap: 4px;
  background: #f3f0ec;
  padding: 4px;
  border-radius: 100px;
  margin-bottom: 30px;
  width: fit-content;
  margin-left: auto;
  margin-right: auto;
}

.tab {
  position: relative;
  z-index: 1;
  padding: 10px 30px;
  border-radius: 100px;
  border: none;
  background: transparent;
  font-family: inherit;
  font-size: 13px;
  font-weight: 600;
  color: #706a64;
  cursor: pointer;
  transition: color 0.35s cubic-bezier(0.22, 1, 0.36, 1);
  letter-spacing: 0.5px;
}

.tab:hover { color: #1a1816; }
.tab.active { color: #1a1816; }

.tab__pill {
  position: absolute;
  top: 4px;
  left: 4px;
  right: calc(50% + 2px);
  height: calc(100% - 8px);
  background: #ffffff;
  border-radius: 100px;
  box-shadow: 0 4px 24px rgba(26,24,22,0.04);
  transition: left 0.45s cubic-bezier(0.34, 1.56, 0.64, 1),
              right 0.45s cubic-bezier(0.34, 1.56, 0.64, 1);
  z-index: 0;
}
.tab-register .tab__pill {
  left: calc(50% + 2px);
  right: 4px;
}

/* ── Form ── */
.form { display: none; }
.form.active { display: block; animation: formIn 0.5s cubic-bezier(0.22, 1, 0.36, 1); }

@keyframes formIn {
  from { opacity: 0; transform: translateY(14px); }
  to { opacity: 1; transform: translateY(0); }
}

.field { position: relative; margin-bottom: 22px; }

.field__input {
  width: 100%;
  height: 58px;
  padding: 22px 46px 9px 16px;
  background: #faf8f6;
  border: 1.5px solid #e6e1dc;
  border-radius: 16px;
  color: #1a1816;
  font-family: inherit;
  font-size: 15px;
  outline: none;
  transition: all 0.3s cubic-bezier(0.22, 1, 0.36, 1);
  box-sizing: border-box;
}
.field__input:hover { border-color: #d3cdc6; }
.field__input:focus {
  border-color: #b05c4f;
  background: #ffffff;
  box-shadow: 0 0 0 4px #fdf1ef;
}

.field__label {
  position: absolute;
  left: 16px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 14px;
  color: #a9a39d;
  pointer-events: none;
  transition: all 0.25s cubic-bezier(0.22, 1, 0.36, 1);
  transform-origin: left top;
}

.field__input:focus + .field__label,
.field__input:not(:placeholder-shown) + .field__label {
  top: 11px;
  transform: translateY(0) scale(0.72);
  color: #b05c4f;
  font-weight: 600;
}

.field__icon {
  position: absolute;
  right: 14px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  color: #a9a39d;
  cursor: pointer;
  padding: 4px;
  display: flex;
  transition: color 0.3s, transform 0.2s cubic-bezier(0.34, 1.56, 0.64, 1);
}
.field__icon:hover { color: #706a64; transform: translateY(-50%) scale(1.1); }

/* ── Options ── */
.options {
  display: flex; justify-content: space-between; align-items: center;
  margin: -2px 0 26px; font-size: 12px;
}

.checkbox {
  display: flex; align-items: center; gap: 9px;
  color: #706a64; cursor: pointer; font-weight: 500;
  transition: color 0.3s;
}
.checkbox:hover { color: #1a1816; }

.checkbox input {
  appearance: none;
  width: 17px; height: 17px;
  border: 1.5px solid #e6e1dc;
  border-radius: 5px;
  background: #ffffff;
  cursor: pointer;
  position: relative;
  transition: all 0.25s cubic-bezier(0.22, 1, 0.36, 1);
  flex-shrink: 0;
}
.checkbox input:checked {
  background: #b05c4f;
  border-color: #b05c4f;
  transform: scale(1.05);
}
.checkbox input:checked::after {
  content: '';
  position: absolute;
  left: 5px; top: 2px;
  width: 4px; height: 7px;
  border: solid white;
  border-width: 0 2px 2px 0;
  transform: rotate(45deg);
  animation: tick 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

@keyframes tick {
  0% { transform: rotate(45deg) scale(0); }
  70% { transform: rotate(45deg) scale(1.2); }
  100% { transform: rotate(45deg) scale(1); }
}

.link {
  color: #b05c4f; text-decoration: none; font-weight: 600; font-size: 12px;
  position: relative; transition: color 0.3s;
}
.link::after {
  content: ''; position: absolute; left: 0; bottom: -2px;
  width: 0; height: 1px; background: #b05c4f;
  transition: width 0.3s cubic-bezier(0.22, 1, 0.36, 1);
}
.link:hover { color: #954a3f; }
.link:hover::after { width: 100%; }

/* ── Button ── */
.btn {
  width: 100%; height: 54px;
  border: none; border-radius: 16px;
  font-family: inherit; font-size: 13px; font-weight: 600;
  letter-spacing: 1.5px; cursor: pointer;
  position: relative; overflow: hidden;
  transition: all 0.4s cubic-bezier(0.22, 1, 0.36, 1);
  color: white; background: #1a1816;
}

.btn::before {
  content: '';
  position: absolute; inset: 0;
  background: linear-gradient(90deg, #b05c4f, #954a3f);
  transform: scaleX(0);
  transform-origin: right;
  transition: transform 0.6s cubic-bezier(0.22, 1, 0.36, 1);
}
.btn:hover::before { transform: scaleX(1); transform-origin: left; }

.btn:hover {
  box-shadow: 0 14px 36px rgba(176,92,79,0.22);
  transform: translateY(-2px);
}
.btn:active { transform: translateY(0); }
.btn:disabled { cursor: not-allowed; opacity: 0.6; }

.btn__text {
  position: relative; z-index: 1;
  transition: opacity 0.3s, transform 0.3s;
  display: inline-flex; align-items: center; gap: 8px;
}
.btn.loading .btn__text { opacity: 0; transform: translateY(-6px); }

.btn__spinner {
  position: absolute; left: 50%; top: 50%;
  transform: translate(-50%, -50%) scale(0.8);
  opacity: 0;
  transition: opacity 0.3s, transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
  z-index: 2;
}
.btn.loading .btn__spinner { opacity: 1; transform: translate(-50%, -50%) scale(1); }

.spinner { display: block; width: 20px; height: 20px; border: 2px solid rgba(255,255,255,0.25); border-top-color: white; border-radius: 50%; animation: spin 0.8s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }

.btn__ripple {
  position: absolute; border-radius: 50%;
  background: rgba(255,255,255,0.25);
  transform: scale(0);
  animation: rippleAnim 0.6s linear;
  pointer-events: none; z-index: 1;
}
@keyframes rippleAnim { to { transform: scale(4); opacity: 0; } }

/* ── Divider ── */
.divider {
  display: flex; align-items: center; gap: 16px;
  margin: 24px 0;
  color: #a9a39d; font-size: 11px; font-weight: 500;
  letter-spacing: 0.5px; text-transform: uppercase;
}
.divider::before, .divider::after {
  content: ''; flex: 1; height: 1px;
  background: linear-gradient(90deg, transparent, #e6e1dc, transparent);
}

/* ── Social ── */
.social { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }

.social__btn {
  height: 48px;
  background: #ffffff;
  border: 1.5px solid #e6e1dc;
  border-radius: 16px;
  color: #706a64;
  font-family: inherit; font-size: 12px; font-weight: 600;
  cursor: pointer;
  transition: all 0.35s cubic-bezier(0.22, 1, 0.36, 1);
  display: flex; align-items: center; justify-content: center; gap: 8px;
}
.social__btn:hover {
  border-color: #d3cdc6; color: #1a1816;
  background: #faf8f6;
  transform: translateY(-2px);
  box-shadow: 0 12px 48px rgba(26,24,22,0.07);
}
.social__btn svg { width: 18px; height: 18px; transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1); }
.social__btn:hover svg { transform: scale(1.15) rotate(-4deg); }

.terms { font-size: 11px; color: #a9a39d; line-height: 1.6; margin-top: 6px; text-align: center; }

/* ── Success Overlay ── */
.success {
  position: fixed; inset: 0; z-index: 100;
  display: flex; flex-direction: column;
  align-items: center; justify-content: center;
  background: #f3f0ec;
  opacity: 0; pointer-events: none;
  transition: opacity 0.6s cubic-bezier(0.22, 1, 0.36, 1);
}
.success.show { opacity: 1; pointer-events: auto; }

.success__ring {
  width: 84px; height: 84px;
  border-radius: 50%;
  border: 2px solid #e6e1dc;
  display: flex; align-items: center; justify-content: center;
  margin-bottom: 24px; position: relative;
}
.success__ring::before {
  content: '';
  position: absolute; inset: -3px;
  border-radius: 50%;
  border: 2px solid transparent;
  border-top-color: #b05c4f;
  animation: spin 1.2s linear infinite;
}
.success__ring svg {
  width: 32px; height: 32px;
  color: #b05c4f;
  transform: scale(0);
}
.success.show .success__ring svg { animation: popIn 0.5s cubic-bezier(0.34, 1.56, 0.64, 1) 0.25s forwards; }

@keyframes popIn { to { transform: scale(1); } }

.success__text {
  font-size: 15px; color: #1a1816;
  letter-spacing: 0.5px; font-weight: 500;
}

/* ── Responsive ── */
@media (max-width: 960px) {
  .hero { display: none; }
  .panel { width: 100%; padding: 32px; }
}
@media (max-width: 460px) {
  .card { padding: 38px 26px 32px; }
  .brand__name { font-size: 26px; }
  .tab { padding: 10px 24px; }
}
</style>
