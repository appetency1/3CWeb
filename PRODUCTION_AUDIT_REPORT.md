、# ClothesDemo 生产就绪审计报告

> 审计时间：2026-06-20  
> 审计范围：ClothesUser（用户前端）、ClothesAdmin（管理后台）、ClothesBack（Java 后端）、Doc（数据库与文档）  
> 审计方式：本地源码静态分析，未运行任何外部扫描器，未修改任何文件  
> 总分：**38/100（Blocked，不建议上线）**

---

## 一、执行摘要

本次审计从 **安全、数据一致性、可访问性、配置管理、部署运维** 五个维度对项目进行了全量检查。

由于存在以下不可接受的风险，当前版本**不适合直接上线**：

1. 认证 token 存储在 `localStorage`，存在 XSS 窃取风险。
2. 商品详情使用 `v-html` 渲染富文本，存在存储型 XSS。
3. 密码使用 MD5 哈希，默认管理员密码为 `123456`。
4. 数据库密码明文硬编码在 `db.properties`。
5. CORS 配置为 `*`，未限制来源。
6. 没有 CSRF 防护、速率限制、CSP、安全响应头。
7. 订单金额由后端重新计算，但前端展示层有独立折扣逻辑，用户预期价格与后端实际价格可能不一致。
8. 支付接口无真实支付校验，仅修改订单状态。
9. 后端异常信息和密码被打印到日志/直接返回客户端。
10. 项目无单元测试，无回滚方案，无健康检查。

---

## 二、阻塞项（Blockers）—— 上线前必须修复

| 编号 | 风险 | 文件位置 | 问题描述 | 修复建议 |
|------|------|----------|----------|----------|
| B-01 | XSS + Token 泄露 | `ClothesUser/src/utils/request.ts:11` | Token 从 `localStorage` 读取，一旦存在 XSS 即可被盗用。 | 改为 `HttpOnly; Secure; SameSite=Strict` Cookie；或至少改为 `httpOnly` Cookie + 服务端 Session。 |
| B-02 | 存储型 XSS | `ClothesUser/src/views/goods/DesktopGoodsDetailView.vue:402`<br>`ClothesUser/src/views/goods/GoodsDetail.vue:231` | 商品 `detail` 字段直接通过 `v-html` 渲染，管理员保存的富文本会原样执行。 | 使用 DOMPurify 清洗，或改为纯文本/结构化组件渲染；后台保存时同步过滤危险标签。 |
| B-03 | 密码哈希弱 | `ClothesBack/src/main/java/org/example/clothesback/util/MD5Utils.java` | 使用 MD5 存储密码，可被彩虹表快速破解。 | 改用 BCrypt / Argon2 / PBKDF2，并为历史密码提供迁移方案。 |
| B-04 | 默认弱口令 | `Doc/schema.sql:257-258` | 默认管理员 `admin / 123456`，且 README 公开了该密码。 | 强制首次登录修改密码；初始化脚本使用随机强密码或要求环境变量注入。 |
| B-05 | 数据库密码硬编码 | `ClothesBack/src/main/resources/db.properties:4` | `jdbc.password=000000` 明文写入代码库。 | 改为环境变量或配置中心注入，并将 db.properties 加入 `.gitignore`。 |
| B-06 | CORS 过宽 | `ClothesBack/src/main/java/org/example/clothesback/filter/CorsFilter.java:16` | `Access-Control-Allow-Origin: *` 允许任意网站调用接口。 | 改为白名单域名，并限制允许的方法/头。 |
| B-07 | 金额不一致风险 | `ClothesUser/src/views/order/DesktopOrderConfirmView.vue:26-27`<br>`ClothesBack/src/main/java/org/example/clothesback/service/OrderService.java:59-95` | 前端页面显示满减优惠（299-50、500-200），但 `submitOrder` 仅传 `addressId/cartIds/remark`，后端完全不应用折扣。 | 将满减规则落地到后端，前端只展示，最终金额必须由后端计算并返回。 |
| B-08 | 伪造支付 | `ClothesBack/src/main/java/org/example/clothesback/service/OrderService.java:155-168` | `pay()` 直接把状态从 0 改为 1，未对接支付渠道、未校验签名回调。 | 接入真实支付网关，并对回调做幂等、签名校验和订单状态机校验。 |
| B-09 | 异常信息泄露 | `ClothesBack/src/main/java/org/example/clothesback/servlet/BaseServlet.java:49-55` | 非业务异常把 `e.getMessage()` 和 cause 直接返回客户端，可能暴露表结构、SQL 或框架信息。 | 生产环境统一返回 `"服务器繁忙"`，详细错误只记录服务端日志。 |
| B-10 | 日志明文打印密码 | `ClothesBack/src/main/java/org/example/clothesback/dao/UserDao.java:30`<br>`ClothesBack/src/main/java/org/example/clothesback/service/UserService.java:55` | `System.out.println` 打印用户名+明文密码。 | 删除所有 `System.out.println` 调试语句，使用日志框架并脱敏敏感字段。 |

