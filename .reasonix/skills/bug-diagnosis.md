---
name: bug-diagnosis
description: Bug诊断助手 — 跨前后端异常排查、联调问题定位、日志分析
runAs: subagent
allowed-tools: read_file, search_content, search_files, directory_tree, list_directory, glob, get_file_info, get_symbols, find_in_code
---
# Bug 诊断助手 (Bug Diagnosis)

> 排查 ClothesDemo 项目的跨模块问题。调查前先确认出问题的模块和现象。

## 常见问题分类与排查路径

### 1. 后端报错（HTTP 500 / 异常堆栈）
排查链路：
```
Servlet 入口 → Service 层 → DAO/JDBC → MySQL
```
- 检查 `BaseServlet` 的异常处理（是否被 catch 吞掉）
- 检查 `CorsFilter` / `AuthInterceptor` 是否拦截了请求
- 检查 SQL 语法（纯 JDBC，手写 SQL 易错）
- 检查 JSON 序列化（Fastjson2 的字段名/类型匹配）
- 检查 `BizException` 是否被正确抛出而非泛型 Exception

### 2. 前端数据不对（空白 / 404 / 数据格式错误）
排查链路：
```
API 请求 → 路由 → 组件渲染 → 数据绑定
```
- 检查请求是否发到正确的后端地址（Vite 代理配置）
- 检查响应 `{ code, message, data }` 中的 code 是否为 200
- 检查 TypeScript 类型定义 `types/model.d.ts` 和 `types/api.d.ts` 是否与实际返回一致
- 检查 Vant 组件数据绑定格式（如 `swipe` 需要数组，`list` 需要 `v-model:loading`）

### 3. 登录/权限问题
排查链路：
```
登录 → Token 生成 → 前端存储 → 请求携带 → Token 校验
```
- 检查 `TokenManager.java` 的 token 生成/解析逻辑
- 检查 `AuthInterceptor` 的拦截路径配置
- 检查前端 `request.ts` 的请求拦截器是否正确携带 Bearer token
- 检查 `stores/user.ts` 或 `stores/admin.ts` 的 token 存取逻辑

### 4. 图片/静态资源不显示
排查链路：
```
请求路径 → 后端映射 → 静态资源目录
```
- 检查图片路径格式 `/assets/products/goods-{id}.jpg`
- 检查 `AppConfig.java` 的静态资源配置
- 检查实际文件是否存在

### 5. 数据库问题
- 连接失败：检查 `JdbcUtils.java` 的数据库连接参数
- SQL 错误：检查手写 SQL 的表名/字段名拼写
- 数据为空：检查 `schema.sql` 是否已导入、种子数据是否已插入

## 诊断流程
1. **确认症状** — 用户描述的异常现象
2. **重现路径** — 什么操作/页面触发
3. **缩小范围** — 是后端报错、前端报错、还是数据不一致
4. **检查边界** — 空值/未登录/参数缺失
5. **检查日志** — dev.err / dev.log / 控制台输出
6. **给出修复建议** — 带着 file:line 的具体修改方案
