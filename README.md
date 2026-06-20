# ClothesDemo - 服装商城系统

一个前后端分离的服装电商平台，包含用户端和管理后台。

---

## 一、项目概述

| 模块 | 说明 | 端口 |
|------|------|------|
| ClothesUser | 用户端（移动端） | 5173 |
| ClothesAdmin | 管理后台（桌面端） | 5174 |
| ClothesBack | 后端 API 服务 | 8080 |

### 技术栈

- **前端**: Vue 3 + Vite + Vant 4 + TypeScript
- **后端**: Jakarta Servlet 6.1 + 原生 JDBC + MySQL 8

---

## 二、环境要求

| 软件 | 版本 |
|------|------|
| Node.js | ≥ 18.0.0 |
| Java | ≥ JDK 17 |
| Maven | ≥ 3.8 |
| MySQL | ≥ 8.0 |
| IntelliJ IDEA | 最新版 |

---

## 三、AI 部署指令

### 核心任务：配置后端数据库

**⚠️ AI 只负责配置，不执行任何运行命令！**

```
AI 执行步骤：

1. 读取 ClothesBack/src/main/resources/db.properties
2. 测试数据库连接：mysql -u root -p密码 -e "SELECT 1"
3. 如果连接失败：
   - 询问用户正确的 MySQL 密码
   - 更新 db.properties 中的 jdbc.password
4. 创建数据库：CREATE DATABASE IF NOT EXISTS clothes_demo
5. 执行建表语句（跳过 schema.sql 的 DROP DATABASE 部分）
6. 验证：SHOW TABLES
7. 提示用户手动启动

✅ AI 不要做：
- ❌ 不要运行 npm install
- ❌ 不要运行 npm run dev
- ❌ 不要启动后端服务
- ❌ 不要修改前端配置
```

### 读取配置文件

```bash
cat ClothesBack/src/main/resources/db.properties
```

**当前配置示例：**
```properties
jdbc.driver=com.mysql.cj.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/clothes_demo?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
jdbc.user=root
jdbc.password=000000
```

---

## 四、用户启动步骤

### 后端（用户手动）

```
1. 用 IntelliJ IDEA 打开 ClothesDemo/ClothesBack
2. 等待 Maven 下载依赖
3. 右键 AppListener.java → Run
4. 访问：http://localhost:8080/ClothesBack_war
```

### 前端（用户手动）

```bash
# 用户端
cd ClothesUser && npm install && npm run dev

# 管理后台
cd ClothesAdmin && npm install && npm run dev
```

---

## 五、常见问题

### AI 部署失败怎么办？

**AI 应该这样做：**

1. 先用当前密码测试连接
2. 如果失败，询问用户密码
3. 更新配置文件
4. 重新测试连接

**询问模板：**
```
我无法连接您的 MySQL 数据库。
请提供您的 MySQL root 密码，我将更新配置文件。
```

### schema.sql 太危险？

是的！`schema.sql` 开头有 `DROP DATABASE`，会删除整个数据库！

**AI 应该手动执行建表语句，跳过 DROP DATABASE。**

---

## 六、默认账号

| 端 | 账号 | 密码 |
|---|---|---|
| 管理后台 | `admin` | `123456` |

---

## 七、项目结构

```
ClothesDemo/
├── ClothesUser/           # 用户端前端
├── ClothesAdmin/          # 管理后台前端
├── ClothesBack/           # 后端服务
│   └── src/main/resources/
│       └── db.properties  # ⚠️ AI 需要修改这个文件
├── Doc/                   # 文档和迁移脚本
└── README.md             # 本文件
```

---

**最后更新：2026-06-20**
