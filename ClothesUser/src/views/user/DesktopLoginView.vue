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
  // Clear errors
  loginErrors.username = ''
  loginErrors.password = ''
  regErrors.username = ''
  regErrors.password = ''
  regErrors.confirmPwd = ''
  regErrors.phone = ''
}
</script>

<template>
  <div class="desktop-login-page">
    <!-- Left Brand -->
    <div class="desktop-login-left">
      <button class="login-back-btn" @click="goBack">
        <span>←</span> 返回
      </button>
      <div class="login-brand-icon">
        <div class="brand-logo">M</div>
      </div>
      <div class="desktop-login-brand">MAISON</div>
      <p class="desktop-login-tagline">
        精选时尚，品质生活<br />发现属于你的独特风格
      </p>
    </div>

    <!-- Right Form -->
    <div class="desktop-login-right">
      <div class="desktop-login-form-title">{{ isLogin ? '登录账户' : '创建账户' }}</div>
      <div class="desktop-login-form-sub">{{ isLogin ? '欢迎回来' : '注册后享受更多权益' }}</div>

      <!-- ── Login Form ── -->
      <template v-if="isLogin">
        <div class="desktop-form-field">
          <label>用户名 / 手机号</label>
          <input
            v-model="login.username"
            class="desktop-form-input"
            :class="{ error: loginErrors.username }"
            placeholder="请输入用户名或手机号"
            @keyup.enter="handleLogin"
          />
          <p v-if="loginErrors.username" class="field-error">{{ loginErrors.username }}</p>
        </div>
        <div class="desktop-form-field">
          <label>密码</label>
          <input
            v-model="login.password"
            type="password"
            class="desktop-form-input"
            :class="{ error: loginErrors.password }"
            placeholder="请输入密码"
            @keyup.enter="handleLogin"
          />
          <p v-if="loginErrors.password" class="field-error">{{ loginErrors.password }}</p>
        </div>
        <button class="desktop-login-submit" :disabled="loading" @click="handleLogin">
          {{ loading ? '登录中...' : '登录' }}
        </button>
      </template>

      <!-- ── Register Form ── -->
      <template v-else>
        <div class="desktop-form-field">
          <label>用户名 <span class="required">*</span></label>
          <input
            v-model="reg.username"
            class="desktop-form-input"
            :class="{ error: regErrors.username }"
            placeholder="3~20个字符，字母或数字"
          />
          <p v-if="regErrors.username" class="field-error">{{ regErrors.username }}</p>
        </div>
        <div class="desktop-form-field">
          <label>密码 <span class="required">*</span></label>
          <input
            v-model="reg.password"
            type="password"
            class="desktop-form-input"
            :class="{ error: regErrors.password }"
            placeholder="至少6位"
          />
          <p v-if="regErrors.password" class="field-error">{{ regErrors.password }}</p>
        </div>
        <div class="desktop-form-field">
          <label>确认密码 <span class="required">*</span></label>
          <input
            v-model="reg.confirmPwd"
            type="password"
            class="desktop-form-input"
            :class="{ error: regErrors.confirmPwd }"
            placeholder="再次输入密码"
          />
          <p v-if="regErrors.confirmPwd" class="field-error">{{ regErrors.confirmPwd }}</p>
        </div>
        <div class="desktop-form-field">
          <label>手机号</label>
          <input
            v-model="reg.phone"
            type="tel"
            class="desktop-form-input"
            :class="{ error: regErrors.phone }"
            placeholder="选填，用于找回密码"
          />
          <p v-if="regErrors.phone" class="field-error">{{ regErrors.phone }}</p>
        </div>
        <div class="desktop-form-field">
          <label>昵称</label>
          <input
            v-model="reg.nickname"
            class="desktop-form-input"
            placeholder="选填，公开显示"
          />
        </div>
        <button class="desktop-login-submit" :disabled="loading" @click="handleRegister">
          {{ loading ? '注册中...' : '注册' }}
        </button>
      </template>

      <!-- Switch -->
      <div class="desktop-login-switch">
        <template v-if="isLogin">
          还没有账户？
          <span @click="isLogin = false; switchMode()">立即注册 →</span>
        </template>
        <template v-else>
          已有账户？
          <span @click="isLogin = true; switchMode()">去登录 →</span>
        </template>
      </div>
    </div>
  </div>
</template>

<style scoped>
.login-back-btn {
  position: absolute;
  top: 28px;
  left: 28px;
  display: flex;
  align-items: center;
  gap: 6px;
  background: rgba(255,255,255,0.1);
  border: 1px solid rgba(255,255,255,0.18);
  color: rgba(255,255,255,0.75);
  border-radius: 8px;
  padding: 8px 16px;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.15s;
  z-index: 10;
}

.login-back-btn:hover {
  background: rgba(255,255,255,0.18);
  color: #fff;
}

.login-brand-icon {
  margin-bottom: 22px;
  position: relative;
  z-index: 1;
}

.brand-logo {
  width: 80px;
  height: 80px;
  background: linear-gradient(135deg, var(--accent), var(--accent-dark));
  border-radius: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 36px;
  font-weight: 700;
  color: white;
}

.desktop-form-input {
  width: 100%;
  height: 46px;
  border: 1.5px solid var(--border);
  border-radius: var(--radius-md);
  padding: 0 16px;
  font-size: 14px;
  outline: none;
  transition: border-color 0.15s, box-shadow 0.15s;
  box-sizing: border-box;
  background: var(--bg-card);
  color: var(--text-primary);
}

.desktop-form-input:focus {
  border-color: var(--accent);
  box-shadow: 0 0 0 3px var(--accent-bg);
}

.desktop-form-input.error {
  border-color: var(--danger);
  box-shadow: 0 0 0 3px rgba(220, 53, 69, 0.08);
}

.field-error {
  margin: 5px 0 0;
  font-size: 12px;
  color: var(--danger);
  line-height: 1.4;
}

.required {
  color: var(--danger);
  margin-left: 2px;
}

.desktop-login-submit {
  width: 100%;
  height: 46px;
  background: var(--accent);
  color: white;
  border: none;
  border-radius: var(--radius-md);
  font-size: 14px;
  font-weight: 700;
  cursor: pointer;
  transition: background 0.15s;
  margin-top: 6px;
}

.desktop-login-submit:hover:not(:disabled) {
  background: var(--accent-dark);
}

.desktop-login-submit:disabled {
  background: var(--border);
  cursor: not-allowed;
}
</style>
