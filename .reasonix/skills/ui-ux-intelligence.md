---
name: ui-ux-intelligence
description: UI/UX 设计检视清单 — 无障碍、触控、布局、色彩、性能
---
# UI/UX Design Intelligence

> 综合 UI/UX 设计指南，用于检视和提升前端界面质量。
> 来源：Trae skills / `ui-ux-intelligence`

## 优先级分类

### 1. 无障碍 (关键)
- [ ] 颜色对比度 ≥ 4.5:1（正文）
- [ ] 聚焦状态可见
- [ ] 图片提供有意义的 alt 文本
- [ ] 纯图标按钮加 aria-label
- [ ] Tab 顺序匹配视觉顺序
- [ ] 表单标签使用 label + for

### 2. 触控与交互 (关键)
- [ ] 触控目标 ≥ 44x44px
- [ ] 异步操作时禁用按钮
- [ ] 错误信息靠近输入框
- [ ] 可点击元素有 `cursor: pointer`

### 3. 性能 (高)
- [ ] 图片使用 WebP、srcset、懒加载
- [ ] 校验 `prefers-reduced-motion`
- [ ] 为异步内容预留空间（防抖动）

### 4. 布局与响应式 (高)
- [ ] `<meta viewport>` 已配置
- [ ] 移动端正文最小 16px
- [ ] 内容不超出视口宽度
- [ ] z-index 分层管理（10, 20, 30, 50）

### 5. 视觉质量
- [ ] 不用 emoji 替代图标（用 SVG）
- [ ] 图标集风格统一
- [ ] Hover 状态不导致布局偏移
- [ ] 过渡动画平滑（150-300ms）

### 6. 交互
- [ ] 可点击元素有 `cursor: pointer`
- [ ] Hover 提供清晰视觉反馈
- [ ] 键盘导航聚焦状态可见
