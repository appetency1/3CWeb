import { createRouter, createWebHistory } from 'vue-router'
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

router.beforeEach((to, _from, next) => {
  const token = localStorage.getItem('admin_token')
  if (to.meta.requiresAuth && !token) {
    next({ name: 'login', query: { redirect: to.fullPath } })
  } else if (to.name === 'login' && token) {
    next({ name: 'dashboard' })
  } else {
    next()
  }
})

export default router
