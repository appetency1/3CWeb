# 上线前安全与质量检查清单

> 生成时间：2026-06-21  
> 范围：ClothesDemo 全仓库（ClothesBack / ClothesUser / ClothesAdmin / Doc / demo 文件）  
> 说明：**支付模块保持模拟**，本清单已将该问题移除，其余问题均需按优先级处理。

---

## 一、总体评估

- **审计得分：58/100（Risky）**
- **结论：当前不建议直接上线**，存在生产密钥泄露、Cookie 安全属性缺失、Token 无过期等高风险问题。
- 已完成 `mvn compile` 验证通过。

---

## 二、阻塞项（必须修复，否则不能上线）

| 编号 | 风险 | 文件位置 | 具体问题 | 建议修复 |
|------|------|----------|----------|----------|
| B-1 | **DeepSeek API Key 硬编码泄露** | `ClothesBack/src/main/resources/app.properties:7` | 曾写入真实 API Key（已从仓库中清除，改为环境变量 `DEEPSEEK_API_KEY` 读取）。 | 1. 已从仓库中清除真实 Key。<br>2. 已改为环境变量优先 + `app.properties` 兜底。<br>3. `app.properties` 已提交空模板，各自填入本地 Key。 |
| B-2 | **默认管理员弱口令** | `Doc/schema.sql:255-259` | 默认管理员密码为 `888888`（MD5），极易被暴力破解。 | 1. schema.sql 中改为 BCrypt 强哈希口令。<br>2. 首次部署强制要求修改默认口令。<br>3. README.md 中删除默认口令明文。 |
| B-3 | **Cookie 安全属性缺失** | `UserServlet.java:47-52`<br>`AdminServlet.java:36-41` | Cookie 未设置 `Secure` 和 `SameSite`，生产环境存在会话劫持与 CSRF 风险。 | 生产环境设置：`Secure=true; SameSite=Strict; HttpOnly=true; MaxAge=...`，并配合 Token 过期策略。 |
| B-4 | **Token 无过期 / 无法主动失效** | `TokenManager.java` | Token 写入文件持久化，无 TTL、无过期清理；用户修改密码仅清当前 token，其它会话仍有效。 | 1. 引入 Redis 或数据库作为 Token 存储。<br>2. 设置 Token TTL（如 2 小时）。<br>3. 支持用户级、全局失效。 |
| B-5 | **AI 客服接口无速率限制** | `AiChatServlet.java` | `/api/public/ai/chat` 公开可访问，被盗刷会快速耗尽 API 余额。 | 增加 IP + 用户维度限流（如每分钟 10 次），并对异常 IP 加入黑名单。 |

---

## 三、严重问题（强烈建议上线前修复）

| 编号 | 风险 | 文件位置 | 具体问题 | 建议修复 |
|------|------|----------|----------|----------|
| C-1 | **用户名可枚举** | `UserService.java:30-40`<br>`AdminService.java:27-42` | 用户不存在返回 400，账号禁用返回 403，状态码差异可枚举有效用户名。 | 统一返回相同 401 状态码与相同错误文案（如“用户名或密码错误”）。 |
| C-2 | **注册异常泄露 SQL** | `UserService.java:76` | `throw new BizException(..., "注册失败: " + e.getMessage())` 可能暴露表结构或数据库细节。 | 仅返回通用错误文案，详细异常写入服务端日志。 |
| C-3 | **WebP 魔数校验不完整** | `UploadServlet.java:57-60` | 只检查 `RIFF` 文件头，任意 RIFF 格式文件可绕过图片校验。 | 同时校验字节 0-3 为 `RIFF` 且字节 8-11 为 `WEBP`。 |
| C-4 | **文件上传大小限制不一致** | `UploadServlet.java:26` | 注解 `maxFileSize=10MB`，但 `AppConfig` 配置为 5MB，可能绕过限制。 | 统一使用 `AppConfig.getMaxUploadBytes()`，或注解值 ≤ 配置值。 |
| C-5 | **生产 API 路径混乱** | `ClothesUser/.env.production:1`<br>`ClothesUser/vite.config.ts:31` | 生产环境使用 `/ClothesBack_war/api`，开发环境代理 `/api`，容易部署错误。 | 统一 API Base 路径，或在部署文档中明确说明反向代理规则。 |
| C-6 | **schema.sql 会删库** | `Doc/schema.sql:9-10` | 脚本开头包含 `DROP DATABASE IF EXISTS clothes_demo;`，生产误执行将清空数据。 | 删除 `DROP DATABASE`，改为 `CREATE DATABASE IF NOT EXISTS` 或拆分为仅初始化表结构脚本。 |

