# 前端开发指南 (Frontend Guide)

> 写给前端开发者的工程实现手册。技术栈已固定：**Vue 3 + Vite 8 + TypeScript + Vant 4 + Pinia + Axios**。
>
> 本项目是服装商城的用户端（ClothesUser），另有管理后台（ClothesAdmin）独立部署。

---

## 一、技术栈

| 项 | 选型 | 版本 |
|---|---|---|
| 框架 | Vue 3 (Composition API) | 3.5 |
| 构建 | Vite | 8 |
| 语言 | TypeScript | 5 |
| UI 库 | Vant 4 (移动端组件库) | 4.9 |
| 状态管理 | Pinia | 3 |
| HTTP 客户端 | Axios | 1.18 |
| 路由 | Vue Router | 4.6 |
| 自动导入 | unplugin-auto-import + unplugin-vue-components | 最新 |
| 环境变量 | Vite .env 文件 | - |

---

## 二、目录结构

```
ClothesUser/
├── index.html                  # 入口 HTML
├── package.json
├── vite.config.ts              # Vite 配置（含别名 / 自动导入配置）
├── tsconfig*.json
├── .env.development            # 开发环境变量
├── .env.production             # 生产环境变量
└── src/
    ├── main.ts                 # 应用入口
    ├── App.vue                 # 根组件（仅含 router-view）
    ├── style.css               # 全局样式
    ├── api/                    # ===== API 层 =====
    │   ├── index.ts            # 统一导出
    │   ├── public.ts           # 公开接口（banner / 分类 / 商品）
    │   ├── user.ts             # 登录 / 注册 / 用户信息
    │   ├── cart.ts             # 购物车
    │   ├── order.ts            # 订单
    │   ├── address.ts          # 收货地址
    │   └── goods.ts            # 商品列表 / 详情 / 搜索
    ├── views/                  # ===== 页面 =====
    │   ├── home/HomeView.vue           # 首页
    │   ├── category/CategoryView.vue   # 分类页
    │   ├── goods/GoodsDetail.vue       # 商品详情
    │   ├── cart/CartView.vue           # 购物车
    │   ├── order/OrderView.vue         # 订单列表
    │   ├── order/OrderDetail.vue      # 订单详情
    │   ├── search/SearchView.vue       # 搜索页
    │   └── user/
    │       ├── LoginView.vue           # 登录 / 注册
    │       ├── UserView.vue           # 个人中心
    │       └── ProfileView.vue        # 个人资料编辑
    ├── stores/                 # ===== Pinia 状态 =====
    │   ├── user.ts             # 登录状态 / token
    │   └── cart.ts             # 购物车（本地，页面刷新丢失）
    ├── router/
    │   └── index.ts            # 路由配置 + 登录拦截
    ├── types/
    │   ├── model.d.ts          # 业务模型（Goods / Order / User 等）
    │   ├── api.d.ts            # API 通用类型（ApiResponse / PageResult）
    │   └── auto-imports.d.ts    # 自动导入的 vue/composables 类型
    ├── utils/
    │   ├── request.ts          # ===== HTTP 核心 =====
    │   └── img.ts              # 图片 URL 拼接工具
    └── components/             # 公共组件（目前未使用）
```

---

## 三、HTTP 核心 — request.ts

这是全项目 HTTP 的入口，**必须先读懂**。

### 3.1 核心函数：`http()`

```ts
// src/utils/request.ts

export const http = Object.assign(fn, { get, post, put, del })
```

`http` 是一个**可调用对象**，默认 GET，支持 3 种调用方式：

**方式 1 — 直接当函数用（最简，推荐）**

```ts
// GET  ?a=1&b=2
http<T>('/api/path', { a: 1, b: 2 })

// POST body = { a: 1, b: 2 }
http<T>('/api/path', { a: 1, b: 2 }, { method: 'POST' })

// POST + 额外配置（headers / timeout 等）
http<T>('/api/upload', undefined, { method: 'POST', data: formData, headers: {...} })
```

**方式 2 — 用 .get / .post / .put / .del**

```ts
http.get<T>('/api/path', { page: 1 })
http.post<T>('/api/path', { name: 'xx' })
http.put<T>('/api/path', { id: 1, name: 'yy' })
http.del<T>('/api/path')
```

> ⚠️ **两种方式内部逻辑完全相同**，选一种风格保持一致即可。

### 3.2 请求拦截器

自动从 `localStorage.token` 读取 token，注入 `Authorization: Bearer <token>` 请求头。**无需手动传 header。**

