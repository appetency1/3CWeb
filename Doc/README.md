# 衣服商城 (ClothesDemo) - 项目文档索引

> **本目录 `Doc/` 存放项目所有说明/设计文档**。后端基于 **Servlet 6.1 + 原生 JDBC + MySQL 8 + Fastjson2 + Maven** 的经典教学项目。
> ⚠️ **不使用任何 Spring / Spring Boot 框架**。

---

## 📚 必读文档

后端开发者请**按顺序**阅读:

| # | 文档 | 说明 | 必读人群 |
|---|---|---|---|
| 1️⃣ | [BACKEND_GUIDE.md](./BACKEND_GUIDE.md) | 后端开发指南:技术栈、目录结构、编码规范、核心类模板 | **后端必读** |
| 2️⃣ | [DB_DESIGN.md](./DB_DESIGN.md) | 数据库表结构设计:ER 图、字段说明、设计原则 | **后端必读** |
| 3️⃣ | [API_DESIGN.md](./API_DESIGN.md) | 接口设计文档:统一响应、Token、接口清单、业务规则 | **后端 + 前端 必读** |
| 4️⃣ | [schema.sql](./schema.sql) | 建库建表 SQL 脚本 + 初始数据 | **后端参考** |

---

## 🗂️ 项目结构

```
ClothesDemo/
├── ClothesAdmin/    # 管理后台前端 (Vue3,待开发)
├── ClothesBack/     # 后端 (本工程)
│   ├── pom.xml
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/org/example/clothesback/   # 源码(待开发)
│   │   │   ├── resources/
│   │   │   │   └── db.properties               # 数据库配置(待创建)
│   │   │   └── webapp/
│   │   │       ├── index.jsp
│   │   │       └── WEB-INF/web.xml
│   │   └── test/                               # 单元测试(待开发)
│   └── target/                                 # 编译输出
├── ClothesUser/     # 用户端前端 (Vue3,待开发)
└── Doc/             # 项目所有说明/设计文档(本目录)
    ├── README.md          # 本文件
    ├── BACKEND_GUIDE.md   # 后端开发指南
    ├── DB_DESIGN.md       # 表设计
    ├── API_DESIGN.md      # 接口设计
    └── schema.sql         # 建库脚本
```

---

## 🛠️ 技术栈(已确定,不可改)

| 类别 | 选型 |
|---|---|
| Web | Jakarta Servlet 6.1 |
| 打包 | WAR (Tomcat 10+) |
| 数据库 | MySQL 8.0+ |
| 数据访问 | **原生 JDBC** (DriverManager + PreparedStatement) |
| JSON | Fastjson2 |
| 构建 | Maven 3.8+ |
| Java | JDK 17+ |
| 测试 | JUnit Jupiter 5 |

**❌ 禁用** :Spring / Spring Boot / MyBatis / Hibernate / Spring MVC 等任何框架

---

## 🚀 快速开始

### 1. 初始化数据库
```bash
# 从项目根目录执行
mysql -u root -p < Doc/schema.sql
```

### 2. 修改数据库配置
在 `src/main/resources/db.properties` 中配置你的 MySQL 用户名密码:
```properties
jdbc.url=jdbc:mysql://localhost:3306/clothes_demo?...
jdbc.user=root
jdbc.password=你的密码
```

### 3. 启动 IDE 配置
- Project SDK: **JDK 17**
- 部署到 **Tomcat 10+**(Application context: `/clothes`)

### 4. 验证启动
访问 `http://localhost:8080/clothes/` 看到欢迎页即成功。

---

## 📋 默认账号

| 端 | 账号 | 密码 |
|---|---|---|
| 管理后台 | `admin` | （首次部署请修改默认密码） |
| 用户端 | (需自行注册) | - |

---

## 📞 后续约定

- 📁 **所有说明/设计文档统一放在 `Doc/` 目录**,不再放到 `ClothesBack/src/main/resources/` 或其他位置
- 📝 任何**新功能**或**接口改动**必须同步更新对应文档
- 🔀 修改表结构必须改 `Doc/schema.sql` + `Doc/DB_DESIGN.md`
- 🔌 修改接口必须改 `Doc/API_DESIGN.md`
- 🏗️ 编码规范 / 目录结构有调整必须改 `Doc/BACKEND_GUIDE.md`

---

**最后更新:2026-06-16**  |  维护者:ClothesDemo Team
