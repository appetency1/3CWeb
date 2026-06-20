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

当 AI 需要配置此项目时，**AI 应自动完成以下操作**：

```
AI 自动执行步骤：

□ 1. 读取用户本地数据库配置
   - 读取 ClothesBack/src/main/resources/db.properties
   - 获取：数据库用户名、密码、连接地址

□ 2. 创建数据库（仅创建，不删除原有数据）
   - 使用 db.properties 中的凭据连接 MySQL
   - 执行：CREATE DATABASE IF NOT EXISTS clothes_demo ...
   - ⚠️ 重要：不要执行 schema.sql 开头的 DROP DATABASE 语句！

□ 3. 导入数据库表结构
   - ⚠️ 重要：手动执行建表语句，跳过 DROP DATABASE
   - 或执行 Doc/migrations/ 下的增量迁移脚本

□ 4. 完成后提示用户
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

```bash
# AI 必须读取此文件获取数据库连接信息
cat ClothesBack/src/main/resources/db.properties
```

**文件内容示例：**
```properties
jdbc.driver=com.mysql.cj.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/clothes_demo?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
jdbc.user=root
jdbc.password=你的密码
```

### 4.2 创建数据库（安全操作）

⚠️ **重要警告**：`Doc/schema.sql` 开头有 `DROP DATABASE` 语句，**会删除整个数据库**！

AI 必须**手动执行建表语句**，不要直接执行 schema.sql：

```sql
-- 从 db.properties 提取用户名和密码后执行：
CREATE DATABASE IF NOT EXISTS clothes_demo CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE clothes_demo;

-- 然后手动执行建表语句（跳过 DROP DATABASE）：
CREATE TABLE IF NOT EXISTS `admin` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
    `username` VARCHAR(50) NOT NULL COMMENT '登录账号',
    `password` VARCHAR(100) NOT NULL COMMENT '密码',
    `nickname` VARCHAR(50) COMMENT '昵称',
    `avatar` VARCHAR(255) COMMENT '头像URL',
    `email` VARCHAR(100) COMMENT '邮箱',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0禁用 1正常',
    `last_login` DATETIME COMMENT '最后登录时间',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='管理员表';

-- 插入默认管理员
INSERT INTO `admin` (`username`, `password`, `nickname`, `status`) VALUES 
('admin', 'e10adc3949ba59abbe56e057f20f883e', '管理员', 1);
```

### 4.3 或者：使用迁移脚本（推荐）

```bash
# 执行增量迁移脚本（不会删除数据）
mysql -u root -p clothes_demo < Doc/migrations/20260617_link_product_images.sql
mysql -u root -p clothes_demo < Doc/migrations/20260618_fix_goods_cover.sql
```

### 4.4 验证配置

```bash
# 验证数据库连接
mysql -u root -p -e "USE clothes_demo; SHOW TABLES;"

# 验证管理员账号
mysql -u root -p -e "USE clothes_demo; SELECT * FROM admin;"
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

管理后台登录账号：
- 用户名：admin
- 密码：123456

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
│   │   ├── layouts/       # 布局组件
│   │   ├── router/        # 路由配置
│   │   ├── stores/        # Pinia 状态管理
│   │   ├── views/         # 页面视图
│   │   └── utils/         # 工具函数
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
│   │       ├── dto/        # 数据传输对象
│   │       ├── entity/     # 实体类
│   │       ├── filter/      # 过滤器 (CORS, 编码)
│   │       ├── interceptor/ # 拦截器
│   │       ├── listener/   # 监听器 (启动入口)
│   │       ├── servlet/    # Servlet 控制器
│   │       ├── service/    # 业务逻辑层
│   │       ├── util/       # 工具类
│   │       └── vo/         # 视图对象
│   ├── src/main/resources/
│   │   ├── db.properties  # 数据库配置 ⚠️ 重要配置
│   │   └── schema.sql     # 数据库建表脚本 ⚠️ 危险：含 DROP DATABASE
│   └── pom.xml
│
├── Doc/                   # 项目文档
│   ├── API_DESIGN.md     # API 接口设计
│   ├── BACKEND_GUIDE.md  # 后端开发指南
│   ├── DB_DESIGN.md      # 数据库设计
│   ├── FRONTEND_GUIDE.md # 前端开发指南
│   └── migrations/        # 数据库迁移脚本（推荐使用）
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

### Q4: schema.sql 会删除数据库吗？

⚠️ **会！** `schema.sql` 开头有 `DROP DATABASE IF EXISTS clothes_demo;`

**正确做法：**
- 只创建数据库，不执行 DROP DATABASE
- 使用 `Doc/migrations/` 下的增量脚本进行迁移
- 或者手动执行建表语句，跳过 DROP DATABASE

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