---

## 四、中低风险 / 运维建议

| 编号 | 风险 | 文件位置 | 具体问题 | 建议修复 |
|------|------|----------|----------|----------|
| M-1 | `.gitignore` 未忽略敏感配置文件 | `.gitignore` | `app.properties`、`.env`、`.env.development`、`db.properties` 等未加入 ignore。 | 将真实配置文件加入 `.gitignore`，仅保留 `.example` 模板。 |
| M-2 | README 泄露数据库/管理员密码 | `README.md:128-132` | 明文写出 `root/000000`、`admin/888888`。 | 删除明文密码，改为“首次启动请修改默认口令”。 |
| M-3 | 根目录 demo HTML 文件可能误部署 | `account-security-demo.html`<br>`ai-service-demo.html`<br>`materials-preview.html` | 三个静态 demo 文件不属于正式应用，含硬编码测试数据和 `innerHTML`，若误部署可能带来风险。 | 删除或移入 `demos/` 目录并加入 `.gitignore`。 |
| M-4 | 缺少安全响应头 | `WEB-INF/web.xml` | 未配置 CSP、X-Frame-Options、X-Content-Type-Options 等。 | 通过 Filter 或 Web 服务器统一添加安全响应头。 |
| M-5 | 缺少自动化测试与 CI/CD | 仓库根目录 | 无单元测试、集成测试、E2E 测试及部署流水线。 | 补充核心流程测试，建立构建-测试-部署流水线。 |
| M-6 | 数据库索引不足 | `Doc/schema.sql` | `comment` 表缺少 `user_id` 索引，`orders` 表缺少复合查询索引。 | 按需补充索引以提升查询性能。 |
| M-7 | 开发服务器 `host: 0.0.0.0` | `ClothesUser/vite.config.ts`<br>`ClothesAdmin/vite.config.ts` | 开发配置监听了所有网卡，生产构建不直接使用，但需确保不会误用 dev server 上线。 | 生产部署使用 `npm run build` 产物 + Nginx/静态服务器。 |

---

## 五、已确认修复的亮点

- ✅ 前后端 Token 存储从 `localStorage` 迁移为 `HttpOnly Cookie`
- ✅ 商品详情 `v-html` 已使用 `DOMPurify` 清洗
- ✅ 密码哈希从 MD5 迁移到 BCrypt，老密码登录自动升级
- ✅ CORS 已从 `*` 改为白名单配置
- ✅ 非业务异常不再向客户端泄露堆栈或 SQL
- ✅ 文件上传增加图片魔数校验
- ✅ 评论内容已做 HTML 实体转义
- ✅ `UserManageServlet` 不再返回用户密码字段
- ✅ 后端 `mvn compile` 通过

---

## 六、建议修复顺序

1. **立即撤销并轮换 DeepSeek API Key**（B-1）
2. 将敏感配置文件加入 `.gitignore` 并清理提交历史（M-1）
3. Cookie 增加 `Secure=true` / `SameSite=Strict` / `MaxAge`（B-3）
4. 修改默认管理员密码并删除 README 明文（B-2 / M-2）
5. Token 存储增加 TTL 与失效能力（B-4）
6. AI 客服接口增加限流（B-5）
7. 统一登录错误返回，防止用户名枚举（C-1）
8. 修复 `schema.sql` 删库语句（C-6）
9. 完善上传校验与路径配置（C-3 / C-4 / C-5）
10. 清理 demo HTML 并补充安全响应头（M-3 / M-4）

