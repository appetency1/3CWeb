-- ============================================================
-- 数据迁移：goods → SPU + SKU
-- 合并同系列商品为 SPU，每个 goods 成为 SKU
-- 前提：spu 表已创建，goods 表已加 spu_id 和 specs 字段
-- ============================================================

-- ============================================================
-- 2. 创建 SPU 并设置 spu_id
-- ============================================================

-- 2a. iPhone 15 Pro 系列 (Pro Max 1TB + Pro 256G)
INSERT INTO `spu`(`name`,`brand`,`cover`,`images`,`description`,`category_id`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`)
SELECT CONCAT('iPhone 15 Pro 系列'), 'Apple',
  '/assets/products/goods-apple-iphone15-pro.svg', '[]',
  'A17 Pro芯片，钛金属设计，4800万像素主摄。可选Pro Max或Pro型号。',
  101, 1, 1, 1, NOW(), NOW();
SET @spu_iphone = LAST_INSERT_ID();
UPDATE `goods` SET `spu_id` = @spu_iphone, `specs` = '{"型号":"Pro Max","存储":"1TB","颜色":"原色钛金属"}' WHERE `id` = 1;
UPDATE `goods` SET `spu_id` = @spu_iphone, `specs` = '{"型号":"Pro","存储":"256G","颜色":"原色钛金属"}' WHERE `id` = 2;

-- 2b. iPad Pro M4 系列 (13英寸 + 11英寸)
INSERT INTO `spu`(`name`,`brand`,`cover`,`images`,`description`,`category_id`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`)
SELECT CONCAT('iPad Pro M4'), 'Apple',
  '/assets/products/goods-apple-ipad-pro-m4.svg', '[]',
  'M4芯片，超XDR显示屏，超轻薄设计。可选13英寸或11英寸。',
  203, 1, 1, 1, NOW(), NOW();
SET @spu_ipad = LAST_INSERT_ID();
UPDATE `goods` SET `spu_id` = @spu_ipad, `specs` = '{"尺寸":"13英寸","颜色":"银/深空黑"}' WHERE `id` = 17;
UPDATE `goods` SET `spu_id` = @spu_ipad, `specs` = '{"尺寸":"11英寸","颜色":"银/深空黑"}' WHERE `id` = 18;

-- 2c. Sony A7 系列 (A7M4 + A7C2)
INSERT INTO `spu`(`name`,`brand`,`cover`,`images`,`description`,`category_id`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`)
SELECT CONCAT('Sony A7 全画幅微单'), 'Sony',
  '/assets/products/goods-sony-a7m4.svg', '[]',
  '全画幅微单相机，卓越画质与对焦性能。可选A7M4或A7C2。',
  302, 1, 1, 1, NOW(), NOW();
SET @spu_sony = LAST_INSERT_ID();
UPDATE `goods` SET `spu_id` = @spu_sony, `specs` = '{"型号":"A7M4","像素":"3300万"}' WHERE `id` = 31;
UPDATE `goods` SET `spu_id` = @spu_sony, `specs` = '{"型号":"A7C2","像素":"3300万"}' WHERE `id` = 32;

-- 2d. 其余商品各自独立成 SPU（1 SPU = 1 SKU）
-- 智能手机剩余
INSERT INTO `spu`(`name`,`brand`,`cover`,`images`,`description`,`category_id`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`)
SELECT g.`name`, g.`brand`, g.`cover`, g.`images`, g.`description`, g.`category_id`, g.`status`, g.`is_hot`, g.`is_new`, NOW(), NOW()
FROM `goods` g WHERE g.`id` IN (3,4,5,6,7,8)
ORDER BY g.`id`;
SET @spu_start = LAST_INSERT_ID();
UPDATE `goods` g JOIN (SELECT id, @rownum:=@rownum+1 AS rn FROM (SELECT id FROM `goods` WHERE id IN (3,4,5,6,7,8) ORDER BY id) t, (SELECT @rownum:=0) r) tmp ON g.id=tmp.id
SET g.`spu_id` = @spu_start + tmp.rn - 1, g.`specs` = '{"规格":"标准版"}';

