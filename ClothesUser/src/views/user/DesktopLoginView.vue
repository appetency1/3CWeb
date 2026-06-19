<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { showFailToast, showToast } from 'vant'
import { userApi } from '@/api/user'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const isLogin = ref(true)
const loading = ref(false)

// Login form
const login = reactive({ username: '', password: '' })
const loginErrors = reactive({ username: '', password: '' })

// Register form
const reg = reactive({ username: '', password: '', confirmPwd: '', phone: '', nickname: '' })
const regErrors = reactive({ username: '', password: '', confirmPwd: '', phone: '' })

function goBack() {
  if (window.history.length > 1) router.back()
  else router.push('/')
}

// ── Login ──
function validateLogin() {
  let ok = true
  loginErrors.username = ''
  loginErrors.password = ''

  if (!login.username.trim()) {
    loginErrors.username = '请输入用户名或手机号'
    ok = false
  }
  if (!login.password) {
    loginErrors.password = '请输入密码'
    ok = false
  }
  return ok
}

async function handleLogin() {
  if (!validateLogin()) return
  loading.value = true
  try {
    const data: any = await userApi.login({ username: login.username, password: login.password })
    userStore.setToken(data.token)
    userStore.setUserInfo(data.userInfo)
    const redirect = (route.query.redirect as string) || '/'
    router.replace(redirect)
  } catch (e: any) {
    showFailToast(e?.message || '登录失败')
  } finally {
    loading.value = false
  }
}

// ── Register ──
function validateRegister() {
  let ok = true
  regErrors.username = ''
  regErrors.password = ''
  regErrors.confirmPwd = ''
  regErrors.phone = ''

  if (!reg.username.trim()) {
    regErrors.username = '请设置用户名'
    ok = false
  } else if (reg.username.trim().length < 3) {
    regErrors.username = '用户名至少3个字符'
    ok = false
  }

  if (!reg.password) {
    regErrors.password = '请设置密码'
    ok = false
  } else if (reg.password.length < 6) {
    regErrors.password = '密码至少6位'
    ok = false
  }

  if (!reg.confirmPwd) {
    regErrors.confirmPwd = '请确认密码'
    ok = false
  } else if (reg.confirmPwd !== reg.password) {
    regErrors.confirmPwd = '两次密码不一致'
    ok = false
  }

  if (reg.phone && !/^1[3-9]\d{9}$/.test(reg.phone)) {
    regErrors.phone = '手机号格式不正确'
    ok = false
  }

  return ok
}

async function handleRegister() {
  if (!validateRegister()) return
  loading.value = true
  try {
    await userApi.register({
      username: reg.username,
      password: reg.password,
      phone: reg.phone || undefined,
      nickname: reg.nickname || undefined,
    })
    showToast('注册成功，请登录')
    reg.username = ''
    reg.password = ''
    reg.confirmPwd = ''
    reg.phone = ''
    reg.nickname = ''
    isLogin.value = true
  } catch (e: any) {
    showFailToast(e?.message || '注册失败')
  } finally {
    loading.value = false
  }
}

function switchMode() {
  loginErrors.username = ''
  loginErrors.password = ''
  regErrors.username = ''
  regErrors.password = ''
  regErrors.confirmPwd = ''
  regErrors.phone = ''
}

function togglePwd(id: string, btn: HTMLElement) {
  const input = document.getElementById(id) as HTMLInputElement
  if (!input) return
  const isPwd = input.type === 'password'
  input.type = isPwd ? 'text' : 'password'
  btn.innerHTML = isPwd
    ? '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>'
    : '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>'
}
</script>