---

## 七、空壳功能与逻辑错误（本次新增）

> 以下问题通过全量比对前后端路由、API、按钮与后端 Servlet 实现得出。问题类型包括：前端有按钮/页面但后端无实现（空壳）、前端功能不完整、以及明显的业务逻辑错误。

### 7.1 用户端空壳功能

| 编号 | 页面/路由 | 前端表现 | 后端实现 | 问题类型 | 建议修复 |
|------|-----------|----------|----------|----------|----------|
| S-1 | `/security` 账号安全页 | 显示「两步验证：未开启」 | 无 2FA 开关 API，无 TOTP/短信验证逻辑 | **空壳** | 若暂不支持，应隐藏该条目或明确标记「即将上线」 |
| S-2 | `/security` 账号安全页 | 微信 / 支付宝 / Apple / Google 绑定/解绑卡片 | 无 OAuth 绑定接口，按钮无事件 | **空壳** | 移除第三方账号区域，或接入真实 OAuth |
| S-3 | `/security` 账号安全页 | 「登录设备」列表 + 「退出其他设备」按钮 | 设备列表为写死 mock 数据，按钮仅弹出 toast | **空壳** | 接入会话管理 API；在无法支持前隐藏该模块 |
| S-4 | `/security` 账号安全页 | 「注销账号」危险区域按钮 | 仅弹出「账号已注销」toast，无删除用户 API | **空壳/危险** | 立即修复：未实现前禁用该按钮，避免用户误以为已注销 |
| S-5 | `/security` 账号安全页 | 安全评分、密码强度 30%、进度条 | 密码强度固定 30%，手机/邮箱进度条 `data-width="0%"` 不随绑定状态更新 | **逻辑错误/展示错误** | 删除固定数值，改为基于真实状态动态计算；或移除评分展示 |
| S-6 | `/profile` 个人资料页 | 侧边栏显示「账户设置」菜单 | 无点击事件、无对应页面 | **空壳** | 移除该菜单项或补充账户设置页面 |
| S-7 | `/profile` 个人资料页 | 统计卡片显示「优惠券 {{ couponCount }}」 | 后端 `UserService.current()` 未返回 `couponCount` 字段 | **空壳** | 移除优惠券卡片，或补齐优惠券模块 |
| S-8 | `/favorites` 收藏页 | 分类筛选 pill（女装/男装/配饰） | 仅改变 `activePill` 状态，未调用过滤 API | **空壳** | 若后端不支持分类筛选，移除 pill；否则接入 API |
| S-9 | `/favorites` 收藏页 | 排序下拉框（最近收藏/价格排序） | 仅 UI，未调用排序 API 或本地排序 | **空壳** | 移除排序框或实现排序逻辑 |
| S-10 | `/service` AI 客服页 | 左侧「相关商品」点击「问问 AI」 | 该功能实际可工作，但**清空对话**按钮仅删除前端 messages，无后端会话清理 | **半空壳** | AI 会话本为 Stateless 可接受；如需记忆历史，应接入后端会话管理 |

### 7.2 管理端空壳功能

| 编号 | 页面/路由 | 前端表现 | 后端实现 | 问题类型 | 建议修复 |
|------|-----------|----------|----------|----------|----------|
| A-1 | `/users` 用户管理 | 表格展示用户状态（正常/禁用） | `ClothesAdmin/src/api/user.ts` 已提供 `updateUserStatus`，但页面未引用，无禁用/启用按钮 | **功能缺失** | 在用户列表增加状态切换按钮，调用现有 API |
| A-2 | `/goods/add` 与 `/goods/:id/edit` 商品表单 | 表单包含：名称、品牌、价格、原价、库存、分类 ID、封面、描述、状态、热门/新品 | 后端 `GoodsSaveDTO` 还期望 `images`、`detail`、`skus` 等字段；前端未提供商品详情、图片列表、SKU 规格录入 | **功能缺失** | 补充多图上传、详情编辑器、SKU 增删改（后端 `SkuServlet` 已支持） |
| A-3 | `/goods` 商品列表 | 显示「销量」列 | 后端 `goods.sales` 字段存在，但需确认是否随订单实时更新 | **待确认** | 验证 `orders` 完成后 `goods.sales` 是否正确累加 |

