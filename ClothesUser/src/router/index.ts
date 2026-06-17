import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: () => import('@/views/home/DesktopHomeView.vue'),
    },
    {
      path: '/category',
      name: 'category',
      component: () => import('@/views/category/DesktopCategoryView.vue'),
    },
    {
      path: '/category/:id',
      name: 'categoryGoods',
      component: () => import('@/views/category/DesktopCategoryView.vue'),
    },
    {
      path: '/goods/:id',
      name: 'goodsDetail',
      component: () => import('@/views/goods/DesktopGoodsDetailView.vue'),
    },
    {
      path: '/cart',
      name: 'cart',
      component: () => import('@/views/cart/DesktopCartView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('@/views/user/DesktopLoginView.vue'),
    },
    {
      path: '/user',
      name: 'user',
      component: () => import('@/views/user/DesktopUserView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/profile',
      name: 'profile',
      component: () => import('@/views/user/DesktopProfileView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/address',
      name: 'address',
      component: () => import('@/views/user/DesktopAddressListView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/order',
      name: 'order',
      component: () => import('@/views/order/DesktopOrderView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/order/:id',
      name: 'orderDetail',
      component: () => import('@/views/order/DesktopOrderDetailView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/order/confirm',
      name: 'orderConfirm',
      component: () => import('@/views/order/DesktopOrderConfirmView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/search',
      name: 'search',
      component: () => import('@/views/search/DesktopSearchView.vue'),
    },
  ],
})

// Auth guard
router.beforeEach((to, _from, next) => {
  const userStore = useUserStore()
  if (to.meta.requiresAuth && !userStore.isLoggedIn) {
    next({ name: 'login', query: { redirect: to.fullPath } })
  } else {
    next()
  }
})

export default router
