import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import 'vant/lib/index.css'
import './style.css'

const app = createApp(App)
const pinia = createPinia()
app.use(pinia)
app.use(router)

// 尝试从 HttpOnly Cookie 恢复管理后台会话
import { useAdminStore } from '@/stores/admin'
const adminStore = useAdminStore()
adminStore.init()

app.mount('#app')
