# ClothesDemo 项目架构（防失忆速查表）

> 写于 2026-06-17。**每次新开会话第一件事：读这个文件再动手**。
> 关键教训：**"全部重写"= 几乎一定错**。先盘点再动手。

---

## 1. 项目结构

```
D:\AI Code\ClothesDemo\
├── ClothesBack\         # 后端 Servlet + 纯 JDBC + MySQL 8
│   └── src\main\java\org\example\clothesback\
│       ├── servlet\     # 20 个 Servlet，路径 /api/{public|user|admin}/*
│       ├── service\     # 业务层
│       ├── dao\         # 纯 JDBC，return Map<String,Object> 或 List<Map>
│       ├── entity\      # POJO
│       ├── dto\         # 输入 record
│       ├── vo\V.java    # 输出 record (LoginVO / CartItemVO / OrderDetailVO / GoodsDetailVO)
│       └── common\      # Result / PageResult / BizException
├── ClothesUser\         # 前端 Vue 3 + Vant 4 + Vite + Pinia
│   └── src\
│       ├── api\         # 7 个模块（已封装好所有后端调用）
│       ├── stores\      # Pinia: user / cart
│       ├── types\       # model.d.ts / api.d.ts
│       ├── utils\       # request.ts (axios) / img.ts
│       ├── components\desktop\DesktopLayout.vue  # 全局布局（顶导+促销条+页脚）
│       ├── router\index.ts  # 13 个路由，全部用 Desktop* 组件
│       └── views\
│           ├── home\
│           │   ├── HomeView.vue           # ⚠️ 老版（保留，路由未引用）
│           │   └── DesktopHomeView.vue    # ✅ 路由引用
│           ├── category\
│           │   ├── CategoryView.vue
│           │   └── DesktopCategoryView.vue
│           ├── goods\
│           │   ├── GoodsDetail.vue
│           │   └── DesktopGoodsDetailView.vue
│           ├── cart\DesktopCartView.vue
│           ├── user\Desktop{Login,User,Profile,AddressList}View.vue
│           ├── order\Desktop{Order,OrderDetail,OrderConfirm}View.vue
│           └── search\DesktopSearchView.vue
└── Doc\                 # 文档（schema.sql / API_DESIGN / 各指南）
```

---

## 2. 路由表（13 个页面）

| 路径 | 名称 | 组件 | 需要登录 |
|---|---|---|---|
| `/` | home | `views/home/DesktopHomeView.vue` | ❌ |
| `/category` | category | `views/category/DesktopCategoryView.vue` | ❌ |
| `/category/:id` | categoryGoods | 同上 | ❌ |
| `/goods/:id` | goodsDetail | `views/goods/DesktopGoodsDetailView.vue` | ❌ |
| `/cart` | cart | `views/cart/DesktopCartView.vue` | ✅ |
| `/login` | login | `views/user/DesktopLoginView.vue` | ❌ |
| `/user` | user | `views/user/DesktopUserView.vue` | ✅ |
| `/profile` | profile | `views/user/DesktopProfileView.vue` | ✅ |
| `/address` | address | `views/user/DesktopAddressListView.vue` | ✅ |
| `/order` | order | `views/order/DesktopOrderView.vue` | ✅ |
| `/order/:id` | orderDetail | `views/order/DesktopOrderDetailView.vue` | ✅ |
| `/order/confirm` | orderConfirm | `views/order/DesktopOrderConfirmView.vue` | ✅ |
| `/search` | search | `views/search/DesktopSearchView.vue` | ❌ |

**`router/index.ts` 已配置好，不要再改。** 改完会触发 vite 整页 reload，可能炸 HMR。

---

## 3. 后端 API 完整清单

### 公共（无需登录）
| 接口 | 路径 | 返回 |
|---|---|---|
| 轮播 | `GET /api/public/banner` | `[{id,title,image,link,sort}]` |
| 分类树 | `GET /api/public/category` | `[{id,parentId,name,icon,sort,children?:[...]}]` |
| 热卖 | `GET /api/public/goods/hot` | `Goods[]` |
| 新品 | `GET /api/public/goods/new` | `Goods[]` |
| 列表 | `GET /api/public/goods?page&size&categoryId&keyword&sort` | `{list,total,page,size}` |
| 详情 | `GET /api/public/goods/{id}` | `{goods, skus[]}` |
| 评论 | `GET /api/public/comment?goodsId&page&size` | `{list,total,page,size}` |
| 上传 | `POST /api/public/upload` (multipart) | `{url, name, size}` |

