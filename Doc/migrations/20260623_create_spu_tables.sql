-- ============================================================
-- SPU/SKU 架构改造：新建 spu 表，goods 表加 spu_id 和 specs
-- ============================================================

-- 1. 创建 spu 表（产品系列）
CREATE TABLE IF NOT EXISTS `spu` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'SPU ID',
  `name` varchar(200) NOT NULL COMMENT 'SPU名称',
  `brand` varchar(50) DEFAULT NULL COMMENT '品牌',
  `cover` varchar(255) DEFAULT NULL COMMENT 'SPU封面图',
  `images` text COMMENT 'SPU图册(JSON数组)',
  `description` text COMMENT 'SPU描述',
  `category_id` bigint NOT NULL COMMENT '所属分类',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态: 0下架 1上架',
  `is_hot` tinyint NOT NULL DEFAULT '0' COMMENT '是否热门',
  `is_new` tinyint NOT NULL DEFAULT '0' COMMENT '是否新品',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_category` (`category_id`),
  KEY `idx_status` (`status`),
  KEY `idx_hot` (`is_hot`),
  KEY `idx_new` (`is_new`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='产品系列(SPU)';

-- 2. goods 表加字段
ALTER TABLE `goods`
  ADD COLUMN `spu_id` bigint NOT NULL COMMENT '所属SPU ID' AFTER `id`,
  ADD COLUMN `specs` varchar(500) DEFAULT NULL COMMENT '规格(JSON: {"颜色":"黑","存储":"256G"})' AFTER `description`,
  ADD INDEX `idx_spu` (`spu_id`);