-- 笔记本电脑（ID: 9~16）
INSERT INTO `spu`(`name`,`brand`,`cover`,`images`,`description`,`category_id`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`)
SELECT g.`name`, g.`brand`, g.`cover`, g.`images`, g.`description`, g.`category_id`, g.`status`, g.`is_hot`, g.`is_new`, NOW(), NOW()
FROM `goods` g WHERE g.`id` IN (9,10,11,12,13,14,15,16)
ORDER BY g.`id`;
SET @spu_start = LAST_INSERT_ID();
UPDATE `goods` g JOIN (SELECT id, @rownum:=@rownum+1 AS rn FROM (SELECT id FROM `goods` WHERE id IN (9,10,11,12,13,14,15,16) ORDER BY id) t, (SELECT @rownum:=0) r) tmp ON g.id=tmp.id
SET g.`spu_id` = @spu_start + tmp.rn - 1, g.`specs` = '{"规格":"标准版"}';

-- 平板剩余（ID: 19~22）
INSERT INTO `spu`(`name`,`brand`,`cover`,`images`,`description`,`category_id`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`)
SELECT g.`name`, g.`brand`, g.`cover`, g.`images`, g.`description`, g.`category_id`, g.`status`, g.`is_hot`, g.`is_new`, NOW(), NOW()
FROM `goods` g WHERE g.`id` IN (19,20,21,22)
ORDER BY g.`id`;
SET @spu_start = LAST_INSERT_ID();
UPDATE `goods` g JOIN (SELECT id, @rownum:=@rownum+1 AS rn FROM (SELECT id FROM `goods` WHERE id IN (19,20,21,22) ORDER BY id) t, (SELECT @rownum:=0) r) tmp ON g.id=tmp.id
SET g.`spu_id` = @spu_start + tmp.rn - 1, g.`specs` = '{"规格":"标准版"}';

-- 耳机/音箱（ID: 23~30）
INSERT INTO `spu`(`name`,`brand`,`cover`,`images`,`description`,`category_id`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`)
SELECT g.`name`, g.`brand`, g.`cover`, g.`images`, g.`description`, g.`category_id`, g.`status`, g.`is_hot`, g.`is_new`, NOW(), NOW()
FROM `goods` g WHERE g.`id` IN (23,24,25,26,27,28,29,30)
ORDER BY g.`id`;
SET @spu_start = LAST_INSERT_ID();
UPDATE `goods` g JOIN (SELECT id, @rownum:=@rownum+1 AS rn FROM (SELECT id FROM `goods` WHERE id IN (23,24,25,26,27,28,29,30) ORDER BY id) t, (SELECT @rownum:=0) r) tmp ON g.id=tmp.id
SET g.`spu_id` = @spu_start + tmp.rn - 1, g.`specs` = '{"规格":"标准版"}';

-- 相机剩余 + 手表 + 功能手机 + 台式 + 对讲机 + 手环 + 配件 + 网络设备
INSERT INTO `spu`(`name`,`brand`,`cover`,`images`,`description`,`category_id`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`)
SELECT g.`name`, g.`brand`, g.`cover`, g.`images`, g.`description`, g.`category_id`, g.`status`, g.`is_hot`, g.`is_new`, NOW(), NOW()
FROM `goods` g WHERE g.`id` IN (33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65)
ORDER BY g.`id`;
SET @spu_start = LAST_INSERT_ID();
UPDATE `goods` g JOIN (SELECT id, @rownum:=@rownum+1 AS rn FROM (SELECT id FROM `goods` WHERE id IN (33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65) ORDER BY id) t, (SELECT @rownum:=0) r) tmp ON g.id=tmp.id
SET g.`spu_id` = @spu_start + tmp.rn - 1, g.`specs` = '{"规格":"标准版"}';


-- ============================================================
-- 4. 验证
-- ============================================================
SELECT CONCAT('SPU 数量: ', COUNT(*)) AS result FROM `spu`;
SELECT CONCAT('SKU(goods) 数量: ', COUNT(*)) AS result FROM `goods`;
SELECT CONCAT('多SKU的SPU数: ', COUNT(DISTINCT tmp.spu_id)) FROM (SELECT spu_id FROM `goods` GROUP BY spu_id HAVING COUNT(*) > 1) tmp;