---

## 三、严重问题（Critical）—— 应尽快修复

### 3.1 认证与会话

| 编号 | 文件位置 | 问题 | 建议 |
|------|----------|------|------|
| C-01 | `ClothesBack/src/main/java/org/example/clothesback/util/TokenManager.java:12` | Token 仅存内存 `ConcurrentHashMap`，无 TTL、无过期清理，服务重启全部失效，且无法单点登出。 | 使用 Redis / 数据库存储 token，设置过期时间，并支持主动失效。 |
| C-02 | `ClothesBack/src/main/java/org/example/clothesback/interceptor/AuthInterceptor.java:18-39` | 仅校验 token 存在性，不校验来源、签名、过期时间。 | 增加 token 过期时间、签名、ip/ua 绑定（可选）。 |
| C-03 | `ClothesBack/src/main/java/org/example/clothesback/servlet/user/UserServlet.java:55-60` | 退出登录接口未强制要求登录即可调用（虽然调用了 `AuthInterceptor`，但路径本身在 `/api/user/*`）。 | 统一认证流程，退出接口也应校验身份。 |
| C-04 | `ClothesBack/src/main/java/org/example/clothesback/servlet/admin/AdminServlet.java:64-67` | 管理员改密码只失效当前 token，其他端 token 仍然有效。 | 改密码后应失效该用户所有 token。 |
| C-05 | `ClothesBack/src/main/java/org/example/clothesback/servlet/user/UserServlet.java:83-91` | 用户改密码同样只失效当前 token。 | 改密码后应失效该用户所有 token。 |

### 3.2 文件上传

| 编号 | 文件位置 | 问题 | 建议 |
|------|----------|------|------|
| C-06 | `ClothesBack/src/main/java/org/example/clothesback/servlet/public_/UploadServlet.java:39-47` | 仅校验扩展名，未校验文件内容/MIME 类型，可上传 `.jpg` 后缀的脚本或 SVG。 | 读取文件头 magic bytes 校验；限制 `Content-Type`；使用独立域名/路径存放上传文件。 |
| C-07 | `ClothesBack/src/main/java/org/example/clothesback/servlet/public_/UploadFileServlet.java:33-40` | 路径遍历过滤只检查 `..`，`Paths.get(uploadDir, decoded)` 在某些系统上仍可能被绕过；且上传目录与代码在同一服务器。 | 使用白名单文件名、UUID 重命名；上传目录配置到独立磁盘/容器卷；返回文件前做二次校验。 |
| C-08 | `ClothesUser/src/utils/request.ts` / `ClothesAdmin/src/utils/request.ts` | 文件上传未限制大小，大文件可能导致 OOM 或磁盘打满。 | 前后端同时限制单文件大小（如 5MB）和总大小。 |

### 3.3 SQL 与数据访问

| 编号 | 文件位置 | 问题 | 建议 |
|------|----------|------|------|
| C-09 | `ClothesBack/src/main/java/org/example/clothesback/dao/GoodsDao.java:41` | `ORDER BY` 字段来自用户输入，虽然有 `ALLOWED_SORT` 白名单，但 `parts[0]` 未校验长度，且 `_` 分割逻辑允许 `price_xxx_asc` 绕过。 | 严格校验 sort 字符串格式，建议只接受后端定义的枚举值。 |
| C-10 | `ClothesBack/src/main/java/org/example/clothesback/servlet/admin/UserManageServlet.java:71-74` | 手动拼接 `LIMIT ? OFFSET ?` 到 params 列表，逻辑正确但维护风险高。 | 统一使用 DAO 层分页，避免在 Servlet 层写 SQL。 |
| C-11 | 多处 `SELECT *` | `GoodsDao.java:21,31,59,64,69,74`<br>`OrderDao.java:27,45`<br>`UserDao.java:64` 等 | 返回所有字段，包含 `password` 等敏感字段，增加 IO 与泄露风险。 | 显式指定列，用户/管理接口分别返回不同字段。 |
| C-12 | `UserManageServlet.java:34-37` | 查询单个用户直接返回整行 Map，包含 `password` 字段。 | DTO 脱敏，不返回密码哈希。 |