### 用户（需登录，Authorization: Bearer xxx）
| 接口 | 路径 | 方法 |
|---|---|---|
| 注册 | `/api/user/register` | POST |
| 登录 | `/api/user/login` | POST → `{token, userInfo}` |
| 登出 | `/api/user/logout` | POST |
| 我的信息 | `/api/user/info` | GET / PUT |
| 改密 | `/api/user/password` | PUT |
| 收货地址 列表 | `/api/user/address` | GET |
| 收货地址 新增 | `/api/user/address` | POST |
| 收货地址 修改 | `/api/user/address/{id}` | PUT |
| 收货地址 删除 | `/api/user/address/{id}` | DELETE |
| 收货地址 设默认 | `/api/user/address/{id}/default` | PUT |
| 购物车 列表 | `/api/user/cart` | GET |
| 购物车 加 | `/api/user/cart` | POST `{skuId,quantity}` |
| 购物车 改数量 | `/api/user/cart/{id}` | PUT `?quantity=` |
| 购物车 选/反 | `/api/user/cart/{id}/select` | PUT `?selected=` |
| 购物车 全选 | `/api/user/cart/select-all` | PUT |
| 购物车 删一项 | `/api/user/cart/{id}` | DELETE |
| 购物车 删选中 | `/api/user/cart/selected` | DELETE |
| 订单 列表 | `/api/user/order?status&page&size` | GET |
| 订单 详情 | `/api/user/order/{id}` | GET |
| 订单 创建 | `/api/user/order` | POST `{addressId,cartIds,remark}` |
| 订单 付款 | `/api/user/order/{id}/pay` | POST |
| 订单 取消 | `/api/user/order/{id}/cancel` | POST |
| 订单 确认收货 | `/api/user/order/{id}/confirm` | POST |
| 收藏 列表 | `/api/user/favorite` | GET |
| 收藏 加 | `/api/user/favorite` | POST `{goodsId}` |
| 收藏 删 | `/api/user/favorite/{goodsId}` | DELETE |
| 评论 我提交的 | `/api/user/comment` | GET |
| 评论 提交 | `/api/user/comment` | POST `{orderId,goodsId,content,rating,images}` |

### 管理员（需 admin token）
所有 `/api/admin/*`，前端 **未使用**。

---

## 4. 数据库表（schema.sql）

| 表 | 关键字段 |
|---|---|
| `user` | id, username, password(MD5), nickname, avatar, phone, email, gender, birthday |
| `admin` | id, username, password, nickname, status |
| `category` | id, parent_id(0=一级), name, icon, sort, status |
| `goods` | id, category_id, name, brand, cover, images(JSON), description, detail(HTML), price, original_price, stock, sales, view_count, status, is_hot, is_new |
| `sku` | id, goods_id, spec(JSON字符串), price, stock, sales, image, sort |
| `address` | id, user_id, receiver, phone, province, city, district, detail, is_default |
| `cart` | id, user_id, goods_id, sku_id, quantity, selected (uk: user_id+sku_id) |
| `orders` | id, order_no, user_id, total_amount, pay_amount, freight_amount, discount_amount, receiver, phone, address, remark, status(0-4), pay_time, ship_time, finish_time, cancel_time |
| `order_item` | id, order_id, goods_id, sku_id, goods_name(快照), goods_cover(快照), spec, price, quantity, subtotal |
| `banner` | id, title, image, link, sort, status |
| `favorite` | id, user_id, goods_id (uk: user_id+goods_id) |
| `comment` | id, user_id, goods_id, order_id, content, rating(1-5), images(JSON) |

**comment 表无昵称/头像字段**——前端要 fallback 显示 `用户 #userId`。

---

## 5. 前端核心文件

