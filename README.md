# ClothesDemo - 服装商城系统

一个前后端分离的服装电商平台，包含用户端和管理后台。

---

## 一、项目概述

### 技术架构

```
┌─────────────────────────────────────────────────────────────────┐
│                         前端 (Vue 3)                            │
├─────────────────────────────────────────────────────────────────┤
│  ClothesUser (用户端)     │     ClothesAdmin (管理后台)          │
│  ├── Vue 3 + Vite        │     ├── Vue 3 + Vite                │
│  ├── Vant 4 (UI组件)     │     ├── Vant 4 (UI组件)             │
│  ├── Pinia (状态管理)    │     ├── Pinia (状态管理)             │
│  ├── TypeScript          │     ├── TypeScript                  │
│  └── 移动端优先          │     └── 桌面端优先                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP API (REST)
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      后端 (Java Servlet)                        │
├─────────────────────────────────────────────────────────────────┤
│  ClothesBack                                                     │
│  ├── Jakarta Servlet 6.1                                        │
│  ├── 原生 JDBC (无 ORM)                                         │
│  ├── Fastjson2 (JSON处理)                                       │
│  └── MySQL 8.0                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 系统模块

| 模块 | 说明 | 端口 |
|------|------|------|
| ClothesUser | 用户端（移动端） | 5173 |
| ClothesAdmin | 管理后台（桌面端） | 5174 |
| ClothesBack | 后端 API 服务 | 8080 |

---

## 二、环境要求

### 必需环境

| 软件 | 版本要求 | 说明 |
|------|----------|------|
| **Node.js** | ≥ 18.0.0 | 前端构建工具 |
| **Java** | ≥ JDK 17 | 后端运行环境 |
| **Maven** | ≥ 3.8 | 后端项目管理 |
| **MySQL** | ≥ 8.0 | 数据库 |
| **Tomcat** | ≥ 10.1 | Servlet 容器 |
| **IntelliJ IDEA** | 最新版 | 后端开发 IDE |

---

## 三、快速启动

### AI 配置后端（自动）

当 AI 需要配置此项目时，**AI 应自动完成以下操作**，无需用户手动配置：

```
AI 自动执行步骤：

□ 1. 读取用户本地数据库配置
   - 读取 ClothesBack/src/main/resources/db.properties
   - 识别数据库连接信息（URL、用户名、密码）

□ 2. 检查并创建数据库
   - 检查数据库 clothes_demo 是否存在
   - 如不存在，自动创建

□ 3. 导入数据库表结构
   - 执行 Doc/schema.sql 初始化数据库表
   - 如有数据迁移脚本，执行 Doc/migrations/ 下的脚本

□ 4. 验证后端配置
   - 确认 db.properties 配置正确
   - 确认 Maven 依赖已下载

□ 5. 完成后提示用户
   - 提示用户打开 IDEA
   - 提示用户运行 ClothesBack 项目
```

### 用户手动启动（只需两步）

#### 第一步：打开 IDEA 运行后端

1. 用 IntelliJ IDEA 打开 `ClothesDemo/ClothesBack` 文件夹
2. 等待 Maven 下载依赖完成
3. 找到 `AppListener.java`，右键选择 **Run 'AppListener'**
4. 后端启动后访问：`http://localhost:8080/ClothesBack_war`

#### 第二步：启动前端

**用户端：**
```bash
cd ClothesUser
npm install
npm run dev
```
访问：`http://localhost:5173`

**管理后台：**
```bash
cd ClothesAdmin
npm install
npm run dev
```
访问：`http://localhost:5174`

---

## 四、AI 配置后端详细指令

### 4.1 读取现有配置

AI 应该读取以下文件获取用户本地配置：

```bash
# 读取数据库配置文件
cat ClothesBack/src/main/resources/db.properties
```

### 4.2 创建数据库（如不存在）

```bash
# 从 db.properties 提取数据库连接信息
# 然后执行：
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS clothes_demo CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
```

### 4.3 导入表结构

```bash
mysql -u root -p clothes_demo < Doc/schema.sql

# 执行数据迁移（如有）
mysql -u root -p clothes_demo < Doc/migrations/20260617_link_product_images.sql
mysql -u root -p clothes_demo < Doc/migrations/20260618_fix_goods_cover.sql
```

### 4.4 验证配置

```bash
# 验证数据库连接
mysql -u root -p -e "USE clothes_demo; SHOW TABLES;"

# 验证 Maven 依赖
cd ClothesBack && mvn dependency:resolve
```

### 4.5 完成配置

配置完成后，AI 应输出：

```
✅ 后端配置完成！

请按以下步骤启动项目：

1. 用 IntelliJ IDEA 打开项目 ClothesDemo/ClothesBack
2. 等待 Maven 下载依赖（底部进度条）
3. 找到 src/main/java/org/example/clothesback/listener/AppListener.java
4. 右键点击，选择 Run 'AppListener'
5. 后端启动后访问：http://localhost:8080/ClothesBack_war

如遇问题，请检查：
- MySQL 服务是否启动
- db.properties 中的数据库密码是否正确
```

