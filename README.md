# ClothesDemo — 服装电商全栈项目

前后端分离的服装商城，含用户端、管理后台、AI 客服。

## 技术栈

| 模块 | 技术 |
|------|------|
| 用户前端 | Vue 3 + TypeScript + Vant 4 + Vite |
| 管理后台 | Vue 3 + TypeScript + Vant 4 + Vite |
| 后端 | Java 17 + Servlet 6.1 + JDBC + Fastjson2 |
| 数据库 | MySQL 8.0+ |
| AI 客服 | DeepSeek API（可选） |

## 前置要求

- **Node.js** 18+
- **Java** 17+
- **Maven** 3.8+
- **MySQL** 8.0+
- **Tomcat** 10+ (或其它支持 Servlet 6.0 的容器)

## 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/appetency1/ClothesDemo.git
cd ClothesDemo
```

### 2. 创建数据库

用 MySQL 客户端导入完整数据库：

```bash
mysql -u root -p < Doc/clothes_demo.sql
```

> 默认数据库名：`clothes_demo`，包含完整表结构 + 64个商品数据。

### 3. 配置数据库连接

打开 `ClothesBack/src/main/resources/db.properties`，把密码改成你的 MySQL 密码：

```properties
jdbc.password=你的MySQL密码
```

> 也可以在系统环境变量设 `DB_PASSWORD`，部署时自动覆盖。

### 4. 启动后端

```bash
mvn -f ClothesBack/pom.xml clean package
```

把生成的 `ClothesBack/target/ClothesBack-1.0-SNAPSHOT.war` 复制到 Tomcat 的 `webapps/` 目录，启动 Tomcat。

### 5. 启动前端（新开终端）

**用户端：**
```bash
cd ClothesUser
npm install
npm run dev
# 访问 http://localhost:5173
```

**管理后台：**
```bash
cd ClothesAdmin
npm install
npm run dev
# 访问 http://localhost:5174
```

### 6. 配置 AI 客服（可选）

打开 `ClothesBack/src/main/resources/app.properties`：

```properties
deepseek.api.key=你的DeepSeek API Key
```

也可以在系统环境变量设 `DEEPSEEK_API_KEY`，优先级更高。

> 不配也不影响其他功能，只是 AI 客服不能用。

### 7. 默认账号

| 端 | 账号 | 密码 |
|----|------|------|
| 管理后台 | `admin` | `888888`（首次登录请修改） |
| 用户端 | 自行注册 | — |

## 项目结构

```
ClothesDemo/
├── ClothesUser/          # 用户端前端（Vue 3 + Vant）
├── ClothesAdmin/         # 管理后台前端（Vue 3 + Vant）
├── ClothesBack/          # 后端服务（Java + Servlet）
│   └── src/main/resources/
│       ├── db.properties      # 数据库连接配置
│       └── app.properties     # 应用配置（CORS、上传、AI Key）
├── Doc/
│   └── clothes_demo.sql   # 完整数据库导出（建表+数据）
└── README.md
```

## 常见问题

**Q: 前端页面空白 / 接口 404？**  
检查 Tomcat 是否在运行，后端 war 是否已部署。前后端默认端口：用户 5173、管理 5174、后端 8080。

**Q: 管理后台频繁提示"未登录"？**  
检查 `db.properties` 中的数据库连接是否正常，后端日志有无报错。
