---
name: asset-manager
description: 素材管理助手 — 素材命名规范校验、批量重命名、占位图生成、素材清单维护
---
# 素材管理助手 (Asset Manager)

> 基于 `素材清单.md` 的命名规范，管理 ClothesDemo 项目的素材文件。

## 命名规范（来自 素材清单.md）

| 类型 | 格式 | 示例 |
|------|------|------|
| 轮播图 | `banner-{序号}-{中文主题关键词}.jpg` | `banner-1-夏季新款.jpg` |
| 商品封面 | `goods-{商品ID}-{商品名拼音}.jpg` | `goods-1-molan-di-mian-t.jpg` |
| 占位图 | `placeholder-{类型}.jpg` | `placeholder-product.jpg` |

## 目录结构

```
ClothesUser/public/assets/
├── banners/       # 轮播图（1920x600px，5张）
├── products/      # 商品图（800x1000px，~69张）
├── avatars/       # 用户头像
├── brand/         # 品牌 Logo
├── icons/         # 图标
├── logos/         # Logo
├── placeholders/  # 占位图
└── ...
```

## 常用操作

1. **校验命名** — 检查 `public/assets/` 下文件是否按规范命名
2. **批量重命名** — 将杂乱命名的素材重命名为规范格式
3. **生成占位图** — 用 Canvas/CSS 生成指定尺寸的占位图
4. **素材清单同步** — 检查 `public/assets/` 实际文件与 `素材清单.md` 是否一致
5. **尺寸检查** — 检查图片实际尺寸是否符合要求（轮播图 1920x600，商品图 800x1000）

## 约束
- 所有图片统一用 **jpg** 格式（非透明背景）
- 商品图白底纯色背景，主体清晰
- 全小写 + 连字符 `-` 命名