### `api/`（后端调用的薄封装，**不要改**）
- `public.ts` — `publicApi.{banners,categories,hotGoods,newGoods,goodsList,goodsDetail,comments,upload}`
- `user.ts` — `userApi.{login,register,info,updateInfo,changePassword}`
- `address.ts` — `addressApi.{list,add,update,remove,setDefault}`
- `cart.ts` — `cartApi.{list,add,updateQty,toggleSelect,selectAll,remove,removeSelected}`
- `order.ts` — `orderApi.{create,list,detail,pay,cancel,confirm}`
- `goods.ts` — `getGoodsList / getGoodsDetail / searchGoods`（次级，可直接用 publicApi）
- `category.ts` — `getCategoryList`（用 publicApi 也行）
- `index.ts` — 统一导出

### `utils/request.ts`
- `http<T>(url, params?, methodOrCfg?)` — 自动加 token、code=200/0 拆 data、code=401 清 token
- 不要修改

### `utils/img.ts`
- `fullImgUrl(path)` — 自动处理本地 `/assets/` vs 后端 `/uploads/` 路径

### `stores/`
- `user.ts` — token + userInfo + isLoggedIn + setToken/logout
- `cart.ts` — items + addItem/removeItem/toggleCheck/toggleAll

### `types/model.d.ts` & `types/api.d.ts`
- 所有后端返回对象的 TS interface 已定义，**优先用**，需要扩展就 here 加

### `components/desktop/DesktopLayout.vue`
- 全站布局：顶部促销条 + 顶导 + 主内容 slot + 页脚
- **新建页面要用 `<DesktopLayout>` 包裹**（与现有 Desktop* 风格一致）
- 提供 `goHome / goCategory / goCart / goUser / goOrder / goLogin / onSearch / userAvatar / cartCount`

---

## 6. 当前的"问题"和"已经做了的"

### ✅ 已完成（2026-06-17 这几次会话做完）
- `DesktopHomeView.vue` — **11 个区块**，从 demo-new.html 风格，max-width 1400px 宽屏
  - 促销条 / Hero (2fr+1fr + 2 侧卡) / 限时秒杀(实时倒计时) / 8 圆分类 / 热卖5列 / 分类专区×4 / 促销双横幅 / 新品5列 / 品牌矩阵 / 服务保障4列
- `DesktopCategoryView.vue` — Hero + 一级 tab + 二级 chip + 价格4档筛选 + 5列 + 5种排序 + 仅显示有货
- `DesktopGoodsDetailView.vue` — 轮播+缩略图+收藏(真接口)+服务保障+SKU+数量+评价(均分+5tab)+猜你喜欢
- **不重写其他 9 个 Desktop* 页面**（cart/login/user/profile/address/order/orderDetail/orderConfirm/search），它们都正常

### ✅ 风格已统一（2026-06-17 19:18 修复）
- 之前：3 个新写的页面**没包 `<DesktopLayout>`**（裸 div），与其他 9 页不一致
- 现在：3 个页面**已用 `<DesktopLayout>` 包裹**（顶导+促销条+页脚），全站 13 页统一
- 删了 3 页里**自己写的** promo-bar（避免和 DesktopLayout 重复）
- 删了详情页自己写的 back-btn header（顶导已有"← 返回"语义）

---

## 7. **下次会话的禁止动作**（血的教训）

| ❌ 错误 | ✅ 正确做法 |
|---|---|
| 用户说"全部重做"立刻重写 | **先读这个 MD**，盘点哪些页面真的缺 |
| 改 `router/index.ts` | **不要改**，路由已配好，改了会触发 reload |
| 改 `api/*.ts` | **不要改**，封装已完整；要新接口在文件内加 |
| 改 `utils/request.ts` | **不要改**，请求层是关键 |
| 改 `types/*.d.ts` | 优先在**现有 interface 加字段**，不要重建 |
| 改 `DesktopLayout.vue` | **不要改**，它是 9 个页面共享的 |
| 创建新 `api/*.ts` 文件 | **不必要**，7 个文件已覆盖 |
| 用 `desktop-` 前缀的 className | 这套是 DesktopLayout 内部用的，新页用自己的 class |
| 用 emoji 图标但大小 ≥ 48px | demo-new 风格用 SVG/CSS 形状优先 |
| 重写 DesktopCartView/OrderView 等 9 个已存在的页面 | **不重写**，要改就局部改 |
| 用户说"内容太少"就直接全替换 | **先看后端**还能加什么（这才是限制） |

