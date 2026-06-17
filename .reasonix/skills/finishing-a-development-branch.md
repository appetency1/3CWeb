---
name: finishing-a-development-branch
description: 分支完工流程 — 验证测试→展示选项→执行选择→清理
---
# Finishing a Development Branch

> 实现完成后，验证并通过结构化选项完成整合。
> 核心原则：验证测试 → 展示选项 → 执行选择 → 清理。
> 来源：Trae skills / `finishing-a-development-branch`

## 流程

### Step 1: 验证测试
```bash
# 运行项目的测试套件
npm test / mvn test / pytest / ...
```
如果失败 → 报出失败数量并停止，先修复。

### Step 2: 确定基准分支
```bash
git merge-base HEAD main
git merge-base HEAD master
```

### Step 3: 展示选项
选项包括：
- **A. 合并到主分支** — 快速合并，无 PR
- **B. 创建 PR** — 请求代码审查
- **C. Squash 提交** — 合并前压缩
- **D. 交互式变基** — 清理提交历史

### Step 4: 执行
- 根据选择的选项执行操作
- 不要 push（让用户自己确认后再推）

### Step 5: 清理
```bash
# 删除已合并的本地分支
git branch -d <branch-name>
```

## 约束
- 测试失败时不能继续
- 不要推送远程（留给用户确认）
- 使用 `git -C <repo>` 格式执行命令