### 3.4 输入验证与业务逻辑

| 编号 | 文件位置 | 问题 | 建议 |
|------|----------|------|------|
| C-13 | `ClothesBack/src/main/java/org/example/clothesback/servlet/user/UserServlet.java:38-46` | 注册/登录未限制长度、未校验格式，用户名/密码直接透传。 | 增加统一 DTO 校验（长度、字符白名单、邮箱/手机号格式）。 |
| C-14 | `ClothesBack/src/main/java/org/example/clothesback/service/UserService.java:22-52` | 登录失败与账号禁用返回同样的 `400` 状态码，但错误信息不同，可枚举有效用户名。 | 统一错误文案 `"用户名或密码错误"`；账号禁用建议统一返回 401 但不区分原因。 |
| C-15 | `ClothesBack/src/main/java/org/example/clothesback/service/OrderService.java:59-95` | 订单创建时 `freight_amount` 和 `discount_amount` 直接写死为 0。 | 补充运费模板与促销规则计算。 |
| C-16 | `ClothesBack/src/main/java/org/example/clothesback/service/OrderService.java:155-168` | 支付无金额校验，用户可反复调用 `pay` 接口。 | 增加幂等键与状态机校验。 |
| C-17 | `ClothesBack/src/main/java/org/example/clothesback/service/CommentService.java:35-45` | 评论内容未做 HTML/脚本过滤，用户可提交 XSS 载荷，且前端直接展示。 | 入库前转义或限制为纯文本；展示层避免 `v-html`。 |

---

## 四、中等问题（High）—— 影响体验与可维护性

### 4.1 前端可访问性

| 编号 | 文件位置 | 问题 | 建议 |
|------|----------|------|------|
| H-01 | `ClothesUser/src/views/home/DesktopHomeView.vue:331,365,424,459,488` | 大量商品图片无 `alt` 属性。 | 使用商品名称作为 `alt`，装饰性图片用 `alt=""`。 |
| H-02 | `ClothesUser/src/views/goods/DesktopGoodsDetailView.vue:282,291,301,450` | 商品详情图无 `alt`。 | 补充有意义的 `alt` 文本。 |
| H-03 | `ClothesUser/src/views/cart/DesktopCartView.vue:119`<br>`ClothesUser/src/views/order/DesktopOrderConfirmView.vue:79`<br>`ClothesUser/src/views/order/DesktopOrderDetailView.vue:115` | 购物车/订单商品图无 `alt`。 | 补充 `alt`。 |
| H-04 | `ClothesUser/src/views/user/DesktopLoginView.vue:165-166` | `label` 与 `input` 未通过 `for`/`id` 关联。 | 添加 `for` 和 `id`。 |
| H-05 | 所有表单 | 错误提示未使用 `aria-invalid` / `aria-describedby` 关联。 | 为输入框增加可访问性属性。 |
| H-06 | `ClothesAdmin/src/views/goods/GoodsList.vue:128`<br>`ClothesAdmin/src/views/banners/BannerList.vue:145`<br>`ClothesAdmin/src/views/goods/GoodsForm.vue:145` | 管理后台图片无 `alt`。 | 补充 `alt`。 |

### 4.2 前端安全与代码质量

| 编号 | 文件位置 | 问题 | 建议 |
|------|----------|------|------|
| H-07 | `ClothesUser/src/views/search/DesktopSearchView.vue:19-27` | 搜索历史使用 `localStorage` 存储并直接渲染，虽然当前代码已转义，但仍存在潜在的 XSS 风险。 | 读取后转义再渲染；或避免使用 `localStorage` 存储用户输入。 |
| H-08 | `ClothesUser/src/views/order/DesktopOrderConfirmView.vue:39-44` | `applyPromo` 仅设置标志位，无任何校验或金额变化。 | 删除虚假功能或对接真实优惠码接口。 |
| H-09 | `ClothesUser/src/views/order/DesktopOrderConfirmView.vue:46-63` | 下单成功后直接在前端过滤购物车，未等待后端确认。 | 下单成功后重新拉取购物车数据。 |
| H-10 | `ClothesAdmin/src/utils/request.ts:1` | `BASE_URL` 硬编码 `http://localhost:8080/ClothesBack_war/api`。 | 使用环境变量 `import.meta.env.VITE_API_BASE`。 |
| H-11 | `ClothesUser/.env.production:1` vs `ClothesUser/vite.config.ts:31` | 生产环境 base 为 `/ClothesBack_war/api`，开发代理为 `/api`，路径不一致。 | 统一环境变量与代理配置，或文档明确说明。 |