### 3.3 响应拦截器

拦截 `code !== 200 && code !== 0` 的情况：
- `code === 401`：清除 token，跳转登录页
- 其余 code：Vant Toast 提示 `body.message`

请求成功时**直接返回 `body.data`**，不用再 `.then(r => r.data)`。

### 3.4 统一返回格式

```ts
// 成功时 resolve body.data
// 失败时 reject Error（已在拦截器里 toast 提示）
// 所以 async/await 时需要用 try/catch：
try {
  const data = await publicApi.banners()
} catch (e: any) {
  // e.message 里有错误信息
}
```

### 3.5 环境变量

| 变量 | 值（开发） | 说明 |
|---|---|---|
| `VITE_API_BASE` | `http://localhost:8080/ClothesBack_war/api` | 所有 API 的 base URL |
| `VITE_IMG_BASE` | `http://localhost:8080/ClothesBack_war` | 图片资源 base URL |

> 如果后端部署地址变了，**只需改 `.env.development`**，无需动任何代码。

---

## 四、API 层

### 4.1 所有 API 清单

**公开接口（无需登录）**

| 方法 | 接口 | 参数 | 返回 |
|---|---|---|---|
| `publicApi.banners()` | `/public/banner` | - | `Banner[]` |
| `publicApi.categories()` | `/public/category` | - | `Category[]`（含 children） |
| `publicApi.hotGoods()` | `/public/goods/hot` | - | `Goods[]` |
| `publicApi.newGoods()` | `/public/goods/new` | - | `Goods[]` |
| `publicApi.goodsList(params)` | `/public/goods` | `{ page?, size?, categoryId?, keyword?, sort? }` | `PageResult<Goods>` |
| `publicApi.goodsDetail(id)` | `/public/goods/{id}` | id | `{ goods: Goods, skus: Sku[] }` |
| `publicApi.comments(goodsId, params)` | `/public/comment` | `{ goodsId, page?, size? }` | `PageResult<Comment>` |

**用户接口（需登录，带 token）**

```ts
// 登录
userApi.login({ username, password })  → LoginVO { token, userInfo }
userApi.register({ username, password, phone?, nickname? }) → void
userApi.info()                         → UserInfo
userApi.updateInfo(data)               → void  PUT /user/info
userApi.changePassword({ oldPassword, newPassword }) → void

// 购物车
cartApi.list()                          → CartItem[]
cartApi.add({ skuId, quantity })        → void
cartApi.updateQty(id, quantity)         → void  PUT
cartApi.toggleSelect(id, selected)      → void  PUT
cartApi.selectAll(selected)             → void  PUT
cartApi.remove(id)                      → void  DELETE
cartApi.removeSelected()                → void  DELETE

// 订单
orderApi.create({ addressId, cartIds, remark? }) → { orderId, orderNo }
orderApi.list({ status?, page?, size? })        → PageResult<Order>
orderApi.detail(id)                               → Order
orderApi.pay(id)                                  → void  POST
orderApi.cancel(id)                               → void  POST
orderApi.confirm(id)                              → void  POST

// 收货地址
addressApi.list()                  → Address[]
addressApi.add(data)               → Address  POST
addressApi.update(id, data)        → void     PUT
addressApi.remove(id)              → void     DELETE
addressApi.setDefault(id)          → void     PUT
```

### 4.2 新增 API 方法

在对应的 `api/*.ts` 文件里添加，例如新增收藏接口：

```ts
// src/api/favorite.ts（新建文件）
import { http } from '@/utils/request'
import type { Goods } from '@/types/model'

export const favoriteApi = {
  list: () => http<Goods[]>('/user/favorite'),
  add: (goodsId: number) => http<void>('/user/favorite', { goodsId }, { method: 'POST' }),
  remove: (goodsId: number) => http<void>(`/user/favorite/${goodsId}`, undefined, { method: 'DELETE' }),
}
```

然后在 `src/api/index.ts` 导出：

```ts
export { favoriteApi } from './favorite'
```

---

## 五、类型定义

### 5.1 业务模型（model.d.ts）

所有业务实体类型都在 `src/types/model.d.ts`，按需 import：

```ts
import type { Goods, CartItem, Order, UserInfo, LoginVO, Banner, Category, Sku, Address, OrderItem } from '@/types/model'
```

### 5.2 分页类型（api.d.ts）

```ts
import type { PageResult } from '@/types/api'

// 接口返回 PageResult<Goods> 时：
const { list, total, pageNum, pageSize } = await publicApi.goodsList({ page: 1, size: 10 })
```

