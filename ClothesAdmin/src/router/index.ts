import { createRouter, createWebHistory } from 'vue-router'
import { useAdminStore } from '@/stores/admin'
import AdminLayout from '@/layouts/AdminLayout.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: () => import('@/views/login/LoginView.vue')
    },
    {
      path: '/',
      component: AdminLayout,
      meta: { requiresAuth: true },
      children: [
        {
          path: '',
          redirect: '/dashboard'
        },
        {
          path: 'dashboard',
          name: 'dashboard',
          component: () => import('@/views/dashboard/DashboardView.vue')
        },
        {
          path: 'goods',
          name: 'goods',
          component: () => import('@/views/goods/GoodsList.vue')
        },
        {
          path: 'goods/add',
          name: 'goodsAdd',
          component: () => import('@/views/goods/GoodsForm.vue')
        },
        {
          path: 'goods/:id/edit',
          name: 'goodsEdit',
          component: () => import('@/views/goods/GoodsForm.vue')
        },
        {
          path: 'orders',
          name: 'orders',
          component: () => import('@/views/orders/OrderList.vue')
        },
        {
          path: 'users',
          name: 'users',
          component: () => import('@/views/users/UserList.vue')
        },
        {
          path: 'categories',
          name: 'categories',
          component: () => import('@/views/categories/CategoryList.vue')
        },
        {
          path: 'banners',
          name: 'banners',
          component: () => import('@/views/banners/BannerList.vue')
        }
      ]
    }
  ]
})

// 路由守卫：先等 init 完成（Cookie 会话恢复），再决定放行还是跳登录
router.beforeEach(async (to) => {
  const adminStore = useAdminStore()
  if (!adminStore.initialized) {
    await adminStore.init()
  }
  if (to.meta.requiresAuth && !adminStore.isLoggedIn) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }
  if (to.name === 'login' && adminStore.isLoggedIn) {
    return { name: 'dashboard' }
  }
})

export default router
