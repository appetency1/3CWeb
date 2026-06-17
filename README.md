# ClothesDemo 服装电商项目

基于 Vue3 + Java Servlet 的全栈服装电商演示项目，包含用户端、管理后台和后端服务三个模块。

## 📁 项目结构

```
ClothesDemo/
├── ClothesAdmin/        # 管理后台（Vue3 + TypeScript）
├── ClothesBack/         # Java后端服务（Servlet + MySQL）
├── ClothesUser/         # 用户前端（Vue3 + TypeScript）
├── Doc/                 # 项目文档
│   ├── API_DESIGN.md    # API设计文档
│   ├── BACKEND_GUIDE.md # 后端开发指南
│   ├── DB_DESIGN.md     # 数据库设计文档
│   ├── FRONTEND_GUIDE.md # 前端开发指南
│   ├── schema.sql       # 数据库初始化脚本
│   └── goods_data_final.sql # 商品数据
└── README.md            # 项目说明文档
```

## 🛠️ 技术栈

### 前端（ClothesUser / ClothesAdmin）
| 技术 | 版本 | 说明 |
|------|------|------|
| Vue | 3.5.34 | 前端框架 |
| TypeScript | ~6.0.2 | 类型安全 |
| Vite | 8.0.12 | 构建工具 |
| Vue Router | 4.6.4 | 路由管理 |
| Pinia | 3.0.4 | 状态管理 |
| Vant | 4.9.24 | UI组件库 |
| Axios | 1.18.0 | HTTP客户端（用户端） |

### 后端（ClothesBack）
| 技术 | 版本 | 说明 |
|------|------|------|
| Java | 17 | 编程语言 |
| Maven | 3.6+ | 依赖管理 |
| Servlet | 6.1.0 | Web框架 |
| MySQL Connector | 9.2.0 | 数据库驱动 |
| FastJSON2 | 2.0.49 | JSON处理 |

### 数据库
| 技术 | 版本 | 说明 |
|------|------|------|
| MySQL | 8.0+ | 关系型数据库 |

## 📋 环境要求

### 前端环境
- **Node.js**: >= 18.0.0
- **npm**: >= 9.0.0
- **pnpm**: >= 8.0.0（推荐）

### 后端环境
- **JDK**: 17（必须）
- **Maven**: >= 3.6.0
- **Tomcat**: >= 10.0（运行Servlet）

### 数据库环境
- **MySQL**: >= 8.0
- 数据库名：`clothes_demo`
- 用户名：`root`
- 密码：`000000`

## 🚀 快速开始

### 1. 数据库配置

创建数据库并执行初始化脚本：

```sql
-- 创建数据库
CREATE DATABASE clothes_demo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 切换到数据库
USE clothes_demo;

-- 执行初始化脚本
SOURCE Doc/schema.sql;
SOURCE Doc/goods_data_final.sql;
```

### 2. 后端服务启动

#### 方式一：使用Maven构建部署

```bash
# 进入后端目录
cd ClothesBack

# 编译项目
mvn clean package -DskipTests

# 将生成的war包部署到Tomcat
# war包位置：target/ClothesBack-1.0-SNAPSHOT.war
# 复制到 Tomcat/webapps/ 目录
```

#### 方式二：使用IDE运行

1. 在IntelliJ IDEA或Eclipse中打开`ClothesBack`项目
2. 配置Tomcat服务器（推荐Tomcat 10）
3. 运行项目

**后端服务地址**: `http://localhost:8080/ClothesBack_war/`

### 3. 用户前端启动

```bash
# 进入用户前端目录
cd ClothesUser

# 安装依赖
npm install
# 或使用pnpm（推荐）
pnpm install

# 开发模式运行
npm run dev

# 构建生产版本
npm run build

# 预览构建结果
npm run preview
```

**用户前端地址**: `http://localhost:5173/`

### 4. 管理后台启动

```bash
# 进入管理后台目录
cd ClothesAdmin

# 安装依赖
npm install
# 或使用pnpm（推荐）
pnpm install

# 开发模式运行
npm run dev

# 构建生产版本
npm run build

# 预览构建结果
npm run preview
```

**管理后台地址**: `http://localhost:5174/`

## 🔧 配置说明

### 后端数据库配置

文件路径：`ClothesBack/src/main/resources/db.properties`

```properties
jdbc.driver=com.mysql.cj.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/clothes_demo?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
jdbc.user=root
jdbc.password=000000
```

### 用户前端环境变量

**开发环境**: `ClothesUser/.env.development`
```env
VITE_API_BASE=http://localhost:8080/ClothesBack_war/api
VITE_IMG_BASE=http://localhost:8080/ClothesBack_war
VITE_APP_TITLE=ClothesUser
```

**生产环境**: `ClothesUser/.env.production`
```env
VITE_API_BASE=/ClothesBack_war/api
VITE_IMG_BASE=/ClothesBack_war
VITE_APP_TITLE=ClothesUser
```

## 📱 功能模块

### 用户端（ClothesUser）

| 模块 | 功能 |
|------|------|
| 首页 | 商品展示、轮播图、分类导航 |
| 分类页 | 商品分类浏览 |
| 商品详情 | 商品信息、SKU选择、加入购物车 |
| 购物车 | 商品管理、数量调整、结算 |
| 订单 | 订单列表、订单详情、订单状态 |
| 用户中心 | 个人信息、收货地址、收藏夹 |

### 管理后台（ClothesAdmin）

