<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { useCartStore } from '@/stores/cart'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const cartStore = useCartStore()

const searchValue = ref('')

const userAvatar = computed(() => {
  const str = userStore.userInfo?.nickname || userStore.userInfo?.username || '?'
  return str[0].toUpperCase()
})

const cartCount = computed(() => cartStore.totalCount)

function goHome() { router.push('/') }
function goCategory() { router.push('/category') }
function goCart() {
  if (!userStore.isLoggedIn) { router.push({ name: 'login', query: { redirect: '/cart' } }); return }
  router.push('/cart')
}
function goUser() {
  if (!userStore.isLoggedIn) { router.push({ name: 'login' }); return }
  router.push('/user')
}
function goOrder() {
  if (!userStore.isLoggedIn) { router.push({ name: 'login', query: { redirect: '/order' } }); return }
  router.push('/order')
}
function goLogin() { router.push('/login') }

function onSearch() {
  if (searchValue.value.trim()) {
    router.push({ name: 'search', query: { keyword: searchValue.value } })
  }
}

function isActive(name: string) {
  return route.name === name || route.path.includes('/' + name)
}
</script>

<template>
  <div class="cl-app">
    <!-- 顶部全宽导航栏 -->
    <header class="cl-header">
      <div class="cl-header-inner">
        <!-- Logo -->
        <div class="cl-logo" @click="goHome">
          <div class="cl-logo-icon">M</div>
          <span class="cl-logo-text">MAISON</span>
        </div>

        <!-- 主导航 -->
        <nav class="cl-nav">
          <a :class="['cl-nav-item', isActive('home') ? 'active' : '']" @click="goHome">首页</a>
          <a :class="['cl-nav-item', isActive('category') ? 'active' : '']" @click="goCategory">全部分类</a>
          <a class="cl-nav-item" @click="$router.push('/category/1')">女装</a>
          <a class="cl-nav-item" @click="$router.push('/category/2')">男装</a>
          <a class="cl-nav-item" @click="$router.push('/category/3')">鞋履</a>
          <a class="cl-nav-item" @click="$router.push('/category/4')">包袋</a>
          <a class="cl-nav-item" @click="$router.push('/category/6')">配饰</a>
        </nav>

        <!-- 搜索框 -->
        <div class="cl-search">
          <input v-model="searchValue" placeholder="搜索商品、品牌..." @keyup.enter="onSearch" />
          <button @click="onSearch">🔍</button>
        </div>

        <!-- 右侧操作区 -->
        <div class="cl-actions">
          <button class="cl-icon-btn" @click="goCart" title="购物车">
            🛒
            <span v-if="cartCount > 0" class="cl-badge">{{ cartCount }}</span>
          </button>
          <button class="cl-icon-btn" @click="goOrder" title="我的订单">
            📋
          </button>
          <button class="cl-icon-btn" @click="goUser" title="个人中心">
            👤
          </button>
          <div v-if="userStore.isLoggedIn" class="cl-user-chip" @click="goUser">
            <div class="cl-user-avatar">{{ userAvatar }}</div>
            <span>{{ userStore.userInfo?.nickname || userStore.userInfo?.username }}</span>
          </div>
          <button v-else class="cl-login-btn" @click="goLogin">登录</button>
        </div>
      </div>
    </header>

    <!-- 顶部促销条 -->
    <div class="cl-promo">
      🎉 新用户首单立减 <strong>¥50</strong> · 全场满 <strong>¥299</strong> 包邮 · 7天无理由退换
    </div>

    <!-- 主内容 -->
    <main class="cl-main">
      <slot />
    </main>

    <!-- 页脚 -->
    <footer class="cl-footer">
      <div class="cl-footer-inner">
        <div class="cl-footer-brand">
          <div class="cl-footer-logo">
            <div class="cl-logo-icon">M</div>
            <span class="cl-logo-text">MAISON</span>
          </div>
          <p>探索全球时尚，定义独特风格。精选优质设计师品牌，为你带来独一无二的穿搭体验。</p>
          <div class="cl-social">
            <a>微</a><a>博</a><a>知</a><a>red</a>
          </div>
        </div>
        <div>
          <h4>购物指南</h4>
          <ul><li>购物流程</li><li>会员介绍</li><li>常见问题</li><li>联系客服</li></ul>
        </div>
        <div>
          <h4>配送与售后</h4>
          <ul><li>配送方式</li><li>运费标准</li><li>退换货政策</li><li>退款说明</li></ul>
        </div>
        <div>
          <h4>关于我们</h4>
          <ul><li>品牌故事</li><li>加入我们</li><li>商务合作</li><li>隐私政策</li></ul>
        </div>
      </div>
      <div class="cl-footer-bottom">
        <span>MAISON © 2026 精选时尚商城 · 沪ICP备XXXXXXXX号</span>
        <div class="cl-payments">
          <span>支付宝</span><span>微信支付</span><span>银联</span><span>Visa</span>
        </div>
      </div>
    </footer>
  </div>
