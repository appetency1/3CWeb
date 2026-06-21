# ClothesDemo 用户端前端

基于 Vue 3 + TypeScript + Vant 4 + Vite 的电商用户端。

## 启动

```bash
npm install
npm run dev   # http://localhost:5173
```

## 后端配置

编辑 `src/utils/request.ts` 中的 `VITE_API_BASE`（默认代理到 `http://localhost:8080`）。

## 目录结构

```
src/
├── api/        # 后端 API 调用封装
├── stores/     # Pinia 状态管理（user / cart）
├── types/      # TS 类型定义（model.d.ts / api.d.ts）
├── utils/      # 工具函数（request.ts / img.ts）
├── router/     # Vue Router 配置
├── views/      # 页面组件（Desktop* 系列）
└── components/ # 通用组件（DesktopLayout）
```
