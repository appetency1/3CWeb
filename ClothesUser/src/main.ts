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

// 尝试从 HttpOnly Cookie 恢复登录会话
import { useUserStore } from '@/stores/user'
const userStore = useUserStore()
userStore.init()

app.mount('#app')