---

## 五、项目结构

```
ClothesDemo/
├── ClothesUser/           # 用户端前端
│   ├── src/
│   │   ├── api/          # API 接口定义
│   │   ├── components/   # 公共组件
│   │   ├── router/       # 路由配置
│   │   ├── stores/       # Pinia 状态管理
│   │   ├── views/        # 页面视图
│   │   └── utils/        # 工具函数
│   ├── public/           # 静态资源
│   ├── .env              # 环境配置
│   └── package.json
│
├── ClothesAdmin/          # 管理后台前端
│   ├── src/
│   │   ├── api/          # API 接口定义
│   │   ├── layouts/      # 布局组件
│   │   ├── router/       # 路由配置
│   │   ├── stores/       # Pinia 状态管理
│   │   ├── views/        # 页面视图
│   │   └── utils/        # 工具函数
│   ├── docs/             # 文档
│   ├── public/           # 静态资源
│   └── package.json
│
├── ClothesBack/           # 后端服务 ⚠️ 用 IDEA 打开并运行
│   ├── src/main/java/
│   │   └── org/example/clothesback/
│   │       ├── common/    # 通用类 (Result, BizException)
│   │       ├── config/    # 配置类
│   │       ├── dao/       # 数据访问层
│   │       ├── dto/       # 数据传输对象
│   │       ├── entity/    # 实体类
│   │       ├── filter/     # 过滤器 (CORS, 编码)
│   │       ├── interceptor/# 拦截器
│   │       ├── listener/  # 监听器 (启动入口)
│   │       ├── servlet/   # Servlet 控制器
│   │       ├── service/   # 业务逻辑层
│   │       ├── util/      # 工具类
│   │       └── vo/        # 视图对象
│   ├── src/main/resources/
│   │   ├── db.properties  # 数据库配置（AI 自动读取配置）
│   │   └── schema.sql    # 数据库建表脚本
│   └── pom.xml
│
├── Doc/                   # 项目文档
│   ├── API_DESIGN.md     # API 接口设计
│   ├── BACKEND_GUIDE.md  # 后端开发指南
│   ├── DB_DESIGN.md      # 数据库设计
│   ├── FRONTEND_GUIDE.md # 前端开发指南
│   └── migrations/       # 数据库迁移脚本
│
└── README.md             # 本文件
```

---

## 六、默认账号

| 端 | 账号 | 密码 | 说明 |
|---|---|---|---|
| 管理后台 | `admin` | `123456` | 超级管理员 |

---

## 七、API 文档

详细 API 接口设计请查看：[Doc/API_DESIGN.md](Doc/API_DESIGN.md)

### 主要接口

| 模块 | 路径前缀 | 说明 |
|------|----------|------|
| 用户 | `/api/user/*` | 登录、注册、用户信息 |
| 商品 | `/api/goods/*` | 商品列表、详情、搜索 |
| 分类 | `/api/category/*` | 分类列表 |
| 购物车 | `/api/cart/*` | 购物车管理 |
| 订单 | `/api/order/*` | 订单创建、支付、查询 |
| 地址 | `/api/address/*` | 收货地址管理 |
| 收藏 | `/api/favorite/*` | 商品收藏 |
| 评价 | `/api/comment/*` | 商品评价 |

---

## 八、常见问题

### Q1: 前端无法连接后端？

1. 检查后端是否启动
2. 检查前端 `.env` 中的 API 地址配置

### Q2: 数据库连接失败？

1. 确认 MySQL 服务已启动
2. 确认数据库 `clothes_demo` 已创建
3. 检查 `db.properties` 中的用户名密码

### Q3: 端口被占用？

```bash
# Windows 查看端口占用
netstat -ano | findstr :8080

# 结束进程
taskkill /PID <进程ID> /F
```

---

## 九、数据库表结构

详细设计请查看：[Doc/DB_DESIGN.md](Doc/DB_DESIGN.md)

| 表名 | 说明 |
|------|------|
| `user` | 用户表 |
| `admin` | 管理员表 |
| `category` | 商品分类表 |
| `goods` | 商品表 (SPU) |
| `sku` | 商品规格表 (SKU) |
| `address` | 收货地址表 |
| `cart` | 购物车表 |
| `orders` | 订单表 |
| `order_item` | 订单详情表 |
| `banner` | 轮播图表 |
| `favorite` | 收藏表 |
| `comment` | 评价表 |

---

## 十、联系方式

- 项目地址：https://github.com/appetency1/ClothesDemo
- GitCode：https://gitcode.com/rafa630/ClothesDemo

---

**最后更新：2026-06-20**
