<script setup lang="ts">
import { computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { userApi } from '@/api/user'
import { fullImgUrl } from '@/utils/img'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const userAvatar = computed(() => userStore.userInfo?.avatar || '')
const userInitial = computed(() => (userStore.userInfo?.nickname || userStore.userInfo?.username || '?')[0].toUpperCase())



const menuIcons: Record<string, string> = {
  home: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="m2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25"/></svg>',
  orders: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M9 12h3.75M9 15h3.75M9 18h3.75m3 .75H18a2.25 2.25 0 0 0 2.25-2.25V6.108c0-1.135-.845-2.098-1.976-2.192a48.424 48.424 0 0 0-1.123-.08m-5.801 0c-.065.21-.1.433-.1.664 0 .414.336.75.75.75h4.5a.75.75 0 0 0 .75-.75 2.25 2.25 0 0 0-.1-.664m-5.8 0A2.251 2.251 0 0 1 13.5 2.25H15c1.012 0 1.867.668 2.15 1.586m-5.8 0c-.376.023-.75.05-1.124.08C9.095 4.01 8.25 4.973 8.25 6.108V8.25m0 0H4.875c-.621 0-1.125.504-1.125 1.125v11.25c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125V9.375c0-.621-.504-1.125-1.125-1.125H8.25ZM6.75 12h.008v.008H6.75V12Zm0 3h.008v.008H6.75V15Zm0 3h.008v.008H6.75V18Z"/></svg>',
  address: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/><path d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1 1 15 0Z"/></svg>',
  fav: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 8.25c0-2.485-2.099-4.5-4.688-4.5-1.935 0-3.597 1.126-4.312 2.733-.715-1.607-2.377-2.733-4.313-2.733C5.1 3.75 3 5.765 3 8.25c0 7.22 9 12 9 12s9-4.78 9-12Z"/></svg>',
  profile: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z"/></svg>',
  security: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M16.5 10.5V6.75a4.5 4.5 0 1 0-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 0 0 2.25-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 2.25 0 0 0 2.25 2.25Z"/></svg>',
  chat: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M20.25 8.511c.884.284 1.5 1.128 1.5 2.097v4.286c0 1.136-.847 2.1-1.98 2.193-.34.027-.68.052-1.02.072v3.091l-3-3c-1.354 0-2.694-.055-4.02-.163a2.115 2.115 0 0 1-.825-.242m9.345-8.334a2.126 2.126 0 0 0-.476-.095 48.64 48.64 0 0 0-8.048 0c-1.131.094-1.976 1.057-1.976 2.192v4.286c0 .837.46 1.58 1.155 1.951m9.345-8.334V6.637c0-1.621-1.152-3.026-2.76-3.235A48.455 48.455 0 0 0 11.25 3c-2.115 0-4.198.137-6.24.402-1.608.209-2.76 1.614-2.76 3.235v6.226c0 1.621 1.152 3.026 2.76 3.235.577.075 1.157.14 1.74.194V21l4.155-4.155"/></svg>',
  logout: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M15.75 9V5.25A2.25 2.25 0 0 0 13.5 3h-6a2.25 2.25 0 0 0-2.25 2.25v13.5A2.25 2.25 0 0 0 7.5 21h6a2.25 2.25 0 0 0 2.25-2.25V15m3 0 3-3m0 0-3-3m3 3H9"/></svg>',
}

const menuItems = [
  { icon: 'home', label: '个人中心', name: 'user', exact: true },
  { icon: 'orders', label: '我的订单', name: 'userOrders' },
  { icon: 'address', label: '收货地址', name: 'userAddress' },
  { icon: 'fav', label: '我的收藏', name: 'userFavorites' },
]

const secondaryItems = [
  { icon: 'profile', label: '个人资料', name: 'userProfile' },
  { icon: 'security', label: '账号安全', name: 'userSecurity' },
]

function navigate(name: string) {
  router.push({ name })
}

function onLogout() {
  userStore.logout()
  router.push('/login')
}

function isActive(name: string) {
  if (name === 'user') return route.path === '/user'
  // 子路由: userOrders → 匹配 path /user/orders
  const suffix = name.replace('user', '').toLowerCase() // 'orders', 'address'...
  return route.path === '/user/' + suffix
}

onMounted(async () => {
  if (userStore.isLoggedIn && !userStore.userInfo) {
    try { const info: any = await userApi.info(); userStore.setUserInfo(info) } catch { /* silent */ }
  }
})
</script>

<template>
  <DesktopLayout>
    <div class="profile-page">
      <!-- 左侧边栏（始终显示） -->
      <aside class="sidebar">
        <div class="user-card">
          <div class="avatar-wrap">
            <img v-if="userAvatar" :src="fullImgUrl(userAvatar)" class="avatar-img" />
            <div v-else class="avatar">{{ userInitial }}</div>
            <div class="avatar-ring"></div>
          </div>
          <div class="user-name">{{ userStore.userInfo?.nickname || userStore.userInfo?.username || '游客' }}</div>
          <div class="user-level">✦ 黄金会员</div>
          <div class="user-meta">
            <div class="user-meta-item">
              <span class="num">0</span>
              <span class="label">积分</span>
            </div>
            <div class="user-meta-item">
              <span class="num">0</span>
              <span class="label">优惠券</span>
            </div>
          </div>
        </div>

        <div class="menu-card">
          <div v-for="item in menuItems" :key="item.label"
            class="menu-item"
            :class="{ active: isActive(item.name) }"
            @click="navigate(item.name)"
          >
            <span class="menu-icon" v-html="menuIcons[item.icon]"></span>
            <span>{{ item.label }}</span>
          </div>

          <div class="menu-divider"></div>

          <div v-for="item in secondaryItems" :key="item.label"
            class="menu-item"
            :class="{ active: isActive(item.name) }"
            @click="navigate(item.name)"
          >
            <span class="menu-icon" v-html="menuIcons[item.icon]"></span>
            <span>{{ item.label }}</span>
          </div>

          <div class="menu-divider"></div>

          <div class="menu-item" @click="router.push('/service')">
            <span class="menu-icon" v-html="menuIcons.chat"></span>
            <span>联系客服</span>
          </div>

          <div v-if="userStore.isLoggedIn" class="menu-item menu-logout" @click="onLogout">
            <span class="menu-icon" v-html="menuIcons.logout"></span>
            <span>退出登录</span>
          </div>
        </div>
      </aside>

      <!-- 右侧主内容 -->
      <main class="main-content">
        <router-view />
      </main>
    </div>
  </DesktopLayout>
</template>

<style scoped>
.profile-page {
  max-width: 1400px;
  margin: 0 auto;
  padding: 24px 40px 60px;
  display: grid;
  grid-template-columns: 280px 1fr;
  gap: 32px;
  align-items: start;
}

/* 左侧边栏 */
.sidebar {
  display: flex;
  flex-direction: column;
  gap: 20px;
  position: sticky;
  top: 88px;
  align-self: start;
}
.user-card {
  background: var(--bg-card);
  border: 1px solid var(--border, #e8e5e0);
  border-radius: var(--radius-lg, 12px);
  padding: 32px 24px;
  text-align: center;
  box-shadow: var(--shadow-sm, 0 1px 3px rgba(0,0,0,0.04));
}
.avatar-wrap {
  position: relative;
  display: inline-block;
  margin-bottom: 16px;
}
.avatar {
  width: 80px; height: 80px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--accent), var(--accent-dark));
  display: flex; align-items: center; justify-content: center;
  color: white; font-size: 32px; font-weight: 600;
  box-shadow: 0 4px 16px rgba(196,92,74,0.3);
}
.avatar-img {
  width: 80px; height: 80px;
  border-radius: 50%;
  object-fit: cover;
  box-shadow: 0 4px 16px rgba(196,92,74,0.3);
}
.avatar-ring {
  position: absolute; inset: -4px;
  border: 2px solid var(--accent-light, #e8a090);
  border-radius: 50%; opacity: 0.5;
}
.user-name {
  font-size: 18px; font-weight: 600; color: var(--text-primary, #1a1a1a);
  margin-bottom: 6px;
}
.user-level {
  display: inline-flex; align-items: center; gap: 4px;
  background: linear-gradient(135deg, rgba(0,240,255,0.08), rgba(170,102,255,0.06));
  color: #8b6914; font-size: 11px; font-weight: 600;
  padding: 4px 12px; border-radius: 20px;
  letter-spacing: 0.5px;
}
.user-meta {
  margin-top: 16px; padding-top: 16px;
  border-top: 1px solid var(--border, #e8e5e0);
  display: flex; justify-content: center; gap: 24px;
}
.user-meta-item { text-align: center; }
.user-meta-item .num {
  font-size: 18px; font-weight: 700; color: var(--accent);
  display: block;
}
.user-meta-item .label {
  font-size: 11px; color: var(--text-muted, #999); margin-top: 2px;
}

/* 菜单 */
.menu-card {
  background: var(--bg-card);
  border: 1px solid var(--border, #e8e5e0);
  border-radius: var(--radius-lg, 12px);
  overflow: hidden;
  box-shadow: var(--shadow-sm, 0 1px 3px rgba(0,0,0,0.04));
}
.menu-item {
  display: flex; align-items: center; gap: 14px;
  padding: 14px 20px;
  color: var(--text-secondary, #666);
  font-size: 14px; font-weight: 500;
  cursor: pointer; user-select: none;
  border-left: 3px solid transparent;
}
.menu-item:hover {
  background: var(--bg-elevated);
  color: var(--accent);
  border-left-color: var(--accent);
}
.menu-item.active {
  background: var(--bg-elevated);
  color: var(--accent);
  border-left-color: var(--accent);
  font-weight: 600;
}
.menu-icon { width: 20px; text-align: center; font-size: 16px; }
.menu-divider { height: 1px; background: var(--border); margin: 4px 16px; }
.menu-logout { color: var(--accent); }
.menu-logout:hover { background: var(--bg-elevated); }

/* 右侧主内容 */
.main-content {
  display: flex;
  flex-direction: column;
  gap: 24px;
  min-height: 400px;
}

/* 隐藏嵌入的子页面中的重复 DesktopLayout 元素 */
.main-content :deep(.navbar) { display: none; }
.main-content :deep(.topbar) { display: none; }
.main-content :deep(.footer) { display: none; }
/* 隐藏子页面自身的 page header（标题 + 副标题） */
.main-content :deep(.page-header-order),
.main-content :deep(.page-header-addr),
.main-content :deep(.page-header),
.main-content :deep(.fav-header) { display: none; }
/* 隐藏个人资料页面的面包屑 */
.main-content :deep(.breadcrumbs) { display: none; }
/* 隐藏 AI 客服页面的自身 header */
.main-content :deep(.chat-header) { display: none; }
/* 调整子页面间距，去掉多余的顶部 padding */
.main-content :deep(.order-page),
.main-content :deep(.address-page),
.main-content :deep(.fav-page),
.main-content :deep(.security-page),
.main-content :deep(.chat-page) { padding-top: 0; }

@media (max-width: 1100px) {
  .profile-page { grid-template-columns: 240px 1fr; }
}
@media (max-width: 768px) {
  .profile-page {
    grid-template-columns: 1fr;
    padding: 16px 20px 40px;
  }
  .sidebar { display: none; }
}
</style>
