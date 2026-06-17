import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useAdminStore = defineStore('admin', () => {
  const token = ref(localStorage.getItem('admin_token') || '')
  const adminInfo = ref<any>(null)

  const isLoggedIn = computed(() => !!token.value)

  function setToken(val: string) {
    token.value = val
    localStorage.setItem('admin_token', val)
  }

  function setAdminInfo(info: any) {
    adminInfo.value = info
  }

  function logout() {
    token.value = ''
    adminInfo.value = null
    localStorage.removeItem('admin_token')
  }

  return { token, adminInfo, isLoggedIn, setToken, setAdminInfo, logout }
})
