<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useCartStore } from '@/stores/cart'

const route = useRoute()
const router = useRouter()
const cartStore = useCartStore()

const isDesktop = ref(window.innerWidth >= 768)

function onResize() {
  isDesktop.value = window.innerWidth >= 768
}

onMounted(() => window.addEventListener('resize', onResize))
onUnmounted(() => window.removeEventListener('resize', onResize))
</script>

<template>
  <!-- Desktop Shell -->
  <template v-if="isDesktop">
    <router-view />
  </template>

  <!-- Mobile Shell -->
  <template v-else>
    <div class="app-shell">
      <router-view />
      <van-tabbar
        :model-value="(['home','category','cart','user'].indexOf(String(route.name)))"
        class="app-tabbar"
        @change="(idx: number) => router.push({ name: ['home','category','cart','user'][idx] })"
      >
        <van-tabbar-item name="home" icon="home-o">首页</van-tabbar-item>
        <van-tabbar-item name="category" icon="apps-o">分类</van-tabbar-item>
        <van-tabbar-item
          name="cart"
          icon="shopping-cart-o"
          :badge="cartStore.totalCount > 0 ? cartStore.totalCount : undefined"
        >购物车</van-tabbar-item>
        <van-tabbar-item name="user" icon="user-o">我的</van-tabbar-item>
      </van-tabbar>
    </div>
  </template>
</template>

<style scoped>
.app-shell {
  min-height: 100vh;
  background: var(--cl-bg);
}
.app-tabbar {
  --van-tabbar-height: 56px;
}
</style>