### 7.3 前后端 API 与逻辑错误

| 编号 | 涉及文件 | 具体问题 | 影响 | 建议修复 |
|------|----------|----------|------|----------|
| L-1 | `ClothesUser/src/views/address/DesktopAddressListView.vue:120-124`<br>`AddressServlet.java:50-56` | 新增地址时可设置 `isDefault`，但**编辑地址**时 `AddressServlet.update()` 只接收 6 个字段，不包含 `isDefault` 和 `tag` | 用户修改地址时无法同步更新「设为默认」和标签 | 在 `update()` 中读取并更新 `isDefault` 与 `tag` |
| L-2 | `ClothesAdmin/src/views/goods/GoodsForm.vue:26-27`<br>`GoodsManageServlet.java:70-75` | `isHot`/`isNew` 前端以 `boolean` 提交，后端 `toInt()` 会将 `Boolean` 转为 0/1 | 当前逻辑可工作，但类型不一致；若未来提交字符串会解析为 `null` | 前端统一提交 0/1 数字，或后端增强校验并显式报错 |
| L-3 | `ClothesBack/src/main/java/.../service/OrderService.java:256-274` | 管理员点击「退款」后，订单状态被更新为 `4`（已取消），而非独立的「已退款」状态 | 用户看到的订单状态为「已取消」，与「退款」文案不符 | 新增订单状态（如 5=已退款）或在退款时保持合理语义 |
| L-4 | `ClothesBack/src/main/java/.../service/CartService.java:24-41` | 添加购物车时仅校验 SKU 存在性，**不校验库存是否充足** | 用户可将缺货商品加入购物车，直到下单时才提示库存不足 | 在加入购物车时校验 SKU 库存 |
| L-5 | `ClothesBack/src/main/java/.../servlet/user/UserServlet.java:47-54` | 注册成功后直接写入 7 天 `token` Cookie | 注册即登录是产品选择，但需确认是否符合预期；同时与登录 Cookie 配置一致 | 若产品允许「注册并登录」，保持即可；否则注册后跳转登录页 |
| L-6 | `ClothesBack/src/main/java/.../servlet/admin/AdminServlet.java:62-83` | 管理员修改密码仍使用 `MD5Utils.hash()` | 与 User 端 BCrypt 升级不一致，管理员密码同样容易被爆破 | 管理员密码也改用 BCrypt |

### 7.4 快速处理建议

1. **立即隐藏或禁用未实现功能**：账号注销、第三方账号绑定、登录设备管理、2FA、优惠券统计、收藏页筛选排序。
2. **补齐管理端缺失操作**：用户禁用/启用、商品 SKU/多图/详情录入。
3. **修复明显逻辑错误**：地址编辑时支持默认地址、退款状态语义、购物车库存校验、管理员密码哈希。
4. **统一字段类型**：`isHot`/`isNew` 前后端统一为 0/1 数字，避免隐式转换。

---

## 八、验证检查点

修复后请确认：

- [ ] `app.properties` 中无真实 API Key、密码等敏感信息
- [ ] `git log --all --grep='sk-'` 等搜索不再命中真实 Key
- [ ] Cookie 响应头包含 `HttpOnly; Secure; SameSite=Strict`
- [ ] 登录接口无论用户名/密码错误/禁用，均返回 401 与统一文案
- [ ] 上传非图片文件被正确拦截
- [ ] `schema.sql` 不再包含 `DROP DATABASE`
- [ ] 后端 `mvn test` / 前端 `npm run build` 均通过
- [ ] 用户端未实现按钮（注销、第三方绑定、2FA 等）已隐藏或禁用
- [ ] 管理端用户列表可正常启用/禁用用户
- [ ] 商品表单可正常录入 SKU、多图、商品详情
- [ ] 编辑地址时「设为默认」状态可正确保存
