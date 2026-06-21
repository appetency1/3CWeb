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



const menuItems = [
  { icon: '🏠', label: '个人中心', name: 'user', exact: true },
  { icon: '📦', label: '我的订单', name: 'userOrders' },
  { icon: '📍', label: '收货地址', name: 'userAddress' },
  { icon: '❤️', label: '我的收藏', name: 'userFavorites' },
]

const secondaryItems = [
  { icon: '👤', label: '个人资料', name: 'userProfile' },
  { icon: '🔒', label: '账号安全', name: 'userSecurity' },
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
            <span class="menu-icon">{{ item.icon }}</span>
            <span>{{ item.label }}</span>
          </div>

          <div class="menu-divider"></div>

          <div v-for="item in secondaryItems" :key="item.label"
            class="menu-item"
            :class="{ active: isActive(item.name) }"
            @click="navigate(item.name)"
          >
            <span class="menu-icon">{{ item.icon }}</span>
            <span>{{ item.label }}</span>
          </div>

          <div class="menu-divider"></div>

          <div class="menu-item" :class="{ active: route.name === 'userService' }" @click="navigate('userService')">
            <span class="menu-icon">💬</span>
            <span>联系客服</span>
          </div>

          <div v-if="userStore.isLoggedIn" class="menu-item menu-logout" @click="onLogout">
            <span class="menu-icon">🚪</span>
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
  background: var(--bg-card, #fff);
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
  background: linear-gradient(135deg, var(--accent, #c45c4a), var(--accent-dark, #8b3a2a));
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
  background: linear-gradient(135deg, #f5e6c8, #e8d5a8);
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
  font-size: 18px; font-weight: 700; color: var(--accent, #c45c4a);
  display: block;
}
.user-meta-item .label {
  font-size: 11px; color: var(--text-muted, #999); margin-top: 2px;
}

/* 菜单 */
.menu-card {
  background: var(--bg-card, #fff);
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
  background: var(--accent-bg, #fdf5f3);
  color: var(--accent, #c45c4a);
  border-left-color: var(--accent, #c45c4a);
}
.menu-item.active {
  background: var(--accent-bg, #fdf5f3);
  color: var(--accent, #c45c4a);
  border-left-color: var(--accent, #c45c4a);
  font-weight: 600;
}
.menu-icon { width: 20px; text-align: center; font-size: 16px; }
.menu-divider { height: 1px; background: var(--border, #e8e5e0); margin: 4px 16px; }
.menu-logout { color: var(--accent, #c45c4a); }
.menu-logout:hover { background: #fdf2f0; }

/* 右侧主内容 */
.main-content {
  display: flex;
  flex-direction: column;
  gap: 24px;
  min-height: 400px;
}

/* 隐藏嵌入的子页面中的重复 DesktopLayout 元素 */
.main-content :deep(.cl-header) { display: none; }
.main-content :deep(.cl-promo) { display: none; }
.main-content :deep(.cl-footer) { display: none; }
.main-content :deep(.cl-topbar) { display: none; }
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
