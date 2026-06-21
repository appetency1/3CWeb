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
    // 用户中心（布局 + 子路由）
    {
      path: '/user',
      component: () => import('@/views/user/DesktopUserView.vue'),
      meta: { requiresAuth: true },
      children: [
        {
          path: '',
          name: 'user',
          component: () => import('@/views/user/UserHome.vue'),
        },
        {
          path: 'orders',
          name: 'userOrders',
          component: () => import('@/views/order/DesktopOrderView.vue'),
        },
        {
          path: 'address',
          name: 'userAddress',
          component: () => import('@/views/user/DesktopAddressListView.vue'),
        },
        {
          path: 'favorites',
          name: 'userFavorites',
          component: () => import('@/views/user/DesktopFavoritesView.vue'),
        },
        {
          path: 'profile',
          name: 'userProfile',
          component: () => import('@/views/user/DesktopProfileView.vue'),
        },
        {
          path: 'security',
          name: 'userSecurity',
          component: () => import('@/views/user/DesktopSecurityView.vue'),
        },
        {
          path: 'service',
          name: 'userService',
          component: () => import('@/views/service/DesktopChatView.vue'),
        },
      ],
    },
    // 旧路由重定向到 /user/ 子路由
    {
      path: '/order',
      redirect: { name: 'userOrders' },
    },
    {
      path: '/address',
      redirect: { name: 'userAddress' },
    },
    {
      path: '/favorites',
      redirect: { name: 'userFavorites' },
    },
    {
      path: '/profile',
      redirect: { name: 'userProfile' },
    },
    {
      path: '/security',
      redirect: { name: 'userSecurity' },
    },
    {
      path: '/service',
      redirect: { name: 'userService' },
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

// Auth guard — Cookie 认证，先等 init 完成再判断
router.beforeEach(async (to) => {
  const userStore = useUserStore()
  if (to.meta.requiresAuth && !userStore.initialized) {
    await userStore.init()
  }
  if (to.meta.requiresAuth && !userStore.isLoggedIn) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }
})

export default router
