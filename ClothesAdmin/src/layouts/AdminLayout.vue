<script setup lang="ts">
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAdminStore } from '@/stores/admin'

const router = useRouter()
const route = useRoute()
const adminStore = useAdminStore()

const menus = [
  { name: 'dashboard', title: '数据概览', icon: 'home-o' },
  { name: 'goods', title: '商品管理', icon: 'shopping-cart-o' },
  { name: 'orders', title: '订单管理', icon: 'orders-o' },
  { name: 'users', title: '用户管理', icon: 'contact' },
  { name: 'categories', title: '分类管理', icon: 'label-o' },
  { name: 'banners', title: '轮播图管理', icon: 'photo-o' }
]

const current = ref(menus.findIndex(m => route.name?.toString().startsWith(m.name)))

function onMenuClick(menu: typeof menus[0]) {
  router.push({ name: menu.name })
}

function onLogout() {
  adminStore.logout()
  router.replace('/login')
}
</script>

<template>
  <div class="admin-layout">
    <van-nav-bar title="Clothes 管理后台" class="admin-header">
      <template #right>
        <van-icon name="logout" size="18" @click="onLogout" />
      </template>
    </van-nav-bar>

    <div class="admin-body">
      <van-sidebar v-model="current" class="admin-sidebar">
        <van-sidebar-item
          v-for="menu in menus"
          :key="menu.name"
          :title="menu.title"
          :icon="menu.icon"
          @click="onMenuClick(menu)"
        />
      </van-sidebar>

      <div class="admin-content">
        <router-view />
      </div>
    </div>
  </div>
</template>

<style scoped>
.admin-layout {
  height: 100vh;
  display: flex;
  flex-direction: column;
}
.admin-header {
  flex-shrink: 0;
}
.admin-body {
  flex: 1;
  display: flex;
  overflow: hidden;
}
.admin-sidebar {
  width: 100px;
  flex-shrink: 0;
}
.admin-content {
  flex: 1;
  padding: 16px;
  overflow-y: auto;
  background: #f5f6f9;
}
</style>