---

## 8. 启动 / 测试

```bash
# 后端（独立启动，端口 8080）
cd D:\AI Code\ClothesDemo\ClothesBack
mvn spring-boot:run   # 或 mvn jetty:run / java -jar

# 前端
cd D:\AI Code\ClothesDemo\ClothesUser
npm run dev   # 默认 5173

# 后端起不来 → 走 mvn，看 java 报错
# 前端起不来 → 走 vite，看 [vite] 报错
# 页面空白 → 看 console.log 报错、Network 404
# vite HMR 报 "Cannot set properties of undefined" → 不影响，下次 reload 就好
```

### vite HMR 坑
- 改 `vite.config.ts` / `.env` 会 restart server
- 改 `router/index.ts` 会 page reload（不报错，但客户端状态丢）
- **不要在 vite 重启时改文件**，否则会触发 `handleHMRUpdate` 那个 TypeError

---

## 9. 配色 / 设计 Token

```
背景:     #faf9f7 (主) / #f5f3f0 (次) / #ffffff (卡)
文字:     #1a1a1a (主) / #666666 (次) / #999999 (弱)
主色 accent: #c45c4a (深红棕) / #8b3a2a (深) / #e8a090 (浅)
强调:     #1a1a1a (黑)
功能:     成功 #2d8a5e / 警告 #d4920a / 危险 #dc3545 / 信息 #4a90d9
边框:     #e8e5e0
阴影:     sm 0 1px 3px / md 0 4px 12px / lg 0 8px 24px
圆角:     sm 4px / md 8px / lg 12px / xl 16px
```

字体: `'Inter', 'Noto Sans SC', -apple-system, sans-serif`

---

## 10. 关键数据约束

- `BigDecimal` 价格 → 永远是 `Number(p).toFixed(2)`
- `is_hot / is_new / status / is_default` → 后端是 0/1 TINYINT，**前端 if (x === 1)**
- `images` 字段 → 可能是 `string[]` 或 `string(JSON)`，**前端要兼容两种**（详情页 utils 已处理）
- `sku.spec` → 可能是 string 或 object，前端 specText() 工具函数处理
- 订单 status: 0=待付款 1=待发货 2=待收货 3=已完成 4=已取消
- 评论 rating: 1-5
- 性别: 0=未知 1=男 2=女

---

## 11. 接口返回字段（前后端契约）

`goods` Map 字段：
- `id, categoryId, name, brand, cover, images, description, detail, price, originalPrice, stock, sales, viewCount, status, isHot, isNew, createTime, updateTime`

`sku` Map 字段：
- `id, goodsId, spec, price, stock, sales, image, sort, createTime, updateTime`

`comment` Map 字段：
- `id, userId, goodsId, orderId, content, rating, images(JSON字符串), createTime`
- **无 nickname**，前端 fallback `用户 #userId`

`order` Map 字段：
- `id, orderNo, userId, totalAmount, payAmount, freightAmount, discountAmount, receiver, phone, address(完整字符串), remark, status, payTime, shipTime, finishTime, cancelTime, createTime, items[]`

`orderItem` Map 字段：
- `id, orderId, goodsId, skuId, goodsName, goodsCover, spec, price, quantity, subtotal`

`category` Map 字段：
- `id, parentId, name, icon, sort, status, children?[]`

`address` Map 字段：
- `id, userId, receiver, phone, province, city, district, detail, isDefault`

`banner` Map 字段：
- `id, title, image, link, sort, status`

---

## 12. 写给"未来的我"

- 每次会话**第一件事**：读这个文件
- 用户说"重做"**不等于**"全部重写"——先问范围
- **盘点完再说**有没有缺，不要臆断
- 后端 12 张表，能加的功能有限（收藏/评论/搜索/价格筛选/品牌矩阵都做了），别再"做更多"了
- 真正还能加的：① 优惠券/积分 ② 客服 IM ③ 物流追踪 ④ 直播/短视频 ⑤ 多语言——但都需要**后端先支持**

---

**最后更新**: 2026-06-17 19:13
