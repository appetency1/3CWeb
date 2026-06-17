---
name: session-handoff
description: 会话交接 — 保存当前会话上下文到项目记忆，方便下个会话无缝对接
---
# 会话交接 (Session Handoff)

> 保存当前会话的关键上下文到项目记忆，让下个会话能无缝衔接。

## 保存的内容

### 1. 当前进度
- 当前在做什么功能/修复什么 Bug
- 完成了哪些步骤
- 还剩哪些步骤

### 2. 文件变更摘要
- 本次对话修改了哪些文件
- 新增了哪些文件
- 删除了哪些文件

### 3. 问题与解决方案
- 遇到过什么坑
- 怎么解决的
- 还有什么待排查的问题

### 4. 技术决策
- 做了哪些设计选择
- 为什么这样选
- 还有什么待决定的

### 5. 下个会话的入口建议
- 建议从哪里开始
- 需要先读什么文件
- 有什么命令要跑

## 输出清单

用 `remember` 保存 1-2 条关键 memory。格式示例：

```
remember({
  type: "project",
  scope: "project",
  name: "session-2026-06-17",
  description: "2026-06-17 会话：已添加优惠券功能基础框架",
  content: "## 已完成\n- 创建 Coupon 表 (schema.sql)\n- 实现 CouponDao/Servlet\n- 完成管理后台优惠券列表页面\n\n## 待办\n- 优惠券发放逻辑\n- 用户端优惠券展示\n- 订单中使用优惠券\n\n## 坑\n- Servlet 路径映射注意 /api/admin/coupon/* 不要和 order 冲突\n\n## 入口\n- 下个会话先读 DOC/DB_DESIGN.md 确认表结构"
})
```
