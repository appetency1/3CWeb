---
name: data-script-generator
description: 数据脚本生成器 — 测试数据SQL、数据修复、批量导入导出、数据清洗
---
# 数据脚本生成器 (Data Script Generator)

> 为 ClothesDemo 项目生成 SQL 数据脚本，参考 `Doc/schema.sql` 和 `Doc/DB_DESIGN.md`。

## 参考文档
- `Doc/schema.sql` — DDL
- `Doc/DB_DESIGN.md` — 数据库设计说明
- `Doc/goods_data_final.sql` — 商品种子数据
- `Doc/goods_data_v2.sql` — 商品数据 v2
- `素材清单.md` — 商品ID映射
- `Doc/migrations/` — 迁移脚本目录

## 常用脚本类型

### 1. 测试数据生成
生成指定数量的：
- 用户测试数据（`User` 表）
- 订单测试数据（`Order` + `OrderItem` 表）
- 评论测试数据（`Comment` 表）
- 收藏测试数据（`Favorite` 表）

### 2. 数据修复
- 修复不一致的引用关系
- 修补空值/默认值
- 数据去重

### 3. 数据导入导出
- CSV/JSON 转 SQL INSERT
- SQL 查询结果格式化输出

### 4. 统计分析
- 生成统计查询（销量、用户数、订单金额等）

## 约束
- 表名、字段名参考 `schema.sql` 定义
- 迁移脚本放在 `Doc/migrations/` 目录，命名格式 `{YYYYMMDD}_{topic}.sql`
- 所有 DDL 更新必须同时更新 `schema.sql` + `DB_DESIGN.md`
- 测试数据不要覆盖已有主键
- 时间字段使用 `NOW()` 或 `DATE_ADD()` 生成相对时间
- 图片路径格式：`/assets/products/goods-{id}-{拼音}.jpg`