<template>
  <div class="maison-login">
    <!-- Left Panel -->
    <div class="left">
      <div class="left__bg"></div>
      <div class="left__overlay"></div>
      <div class="left__content">
        <div class="left__brand">
          <div class="left__mark">M</div>
          <div class="left__name">MAISON</div>
        </div>
        <h1 class="left__headline">发现属于你的<br>独特风格</h1>
        <p class="left__desc">精选全球时尚单品，从日常穿搭到特别场合，为你的每一刻注入品质与优雅。品质生活，从MAISON开始。</p>
      </div>
    </div>

    <!-- Right Panel -->
    <div class="right">
      <div class="right__deco">
        <div class="right__deco-circle right__deco-circle--1"></div>
        <div class="right__deco-circle right__deco-circle--2"></div>
      </div>

      <div class="login-wrap">
        <div class="login-card">
          <div class="brand">
            <div class="brand__mark">M</div>
            <div class="brand__name">MAISON</div>
            <div class="brand__tagline">精选时尚，品质生活</div>
          </div>

          <div class="tabs">
            <button :class="['tab', { active: isLogin }]" @click="isLogin = true; switchMode()">登录</button>
            <button :class="['tab', { active: !isLogin }]" @click="isLogin = false; switchMode()">注册</button>
          </div>

          <!-- Login Form -->
          <form v-show="isLogin" class="form" @submit.prevent="handleLogin">
            <div class="field">
              <label class="field__label">用户名 / 手机号</label>
              <div class="field__wrap">
                <input
                  v-model="login.username"
                  type="text"
                  class="field__input"
                  :class="{ 'field__input--error': loginErrors.username }"
                  placeholder="请输入用户名或手机号"
                  autocomplete="username"
                />
              </div>
              <p v-if="loginErrors.username" class="field__error">{{ loginErrors.username }}</p>
            </div>

            <div class="field">
              <label class="field__label">密码</label>
              <div class="field__wrap">
                <input
                  :id="'login-pwd'"
                  v-model="login.password"
                  type="password"
                  class="field__input"
                  :class="{ 'field__input--error': loginErrors.password }"
                  placeholder="请输入密码"
                  autocomplete="current-password"
                />
                <button type="button" class="field__icon" @click="togglePwd('login-pwd', $event.currentTarget as HTMLElement)">
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>
                  </svg>
                </button>
              </div>
              <p v-if="loginErrors.password" class="field__error">{{ loginErrors.password }}</p>
            </div>

            <div class="options">
              <label class="checkbox">
                <input type="checkbox" />
                <span>记住我</span>
              </label>
              <a href="#" class="link">忘记密码？</a>
            </div>

            <button type="submit" class="btn btn--primary" :disabled="loading">
              <span>{{ loading ? '登录中...' : '登 录' }}</span>
            </button>
          </form>

          <!-- Register Form -->
          <form v-show="!isLogin" class="form" @submit.prevent="handleRegister">
            <div class="field">
              <label class="field__label">用户名 <span class="required">*</span></label>
              <div class="field__wrap">
                <input
                  v-model="reg.username"
                  type="text"
                  class="field__input"
                  :class="{ 'field__input--error': regErrors.username }"
                  placeholder="3~20个字符，字母或数字"
                  autocomplete="username"
                />
              </div>
              <p v-if="regErrors.username" class="field__error">{{ regErrors.username }}</p>
            </div>

            <div class="field">
              <label class="field__label">手机号</label>
              <div class="field__wrap">
                <input
                  v-model="reg.phone"
                  type="tel"
                  class="field__input"
                  :class="{ 'field__input--error': regErrors.phone }"
                  placeholder="请输入手机号"
                  autocomplete="tel"
                />
              </div>
              <p v-if="regErrors.phone" class="field__error">{{ regErrors.phone }}</p>
            </div>

            <div class="field">
              <label class="field__label">密码 <span class="required">*</span></label>
              <div class="field__wrap">
                <input
                  :id="'reg-pwd'"
                  v-model="reg.password"
                  type="password"
                  class="field__input"
                  :class="{ 'field__input--error': regErrors.password }"
                  placeholder="至少6位"
                  autocomplete="new-password"
                />
                <button type="button" class="field__icon" @click="togglePwd('reg-pwd', $event.currentTarget as HTMLElement)">
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>
                  </svg>
                </button>
              </div>
              <p v-if="regErrors.password" class="field__error">{{ regErrors.password }}</p>
            </div>

            <div class="field">
              <label class="field__label">确认密码 <span class="required">*</span></label>
              <div class="field__wrap">
                <input
                  v-model="reg.confirmPwd"
                  type="password"
                  class="field__input"
                  :class="{ 'field__input--error': regErrors.confirmPwd }"
                  placeholder="再次输入密码"
                  autocomplete="new-password"
                />
              </div>
              <p v-if="regErrors.confirmPwd" class="field__error">{{ regErrors.confirmPwd }}</p>
            </div>

            <div class="field">
              <label class="field__label">昵称</label>
              <div class="field__wrap">
                <input
                  v-model="reg.nickname"
                  type="text"
                  class="field__input"
                  placeholder="选填，公开显示"
                />
              </div>
            </div>

            <div class="options">
              <label class="checkbox">
                <input type="checkbox" />
                <span>我已阅读并同意</span>
              </label>
              <p class="terms"><a href="#">用户协议</a> 和 <a href="#">隐私政策</a></p>
            </div>

            <button type="submit" class="btn btn--primary" :disabled="loading">
              <span>{{ loading ? '注册中...' : '注 册' }}</span>
            </button>
          </form>

          <div class="divider">或使用以下方式</div>

          <div class="social">
            <button class="social__btn">
              <svg viewBox="0 0 24 24" fill="currentColor">
                <path d="M8.691 2.188C3.891 2.188 0 5.476 0 9.53c0 2.212 1.17 4.203 3.002 5.55a.59.59 0 01.213.665l-.39 1.48c-.019.07-.048.141-.048.213 0 .163.13.295.29.295a.326.326 0 00.167-.054l1.903-1.114a.864.864 0 01.717-.098 10.16 10.16 0 002.837.403c.276 0 .543-.027.811-.05a6.093 6.093 0 01-.305-1.855c0-3.564 3.348-6.456 7.473-6.456.26 0 .515.013.768.037C15.627 4.69 12.47 2.188 8.691 2.188z"/>
              </svg>
              微信
            </button>
            <button class="social__btn">
              <svg viewBox="0 0 24 24" fill="currentColor">
                <path d="M12.48 10.92v3.28h7.84c-.24 1.84-.853 3.187-1.787 4.133-1.147 1.147-2.933 2.4-6.053 2.4-4.827 0-8.6-3.893-8.6-8.72s3.773-8.72 8.6-8.72c2.6 0 4.507 1.027 5.907 2.347l2.307-2.307C18.747 1.44 16.133 0 12.48 0 5.867 0 .307 5.387.307 12s5.56 12 12.173 12c3.573 0 6.267-1.173 8.373-3.36 2.16-2.16 2.84-5.213 2.84-7.667 0-.76-.053-1.467-.173-2.053H12.48z"/>
              </svg>
              Google
            </button>
          </div>
        </div>

        <div class="footer">
          <template v-if="isLogin">
            还没有账户？<a href="#" @click.prevent="isLogin = false; switchMode()">立即注册</a>
          </template>
          <template v-else>
            已有账户？<a href="#" @click.prevent="isLogin = true; switchMode()">去登录</a>
          </template>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.maison-login {
  width: 100%;
  min-height: 100vh;
  display: flex;
  font-family: 'Montserrat', -apple-system, BlinkMacSystemFont, sans-serif;
  color: #1c1917;
  -webkit-font-smoothing: antialiased;
  background: #faf9f7;
}