### 4.3 后端代码规范

| 编号 | 文件位置 | 问题 | 建议 |
|------|----------|------|------|
| H-12 | `ClothesBack/src/main/java/org/example/clothesback/service/GoodsService.java:27,32,36,50,61,71` | 多处错误信息包含 `e.getMessage()`。 | 使用统一错误码，不暴露底层异常。 |
| H-13 | `ClothesBack/src/main/java/org/example/clothesback/servlet/BaseServlet.java:52` | `e.printStackTrace()` 打印到标准错误。 | 使用日志框架记录。 |
| H-14 | `ClothesBack/src/main/java/org/example/clothesback/servlet/admin/AdminServlet.java:58-59` | 在 Servlet 层直接 `new AdminDao()`，破坏分层。 | 通过 Service 层调用。 |
| H-15 | `ClothesBack/src/main/java/org/example/clothesback/service/OrderService.java:46` | 地址归属校验使用 `Map.get("user_id")` 强转，可读性差。 | 使用 DTO/Entity 代替 Map。 |

---

## 五、低优先级 / 建议（Medium / Low）

| 编号 | 文件位置 | 问题 | 建议 |
|------|----------|------|------|
| L-01 | `Doc/schema.sql:9` | `DROP DATABASE IF EXISTS clothes_demo;` 在初始化脚本中，生产环境误执行会导致数据丢失。 | 删除该语句，改为 `CREATE DATABASE IF NOT EXISTS`。 |
| L-02 | `Doc/schema.sql` | 部分高频查询缺少复合索引，如 `orders(user_id, status)`、`orders(status, create_time)`、`goods(name)` 全文索引。 | 根据查询场景补充索引。 |
| L-03 | `Doc/schema.sql:250-251` | `comment` 表缺少 `idx_user_id` 索引。 | 为 `comment.user_id` 增加索引。 |
| L-04 | `ClothesBack/src/main/resources/db.properties:2` | MySQL URL 中 `useSSL=false` 和 `allowPublicKeyRetrieval=true` 降低了连接安全性。 | 生产环境启用 SSL，关闭 `allowPublicKeyRetrieval`。 |
| L-05 | `ClothesBack/src/main/webapp/WEB-INF/web.xml` | 未配置安全头（CSP、X-Frame-Options、X-Content-Type-Options 等）。 | 增加安全头过滤器。 |
| L-06 | `ClothesBack/src/main/java/org/example/clothesback/filter/CorsFilter.java` | 未配置 `Access-Control-Allow-Credentials`，且允许所有来源。 | 白名单 + 按需开启 credentials。 |
| L-07 | 项目根目录 | 存在 `.bak.vue` 备份文件，可能被误提交。 | 清理备份文件或加入 `.gitignore`。 |
| L-08 | `ClothesBack/pom.xml` | 已引入 JUnit，但 `src/test` 完全为空。 | 为核心业务（下单、支付、库存）补充单元测试。 |
| L-09 | 项目整体 | 没有 CI/CD、健康检查、回滚方案、监控告警。 | 补充 `README` 运维章节，配置健康检查端点。 |
| L-10 | `ClothesUser/src/views/home/DesktopHomeView.vue:71-178` | 限时秒杀倒计时为前端写死（2小时15分43秒），且销量数据直接来自商品表，可能存在虚假宣传风险。 | 改为真实活动接口；销量数据需有审计依据。 |

---

## 六、功能性缺陷与虚假模块（新增）

以下功能在前端有 UI 占位或文案，但实际后端未实现、数据库无对应表，属于"有页面无服务"的虚假功能或半实现功能。

