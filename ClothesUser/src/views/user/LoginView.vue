<script setup lang="ts">
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { showFailToast, showToast } from 'vant'
import { userApi } from '@/api/user'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const active = ref(0) // 0: 登录  1: 注册
const loginForm = ref({ username: '', password: '' })
const registerForm = ref({ username: '', password: '', phone: '', nickname: '' })
const loginLoading = ref(false)
const registerLoading = ref(false)

async function handleLogin() {
  if (!loginForm.value.username || !loginForm.value.password) {
    showToast('请输入用户名和密码')
    return
  }
  loginLoading.value = true
  try {
    const data: any = await userApi.login(loginForm.value)
    userStore.setUserInfo(data.userInfo)
    const redirect = (route.query.redirect as string) || '/'
    router.replace(redirect)
  } catch (e: any) {
    showFailToast(e?.message || '登录失败')
  } finally {
    loginLoading.value = false
  }
}

async function handleRegister() {
  if (!registerForm.value.username || !registerForm.value.password) {
    showToast('请填写完整信息')
    return
  }
  if (registerForm.value.password.length < 6) {
    showToast('密码至少6位')
    return
  }
  registerLoading.value = true
  try {
    await userApi.register(registerForm.value)
    showToast('注册成功，请登录')
    registerForm.value = { username: '', password: '', phone: '', nickname: '' }
    active.value = 0
    loginForm.value.username = registerForm.value.username
  } catch (e: any) {
    showFailToast(e?.message || '注册失败')
  } finally {
    registerLoading.value = false
  }
}
</script>

<template>
  <div class="login-page">
    <!-- Hero Brand Area -->
    <div class="login-hero">
      <div class="login-logo">👗</div>
      <h1 class="login-brand">Fashion Store</h1>
      <p class="login-tagline">精选时尚，品质生活</p>
    </div>

    <!-- Tabs -->
    <van-tabs v-model:active="active" class="login-tabs" swipeable>
      <van-tab title="登录" :swipeable="true">
        <van-form @submit="handleLogin" class="form">
          <div class="field-group">
            <div class="field-item">
              <span class="field-icon">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
                  <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                  <circle cx="12" cy="7" r="4"/>
                </svg>
              </span>
              <van-field
                v-model="loginForm.username"
                name="username"
                placeholder="用户名 / 手机号"
                :border="false"
                :disabled="loginLoading"
                :rules="[{ required: true, message: '请输入用户名' }]"
              />
            </div>
            <div class="field-divider" />
            <div class="field-item">
              <span class="field-icon">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
                  <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                  <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                </svg>
              </span>
              <van-field
                v-model="loginForm.password"
                type="password"
                name="password"
                placeholder="请输入密码"
                :border="false"
                :disabled="loginLoading"
                :rules="[{ required: true, message: '请输入密码' }]"
              />
            </div>
          </div>

          <div class="form-options">
            <span class="form-link" @click="showToast('请联系客服找回密码')">忘记密码？</span>
          </div>

          <div class="form-submit">
            <van-button
              type="primary"
              round
              block
              native-type="submit"
              :loading="loginLoading"
              loading-text="登录中..."
              class="submit-btn"
            >
              登 录
            </van-button>
          </div>
        </van-form>
      </van-tab>

      <van-tab title="注册" :swipeable="true">
        <van-form @submit="handleRegister" class="form">
          <div class="field-group">
            <div class="field-item">
              <span class="field-icon">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
                  <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                  <circle cx="12" cy="7" r="4"/>
                </svg>
              </span>
              <van-field
                v-model="registerForm.username"
                name="username"
                placeholder="设置用户名"
                :border="false"
                :disabled="registerLoading"
                :rules="[{ required: true, message: '请输入用户名' }]"
              />
            </div>
            <div class="field-divider" />
            <div class="field-item">
              <span class="field-icon">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
                  <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                  <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                </svg>
              </span>
              <van-field
                v-model="registerForm.password"
                type="password"
                name="password"
                placeholder="设置密码（至少6位）"
                :border="false"
                :disabled="registerLoading"
                :rules="[{ required: true, message: '请输入密码' }]"
              />
            </div>
            <div class="field-divider" />
            <div class="field-item">
              <span class="field-icon">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
                  <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 13a19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 3.6 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 9.91a16 16 0 0 0 6.16 6.16l1.02-1.02a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/>
                </svg>
              </span>
              <van-field
                v-model="registerForm.phone"
                name="phone"
                placeholder="选填：手机号"
                :border="false"
                :disabled="registerLoading"
              />
            </div>
            <div class="field-divider" />
            <div class="field-item">
              <span class="field-icon">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
                  <path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/>
                </svg>
              </span>
              <van-field
                v-model="registerForm.nickname"
                name="nickname"
                placeholder="选填：昵称"
                :border="false"
                :disabled="registerLoading"
              />
            </div>
          </div>

          <div class="form-submit">
            <van-button
              type="primary"
              round
              block
              native-type="submit"
              :loading="registerLoading"
              loading-text="注册中..."
              class="submit-btn"
            >
              注 册
            </van-button>
          </div>
        </van-form>
      </van-tab>
    </van-tabs>

    <!-- Bottom text -->
    <p class="login-footer">登录即表示同意 <span @click="showToast('查看用户协议')">《用户协议》</span> 和 <span @click="showToast('查看隐私政策')">《隐私政策》</span></p>
  </div>