/* ── Left Panel ── */
.left {
  position: relative;
  width: 55%;
  min-height: 100vh;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  padding: 48px;
}

.left__bg {
  position: absolute;
  inset: 0;
  background: url('https://images.unsplash.com/photo-1558171813-4c088753af8f?q=80&w=2835&auto=format&fit=crop') center/cover no-repeat;
  filter: grayscale(15%) contrast(1.05);
}

.left__overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(
    0deg,
    rgba(28, 25, 23, 0.75) 0%,
    rgba(28, 25, 23, 0.35) 50%,
    rgba(28, 25, 23, 0.15) 100%
  );
}

.left__content {
  position: relative;
  z-index: 1;
  color: white;
  max-width: 480px;
  opacity: 0;
  transform: translateY(20px);
  animation: fadeUp 1s cubic-bezier(0.22, 1, 0.36, 1) 0.4s forwards;
}

@keyframes fadeUp {
  to { opacity: 1; transform: translateY(0); }
}

.left__brand {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-bottom: 24px;
}

.left__mark {
  width: 40px;
  height: 40px;
  background: white;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #b85c4f;
  font-family: 'Cormorant Garamond', serif;
  font-size: 18px;
  font-weight: 600;
  letter-spacing: 2px;
}

.left__name {
  font-family: 'Cormorant Garamond', serif;
  font-size: 28px;
  font-weight: 600;
  letter-spacing: 4px;
}

