---
name: build-deploy-helper
description: 多模块构建部署 — 一键启动/构建 ClothesAdmin + ClothesUser + ClothesBack
---
# 多模块构建部署 (Build & Deploy Helper)

> ClothesDemo 三模块构建/启动助手。

## 各模块构建命令

### ClothesAdmin（管理后台前端）
```bash
cd ClothesAdmin
npm install     # 安装依赖
npm run dev     # 启动开发服务器（默认 http://localhost:5173）
npm run build   # 构建生产版本
npm run preview # 预览生产构建
```

### ClothesUser（用户前端）
```bash
cd ClothesUser
npm install        # 安装依赖
npm run dev        # 启动开发服务器（默认 http://localhost:5174）
npm run build      # 构建生产版本
npm run preview    # 预览生产构建
```

### ClothesBack（Java 后端）
```bash
cd ClothesBack
mvn clean package  # 构建 war 包
# 部署到 Tomcat 10+ webapps/ 目录
```

## 配置参考

### 开发代理配置
两个前端工程的 `vite.config.ts` 中配置了代理到后端 `http://localhost:8080/clothes`：
- API 请求前缀 `/api` 被代理到后端
- 无需配置跨域（由代理处理）

### 环境变量
- ClothesUser: `.env.development` / `.env.production` / `.env`
- API 基础路径配置在这些文件中

## 常见命令组合
- `全量启动`: 后端 Tomcat + ClothesUser (dev) + ClothesAdmin (dev)
- `全量构建`: ClothesBack (mvn package) + ClothesUser (npm build) + ClothesAdmin (npm build)
- `仅前端调试`: ClothesUser dev + ClothesAdmin dev（后端需先启动）
