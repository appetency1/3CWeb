<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { userApi } from '@/api/user'

const router = useRouter()
const userStore = useUserStore()

onMounted(async () => {
  if (userStore.isLoggedIn && !userStore.userInfo) {
    try {
      const info: any = await userApi.info()
      userStore.setUserInfo(info)
    } catch { /* 静默 */ }
  }
})

function onLogout() {
  userStore.logout()
  router.replace('/login')
}

function formatAvatar(nickname?: string, username?: string) {
  const str = nickname || username || '?'
  return str[0].toUpperCase()
}
</script>

<template>
  <div class="user-page">
    <!-- Hero Header -->
    <div class="user-hero">
      <div class="user-avatar-ring">
        <div class="user-avatar">
          {{ formatAvatar(userStore.userInfo?.nickname, userStore.userInfo?.username) }}
        </div>
      </div>
      <div v-if="userStore.isLoggedIn" class="user-info">
        <p class="user-nickname">{{ userStore.userInfo?.nickname || userStore.userInfo?.username }}</p>
        <p class="user-meta">
          <span v-if="userStore.userInfo?.phone">{{ userStore.userInfo.phone }}</span>
          <span v-else class="user-meta-tip">完善个人信息，享受更多权益</span>
        </p>
      </div>
      <div v-else class="user-info">
        <p class="user-nickname">游客用户</p>
        <van-button type="primary" size="small" round class="login-btn" @click="router.push('/login')">
          登录 / 注册
        </van-button>
      </div>
    </div>

    <!-- Order Stats -->
    <div class="order-stats" v-if="userStore.isLoggedIn">
      <div class="stats-header">
        <span class="stats-title">我的订单</span>
        <span class="stats-more" @click="router.push('/order')">
          查看全部 <van-icon name="arrow" size="12" />
        </span>
      </div>
      <div class="stats-grid">
        <div class="stats-item" @click="router.push('/order?status=0')">
          <div class="stats-icon">⏳</div>
          <span class="stats-label">待付款</span>
        </div>
        <div class="stats-item" @click="router.push('/order?status=1')">
          <div class="stats-icon">📦</div>
          <span class="stats-label">待发货</span>
        </div>
        <div class="stats-item" @click="router.push('/order?status=2')">
          <div class="stats-icon">🚚</div>
          <span class="stats-label">待收货</span>
        </div>
        <div class="stats-item" @click="router.push('/order?status=3')">
          <div class="stats-icon">⭐</div>
          <span class="stats-label">待评价</span>
        </div>
      </div>
    </div>

    <!-- Menu List -->
    <div class="menu-section">
      <van-cell-group :border="false" class="menu-group">
        <van-cell
          title="收货地址"
          icon="location-o"
          is-link
          to="/address"
          class="menu-item"
        />
        <van-cell
          title="我的收藏"
          icon="star-o"
          is-link
          @click="() => {}"
          class="menu-item"
        />
        <van-cell
          title="浏览记录"
          icon="clock-o"
          is-link
          @click="() => {}"
          class="menu-item"
        />
      </van-cell-group>

      <van-cell-group :border="false" class="menu-group">
        <van-cell
          title="个人资料"
          icon="user-o"
          is-link
          to="/profile"
          class="menu-item"
        />
        <van-cell
          title="账号安全"
          icon="shield-o"
          is-link
          @click="() => {}"
          class="menu-item"
        />
        <van-cell
          title="联系客服"
          icon="service-o"
          is-link
          @click="() => {}"
          class="menu-item"
        />
        <van-cell
          title="关于我们"
          icon="info-o"
          is-link
          @click="() => {}"
          class="menu-item"
        />
      </van-cell-group>
    </div>

    <!-- Logout -->
    <div v-if="userStore.isLoggedIn" class="logout-area">
      <van-button
        type="default"
        block
        round
        class="logout-btn"
        @click="onLogout"
      >
        退出登录
      </van-button>
    </div>
  </div>
</template>

<style scoped>
.user-page {
  min-height: 100vh;
  background: var(--cl-bg);
  padding-bottom: env(safe-area-inset-bottom);
}

/* Hero */
.user-hero {
  background: var(--cl-primary);
  padding: 40px 20px 32px;
  display: flex;
  align-items: center;
  gap: 16px;
  position: relative;
  overflow: hidden;
}
.user-hero::before {
  content: '';
  position: absolute;
  right: -40px;
  top: -40px;
  width: 200px;
  height: 200px;
  border-radius: 50%;
  background: rgba(255,255,255,0.04);
}
.user-avatar-ring {
  width: 68px;
  height: 68px;
  border-radius: 50%;
  background: rgba(255,255,255,0.15);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.user-avatar {
  width: 58px;
  height: 58px;
  border-radius: 50%;
  background: var(--cl-accent);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  font-weight: 700;
  color: #fff;
  font-family: var(--font-display);
}
.user-info {
  flex: 1;
}
.user-nickname {
  font-family: var(--font-display);
  font-size: 20px;
  font-weight: 600;
  color: #fff;
  margin-bottom: 6px;
}
.user-meta {
  font-size: 12px;
  color: rgba(255,255,255,0.6);
}
.user-meta-tip {
  font-size: 12px;
}
.login-btn {
  background: rgba(255,255,255,0.2) !important;
  border-color: rgba(255,255,255,0.3) !important;
  color: #fff !important;
  font-size: 13px;
}

/* Order Stats */
.order-stats {
  background: var(--cl-bg-card);
  margin: -16px 12px 12px;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  overflow: hidden;
}
.stats-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 16px 10px;
  border-bottom: 1px solid var(--cl-border-light);
}
.stats-title {
  font-size: 14px;
  font-weight: 600;
  color: var(--cl-text-primary);
}
.stats-more {
  font-size: 12px;
  color: var(--cl-text-muted);
  display: flex;
  align-items: center;
  gap: 2px;
  cursor: pointer;
}
.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  padding: 12px 0;
}
.stats-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
}
.stats-item:active {
  opacity: 0.7;
}
.stats-icon {
  font-size: 22px;
}
.stats-label {
  font-size: 11px;
  color: var(--cl-text-secondary);
}

/* Menu */
.menu-section {
  padding: 0 12px;
}
.menu-group {
  margin-bottom: 12px;
  border-radius: var(--radius-lg);
  overflow: hidden;
  box-shadow: var(--shadow-xs);
}
.menu-group :deep(.van-cell-group__content) {
  border-radius: var(--radius-lg);
  overflow: hidden;
}
.menu-item {
  --van-cell-font-size: 14px;
  --van-cell-text-color: var(--cl-text-primary);
  --van-cell-icon-size: 18px;
  --van-cell-icon-color: var(--cl-accent);
}
.menu-item:not(:last-child) {
  border-bottom: 1px solid var(--cl-border-light);
}

/* Logout */
.logout-area {
  padding: 20px 12px 0;
}
.logout-btn {
  background: var(--cl-bg-card) !important;
  border-color: var(--cl-border) !important;
  color: var(--cl-text-secondary) !important;
  font-size: 14px;
  height: 46px;
}
</style>