.left__headline {
  font-family: 'Cormorant Garamond', serif;
  font-size: 48px;
  font-weight: 400;
  line-height: 1.15;
  margin-bottom: 16px;
  letter-spacing: 1px;
}

.left__desc {
  font-size: 15px;
  line-height: 1.7;
  opacity: 0.8;
  font-weight: 300;
  max-width: 400px;
}

/* ── Right Panel ── */
.right {
  width: 45%;
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #faf9f7;
  position: relative;
  overflow: hidden;
  padding: 40px 20px;
}

.right__deco {
  position: absolute;
  inset: 0;
  pointer-events: none;
}

.right__deco-circle {
  position: absolute;
  border-radius: 50%;
  filter: blur(70px);
  opacity: 0.35;
}

.right__deco-circle--1 {
  width: 350px;
  height: 350px;
  background: #e8d5cf;
  top: -80px;
  right: -80px;
}

.right__deco-circle--2 {
  width: 300px;
  height: 300px;
  background: #f5e6dc;
  bottom: -60px;
  left: -60px;
}

.login-wrap {
  position: relative;
  z-index: 1;
  width: 100%;
  max-width: 400px;
  opacity: 0;
  transform: translateY(20px);
  animation: riseUp 0.8s cubic-bezier(0.22, 1, 0.36, 1) 0.2s forwards;
}

@keyframes riseUp {
  to { opacity: 1; transform: translateY(0); }
}

.login-card {
  background: #ffffff;
  border-radius: 20px;
  padding: 40px 36px 32px;
  box-shadow: 0 12px 40px rgba(28, 25, 23, 0.08);
  border: 1px solid rgba(231, 229, 228, 0.6);
}

/* ── Brand ── */
.brand {
  text-align: center;
  margin-bottom: 28px;
}

.brand__mark {
  width: 44px;
  height: 44px;
  background: #b85c4f;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-family: 'Cormorant Garamond', serif;
  font-size: 18px;
  font-weight: 600;
  letter-spacing: 2px;
  margin: 0 auto 16px;
  box-shadow: 0 6px 20px rgba(184, 92, 79, 0.25);
}

.brand__name {
  font-family: 'Cormorant Garamond', serif;
  font-size: 28px;
  font-weight: 600;
  letter-spacing: 5px;
  color: #1c1917;
  margin-bottom: 4px;
}

.brand__tagline {
  font-size: 12px;
  color: #a8a29e;
  letter-spacing: 1px;
}

/* ── Tabs ── */
.tabs {
  display: flex;
  gap: 4px;
  background: #faf9f7;
  padding: 4px;
  border-radius: 100px;
  margin-bottom: 24px;
  width: fit-content;
  margin-left: auto;
  margin-right: auto;
}

.tab {
  padding: 8px 24px;
  border-radius: 100px;
  border: none;
  background: transparent;
  font-family: inherit;
  font-size: 13px;
  font-weight: 600;
  color: #78716c;
  cursor: pointer;
  transition: all 0.4s cubic-bezier(0.22, 1, 0.36, 1);
  letter-spacing: 0.5px;
}

.tab:hover { color: #1c1917; }

.tab.active {
  background: #ffffff;
  color: #1c1917;
  box-shadow: 0 1px 3px rgba(28, 25, 23, 0.04);
}

/* ── Form ── */
.form {
  animation: fadeIn 0.4s cubic-bezier(0.22, 1, 0.36, 1);
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(8px); }
  to { opacity: 1; transform: translateY(0); }
}

.field {
  margin-bottom: 18px;
}

.field__label {
  display: block;
  font-size: 12px;
  font-weight: 600;
  color: #78716c;
  margin-bottom: 8px;
  letter-spacing: 0.5px;
}

.field__wrap {
  position: relative;
}

.field__input {
  width: 100%;
  height: 48px;
  padding: 0 44px 0 16px;
  border: 1.5px solid #e7e5e4;
  border-radius: 12px;
  background: #faf9f7;
  font-family: inherit;
  font-size: 14px;
  color: #1c1917;
  outline: none;
  transition: all 0.3s cubic-bezier(0.22, 1, 0.36, 1);
  box-sizing: border-box;
}

.field__input::placeholder {
  color: #a8a29e;
  font-weight: 400;
}

