<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAdminStore } from '@/stores/admin'

const router = useRouter()
const route = useRoute()
const adminStore = useAdminStore()

const menus = [
  { key: 'dashboard', label: '数据概览', icon: 'dashboard' },
  { key: 'goods', label: '商品管理', icon: 'goods' },
  { key: 'orders', label: '订单管理', icon: 'orders' },
  { key: 'users', label: '用户管理', icon: 'users' },
  { key: 'categories', label: '分类管理', icon: 'categories' },
  { key: 'banners', label: '轮播图管理', icon: 'banners' },
]

const currentPage = computed(() => {
  const name = route.name?.toString() || ''
  const match = menus.find(m => name.startsWith(m.key))
  return match?.key || 'dashboard'
})

const pageTitle = computed(() => {
  const m = menus.find(m => m.key === currentPage.value)
  return m?.label || '数据概览'
})

function onMenuClick(menu: typeof menus[0]) {
  router.push({ name: menu.key })
}

function goHome() {
  router.push('/dashboard')
}

function onLogout() {
  adminStore.logout()
  router.replace('/login')
}

const adminInitial = computed(() => {
  const info = adminStore.adminInfo
  const str = info?.nickname || info?.username || 'A'
  return String(str)[0].toUpperCase()
})
</script>

<template>
  <div class="admin-app">
    <!-- Sidebar -->
    <aside class="sidebar">
      <div class="sidebar-logo" @click="goHome">Clothes<span>.</span></div>
      <ul class="nav-list">
        <li
          v-for="item in menus"
          :key="item.key"
          :class="['nav-item', { active: currentPage === item.key }]"
          @click="onMenuClick(item)"
        >
          <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <template v-if="item.key === 'dashboard'">
              <path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/>
              <polyline points="9 22 9 12 15 12 15 22"/>
            </template>
            <template v-if="item.key === 'goods'">
              <path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/>
              <line x1="3" y1="6" x2="21" y2="6"/>
              <path d="M16 10a4 4 0 01-8 0"/>
            </template>
            <template v-if="item.key === 'orders'">
              <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/>
              <polyline points="14 2 14 8 20 8"/>
              <line x1="16" y1="13" x2="8" y2="13"/>
              <line x1="16" y1="17" x2="8" y2="17"/>
            </template>
            <template v-if="item.key === 'users'">
              <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/>
              <circle cx="12" cy="7" r="4"/>
            </template>
            <template v-if="item.key === 'categories'">
              <path d="M4 20h16M4 4h16v12H4z"/>
            </template>
            <template v-if="item.key === 'banners'">
              <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
              <circle cx="8.5" cy="8.5" r="1.5"/>
              <polyline points="21 15 16 10 5 21"/>
            </template>
          </svg>
          {{ item.label }}
        </li>
      </ul>
      <div class="sidebar-footer">
        <div class="user-mini">
          <div class="user-avatar">{{ adminInitial }}</div>
          <div>
            <div class="user-name">{{ adminStore.adminInfo?.nickname || adminStore.adminInfo?.username || 'Admin' }}</div>
            <div class="user-role">超级管理员</div>
          </div>
        </div>
      </div>
    </aside>

    <!-- Main Area -->
    <main class="main">
      <header class="topbar">
        <div class="breadcrumb">管理后台 / <strong>{{ pageTitle }}</strong></div>
        <div class="topbar-actions">
          <button class="icon-btn" title="搜索">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
            </svg>
          </button>
          <button class="icon-btn" title="通知">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
              <path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/>
            </svg>
          </button>
          <button class="icon-btn" title="退出" @click="onLogout">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
              <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4M16 17l5-5-5-5M21 12H9"/>
            </svg>
          </button>
        </div>
      </header>

      <div class="content">
        <router-view />
      </div>
    </main>
  </div>
</template>

<style scoped>
.admin-app {
  display: flex;
  width: 100%;
  height: 100%;
  font-family: 'Sora', 'Noto Sans SC', -apple-system, sans-serif;
  background: #f5f3f0;
  color: #1a1a1a;
}

/* ── Sidebar ── */
.sidebar {
  width: 240px;
  flex-shrink: 0;
  background: #f5f3f0;
  border-right: 1px solid #e8e5e0;
  display: flex;
  flex-direction: column;
  padding: 40px 0 24px;
}

.sidebar-logo {
  padding: 0 32px 40px;
  font-family: 'Cormorant Garamond', 'Noto Serif SC', Georgia, serif;
  font-size: 22px;
  font-weight: 600;
  letter-spacing: -0.3px;
  position: relative;
  cursor: pointer;
  color: #1a1a1a;
}

.sidebar-logo::after {
  content: '';
  position: absolute;
  left: 32px;
  right: 32px;
  bottom: 16px;
  height: 1px;
  background: linear-gradient(to right, #e8e5e0, transparent);
}

.sidebar-logo span { color: #c45c4a; }

.nav-list {
  list-style: none;
  flex: 1;
  padding-top: 8px;
  margin: 0;
}

.nav-item {
  padding: 14px 32px;
  font-size: 13px;
  color: #666;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 14px;
  border-left: 2px solid transparent;
  transition: all 0.3s;
  letter-spacing: 0.3px;
  margin: 2px 0;
}

.nav-item:hover {
  color: #1a1a1a;
  background: rgba(0,0,0,0.03);
}

.nav-item.active {
  color: #1a1a1a;
  background: #ffffff;
  border-left-color: #c45c4a;
}

.nav-icon {
  width: 18px;
  height: 18px;
  opacity: 0.5;
  transition: opacity 0.3s;
  flex-shrink: 0;
}

.nav-item.active .nav-icon { opacity: 1; }
.nav-item:hover .nav-icon { opacity: 0.85; }

.sidebar-footer {
  padding: 20px 32px 0;
  border-top: 1px solid #e8e5e0;
  margin: 0 24px;
}

.user-mini {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-avatar {
  width: 34px;
  height: 34px;
  border-radius: 50%;
  background: #faf9f7;
  border: 1px solid #e8e5e0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'Cormorant Garamond', serif;
  font-size: 15px;
  color: #b8963f;
  flex-shrink: 0;
}

.user-name {
  font-size: 13px;
  font-weight: 500;
  color: #1a1a1a;
}

.user-role {
  font-size: 11px;
  color: #999;
  margin-top: 2px;
}

/* ── Main ── */
.main {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.topbar {
  height: 72px;
  background: #ffffff;
  border-bottom: 1px solid #e8e5e0;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 40px;
  flex-shrink: 0;
}

.breadcrumb {
  font-size: 13px;
  color: #666;
}

.breadcrumb strong {
  color: #1a1a1a;
  font-weight: 500;
}

.topbar-actions {
  display: flex;
  align-items: center;
  gap: 16px;
}

.icon-btn {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: transparent;
  border: 1px solid #e8e5e0;
  color: #666;
  cursor: pointer;
  transition: all 0.25s;
}

.icon-btn:hover {
  border-color: #999;
  color: #1a1a1a;
}

.content {
  flex: 1;
  overflow-y: auto;
  padding: 40px;
}

/* ── Scrollbar ── */
::-webkit-scrollbar { width: 5px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb { background: #e8e5e0; border-radius: 3px; }
::-webkit-scrollbar-thumb:hover { background: #999; }
</style>
