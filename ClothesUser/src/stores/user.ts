import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { userApi } from '@/api/user'

export const useUserStore = defineStore('user', () => {
  const userInfo = ref<any>(null)
  const token = ref<string | null>(localStorage.getItem('token'))
  const initialized = ref(false)

  const isLoggedIn = computed(() => !!userInfo.value)

  /** 从 HttpOnly Cookie 恢复会话：尝试获取用户信息 */
  async function init() {
    if (initialized.value) return
    try {
      const info: any = await userApi.info()
      userInfo.value = info
    } catch {
      // Cookie 无效或未登录，保持 userInfo = null
    } finally {
      initialized.value = true
    }
  }

  function setUserInfo(info: any) {
    userInfo.value = info
  }

  function setToken(t: string) {
    token.value = t
    localStorage.setItem('token', t)
  }

  function logout() {
    userInfo.value = null
    token.value = null
    localStorage.removeItem('token')
  }

  return { userInfo, token, isLoggedIn, initialized, init, setUserInfo, setToken, logout }
})
