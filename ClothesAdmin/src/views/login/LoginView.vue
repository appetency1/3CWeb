<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { showToast, showLoadingToast, showFailToast } from 'vant'
import { useAdminStore } from '@/stores/admin'
import { post, unwrap } from '@/utils/request'

const router = useRouter()
const adminStore = useAdminStore()

const username = ref('')
const password = ref('')
const loading = ref(false)

async function onLogin() {
  if (!username.value || !password.value) {
    showToast('请输入管理员账号和密码')
    return
  }
  loading.value = true
  const t = showLoadingToast({ message: '登录中...', forbidClick: true })
  try {
    const res = await post<any>('/admin/login', {
      username: username.value,
      password: password.value,
    })
    const data = unwrap(res)  // { token, userInfo }
    adminStore.setToken(data.token)
    adminStore.setAdminInfo(data.userInfo)
    t.close()
    router.replace('/dashboard')
  } catch (e: any) {
    t.close()
    showFailToast(e?.message || '登录失败')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login-page">
    <div class="login-box">
      <h1 class="login-title">管理员登录</h1>

      <van-form @submit="onLogin">
        <van-field
          v-model="username"
          label="账号"
          placeholder="请输入管理员账号"
          :rules="[{ required: true, message: '请输入账号' }]"
        />
        <van-field
          v-model="password"
          type="password"
          label="密码"
          placeholder="请输入密码"
          :rules="[{ required: true, message: '请输入密码' }]"
        />
        <div style="margin-top: 24px">
          <van-button round block type="primary" native-type="submit">
            登录
          </van-button>
        </div>
      </van-form>
    </div>
  </div>
</template>

<style scoped>
.login-page {
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f6f9;
}
.login-box {
  width: 360px;
  padding: 32px;
  background: #fff;
  border-radius: 12px;
}
.login-title {
  text-align: center;
  font-size: 24px;
  margin-bottom: 32px;
  color: #323233;
}
</style>