| 编号 | 功能 | 文件位置 | 问题描述 | 风险 |
|------|------|----------|----------|------|
| F-01 | 优惠码/优惠券 | `ClothesUser/src/views/cart/DesktopCartView.vue:156-163`<br>`ClothesUser/src/views/order/DesktopOrderConfirmView.vue:162-165` | 前端提供优惠码输入框，点击"应用"仅 `showToast('优惠码已应用')`，未调用任何后端接口，金额也未变化。 | 用户误以为已优惠，实际支付金额未变；虚假宣传风险。 |
| F-02 | 优惠券数量 | `ClothesUser/src/views/user/DesktopProfileView.vue:169-172`<br>`ClothesUser/src/views/user/DesktopUserView.vue:82-85` | 个人中心展示"优惠券 0"，但数据库无 `coupon` 表，后端无优惠券接口。 | 功能占位，无法扩展。 |
| F-03 | 会员/积分 | `ClothesUser/src/views/user/DesktopUserView.vue:75-85` | 显示"✦ 黄金会员"、"积分 0"，但数据库无 `member_level` / `user_points` 表，后端无相关接口。 | 会员权益、积分兑换均无法落地。 |
| F-04 | 限时秒杀 | `ClothesUser/src/views/home/DesktopHomeView.vue:25,143-148,309-327` | 秒杀倒计时写死为 `02:15:43`；秒杀商品从 `hotGoods` 中挑选，不是真实活动数据；无 `seckill` / `activity` 表。 | 虚假宣传、价格欺诈风险。 |
| F-05 | 专属客服 | `ClothesUser/src/views/user/DesktopUserView.vue:111-114`<br>`ClothesUser/src/components/desktop/DesktopLayout.vue:160` | 点击"联系客服"跳转 `/service`，但路由表中无该路由，会进入 404。 | 功能不可用。 |
| F-06 | 头像上传 | `ClothesUser/src/views/user/ProfileView.vue:89` | 移动端个人资料页提示"点击头像更换（开发中）"。 | 功能未实现。 |
| F-07 | 退款/售后 | `ClothesAdmin/src/views/orders/OrderList.vue:57-64`<br>`ClothesBack/src/main/java/org/example/clothesback/service/OrderService.java:241-263` | 管理后台"退款"按钮调用 `refundOrder` 后仅 Toast 提示；后端 `refund()` 只是恢复库存+改状态，未对接支付渠道真实退款。 | 用户已付款但无法真正退款，存在资损与法律风险。 |
| F-08 | 运费计算 | `ClothesUser/src/views/cart/DesktopCartView.vue:177-180`<br>`ClothesBack/src/main/java/org/example/clothesback/service/OrderService.java:82-85` | 运费固定显示 ¥0.00，后端订单创建时 `freight_amount` 硬编码为 0。 | 无法支持运费模板、偏远地区加价等。 |
| F-09 | 促销 Banner 文案 | `ClothesUser/src/views/home/DesktopHomeView.vue:501-518` | "限时 8 折"、"满 199 减 30" 等文案写死，无对应活动配置。 | 虚假宣传。 |
| F-10 | 服务保障文案 | `ClothesUser/src/views/home/DesktopHomeView.vue:523-554`<br>`ClothesUser/src/components/desktop/DesktopLayout.vue:158-164` | "24 小时专属客服"、"7 天无理由"、"假一赔十"等仅为页面文案，无实际规则与流程支撑。 | 虚假宣传、消费纠纷风险。 |
| F-11 | 商品销量 | `ClothesUser/src/views/home/DesktopHomeView.vue:143-148` | 秒杀区显示"已售 xxx"，数据直接来自商品表的 `sales` 字段，可被管理员随意修改。 | 销量造假风险。 |
| F-12 | 消息通知 | 多处 footer / 个人中心 | 无 "消息中心"、"通知" 页面与表。 | 功能缺失。 |

### 影响评估

- **法律/合规风险**：F-01、F-04、F-09、F-10 的虚假折扣、销量、服务承诺可能违反《广告法》/《消费者权益保护法》。
- **资损风险**：F-07 退款未真实执行，用户付款后无法退款。
- **体验风险**：F-05、F-06、F-12 导致用户点击无反应或功能不可用。

---

## 七、按模块汇总

### 7.1 安全问题 Top 10
1. **B-01** Token 存储在 localStorage（XSS 窃取）
2. **B-02** `v-html` 渲染商品详情（存储型 XSS）
3. **B-03** MD5 密码哈希
4. **B-04** 默认管理员弱口令
5. **B-05** 数据库密码硬编码
6. **B-06** CORS `*`
7. **B-07** 前后端折扣不一致
8. **B-08** 伪造支付
9. **C-06/C-07** 文件上传校验不足
10. **C-17** 评论内容未过滤 XSS