| 模块 | 功能 |
|------|------|
| 登录 | 管理员登录 |
| 仪表盘 | 数据统计概览 |
| 商品管理 | 商品列表、新增、编辑、删除 |
| 分类管理 | 商品分类维护 |
| 订单管理 | 订单列表、状态管理 |
| 用户管理 | 用户列表、权限管理 |
| 轮播管理 | 首页轮播图管理 |

## 🔐 默认账号

### 管理员账号
- **用户名**: `admin`
- **密码**: `123456`

### 测试用户账号
- **用户名**: `test`
- **密码**: `123456`

⚠️ 注意：生产环境请务必修改默认密码！

## 📡 API接口

### 公共接口（无需登录）
- `GET /api/public/banners` - 获取轮播图列表
- `GET /api/public/categories` - 获取分类列表
- `GET /api/public/goods` - 获取商品列表
- `GET /api/public/goods/{id}` - 获取商品详情
- `GET /api/public/comments/{goodsId}` - 获取商品评论

### 用户接口（需登录）
- `POST /api/user/register` - 用户注册
- `POST /api/user/login` - 用户登录
- `GET /api/user/info` - 获取用户信息
- `POST /api/user/logout` - 用户退出
- `GET /api/user/addresses` - 获取收货地址列表
- `POST /api/user/addresses` - 添加收货地址
- `GET /api/cart` - 获取购物车列表
- `POST /api/cart` - 添加商品到购物车
- `GET /api/favorites` - 获取收藏列表
- `POST /api/favorites` - 添加收藏

### 管理员接口（需管理员登录）
- `POST /api/admin/login` - 管理员登录
- `GET /api/admin/dashboard` - 获取仪表盘数据
- `GET /api/admin/goods` - 获取商品列表（管理）
- `POST /api/admin/goods` - 新增商品
- `PUT /api/admin/goods/{id}` - 修改商品
- `DELETE /api/admin/goods/{id}` - 删除商品
- `GET /api/admin/orders` - 获取订单列表（管理）
- `PUT /api/admin/orders/{id}` - 修改订单状态

## 📁 目录结构详解

### ClothesBack 后端结构

```
ClothesBack/src/main/java/org/example/clothesback/
├── common/          # 通用类（返回结果、异常处理）
├── config/          # 配置类
├── dao/             # 数据访问层
├── dto/             # 数据传输对象
├── entity/          # 实体类
├── filter/          # 过滤器（CORS、编码）
├── interceptor/     # 拦截器（认证、权限）
├── listener/        # 监听器
├── service/         # 业务逻辑层
├── servlet/         # 控制器层
│   ├── admin/       # 管理员接口
│   ├── public_/     # 公共接口
│   └── user/        # 用户接口
├── util/            # 工具类
└── vo/              # 视图对象
```

### ClothesUser 用户端结构

```
ClothesUser/src/
├── api/             # API请求封装
├── components/      # 公共组件
├── router/          # 路由配置
├── stores/          # Pinia状态管理
├── types/           # TypeScript类型定义
├── utils/           # 工具函数
├── views/           # 页面视图
│   ├── cart/        # 购物车相关
│   ├── category/    # 分类相关
│   ├── goods/       # 商品相关
│   ├── home/        # 首页
│   ├── order/       # 订单相关
│   ├── search/      # 搜索相关
│   └── user/        # 用户相关
├── App.vue          # 根组件
├── main.ts          # 入口文件
└── style.css        # 全局样式
```

### ClothesAdmin 管理后台结构

```
ClothesAdmin/src/
├── api/             # API请求封装
├── layouts/         # 布局组件
├── router/          # 路由配置
├── stores/          # Pinia状态管理
├── utils/           # 工具函数
├── views/           # 页面视图
│   ├── banners/     # 轮播管理
│   ├── categories/  # 分类管理
│   ├── dashboard/   # 仪表盘
│   ├── goods/       # 商品管理
│   ├── login/       # 登录页
│   ├── orders/      # 订单管理
│   └── users/       # 用户管理
├── App.vue          # 根组件
├── main.ts          # 入口文件
└── style.css        # 全局样式
```

## 🚦 开发流程

### 前端开发

```bash
# 1. 进入对应目录
cd ClothesUser  # 或 ClothesAdmin

# 2. 安装依赖
pnpm install

# 3. 开发模式（热更新）
pnpm dev

# 4. 代码检查
pnpm run typecheck

# 5. 构建生产版本
pnpm run build
```

### 后端开发

```bash
# 1. 进入后端目录
cd ClothesBack

# 2. 编译项目
mvn clean compile

# 3. 运行测试
mvn test

# 4. 打包（跳过测试）
mvn clean package -DskipTests

# 5. 运行（需要配置Tomcat）
# 使用IDE配置Tomcat运行或部署war包
```

## 🐛 常见问题

### 数据库连接失败
1. 确认MySQL服务已启动
2. 检查`db.properties`中的数据库配置是否正确
3. 确认MySQL用户有权限访问`clothes_demo`数据库

### 前端无法访问后端API
1. 确认后端服务已启动
2. 检查前端环境变量`VITE_API_BASE`配置是否正确
3. 确认CORS配置正确（后端已配置CORS过滤器）

### 端口冲突
- 用户前端默认端口：5173
- 管理后台默认端口：5174（需修改vite.config.ts）
- 后端服务端口：8080（Tomcat默认）

如需修改端口，可在`vite.config.ts`中配置：

```typescript
export default defineConfig({
  server: {
    port: 5174  // 修改端口
  }
})
```

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交Issue和Pull Request！

---

**项目地址**: https://github.com/appetency1/ClothesDemo
