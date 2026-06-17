---
name: fullstack-feature-guide
description: 全栈功能开发向导 — 从需求到DB→后端Servlet→前端页面的端到端开发指导
runAs: subagent
allowed-tools: read_file, search_content, search_files, directory_tree, list_directory, glob, get_file_info, get_symbols, find_in_code
---
# 全栈功能开发向导 (Fullstack Feature Guide)

> 专为 ClothesDemo 服装电商项目设计。每次添加新功能时，按照此流程逐步完成所有层级。

## 架构概览

```
ClothesDemo/
├── ClothesBack/src/main/java/org/example/clothesback/
│   ├── entity/        # POJO，对应数据库表
│   ├── dto/           # 输入参数 record
│   ├── dao/           # 纯 JDBC 数据访问
│   ├── service/       # 业务逻辑
│   ├── servlet/       # REST 接口
│   │   ├── public/    # 公共 API（无需登录）
│   │   ├── user/      # 用户 API（需登录）
│   │   └── admin/     # 管理 API（需管理员）
│   └── vo/            # 输出 record
├── ClothesUser/src/api/    # 用户前端 API 封装
├── ClothesAdmin/src/api/   # 管理后台 API 封装
├── ClothesUser/src/views/  # 用户前端页面
└── ClothesAdmin/src/views/ # 管理后台页面
```

## 工作流程

### Step 1: 确认需求 & 阅读文档
先读取以下文件了解现有设计：
- `Doc/DB_DESIGN.md` — 数据库设计
- `Doc/API_DESIGN.md` — API 设计
- `Doc/schema.sql` — DDL

### Step 2: 数据库层
1. 在 `Doc/schema.sql` 中添加/修改表
2. 在 `Doc/DB_DESIGN.md` 中更新表结构说明
3. 如果需要迁移已部署数据，在 `Doc/migrations/` 下创建迁移脚本

### Step 3: 后端层（按顺序）
1. **Entity** — 在 `entity/` 创建 POJO，字段与数据库列一一对应
2. **DTO** — 在 `dto/` 创建输入参数 record（如果有）
3. **VO** — 在 `vo/V.java` 中添加输出 record（如果需要新的返回类型）
4. **DAO** — 在 `dao/` 创建数据访问层，纯 JDBC
5. **Service** — 在 `service/` 创建业务逻辑层
6. **Servlet** — 在 `servlet/{public,user,admin}/` 创建 REST 端点

### Step 4: 前端层
- **API 封装** — 在对应前端项目的 `api/` 目录添加 axios 调用
- **页面/组件** — 在 `views/` 目录添加 Vue 3 组件
- **路由** — 在 `router/index.ts` 添加路由（如果需要新页面）

## 关键约束
- 响应格式：`{ code, message, data }` — 用 `Result` 类
- 业务异常：`BizException(code, message)`
- 事务：订单创建/取消/退款必须加事务
- 所有 DDL 必须同时更新 `schema.sql` + `DB_DESIGN.md`
- 不要修改现有的路由配置（`router/index.ts` 已稳定）
- 用户前端 UI 库是 Vant 4，管理后台是纯 Vue 3（无 Element Plus）
- 图片路径用 `/assets/products/{filename}` 格式
- 后端是 Servlet 6.1 + 纯 JDBC，**不能用 Spring / MyBatis / Hibernate**