### 7.2 业务正确性问题

1. **B-07** 前端满减后端不生效
2. **B-08** 支付无真实校验
3. **C-15** 运费/折扣硬编码为 0
4. **C-16** 支付接口幂等缺失
5. **F-04/F-09/F-10/F-11** 秒杀、销量、促销、服务承诺不真实

### 7.3 可访问性问题

1. **H-01 ~ H-06** 大量图片缺少 `alt`
2. **H-04** 登录表单 label 未关联 input
3. **H-05** 错误提示未关联输入框

### 7.4 配置与部署问题

1. **B-05** 数据库密码硬编码
2. **B-06** CORS 过宽
3. **H-10/H-11** 前端 API 地址配置混乱
4. **L-04** MySQL 连接安全参数不当
5. **L-05** 缺少安全响应头
6. **L-07** 备份文件残留
7. **L-08** 无测试
8. **L-09** 无 CI/CD 与回滚方案

### 7.5 功能性虚假/半实现模块

1. **F-01** 优惠码/优惠券
2. **F-02** 优惠券数量
3. **F-03** 会员/积分
4. **F-04** 限时秒杀
5. **F-05** 专属客服
6. **F-06** 头像上传
7. **F-07** 退款/售后
8. **F-08** 运费计算
9. **F-09** 促销 Banner 文案
10. **F-10** 服务保障文案
11. **F-11** 商品销量真实性
12. **F-12** 消息通知

---

## 八、修复优先级建议

### 第一阶段（上线前必须完成，预计 5-7 天）

**安全与合规（最高优先级）：**

1. 替换 MD5 为 BCrypt，初始化脚本不再使用弱口令。
2. Token 改为 HttpOnly Cookie + 服务端 Session/Redis。
3. 修复 `v-html` XSS：后台保存时过滤 + 前端渲染时清洗。
4. 数据库密码改为环境变量。
5. CORS 改为白名单。
6. 将满减规则落地到后端，前端只展示。
7. 支付接口接入真实支付或至少增加金额/签名/幂等校验。
8. 删除 `System.out.println` 与 `e.printStackTrace()`，统一错误响应。
9. 文件上传增加内容/MIME/大小校验。

**功能合规（避免法律风险）：**

10. 下线或屏蔽虚假功能入口：优惠码、秒杀倒计时、促销 Banner 文案、服务保障文案，直到后端真实实现。
11. 退款接口必须对接真实支付渠道退款，否则关闭管理员退款按钮。
12. 商品销量展示需明确数据来源，避免误导消费者。

### 第二阶段（上线后 1-2 周内完成）

1. 补充图片 `alt` 与表单可访问性。
2. 增加速率限制、CSRF 防护、CSP、安全响应头。
3. 评论内容 XSS 过滤。
4. 清理 `.bak` 文件，完善 `.gitignore`。
5. 补充核心单元测试。
6. 实现客服入口或移除未实现的 `/service` 跳转。

### 第三阶段（持续优化）

1. 数据库索引优化。
2. 引入 CI/CD、健康检查、日志聚合。
3. 代码分层重构（Servlet 层不写 SQL）。
4. 编写部署与回滚文档。

---

## 九、证据清单

本次审计检查过的关键文件：