### 5.3 新增字段类型

在 `model.d.ts` 对应接口里追加字段即可。**不要新建单独的接口**（如 `GoodsItem`），用 `Pick` / `Omit` 从现有类型派生：

```ts
// 错误：创建了重复的类型
export interface GoodsItem { id: number; name: string; ... }

// 正确：复用现有 Goods
export type GoodsItem = Pick<Goods, 'id' | 'name' | 'cover' | 'price'>
```

---

## 六、图片处理

使用 `src/utils/img.ts` 里的 `fullImgUrl()` 拼接完整图片 URL：

```ts
import { fullImgUrl } from '@/utils/img'

// 相对路径 → 自动拼接 VITE_IMG_BASE
<img :src="fullImgUrl(item.cover)" />

// 绝对/外链 URL → 原样返回
<img :src="fullImgUrl('https://xxx.com/1.jpg')" />

// 空值 → SVG 占位图
```

> 所有商品图片、banner 图片都用这个函数包裹，**不要直接写 `:src="item.cover"`**。

---

## 七、页面开发规范

### 7.1 新建页面

**Step 1**：在 `src/views/` 下创建目录和 `.vue` 文件

```
src/views/activity/ActivityView.vue
```

**Step 2**：在 `src/router/index.ts` 添加路由

```ts
{
  path: '/activity',
  name: 'activity',
  component: () => import('@/views/activity/ActivityView.vue'),
  meta: { requiresAuth: false }  // true=需要登录
}
```

**Step 3**：在 `api/` 下新建对应的 api 文件（如有接口调用）

**Step 4**：页面开发（见 7.2）

### 7.2 页面模板（带完整错误处理）

```vue
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { showLoadingToast, showFailToast, showToast } from 'vant'
import { publicApi } from '@/api/public'
import { fullImgUrl } from '@/utils/img'

const loading = ref(false)
const list = ref<any[]>([])
const finished = ref(false)

async function fetchData() {
  loading.value = true
  try {
    const data: any = await publicApi.hotGoods()
    list.value = data || []
    finished.value = true
  } catch (e: any) {
    showFailToast('加载失败：' + (e?.message || ''))
  } finally {
    loading.value = false
  }
}

onMounted(fetchData)
</script>

<template>
  <div>
    <van-list v-model:loading="loading" :finished="finished" @load="fetchData">
      <van-card
        v-for="item in list"
        :key="item.id"
        :title="item.name"
        :price="item.price"
        :thumb="fullImgUrl(item.cover)"
      />
    </van-list>
  </div>
</template>
```

### 7.3 需要登录的页面

路由里加 `meta: { requiresAuth: true }`，路由守卫会自动拦截并跳转登录页，登录后带 `redirect` 参数返回原页面：

```ts
// router/index.ts
{
  path: '/order',
  name: 'order',
  component: () => import('@/views/order/OrderView.vue'),
  meta: { requiresAuth: true }
}
```

---

## 八、状态管理 — Pinia

### 8.1 用户状态（user.ts）

```ts
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()

userStore.token        // 当前 token（空=未登录）
userStore.isLoggedIn   // computed，是否已登录
userStore.userInfo     // 用户信息对象

userStore.setToken('xxx')      // 登录成功后调用
userStore.setUserInfo(info)    // 登录成功后调用
userStore.logout()             // 退出登录
```

**登录成功后的标准流程**：

```ts
import { userApi } from '@/api/user'
import { useUserStore } from '@/stores/user'

async function handleLogin() {
  try {
    const data = await userApi.login({ username, password })
    userStore.setToken(data.token)
    userStore.setUserInfo(data.userInfo)
    router.replace('/')
  } catch (e) {
    // 拦截器已经 toast，这里不用处理
  }
}
```

### 8.2 购物车状态（cart.ts）

```ts
import { useCartStore } from '@/stores/cart'

const cartStore = useCartStore()

cartStore.items        // CartItem[]  本地数组
cartStore.totalCount   // 总数量
cartStore.totalPrice    // 已选商品总价
cartStore.checkedCount  // 已选数量

cartStore.addItem(item)          // 添加商品
cartStore.removeItem(goodsId, sku) // 删除
cartStore.toggleCheck(goodsId, sku) // 切换选中
cartStore.toggleAll(checked)      // 全选/取消全选
cartStore.clear()                  // 清空
```

> ⚠️ 当前 cartStore 是**纯前端本地状态**，页面刷新后丢失。如需持久化，可将 `items` 改为 `localStorage` 同步或调用 `cartApi.list()` 从后端拉取。