.field__input:hover { border-color: #d6d3d1; }

.field__input:focus {
  border-color: #b85c4f;
  background: #ffffff;
  box-shadow: 0 0 0 4px #fdf2f0;
}

.field__input--error {
  border-color: #dc2626;
}

.field__error {
  margin: 5px 0 0;
  font-size: 12px;
  color: #dc2626;
  line-height: 1.4;
}

.required { color: #dc2626; margin-left: 2px; }

.field__icon {
  position: absolute;
  right: 14px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  color: #a8a29e;
  cursor: pointer;
  padding: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: color 0.3s;
}

.field__icon:hover { color: #78716c; }

/* ── Options ── */
.options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 2px 0 22px;
  font-size: 13px;
}

.checkbox {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #78716c;
  cursor: pointer;
  font-weight: 500;
}

.checkbox input {
  appearance: none;
  width: 18px;
  height: 18px;
  border: 1.5px solid #e7e5e4;
  border-radius: 5px;
  background: #ffffff;
  cursor: pointer;
  position: relative;
  transition: all 0.25s;
  flex-shrink: 0;
}

.checkbox input:checked {
  background: #b85c4f;
  border-color: #b85c4f;
}

.checkbox input:checked::after {
  content: '';
  position: absolute;
  left: 5px;
  top: 2px;
  width: 4px;
  height: 8px;
  border: solid white;
  border-width: 0 2px 2px 0;
  transform: rotate(45deg);
}

.link {
  color: #b85c4f;
  text-decoration: none;
  font-weight: 600;
  font-size: 13px;
  transition: opacity 0.3s;
}

.link:hover { opacity: 0.8; text-decoration: underline; }

/* ── Button ── */
.btn {
  width: 100%;
  height: 48px;
  border: none;
  border-radius: 12px;
  font-family: inherit;
  font-size: 14px;
  font-weight: 600;
  letter-spacing: 1px;
  cursor: pointer;
  transition: all 0.4s cubic-bezier(0.22, 1, 0.36, 1);
  position: relative;
  overflow: hidden;
}

.btn--primary {
  background: #1c1917;
  color: white;
}

.btn--primary::before {
  content: '';
  position: absolute;
  inset: 0;
  background: #b85c4f;
  transform: scaleX(0);
  transform-origin: right;
  transition: transform 0.5s cubic-bezier(0.22, 1, 0.36, 1);
}

.btn--primary:hover:not(:disabled)::before {
  transform: scaleX(1);
  transform-origin: left;
}

.btn--primary:hover:not(:disabled) {
  box-shadow: 0 8px 24px rgba(184, 92, 79, 0.25);
  transform: translateY(-1px);
}

.btn--primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn span { position: relative; z-index: 1; }

/* ── Divider & Social ── */
.divider {
  display: flex;
  align-items: center;
  gap: 16px;
  margin: 22px 0;
  color: #a8a29e;
  font-size: 12px;
  font-weight: 500;
}

.divider::before,
.divider::after {
  content: '';
  flex: 1;
  height: 1px;
  background: #e7e5e4;
}

.social {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}

.social__btn {
  height: 44px;
  background: #ffffff;
  border: 1.5px solid #e7e5e4;
  border-radius: 12px;
  color: #78716c;
  font-family: inherit;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.22, 1, 0.36, 1);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.social__btn:hover {
  border-color: #d6d3d1;
  color: #1c1917;
  background: #faf9f7;
  transform: translateY(-1px);
  box-shadow: 0 1px 3px rgba(28, 25, 23, 0.04);
}

.social__btn svg { width: 18px; height: 18px; }

/* ── Footer ── */
.footer {
  margin-top: 20px;
  text-align: center;
  font-size: 13px;
  color: #78716c;
}

.footer a {
  color: #b85c4f;
  text-decoration: none;
  font-weight: 600;
  transition: opacity 0.3s;
}

.footer a:hover { text-decoration: underline; opacity: 0.85; }

/* ── Terms ── */
.terms {
  font-size: 12px;
  color: #a8a29e;
  line-height: 1.6;
  margin-top: 6px;
}

.terms a { color: #78716c; text-decoration: underline; }

/* ── Responsive ── */
@media (max-width: 900px) {
  .left { display: none; }
  .right { width: 100%; }
}

@media (max-width: 520px) {
  .right { padding: 24px 16px; }
  .login-card { padding: 36px 24px 28px; }
  .brand__name { font-size: 26px; }
}
</style>