</template>

<style scoped>
.cl-app {
  min-height: 100vh;
  background: var(--bg-primary);
  display: flex;
  flex-direction: column;
}

/* ── 顶部导航栏 ── */
.cl-header {
  background: var(--bg-card);
  border-bottom: 1px solid var(--border);
  position: sticky;
  top: 0;
  z-index: 1000;
  box-shadow: var(--shadow-sm);
}

.cl-header-inner {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 40px;
  height: 72px;
  display: flex;
  align-items: center;
  gap: 32px;
}

.cl-logo {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  flex-shrink: 0;
}

.cl-logo-icon {
  width: 38px;
  height: 38px;
  background: linear-gradient(135deg, var(--accent), var(--accent-dark));
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  font-weight: 700;
  color: white;
  letter-spacing: -1px;
}

.cl-logo-text {
  font-size: 20px;
  font-weight: 700;
  color: var(--text-primary);
  letter-spacing: 2px;
}

.cl-nav {
  display: flex;
  gap: 28px;
  flex-shrink: 0;
}

.cl-nav-item {
  font-size: 14px;
  font-weight: 500;
  color: var(--text-secondary);
  cursor: pointer;
  padding: 8px 0;
  position: relative;
  transition: color 0.2s ease;
  text-decoration: none;
}

.cl-nav-item:hover {
  color: var(--text-primary);
}

.cl-nav-item.active {
  color: var(--text-primary);
}

.cl-nav-item.active::after {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  right: 0;
  height: 2px;
  background: var(--accent);
}

.cl-search {
  flex: 1;
  max-width: 320px;
  position: relative;
}

.cl-search input {
  width: 100%;
  height: 40px;
  border: 1.5px solid var(--border);
  border-radius: 20px;
  padding: 0 48px 0 18px;
  font-size: 13px;
  outline: none;
  background: var(--bg-secondary);
  transition: all 0.2s ease;
  box-sizing: border-box;
  color: var(--text-primary);
}

.cl-search input:focus {
  border-color: var(--accent);
  background: var(--bg-card);
}

.cl-search input::placeholder {
  color: var(--text-muted);
}

.cl-search button {
  position: absolute;
  right: 4px;
  top: 50%;
  transform: translateY(-50%);
  width: 32px;
  height: 32px;
  border: none;
  background: var(--accent);
  color: white;
  border-radius: 50%;
  cursor: pointer;
  font-size: 13px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.2s ease;
}

.cl-search button:hover {
  background: var(--accent-dark);
}

.cl-actions {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-left: auto;
}