---

## 九、现有页面完成度

| 页面 | 状态 | 说明 |
|---|---|---|
| 首页 `HomeView` | ✅ 全部完成 | API全通，品牌化UI，轮播/分类/热销/新品/商品列表 |
| 登录注册 `LoginView` | ✅ 全部完成 | API全通，品牌化登录注册表单 |
| 商品详情 `GoodsDetail` | ✅ 全部完成 | API全通，轮播图/SKU选择器/评论/加入购物车/立即购买 |
| 分类页 `CategoryView` | ✅ 全部完成 | API全通，侧边栏分类+排序+网格商品 |
| 搜索页 `SearchView` | ✅ 全部完成 | API全通，搜索历史/热门关键词/分页结果 |
| 购物车 `CartView` | ✅ 全部完成 | API全通，后端同步，滑动删除 |
| 订单列表 `OrderView` | ✅ 全部完成 | 全部5个状态Tab，API全通 |
| 订单详情 `OrderDetail` | ✅ 全部完成 | 状态进度条/支付/取消/确认收货全API |
| 个人中心 `UserView` | ✅ 全部完成 | 订单统计入口，API全通 |
| 个人资料 `ProfileView` | ✅ 全部完成 | API全通，昵称/手机/邮箱/性别编辑 |
| 收货地址 `AddressListView` | ✅ 全部完成 | 增删改查+默认地址+路由注册 |
| 订单确认 `OrderConfirmView` | ✅ 全部完成 | 新增页面，地址选择+下单API |

---

## 十、开发注意事项

### 10.1 Vite 自动导入

Vant 组件和 Vue Composition API（`ref` / `onMounted` 等）已配置自动导入，**无需手动 import**：

```vue
<!-- 不需要写 import { ref } from 'vue' -->
<script setup>
const count = ref(0)  // ref 自动可用
</script>
```

### 10.2 Vant 组件自动导入

所有 `vant` 的组件（`van-button` / `van-card` / `van-list` 等）直接在模板使用，**无需 import 和注册**。

### 10.3 TypeScript 类型安全

后端返回的 `code !== 200` 时 `http()` 会 reject，**永远不要省略 try/catch**：

```ts
// ❌ 错误：不处理异常会导致页面静默失败
const data = await publicApi.banners()

// ✅ 正确
try {
  const data: any = await publicApi.banners()
} catch (e: any) {
  showFailToast(e?.message || '加载失败')
}
```

### 10.4 接口 URL 对照

```
前端 http<T>('/public/banner')
后端路由  /api/public/banner          ← 拦截器自动拼接 VITE_API_BASE
```

不要在 api 方法里写 `/api` 前缀，`VITE_API_BASE` 已经包含了。

### 10.5 图片路径

数据库里存的是**相对路径**（如 `/banners/banner1.jpg`），用 `fullImgUrl()` 拼接完整 URL 后访问。后端需要把图片放在 WAR 包解压后的对应目录下。

### 10.6 前后端并行开发

如果后端接口还没写完，前端可以用 **mock 数据**调试：

```ts
// 临时注释掉真实 API，用本地数据
// const data: any = await publicApi.categories()

const data = [
  { id: 1, name: '女装', parentId: 0 },
  { id: 2, name: '男装', parentId: 0 },
]
```

---

## 十一、快速启动

```bash
# 安装依赖（如果 node_modules 丢失）
cd D:\AI Code\ClothesDemo\ClothesUser
pnpm install   # 或 npm install

# 开发模式（热更新）
npm run dev

# 访问地址（端口冲突时会自动换，需看终端输出）
http://localhost:5173/

# 类型检查（不打包，只是检查 TS 错误）
npx vue-tsc -b

# 生产构建
npm run build
```

---

## 十二、待完成功能清单

以下功能已全部完成 ~~（见上方第九节）~~：
- [x] 登录 / 注册 API 接入 + token 持久化
- [x] 商品详情页 API 接入（图片轮播 / SKU 选择 / 评论）
- [x] 分类页 API 接入
- [x] 搜索页 API 接入
- [x] 购物车对接后端 API（已从本地store升级为前后端同步）
- [x] 订单列表 / 详情页完整实现
- [x] 收货地址管理页面 + 路由注册
- [x] 个人资料修改 API 接入
- [x] 购物车数据持久化（后端同步）
- [ ] 收藏功能
- [ ] 管理后台 ClothesAdmin 的用户端开发
