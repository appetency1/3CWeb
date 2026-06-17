<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { userApi } from '@/api/user'

const router = useRouter()
const userStore = useUserStore()

const menuItems = [
  {
    icon: `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2"/><rect x="9" y="3" width="6" height="4" rx="1"/><line x1="9" y1="12" x2="15" y2="12"/><line x1="9" y1="16" x2="15" y2="16"/></svg>`,
    label: '我的订单', path: '/order'
  },
  {
    icon: `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>`,
    label: '收货地址', path: '/address'
  },
  {
    icon: `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 000-7.78z"/></svg>`,
    label: '我的收藏', path: '/favorites'
  },
  {
    icon: `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>`,
    label: '个人资料', path: '/profile'
  },
  {
    icon: `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>`,
    label: '账号安全', path: '/security'
  },
  {
    icon: `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07A19.5 19.5 0 013.07 9.81a19.79 19.79 0 01-3.07-8.68A2 2 0 012 .84h3a2 2 0 012 1.72c.127.96.361 1.903.7 2.81a2 2 0 01-.45 2.11L6.91 8.4a16 16 0 006.18 6.18l1.27-1.27a2 2 0 012.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0122 16.92z"/></svg>`,
    label: '联系客服', path: '/service'
  },
]

onMounted(async () => {
  if (userStore.isLoggedIn && !userStore.userInfo) {
    try {
      const info: any = await userApi.info()
      userStore.setUserInfo(info)
    } catch { /* silent */ }
  }
})

function navigate(path: string) { router.push(path) }

function onLogout() {
  userStore.logout()
  router.push('/login')
}
</script>

<template>
  <DesktopLayout>
    <div class="desktop-user-layout">
      <!-- Left Panel -->
      <div class="desktop-user-panel">
        <div class="desktop-user-panel-header">
          <div class="desktop-user-panel-avatar">
            {{ (userStore.userInfo?.nickname || userStore.userInfo?.username || '?')[0].toUpperCase() }}
          </div>
          <div class="desktop-user-panel-name">
            {{ userStore.userInfo?.nickname || userStore.userInfo?.username || '未登录' }}
          </div>
          <div class="desktop-user-panel-meta" v-if="userStore.isLoggedIn">
            {{ userStore.userInfo?.phone || userStore.userInfo?.email || '' }}
          </div>
          <div class="desktop-user-panel-meta" v-else>
            <span style="color:rgba(255,255,255,0.7);cursor:pointer" @click="router.push('/login')">点击登录 →</span>
          </div>
        </div>

        <div
          v-for="item in menuItems"
          :key="item.label"
          class="desktop-user-menu-item"
          @click="navigate(item.path)"
        >
          <span v-html="item.icon"></span>
          <span>{{ item.label }}</span>
        </div>

        <div v-if="userStore.isLoggedIn" class="desktop-user-menu-item" style="color:var(--danger)" @click="onLogout">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/>
            <polyline points="16 17 21 12 16 7"/>
            <line x1="21" y1="12" x2="9" y2="12"/>
          </svg>
          <span>退出登录</span>
        </div>
      </div>

      <!-- Right Content -->
      <div class="desktop-user-content">
        <div class="desktop-page-title" style="margin-bottom:24px">个人中心</div>

        <!-- Stats -->
        <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:28px">
          <div style="background:var(--accent-bg);border-radius:var(--radius-lg);padding:20px;text-align:center;border:1px solid var(--border)">
            <div style="font-size:28px;font-weight:800;color:var(--accent)">0</div>
            <div style="font-size:12px;color:var(--text-muted);margin-top:4px">全部订单</div>
          </div>
          <div style="background:var(--bg-secondary);border-radius:var(--radius-lg);padding:20px;text-align:center;border:1px solid var(--border)">
            <div style="font-size:28px;font-weight:800;color:var(--warning)">0</div>
            <div style="font-size:12px;color:var(--text-muted);margin-top:4px">待付款</div>
          </div>
          <div style="background:var(--bg-secondary);border-radius:var(--radius-lg);padding:20px;text-align:center;border:1px solid var(--border)">
            <div style="font-size:28px;font-weight:800;color:var(--success)">0</div>
            <div style="font-size:12px;color:var(--text-muted);margin-top:4px">待收货</div>
          </div>
          <div style="background:var(--bg-secondary);border-radius:var(--radius-lg);padding:20px;text-align:center;border:1px solid var(--border)">
            <div style="font-size:28px;font-weight:800;color:var(--info)">0</div>
            <div style="font-size:12px;color:var(--text-muted);margin-top:4px">待评价</div>
          </div>
        </div>

        <!-- User Info -->
        <div v-if="userStore.isLoggedIn">
          <div style="font-size:15px;font-weight:700;color:var(--text-primary);margin-bottom:16px">账户信息</div>
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px">
            <div style="background:var(--bg-secondary);border-radius:var(--radius-md);padding:14px 16px;border:1px solid var(--border)">
              <div style="font-size:11px;color:var(--text-muted);margin-bottom:4px">用户名</div>
              <div style="font-size:14px;color:var(--text-primary)">{{ userStore.userInfo?.username }}</div>
            </div>
            <div style="background:var(--bg-secondary);border-radius:var(--radius-md);padding:14px 16px;border:1px solid var(--border)">
              <div style="font-size:11px;color:var(--text-muted);margin-bottom:4px">昵称</div>
              <div style="font-size:14px;color:var(--text-primary)">{{ userStore.userInfo?.nickname || '未设置' }}</div>
            </div>
            <div style="background:var(--bg-secondary);border-radius:var(--radius-md);padding:14px 16px;border:1px solid var(--border)">
              <div style="font-size:11px;color:var(--text-muted);margin-bottom:4px">手机号</div>
              <div style="font-size:14px;color:var(--text-primary)">{{ userStore.userInfo?.phone || '未绑定' }}</div>
            </div>
            <div style="background:var(--bg-secondary);border-radius:var(--radius-md);padding:14px 16px;border:1px solid var(--border)">
              <div style="font-size:11px;color:var(--text-muted);margin-bottom:4px">邮箱</div>
              <div style="font-size:14px;color:var(--text-primary)">{{ userStore.userInfo?.email || '未绑定' }}</div>
            </div>
          </div>
        </div>
        <div v-else style="text-align:center;padding:40px;color:var(--text-muted)">
          <p>登录后查看完整信息</p>
          <button
            style="background:var(--accent);color:white;border:none;border-radius:var(--radius-md);padding:12px 32px;font-size:14px;font-weight:600;cursor:pointer;margin-top:16px"
            @click="router.push('/login')"
          >去登录</button>
        </div>
      </div>
    </div>
  </DesktopLayout>
</template>
