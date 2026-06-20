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

### AI 部署指令

当 AI 需要部署此项目时，请按以下步骤执行：

### 第一步：询问用户数据库配置

在开始部署前，AI **必须询问用户**以下信息：

```
请提供以下信息以完成部署：

1. MySQL 数据库密码是什么？
   （注意：如果 MySQL 使用其他用户名而非 root，请一并告知）

2. MySQL 连接地址是什么？
   （默认：localhost:3306，如有不同请告知）

3. 是否需要修改端口配置？
   （后端默认：8080，前端用户端默认：5173，管理后台默认：5174）
```

### 第二步：检查环境

```bash
# 检查 Node.js 版本
node --version

# 检查 Java 版本
java -version

# 检查 Maven 版本
mvn --version

# 检查 MySQL 是否运行
mysql -u root -p -e "SELECT 1"
```

### 第三步：初始化数据库

```bash
# 登录 MySQL
mysql -u root -p

# 在 MySQL 中执行：
CREATE DATABASE IF NOT EXISTS clothes_demo CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
EXIT;
```

### 第四步：配置后端数据库连接

**AI 必须询问用户获取数据库密码**，然后编辑 `ClothesBack/src/main/resources/db.properties`：

```properties
jdbc.driver=com.mysql.cj.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/clothes_demo?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
jdbc.user=root
jdbc.password=【用户提供的密码】
```

### 第五步：导入数据库表结构

```bash
mysql -u root -p clothes_demo < Doc/schema.sql
```

### 第六步：启动后端

```bash
cd ClothesBack

# 打包 WAR 文件
mvn clean package

# 复制 WAR 文件到 Tomcat
# Linux/Mac:
cp target/ClothesBack-1.0-SNAPSHOT.war /path/to/tomcat/webapps/

# Windows:
copy target\ClothesBack-1.0-SNAPSHOT.war C:\path\to\tomcat\webapps\

# 启动 Tomcat，或在 IDE 中直接运行
```

后端启动后访问：`http://localhost:8080/ClothesBack_war`

### 第七步：启动前端（用户端）

```bash
cd ClothesUser

# 安装依赖
npm install

# 启动开发服务器
npm run dev
```

访问：`http://localhost:5173`

### 第八步：启动前端（管理后台）

```bash
cd ClothesAdmin

# 安装依赖
npm install

# 启动开发服务器
npm run dev
```

访问：`http://localhost:5174`

---

## 三、部署检查清单

在部署过程中，AI 应该按以下顺序检查：

```
□ 1. 环境检查
  □ Node.js ≥ 18.0.0
  □ Java ≥ JDK 17
  □ Maven ≥ 3.8
  □ MySQL 8.0+

□ 2. 数据库配置
  □ 已创建数据库 clothes_demo
  □ 已导入 Doc/schema.sql
  □ 已配置 db.properties 中的密码

□ 3. 后端启动
  □ WAR 文件已部署到 Tomcat
  □ Tomcat 已启动
  □ API 可访问：curl http://localhost:8080/ClothesBack_war/api/public/banners

□ 4. 前端启动
  □ ClothesUser 已安装依赖并启动
  □ ClothesAdmin 已安装依赖并启动
```

---

## 四、项目结构

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
├── ClothesBack/           # 后端服务
│   ├── src/main/java/
│   │   └── org/example/clothesback/
│   │       ├── common/    # 通用类 (Result, BizException)
│   │       ├── config/    # 配置类
│   │       ├── dao/       # 数据访问层
│   │       ├── dto/       # 数据传输对象
│   │       ├── entity/    # 实体类
│   │       ├── filter/     # 过滤器 (CORS, 编码)
│   │       ├── interceptor/# 拦截器
│   │       ├── listener/  # 监听器
│   │       ├── servlet/   # Servlet 控制器
│   │       ├── service/   # 业务逻辑层
│   │       ├── util/      # 工具类
│   │       └── vo/        # 视图对象
│   ├── src/main/resources/
│   │   ├── db.properties  # 数据库配置 ⚠️ 需要修改密码
│   │   └── schema.sql    # 数据库建表脚本
│   └── pom.xml
│
├── Doc/                   # 项目文档
│   ├── API_DESIGN.md     # API 接口设计
│   ├── BACKEND_GUIDE.md  # 后端开发指南
│   ├── DB_DESIGN.md      # 数据库设计
│   └── FRONTEND_GUIDE.md # 前端开发指南
│
└── README.md             # 本文件
```

---

## 五、默认账号

| 端 | 账号 | 密码 | 说明 |
|---|---|---|---|
| 管理后台 | `admin` | `123456` | 超级管理员 |

---

## 六、API 文档

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

## 七、常见问题

### Q1: 前端无法连接后端？

1. 检查后端是否启动：`curl http://localhost:8080/ClothesBack_war/api/public/banners`
2. 检查前端 `.env` 中的 API 地址配置
3. 检查后端 `db.properties` 数据库密码是否正确

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

### Q4: npm install 失败？

```bash
# 清除缓存
npm cache clean --force

# 删除 node_modules 和 package-lock.json 后重试
rm -rf node_modules package-lock.json
npm install
```

---

## 八、数据库表结构

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

## 九、AI 部署提示

本项目专为 AI 辅助部署设计，AI 在部署时应：

1. **必须询问**：数据库密码、MySQL 用户名（非 root 时）、自定义端口等配置
2. **自动检测**：检测环境是否满足要求，不满足时提示用户安装
3. **逐步引导**：按照检查清单逐步执行，每步完成后确认
4. **错误处理**：遇到错误时分析原因并提供解决方案

---

## 十、联系方式

- 项目地址：https://github.com/appetency1/ClothesDemo
- GitCode：https://gitcode.com/rafa630/ClothesDemo

---

**最后更新：2026-06-20**
