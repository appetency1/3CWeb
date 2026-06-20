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

| 软件 | 版本要求 | 说明 |
|------|----------|------|
| **Node.js** | ≥ 18.0.0 | 前端构建工具 |
| **Java** | ≥ JDK 17 | 后端运行环境 |
| **Maven** | ≥ 3.8 | 后端项目管理 |
| **MySQL** | ≥ 8.0 | 数据库 |
| **IntelliJ IDEA** | 最新版 | 后端开发 IDE |

---

## 三、快速启动

### 第一步：配置数据库（AI 自动完成）

当 AI 帮助部署时，AI 应该：

```
1. 询问用户 MySQL 密码：
   "请提供您的 MySQL root 密码，我将自动配置数据库"

2. 读取 db.properties 模板
3. 生成包含用户密码的 db.properties
4. 创建数据库 clothes_demo
5. 导入表结构
6. 验证配置
```

### 第二步：用户手动启动

#### 打开 IDEA 运行后端

1. 用 IntelliJ IDEA 打开 `ClothesDemo/ClothesBack` 文件夹
2. 等待 Maven 下载依赖完成
3. 找到 `AppListener.java`，右键选择 **Run 'AppListener'**
4. 后端启动后访问：`http://localhost:8080/ClothesBack_war`

#### 启动前端

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

## 四、AI 部署完整指令

### 4.1 AI 必须先询问用户

AI 在部署前**必须询问**：

```
请提供以下信息：

1. MySQL 数据库密码是什么？
   （如果使用其他用户名而非 root，也请告知）
```

### 4.2 AI 执行配置

获得密码后，AI 自动执行：

```bash
# 1. 生成 db.properties（使用用户提供的密码）
# 内容示例：
jdbc.driver=com.mysql.cj.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/clothes_demo?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
jdbc.user=root
jdbc.password=【用户密码】

# 2. 创建数据库
mysql -u root -p用户密码 -e "CREATE DATABASE IF NOT EXISTS clothes_demo CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"

# 3. 创建表（手动执行，跳过 DROP DATABASE）
# AI 应该读取 schema.sql，然后跳过前10行（DROP DATABASE 部分）执行

# 4. 导入数据
mysql -u root -p用户密码 clothes_demo < Doc/migrations/20260617_link_product_images.sql
mysql -u root -p用户密码 clothes_demo < Doc/migrations/20260618_fix_goods_cover.sql

# 5. 验证
mysql -u root -p用户密码 -e "USE clothes_demo; SHOW TABLES;"
```

### 4.3 AI 完成后提示

```
✅ 配置完成！

后端已配置好，请：

1. 用 IntelliJ IDEA 打开 ClothesDemo/ClothesBack
2. 等待 Maven 下载依赖完成
3. 右键点击 src/main/java/org/example/clothesback/listener/AppListener.java
4. 选择 Run 'AppListener'

启动后访问：http://localhost:8080/ClothesBack_war

管理后台账号：admin / 123456
```

---

## 五、项目结构

```
ClothesDemo/
├── ClothesUser/           # 用户端前端
├── ClothesAdmin/          # 管理后台前端
├── ClothesBack/           # 后端服务
│   └── src/main/resources/
│       ├── db.properties  # ⚠️ 数据库配置（需要密码）
│       └── schema.sql     # ⚠️ 表结构（含 DROP DATABASE）
├── Doc/                   # 文档和迁移脚本
└── README.md             # 本文件
```

---

## 六、数据库配置

### 配置文件位置
`ClothesBack/src/main/resources/db.properties`

### 必须包含的内容
```properties
jdbc.driver=com.mysql.cj.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/clothes_demo?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
jdbc.user=root
jdbc.password=【你的MySQL密码】
```

---

## 七、默认账号

| 端 | 账号 | 密码 |
|---|---|---|
| 管理后台 | `admin` | `123456` |

---

## 八、常见问题

### Q: AI 部署时应该怎么做？

**AI 部署步骤：**

1. **询问用户密码**
2. 读取 `ClothesBack/src/main/resources/db.properties`
3. 使用用户密码更新配置文件
4. 创建数据库
5. 导入表结构（跳过 schema.sql 开头的 DROP DATABASE）
6. 验证配置
7. 提示用户启动 IDEA

### Q: schema.sql 太危险？

是的！`schema.sql` 开头有 `DROP DATABASE`，会删除整个数据库。

**正确做法：**
- 让 AI 跳过前10行执行建表语句
- 或使用 `Doc/migrations/` 下的增量脚本

---

## 九、联系方式

- 项目地址：https://github.com/appetency1/ClothesDemo
- GitCode：https://gitcode.com/rafa630/ClothesDemo

---

**最后更新：2026-06-20**
