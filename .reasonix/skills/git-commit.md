---
name: git-commit
description: 标准化 Git 提交信息 — Conventional Commits 格式，自动分析变更类型和scope
---
# Git Commit with Conventional Commits

> 使用 Conventional Commits 规范创建标准化的 Git 提交信息。
> 来源：Trae skills / `git-commit`

## 提交格式

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## 提交类型

| 类型 | 用途 |
|------|------|
| `feat` | 新功能 |
| `fix` | Bug 修复 |
| `docs` | 文档更新 |
| `style` | 格式调整（无逻辑变更） |
| `refactor` | 代码重构（非功能/修复） |
| `perf` | 性能优化 |
| `test` | 添加/更新测试 |
| `build` | 构建系统/依赖变更 |
| `ci` | CI 配置变更 |
| `chore` | 杂项维护 |
| `revert` | 回退提交 |

## 工作流

1. 分析变更 diff，自动检测类型和 scope
2. 生成推荐提交信息
3. 支持手动覆盖 type/scope/description
4. 采用 `git -C <repo>` 执行命令

## 约束
- 描述使用祈使句（"Fix bug" 而非 "Fixed bug"）
- 首字母小写，末尾无句号
- scope 用小写 + 连字符
