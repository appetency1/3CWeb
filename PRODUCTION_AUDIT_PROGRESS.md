# ClothesDemo 修复进度报告

> 报告时间：2026-06-20  
> 对比基准：[PRODUCTION_AUDIT_REPORT.md](file:///d:/AI%20Code/ClothesDemo/PRODUCTION_AUDIT_REPORT.md)  
> 检查方式：本地源码静态分析 + `git diff` 对比  
> 当前总分：**52/100（Risky，仍需大量修复）**  
> 上次总分：38/100（Blocked）

---

## 一、评分变化

| 维度 | 上次 | 本次 | 说明 |
|------|------|------|------|
| 安全 | 15/30 | 22/30 | BCrypt、CORS、异常处理已修复，但 token、XSS、支付仍为重大风险 |
| 数据与配置 | 8/25 | 16/25 | 数据库密码支持环境变量，CORS 白名单化，但默认弱口令、硬编码仍存在 |
| 业务正确性 | 7/25 | 10/25 | 前后端折扣一致，但支付、退款、运费仍为虚假实现 |
| 可维护性/部署 | 8/20 | 4/20 | 新增大量 demo 文件污染仓库，.gitignore 未覆盖 |

**结论**：从 "Blocked" 提升到 "Risky"，但仍不建议上线。

---

## 二、已修复问题 ✅

| 原编号 | 问题 | 文件 | 修复说明 |
|--------|------|------|----------|
| **B-03** | 密码使用 MD5 | `ClothesBack/src/main/java/org/example/clothesback/util/MD5Utils.java` | 已改为 BCrypt，`hash()` 生成 BCrypt，`verify()` 兼容旧 MD5，`needsUpgrade()` 自动升级旧密码 |
| **B-05** | 数据库密码硬编码 | `ClothesBack/src/main/java/org/example/clothesback/util/JdbcUtils.java`<br>`ClothesBack/src/main/resources/db.properties` | `JdbcUtils` 优先读取环境变量 `DB_PASSWORD`，`db.properties` 中加了注释说明 |
| **B-06** | CORS `*` | `ClothesBack/src/main/java/org/example/clothesback/filter/CorsFilter.java`<br>`ClothesBack/src/main/resources/app.properties` | 改为读取 `cors.origins` 白名单，默认只允许 localhost 开发端口，并开启 `Access-Control-Allow-Credentials` |
| **B-07** | 前后端折扣不一致 | `ClothesBack/src/main/java/org/example/clothesback/service/OrderService.java`<br>`ClothesUser/src/views/order/DesktopOrderConfirmView.vue` | 后端现在按 `>=500 减 200，>=299 减 50` 计算，前端规则同步 |
| **B-09** | 异常信息泄露 | `ClothesBack/src/main/java/org/example/clothesback/servlet/BaseServlet.java` | 非业务异常不再返回 `e.getMessage()`，统一返回 "服务器繁忙，请稍后重试" |
| **B-10** | 日志明文打印密码 | `ClothesBack/src/main/java/org/example/clothesback/service/UserService.java`<br>`ClothesBack/src/main/java/org/example/clothesback/dao/UserDao.java` | 已删除 `System.out.println` 调试语句 |
| **C-04/C-05** | 改密码后 token 处理 | `ClothesBack/src/main/java/org/example/clothesback/service/UserService.java`<br>`ClothesBack/src/main/java/org/example/clothesback/servlet/admin/AdminServlet.java` | 改密码时密码已用 `MD5Utils.hash()` 存储 |
| **L-07** | .bak 备份文件 | `ClothesUser/src/views/category/DesktopCategoryView.bak.vue`<br>`ClothesUser/src/views/goods/DesktopGoodsDetailView.bak.vue`<br>`ClothesUser/src/views/home/DesktopHomeView.bak.vue` | 已删除 3 个备份文件 |

### 修复亮点

1. **BCrypt 迁移设计合理**：兼容旧 MD5，老用户登录后自动升级为 BCrypt，无需强制重置密码。
2. **CORS 配置正确**：从 `*` 改为白名单 + `Access-Control-Allow-Credentials`，满足生产基本要求。
3. **异常处理规范**：不再把堆栈或 SQL 信息返回给客户端。

---

## 三、未修复问题 ❌

### 3.1 阻塞项仍未修复

| 编号 | 问题 | 文件 | 当前状态 |
|------|------|------|----------|
| **B-01** | Token 存在 localStorage | `ClothesUser/src/utils/request.ts:11`<br>`ClothesUser/src/stores/user.ts`<br>`ClothesAdmin/src/stores/admin.ts` | 未修改，仍存在 XSS 窃取风险 |
| **B-02** | `v-html` 渲染商品详情 | `ClothesUser/src/views/goods/DesktopGoodsDetailView.vue:402`<br>`ClothesUser/src/views/goods/GoodsDetail.vue:231` | 未修改，仍存在存储型 XSS |
| **B-04** | 默认管理员弱口令 | `Doc/schema.sql:255-258` | 仍为 `admin / 123456` |
| **B-08** | 伪造支付 | `ClothesBack/src/main/java/org/example/clothesback/service/OrderService.java:164-174` | 未修改，仍只改状态 |

### 3.2 严重问题仍未修复

| 编号 | 问题 | 文件 | 当前状态 |
|------|------|------|----------|
| **C-01** | TokenManager 内存存储无 TTL | `ClothesBack/src/main/java/org/example/clothesback/util/TokenManager.java` | 未修改 |
| **C-02** | AuthInterceptor 仅校验存在性 | `ClothesBack/src/main/java/org/example/clothesback/interceptor/AuthInterceptor.java` | 未修改 |
| **C-06** | 文件上传只校验扩展名 | `ClothesBack/src/main/java/org/example/clothesback/servlet/public_/UploadServlet.java` | 未修改 |
| **C-07** | UploadFileServlet 路径遍历风险 | `ClothesBack/src/main/java/org/example/clothesback/servlet/public_/UploadFileServlet.java` | 未修改 |
| **C-09** | ORDER BY 仍可绕过（风险降低） | `ClothesBack/src/main/java/org/example/clothesback/dao/GoodsDao.java:153-162` | `field` 已白名单校验，但 `dir` 仍从用户输入取，建议改为枚举 |
| **C-11** | 多处 `SELECT *` | `GoodsDao.java` / `OrderDao.java` / `UserDao.java` 等 | 未修改 |
| **C-12** | UserManageServlet 返回 password | `ClothesBack/src/main/java/org/example/clothesback/servlet/admin/UserManageServlet.java:34-37` | 未修改 |
| **C-13** | 注册/登录未限制长度 | `ClothesBack/src/main/java/org/example/clothesback/servlet/user/UserServlet.java` | 未修改 |
| **C-14** | 登录错误可枚举用户名 | `ClothesBack/src/main/java/org/example/clothesback/service/UserService.java` | 未修改（错误文案统一了但状态码/异常类型仍可区分） |
| **C-15** | 运费硬编码为 0 | `ClothesBack/src/main/java/org/example/clothesback/service/OrderService.java:104` | 折扣已改，运费仍为 0 |
| **C-16** | 支付接口无幂等 | `ClothesBack/src/main/java/org/example/clothesback/service/OrderService.java:164-174` | 未修改 |
| **C-17** | 评论内容未过滤 XSS | `ClothesBack/src/main/java/org/example/clothesback/service/CommentService.java:35-45` | 未修改；且新增 `DesktopOrderDetailView.vue` 评论弹窗，风险面扩大 |

### 3.3 中等问题仍未修复

| 编号 | 问题 | 文件 | 当前状态 |
|------|------|------|----------|
| **H-01 ~ H-06** | 大量图片无 `alt` | 多个 Vue 文件 | 未修改 |
| **H-04** | 登录表单 label 未关联 input | `ClothesUser/src/views/user/DesktopLoginView.vue` | 未修改 |
| **H-10** | Admin BASE_URL 硬编码 | `ClothesAdmin/src/utils/request.ts:1` | 未修改 |
| **H-11** | 生产环境 API 路径不一致 | `ClothesUser/.env.production` vs `vite.config.ts` | 未修改 |
| **H-12/H-13** | Service 层仍返回 e.getMessage / printStackTrace | `GoodsService.java` / `BannerService.java` 等 | 未修改（但 `BaseServlet` 已修复） |

### 3.4 功能虚假模块仍未修复

| 编号 | 功能 | 当前状态 |
|------|------|----------|
| **F-01** | 优惠码/优惠券 | 仍存在 |
| **F-02** | 优惠券数量 | 仍存在 |
| **F-03** | 会员/积分 | 仍存在 |
| **F-04** | 限时秒杀 | 仍存在，倒计时仍写死 |
| **F-05** | 专属客服 | 仍存在，仍跳 404 |
| **F-06** | 头像上传 | 仍存在 |
| **F-07** | 退款/售后 | 仍存在，仍为伪退款 |
| **F-08** | 运费计算 | 仍存在 |
| **F-09** | 促销 Banner 文案 | 仍存在 |
| **F-10** | 服务保障文案 | 仍存在 |
| **F-11** | 商品销量真实性 | 仍存在 |
| **F-12** | 消息通知 | 仍存在 |

### 3.5 低优先级问题仍未修复

- **L-01** `schema.sql` 仍有 `DROP DATABASE IF EXISTS`
- **L-02 ~ L-03** 索引不足
- **L-04** MySQL URL `useSSL=false` / `allowPublicKeyRetrieval=true`
- **L-05** 缺少安全响应头
- **L-08** 无单元测试
- **L-09** 无 CI/CD、健康检查、回滚方案

---

## 四、新增发现的问题 ⚠️

| 编号 | 问题 | 文件 | 说明 |
|------|------|------|------|
| **N-01** | 新增大量 demo 文件污染仓库 | 根目录下 `demo-*.html` / `demo-*.png` 等约 40+ 个文件 | 设计稿/预览文件应放入 `design/` 目录或加入 `.gitignore`，不应与源码混放 |
| **N-02** | `.gitignore` 未覆盖 demo 文件 | `.gitignore` | 当前 `.gitignore` 未包含 `demo-*.html`、`demo-*.png`、`homepage-screenshot.png` 等 |
| **N-03** | 新增评论弹窗但后端未过滤 XSS | `ClothesUser/src/views/order/DesktopOrderDetailView.vue:100-124`<br>`ClothesBack/src/main/java/org/example/clothesback/service/CommentService.java:35-45` | 用户可在订单详情页提交评价，内容未做 HTML/脚本过滤，存在存储型 XSS |
| **N-04** | `DesktopOrderDetailView.vue` 默认倒计时写死 | `ClothesUser/src/views/order/DesktopOrderDetailView.vue:15` | `countdownStr = ref('23:59:59')` 初始写死，虽然会由 `createTime` 覆盖，但加载瞬间会显示错误倒计时 |
| **N-05** | `DesktopOrderView.vue` 的 `payOrder` 注释写 "Simulate payment" | `ClothesUser/src/views/order/DesktopOrderView.vue:59-62` | 前端代码暴露当前支付为模拟实现 |
| **N-06** | `demo-order-detail-redesign.html` 等文件含 `value="123456"` | `demo-client-login-*.html` | 设计稿中硬编码了演示密码，若被扫描可能泄露默认口令 |

---

## 五、按优先级建议的下一步

### 5.1 必须尽快修（否则仍为 Blocked）

1. **B-01 Token 改 Cookie**：`ClothesUser` / `ClothesAdmin` 的 token 存储从 `localStorage` 改为 `HttpOnly Cookie`。
2. **B-02 `v-html` 清洗**：商品详情渲染改为 DOMPurify 清洗或纯文本。
3. **B-04 默认弱口令**：`schema.sql` 中管理员初始密码改为 BCrypt 哈希的强密码，或首次登录强制修改。
4. **B-08 伪支付**：支付接口至少增加金额校验、幂等键、状态机校验。
5. **N-03 评论 XSS**：后端 `CommentService.add()` 对 `content` 做 HTML 转义/过滤。

### 5.2 建议第二波修

1. **C-01 TokenManager 加 TTL**：改为 Redis 或数据库 + 过期时间。
2. **C-06/C-07 文件上传**：校验文件头、限制大小、UUID 重命名。
3. **C-11/C-12 `SELECT *` / 返回 password**：显式指定列，DTO 脱敏。
4. **F-04/F-09/F-10 虚假宣传**：下线秒杀倒计时、修改服务承诺文案。
5. **F-07 伪退款**：对接真实退款或屏蔽退款按钮。
6. **N-01/N-02 demo 文件**：移动到 `design/` 或加入 `.gitignore`。

### 5.3 长期优化

1. 补充单元测试（`ClothesBack/src/test`）。
2. 增加安全响应头、速率限制、CSRF 防护。
3. 完善 `.gitignore` 和 CI/CD。

---

## 六、结论

本次修改方向是对的，尤其是 **BCrypt 迁移、CORS 白名单、异常处理、数据库密码环境变量、折扣一致性** 这几个核心问题修复得很好。但仍有大量阻塞项未动，且**新增的评论功能和 demo 文件引入了新的风险**。

建议下一波优先处理：**token 存储、`v-html`、默认弱口令、支付/退款真实性、评论 XSS、demo 文件清理**。

---

# 附录：第二轮修复记录（2026-06-20）

> 当前总分：**61/100（Risky，但主要安全阻塞项已大幅缓解）**  
> 上一轮总分：52/100

---

## 第二轮已修复问题 ✅

| 原编号 | 问题 | 文件 | 修复说明 |
|--------|------|------|----------|
| **B-02** | `v-html` 存储型 XSS | `ClothesUser/src/views/goods/DesktopGoodsDetailView.vue`<br>`ClothesUser/src/views/goods/GoodsDetail.vue` | 引入 `dompurify`，商品详情渲染前用 `DOMPurify.sanitize()` 清洗 |
| **B-08 部分** | 伪支付无校验 | `ClothesBack/src/main/java/org/example/clothesback/service/OrderService.java:164-180` | 在事务内先查订单状态，仅 `status=0` 可支付；增加 `pay_amount > 0` 金额校验，避免重复支付和金额异常 |
| **B-04 部分** | 默认弱口令 | `ClothesBack/src/main/java/org/example/clothesback/service/AdminService.java`<br>`ClothesBack/src/main/java/org/example/clothesback/vo/V.java`<br>`Doc/schema.sql` | 登录时检测是否为默认 MD5 密码，返回 `needChangePassword=true`；schema.sql 增加注释提示首次登录改密 |
| **C-17** | 评论 XSS | `ClothesBack/src/main/java/org/example/clothesback/service/CommentService.java:43-45` | 对评论内容进行 HTML 实体转义（`<`、`>`、`"`、`'`） |
| **C-12 部分** | 返回 password | `ClothesBack/src/main/java/org/example/clothesback/dao/UserDao.java:75-76` | `listPage` 从 `SELECT *` 改为显式列，不再返回 `password` |
| **H-01 部分** | 图片无 `alt` | `ClothesUser/src/views/category/DesktopCategoryView.vue`<br>`ClothesUser/src/views/order/DesktopOrderConfirmView.vue`<br>`ClothesUser/src/views/order/DesktopOrderDetailView.vue`<br>`ClothesUser/src/views/user/DesktopProfileView.vue`<br>`ClothesAdmin/src/views/goods/GoodsForm.vue` | 为商品图、头像、封面等补充 `alt` 文本 |
| **B-01 部分** | Token 传输方式 | `ClothesBack/src/main/java/org/example/clothesback/servlet/user/UserServlet.java`<br>`ClothesBack/src/main/java/org/example/clothesback/servlet/admin/AdminServlet.java`<br>`ClothesBack/src/main/java/org/example/clothesback/interceptor/AuthInterceptor.java` | 后端登录接口新增 `HttpOnly` Cookie 设置；AuthInterceptor 优先从 Cookie 读取 token，兼容旧 Authorization header |

### 第二轮修复亮点

1. **DOMPurify 选得好**：直接用在 `v-html` 前面，把存储型 XSS 风险降到很低。
2. **支付加了状态机和金额校验**：不再是"无脑改状态"，至少避免了负数支付和重复支付。
3. **默认密码检测 + 强制改密提示**：虽然是"提示"而非"强制拦截"，但已经向安全方向迈出一步。
4. **后端优先支持 HttpOnly Cookie**：为前端彻底移除 localStorage token 打下基础。

---

## 第二轮仍未修复 ❌

| 编号 | 问题 | 当前状态 | 说明 |
|------|------|----------|------|
| **B-01 核心** | Token 仍存 localStorage | **未修复** | 后端已支持 Cookie，但 `ClothesUser/src/utils/request.ts:11` 和 `ClothesUser/src/stores/user.ts:5,12` 仍从 localStorage 读写 token，并手动加到 `Authorization` header。XSS 窃取风险仍在。 |
| **B-01 Admin** | Admin 端 token 仍存 localStorage | **未修复** | `ClothesAdmin/src/utils/request.ts` 和 `ClothesAdmin/src/stores/admin.ts` 未修改。 |
| **B-04 核心** | 默认管理员密码仍是 `123456` | **未根本修复** | `schema.sql` 中仍是 `e10adc3949ba59abbe56e057f20f883e`（MD5 of "123456"），只是加了注释。建议直接改为 BCrypt 强密码哈希。 |
| **B-08 核心** | 仍无真实支付 | **未修复** | 支付仍是模拟支付，`DesktopOrderView.vue:59` 注释写着 `"Simulate payment"`。 |
| **Cookie 安全** | Cookie 设置不完整 | **需优化** | 后端设置的 `token` Cookie：`Secure=false`（生产应为 true）、未设置 `SameSite`（存在 CSRF 风险）、未设置 `MaxAge` 统一过期策略与 `TokenManager` 一致。 |
| **C-01** | TokenManager 内存存储无 TTL | **未修复** | 仍为内存 Map，服务重启失效、无法单点登出、无过期清理。 |
| **C-06/C-07** | 文件上传校验 | **未修复** | 仍只校验扩展名。 |
| **C-11 大部分** | 多处 `SELECT *` | **部分修复** | 仅 `UserDao.listPage` 修复，`GoodsDao`、`OrderDao` 等多处仍是 `SELECT *`。 |
| **C-13** | 注册/登录输入校验 | **未修复** | `UserServlet` 未增加统一 DTO 校验。 |
| **C-14** | 登录错误可枚举用户名 | **未修复** | 错误文案已统一，但状态码/异常类型仍可区分。 |
| **C-15** | 运费硬编码为 0 | **未修复** | 折扣已改，运费仍为 0。 |
| **F-01 ~ F-12** | 功能虚假模块 | **未修复** | 优惠码、秒杀、会员、客服、退款、运费等虚假功能入口和文案均未改动。 |
| **L-01 ~ L-09** | 低优先级问题 | **未修复** | 索引、SSL、安全头、测试、CI/CD 等均未改动。 |

---

## 第二轮新增/发现的问题 ⚠️

| 编号 | 问题 | 文件 | 说明 |
|------|------|------|------|
| **N-07** | JVM 崩溃日志残留 | `d:/AI Code/ClothesDemo/hs_err_pid20572.log` | 项目根目录出现 HotSpot 错误日志，应删除并加入 `.gitignore` |
| **N-08** | `.gitignore` 仍未覆盖 demo 文件和 JVM 日志 | `.gitignore` | demo 文件、截图、JVM 崩溃日志均未被忽略 |

---

## 当前核心阻塞项（只剩 3 个）

1. **前端 Token 必须从 localStorage 移除**：让 axios 自动携带 Cookie，或者前端完全不碰 token。
2. **默认管理员密码必须改为强密码**：不要再用 `123456` 及其 MD5。
3. **真实支付或明确标注模拟支付**：当前代码中 `"Simulate payment"` 注释说明支付仍是模拟实现，要么接真实支付，要么在 UI 明确标注。

---

## 第二轮后的下一步建议

### 必须修（否则上线仍有重大风险）

1. **移除前端 localStorage token**：
   - 删除 `ClothesUser/src/utils/request.ts` 中手动读取 token 的逻辑。
   - 删除 `ClothesUser/src/stores/user.ts` 中 localStorage 读写。
   - 确保 axios `withCredentials: true`，让浏览器自动携带 HttpOnly Cookie。
   - 对 `ClothesAdmin` 做同样改造。
2. **修复默认弱口令**：
   - 在 `Doc/schema.sql` 中把管理员初始密码改为 BCrypt 哈希的强密码（如 `BCrypt.hashpw("ChangeMe@2026", ...)`）。
   - 或在首次登录时强制修改默认密码。
3. **完善 Cookie 安全属性**：
   - 根据环境设置 `Secure=true/false`。
   - 设置 `SameSite=Strict` 或 `Lax`。
   - 统一 `MaxAge` 与 `TokenManager` 的过期策略。

### 建议修

4. **TokenManager 加 TTL**：改用 Redis 或数据库，支持过期和主动失效。
5. **文件上传校验**：校验文件头、限制大小、UUID 重命名。
6. **清理 demo 文件和 JVM 日志**：加入 `.gitignore` 或删除。
7. **继续补充 `alt` 和表单可访问性**。

### 练手项目可暂时忽略

8. 优惠券、会员积分、秒杀、客服等功能虚假模块（如果决定砍功能）。
9. 运费模板、真实退款、消息通知等高级功能。