# 3C数码科幻电商平台 — 技术架构文档

## 1. 架构设计

现有项目改造，保持前后端分离架构：

```
┌─────────────────┐      REST API      ┌─────────────────┐
│   ClothesUser   │ ◄────────────────► │   ClothesBack   │
│  (Vue3 + Vite)  │                    │  (Java Servlet) │
└─────────────────┘                    └─────────────────┘
```

## 2. 技术栈

- **前端框架**: Vue 3.5 + TypeScript + Vite 8
- **UI组件库**: Vant 4 (移动端) + 自定义桌面端组件
- **状态管理**: Pinia 3
- **路由**: Vue Router 4
- **样式**: 原生CSS变量 + Scoped Style
- **动效**: CSS Animation + Canvas 2D粒子系统

## 3. 改造范围

| 文件 | 改造内容 |
|------|----------|
| `style.css` | 全局CSS变量重定义为赛博朋克深色主题 |
| `App.vue` | 添加Canvas动态粒子背景层 |
| `DesktopHomeView.vue` | 首页全面科幻风格化（Hero、卡片、光效） |
| `DesktopLayout.vue` | 导航栏深色改造 |

## 4. 设计Token

```css
:root {
  --bg-primary: #0a0a0f;
  --bg-secondary: #12121a;
  --bg-card: #161622;
  --accent: #00f0ff;
  --accent-secondary: #ff00aa;
  --accent-glow: rgba(0, 240, 255, 0.4);
  --text-primary: #e0e0e8;
  --text-secondary: #8a8aa0;
  --border: rgba(0, 240, 255, 0.15);
}
```

## 5. 特效实现

- **粒子背景**: Canvas 2D 绘制星空/霓虹粒子，跟随鼠标交互
- **霓虹光晕**: CSS `box-shadow` + `drop-shadow` 多层发光
- **渐变文字**: `background-clip: text` 实现彩虹/霓虹渐变标题
- **扫描线**: 伪元素实现CRT显示器扫描线效果
- **悬浮动效**: `transform` + `transition` 实现卡片悬浮位移