- 后端源码
  - `ClothesBack/src/main/java/org/example/clothesback/util/TokenManager.java`
  - `ClothesBack/src/main/java/org/example/clothesback/util/MD5Utils.java`
  - `ClothesBack/src/main/java/org/example/clothesback/util/JdbcUtils.java`
  - `ClothesBack/src/main/java/org/example/clothesback/util/IdGenerator.java`
  - `ClothesBack/src/main/java/org/example/clothesback/servlet/BaseServlet.java`
  - `ClothesBack/src/main/java/org/example/clothesback/servlet/user/UserServlet.java`
  - `ClothesBack/src/main/java/org/example/clothesback/servlet/user/OrderServlet.java`
  - `ClothesBack/src/main/java/org/example/clothesback/servlet/user/CartServlet.java`
  - `ClothesBack/src/main/java/org/example/clothesback/servlet/user/CommentServlet.java`
  - `ClothesBack/src/main/java/org/example/clothesback/servlet/user/FavoriteServlet.java`
  - `ClothesBack/src/main/java/org/example/clothesback/servlet/admin/AdminServlet.java`
  - `ClothesBack/src/main/java/org/example/clothesback/servlet/admin/GoodsManageServlet.java`
  - `ClothesBack/src/main/java/org/example/clothesback/servlet/admin/OrderManageServlet.java`
  - `ClothesBack/src/main/java/org/example/clothesback/servlet/admin/UserManageServlet.java`
  - `ClothesBack/src/main/java/org/example/clothesback/servlet/public_/UploadServlet.java`
  - `ClothesBack/src/main/java/org/example/clothesback/servlet/public_/UploadFileServlet.java`
  - `ClothesBack/src/main/java/org/example/clothesback/service/UserService.java`
  - `ClothesBack/src/main/java/org/example/clothesback/service/AdminService.java`
  - `ClothesBack/src/main/java/org/example/clothesback/service/OrderService.java`
  - `ClothesBack/src/main/java/org/example/clothesback/service/GoodsService.java`
  - `ClothesBack/src/main/java/org/example/clothesback/service/CommentService.java`
  - `ClothesBack/src/main/java/org/example/clothesback/dao/UserDao.java`
  - `ClothesBack/src/main/java/org/example/clothesback/dao/GoodsDao.java`
  - `ClothesBack/src/main/java/org/example/clothesback/dao/OrderDao.java`
  - `ClothesBack/src/main/java/org/example/clothesback/dao/CommentDao.java`
  - `ClothesBack/src/main/java/org/example/clothesback/interceptor/AuthInterceptor.java`
  - `ClothesBack/src/main/java/org/example/clothesback/interceptor/AdminInterceptor.java`
  - `ClothesBack/src/main/java/org/example/clothesback/filter/CorsFilter.java`
  - `ClothesBack/src/main/resources/db.properties`
  - `ClothesBack/src/main/resources/app.properties`
  - `ClothesBack/src/main/webapp/WEB-INF/web.xml`
  - `ClothesBack/pom.xml`

- 前端源码
  - `ClothesUser/src/utils/request.ts`
  - `ClothesUser/src/utils/img.ts`
  - `ClothesUser/src/router/index.ts`
  - `ClothesUser/src/components/desktop/DesktopLayout.vue`
  - `ClothesUser/src/views/user/DesktopLoginView.vue`
  - `ClothesUser/src/views/user/DesktopUserView.vue`
  - `ClothesUser/src/views/user/DesktopProfileView.vue`
  - `ClothesUser/src/views/user/ProfileView.vue`
  - `ClothesUser/src/views/goods/DesktopGoodsDetailView.vue`
  - `ClothesUser/src/views/goods/GoodsDetail.vue`
  - `ClothesUser/src/views/cart/DesktopCartView.vue`
  - `ClothesUser/src/views/order/DesktopOrderConfirmView.vue`
  - `ClothesUser/src/views/order/DesktopOrderView.vue`
  - `ClothesUser/src/views/order/DesktopOrderDetailView.vue`
  - `ClothesUser/src/views/home/DesktopHomeView.vue`
  - `ClothesUser/src/views/search/DesktopSearchView.vue`
  - `ClothesUser/src/views/category/DesktopCategoryView.vue`
  - `ClothesUser/.env.production`
  - `ClothesUser/vite.config.ts`
  - `ClothesAdmin/src/utils/request.ts`
  - `ClothesAdmin/src/router/index.ts`
  - `ClothesAdmin/src/views/goods/GoodsList.vue`
  - `ClothesAdmin/src/views/banners/BannerList.vue`
  - `ClothesAdmin/src/views/orders/OrderList.vue`
  - `ClothesAdmin/src/views/goods/GoodsForm.vue`

- 数据库与文档
  - `Doc/schema.sql`
  - `Doc/goods_data_final.sql`
  - `Doc/migrations/*.sql`
  - `README.md`
  - `.gitignore`

---

## 十、结论

当前项目是一个**功能演示/教学性质的电商系统**，但**距离生产上线还有较大差距**。除安全与数据风险外，还存在大量"有 UI 无服务"的虚假功能，可能引发虚假宣传、用户投诉甚至法律风险。最核心的风险集中在：

- 认证与会话安全（localStorage token、MD5、默认弱口令）
- XSS 与输入过滤（`v-html`、评论、文件上传）
- 密码与敏感信息保护（硬编码、日志泄露）
- 支付与金额一致性（伪支付、前端折扣后端不生效）
- 虚假/半实现功能（秒杀、优惠券、会员积分、客服、退款、运费等）