</template>

<style scoped>
.login-page {
  min-height: 100vh;
  background: var(--cl-bg);
  padding-bottom: env(safe-area-inset-bottom);
}

/* Hero */
.login-hero {
  padding: 48px 16px 32px;
  text-align: center;
  background: var(--cl-primary);
  position: relative;
  overflow: hidden;
}
.login-hero::before {
  content: '';
  position: absolute;
  top: -50%;
  right: -20%;
  width: 300px;
  height: 300px;
  border-radius: 50%;
  background: rgba(255,255,255,0.04);
}
.login-hero::after {
  content: '';
  position: absolute;
  bottom: -30%;
  left: -10%;
  width: 200px;
  height: 200px;
  border-radius: 50%;
  background: rgba(201,169,110,0.15);
}
.login-logo {
  font-size: 56px;
  margin-bottom: 12px;
  position: relative;
  z-index: 1;
}
.login-brand {
  font-family: var(--font-display);
  font-size: 26px;
  font-weight: 700;
  color: #fff;
  letter-spacing: 1px;
  margin-bottom: 6px;
  position: relative;
  z-index: 1;
}
.login-tagline {
  font-size: 13px;
  color: rgba(255,255,255,0.6);
  position: relative;
  z-index: 1;
}

/* Tabs */
.login-tabs {
  margin-top: -12px;
}
.login-tabs :deep(.van-tabs__wrap) {
  border-radius: var(--radius-lg) var(--radius-lg) 0 0;
  background: var(--cl-bg-card);
  box-shadow: var(--shadow-sm);
}
.login-tabs :deep(.van-tabs__nav) {
  background: transparent;
}
.login-tabs :deep(.van-tab) {
  font-size: 15px;
  font-weight: 500;
}
.login-tabs :deep(.van-tabs__line) {
  background: var(--cl-primary);
  height: 2px;
}

/* Form */
.form {
  padding: 20px 24px;
}
.field-group {
  background: var(--cl-bg-card);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  overflow: hidden;
  border: 1px solid var(--cl-border-light);
}
.field-item {
  display: flex;
  align-items: center;
  padding: 0 14px;
  min-height: 52px;
}
.field-divider {
  height: 1px;
  background: var(--cl-border-light);
  margin: 0 14px;
}
.field-icon {
  color: var(--cl-text-muted);
  display: flex;
  align-items: center;
  margin-right: 10px;
  flex-shrink: 0;
}
.field-group :deep(.van-field__body) {
  font-size: 14px;
}
.field-group :deep(.van-field__control) {
  color: var(--cl-text-primary);
}
.field-group :deep(.van-field__control::placeholder) {
  color: var(--cl-text-muted);
}

.form-options {
  display: flex;
  justify-content: flex-end;
  padding: 12px 4px;
}
.form-link {
  font-size: 13px;
  color: var(--cl-text-muted);
  cursor: pointer;
}
.form-link:active {
  color: var(--cl-primary);
}

.form-submit {
  padding-top: 8px;
}
.submit-btn {
  height: 48px;
  font-size: 16px;
  font-weight: 600;
  letter-spacing: 2px;
  background: var(--cl-primary) !important;
  border-color: var(--cl-primary) !important;
}

/* Footer */
.login-footer {
  text-align: center;
  font-size: 11px;
  color: var(--cl-text-muted);
  padding: 16px 24px 32px;
  line-height: 1.6;
}
.login-footer span {
  color: var(--cl-primary);
  cursor: pointer;
}
.login-footer span:active {
  opacity: 0.7;
}
</style>