.cl-icon-btn {
  width: 40px;
  height: 40px;
  border: none;
  background: transparent;
  border-radius: 50%;
  cursor: pointer;
  font-size: 18px;
  color: var(--text-secondary);
  position: relative;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.cl-icon-btn:hover {
  background: var(--bg-secondary);
  color: var(--accent);
}

.cl-badge {
  position: absolute;
  top: 4px;
  right: 4px;
  min-width: 16px;
  height: 16px;
  background: var(--accent);
  color: white;
  font-size: 10px;
  font-weight: 700;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 4px;
}

.cl-user-chip {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 4px 14px 4px 4px;
  background: var(--bg-secondary);
  border-radius: 20px;
  cursor: pointer;
  font-size: 13px;
  color: var(--text-primary);
  transition: all 0.2s ease;
}

.cl-user-chip:hover {
  background: var(--accent-bg);
  color: var(--accent);
}

.cl-user-avatar {
  width: 28px;
  height: 28px;
  background: linear-gradient(135deg, var(--accent), var(--accent-dark));
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 12px;
  font-weight: 700;
}

.cl-login-btn {
  padding: 8px 18px;
  background: var(--accent);
  color: white;
  border: none;
  border-radius: var(--radius-md);
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s ease;
}

.cl-login-btn:hover {
  background: var(--accent-dark);
}

/* ── 促销条 ── */
.cl-promo {
  background: var(--bg-dark);
  color: white;
  text-align: center;
  padding: 10px 20px;
  font-size: 12px;
  font-weight: 500;
  letter-spacing: 0.5px;
}

.cl-promo strong {
  color: var(--accent-light);
  margin: 0 4px;
}

/* ── 主内容 ── */
.cl-main {
  flex: 1;
}

/* ── 页脚 ── */
.cl-footer {
  background: var(--bg-dark);
  color: white;
  padding: 60px 40px 30px;
  margin-top: 60px;
}

.cl-footer-inner {
  max-width: 1400px;
  margin: 0 auto;
  display: grid;
  grid-template-columns: 2fr repeat(3, 1fr);
  gap: 60px;
  margin-bottom: 48px;
}

.cl-footer-brand .cl-footer-logo {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 16px;
}

.cl-footer-brand .cl-logo-text {
  color: white;
}

.cl-footer-brand p {
  font-size: 13px;
  color: rgba(255,255,255,0.6);
  line-height: 1.7;
  margin-bottom: 20px;
  max-width: 360px;
}

.cl-social {
  display: flex;
  gap: 10px;
}

.cl-social a {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(255,255,255,0.1);
  border-radius: 50%;
  color: white;
  font-size: 13px;
  cursor: pointer;
  transition: background 0.2s ease;
}

.cl-social a:hover {
  background: var(--accent);
}

.cl-footer h4 {
  font-size: 13px;
  font-weight: 600;
  letter-spacing: 1px;
  text-transform: uppercase;
  margin-bottom: 20px;
  color: white;
}

.cl-footer ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.cl-footer ul li {
  margin-bottom: 10px;
  font-size: 13px;
  color: rgba(255,255,255,0.6);
  cursor: pointer;
  transition: color 0.2s ease;
}

.cl-footer ul li:hover {
  color: white;
}

.cl-footer-bottom {
  max-width: 1400px;
  margin: 0 auto;
  padding-top: 24px;
  border-top: 1px solid rgba(255,255,255,0.1);
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 12px;
  color: rgba(255,255,255,0.4);
}

.cl-payments {
  display: flex;
  gap: 10px;
}

.cl-payments span {
  padding: 6px 12px;
  background: rgba(255,255,255,0.1);
  border-radius: var(--radius-sm);
  font-size: 11px;
  color: rgba(255,255,255,0.6);
}

/* ── 响应式 ── */
@media (max-width: 1024px) {
  .cl-header-inner {
    padding: 0 20px;
    gap: 20px;
  }
  
  .cl-nav {
    display: none;
  }
  
  .cl-search {
    max-width: 240px;
  }
}

@media (max-width: 768px) {
  .cl-header-inner {
    height: 60px;
    padding: 0 16px;
  }
  
  .cl-search {
    max-width: 180px;
  }
  
  .cl-actions {
    gap: 4px;
  }
  
  .cl-icon-btn {
    width: 36px;
    height: 36px;
  }
  
  .cl-user-chip {
    display: none;
  }
  
  .cl-footer-inner {
    grid-template-columns: 1fr;
    gap: 32px;
  }
  
  .cl-footer-bottom {
    flex-direction: column;
    gap: 16px;
    text-align: center;
  }
}
</style>
