import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { get } from '@/utils/request'

export const useAdminStore = defineStore('admin', () => {
  const adminInfo = ref<any>(null)
  const initialized = ref(false)

  const isLoggedIn = computed(() => !!adminInfo.value)

  /** 从 HttpOnly Cookie 恢复管理后台会话 */
  async function init() {
    if (initialized.value) return
    try {
      const res = await get<any>('/admin/info')
      // get() 返回的是 ApiResponse，需要 unwrap 内部 data
      adminInfo.value = res.data || res
    } catch {
      // Cookie 无效，保持 null
    } finally {
      initialized.value = true
    }
  }

  function setAdminInfo(info: any) {
    adminInfo.value = info
  }

  function logout() {
    adminInfo.value = null
  }

  return { adminInfo, isLoggedIn, initialized, init, setAdminInfo, logout }
})