建议在完成第一阶段修复后，重新进行一轮安全与功能审计，并补充自动化测试与 CI/CD 流程，再考虑小范围上线。

---

## 十一、练手项目功能瘦身建议

如果本项目仅作为**练手/学习作品**，不必追求功能大而全，反而应该把链路做干净。以下是对功能取舍的建议，按"砍掉"、"简化保留"、"必须修的真实 bug"三类划分。

### 11.1 建议砍掉的功能

这些功能对练手价值低，且当前实现存在虚假宣传或法律风险，直接移除 UI 入口和文案更安全。

| 功能 | 理由 |
|------|------|
| **优惠码/优惠券** | 需要完整的优惠券表、领取、使用、叠加规则，练手价值不大，还涉及金额计算风险。当前前端仅 `showToast` 无后端，建议删除输入框。 |
| **会员/积分** | 需要积分流水、等级规则、权益表。当前仅为"黄金会员""积分 0"占位文案，无后端支撑。 |
| **限时秒杀** | 真实秒杀需要库存预热、队列、防超卖，复杂度高。当前倒计时写死、商品从 hot 中挑选，明显虚假。 |
| **专属客服** | 当前点击跳转 `/service` 会 404。无 IM 系统支撑，建议删除入口或只留邮箱链接。 |
| **服务保障文案** | "假一赔十""24h 客服""7 天无理由"等属于具体服务承诺，无规则与流程支撑，建议改成"精选商品""快速发货"等模糊文案。 |
| **退款按钮（Admin）** | 当前未对接支付渠道，点了只是改状态，用户拿不到钱。建议要么屏蔽按钮，要么文案改为"标记退款（测试用）"。 |
| **运费明细** | 当前固定 ¥0.00，无运费模板。建议直接显示"全场包邮"或不展示运费行。 |
| **消息通知中心** | 无消息表、无通知页、无推送，建议移除相关入口。 |

### 11.2 建议保留但简化的功能

这些是电商核心链路，练手价值高，保持精简即可。

| 功能 | 简化方案 |
|------|----------|
| **收藏** | 保留，已有完整前后端链路。 |
| **购物车 → 下单 → 订单列表** | 保留，这是电商最核心的链路。 |
| **支付** | 可保留"模拟支付"按钮，但必须在 UI 上明确标注"模拟支付（测试用）"。 |
| **评论** | 保留，但只做纯文本评论，暂不支持图片。 |
| **地址管理** | 保留，表单逻辑完整。 |
| **轮播图 / Banner** | 保留，管理后台已有完整增删改查。 |
| **个人资料** | 保留基础字段（昵称、手机号、邮箱），头像上传可标记为"开发中"或直接隐藏。 |

### 11.3 无论是否瘦身都要修的真实 Bug

以下问题与功能范围无关，属于基础正确性或安全性，练手项目也应修复：

1. **MD5 改 BCrypt** — 登录注册是核心，密码安全不能演示。
2. **Token 别放 localStorage** — 体现对 XSS 的基本理解。
3. **`v-html` 清洗或移除** — 如果保留富文本商品详情，必须做 XSS 防护。
4. **前后端金额一致** — 结算总价必须由后端计算，前端只展示，这是基本正确性。
5. **异常不暴露** — 生产环境返回统一错误信息，不暴露堆栈和 SQL。
6. **数据库密码不硬编码** — 使用环境变量注入。

### 11.4 推荐的项目定位描述

瘦身并修复基础问题后，可以这样描述本项目：

> "一个前后端分离的服饰电商演示系统，完成了用户注册登录、商品浏览、收藏、购物车、下单、模拟支付、订单管理、地址管理、后台商品/分类/轮播图管理等核心链路。"

这样的范围听起来完整，且不包含虚假功能，面试或作品展示时更安全。

### 11.5 最小改动清单（推荐第一波执行）

如果决定只做"瘦身 + 基础修复"，建议按以下顺序：

1. 删除/屏蔽优惠码、会员积分、秒杀、客服入口。
2. 修改首页服务保障文案为中性描述。
3. 管理员退款按钮改为"标记退款（测试用）"或屏蔽。
4. 结算页运费写"全场包邮"或隐藏运费行。
5. 修复 MD5、localStorage token、`v-html`、金额一致性、异常泄露、数据库密码硬编码。
6. 清理 `.bak` 备份文件。

这样项目会从一个"漏洞百出、功能虚假"的演示系统，变成一个**干净、可运行、适合练手**的电商 Demo。