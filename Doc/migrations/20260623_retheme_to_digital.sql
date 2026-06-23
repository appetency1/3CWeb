-- ============================================================
-- 主题改造：服装 → 数码/3C 产品（完整版）
-- 说明：清理所有服装数据 + 更新分类 + 插入数码示例数据
-- ============================================================

-- ============================================================
-- 第一部分：清理旧数据
-- ============================================================

-- 1.1 清空业务数据（注意外键顺序）
DELETE FROM `comment`;
DELETE FROM `favorite`;
DELETE FROM `cart`;
DELETE FROM `order_item`;
DELETE FROM `orders`;
DELETE FROM `sku`;
DELETE FROM `goods`;

-- 1.2 清理测试用户（保留 admin）
DELETE FROM `user` WHERE `id` > 1;

-- 1.3 重置自增主键
ALTER TABLE `goods` AUTO_INCREMENT = 1;
ALTER TABLE `sku` AUTO_INCREMENT = 1;
ALTER TABLE `orders` AUTO_INCREMENT = 1;
ALTER TABLE `order_item` AUTO_INCREMENT = 1;
ALTER TABLE `comment` AUTO_INCREMENT = 1;

-- ============================================================
-- 第二部分：更新分类为数码/3C
-- ============================================================

-- 2.1 一级分类
UPDATE `category` SET `name` = '手机通讯', `icon` = '/assets/icons/cat-phone.svg' WHERE `id` = 1;
UPDATE `category` SET `name` = '电脑办公', `icon` = '/assets/icons/cat-computer.svg' WHERE `id` = 2;
UPDATE `category` SET `name` = '数码影音', `icon` = '/assets/icons/cat-audio.svg' WHERE `id` = 3;
UPDATE `category` SET `name` = '智能穿戴', `icon` = '/assets/icons/cat-wearable.svg' WHERE `id` = 4;
UPDATE `category` SET `name` = '手机配件', `icon` = '/assets/icons/cat-phone.svg' WHERE `id` = 501;
UPDATE `category` SET `name` = '网络设备', `icon` = '/assets/icons/cat-network.svg' WHERE `id` = 502;

-- 2.2 二级分类（手机通讯 → 子分类）
UPDATE `category` SET `name` = '智能手机'   WHERE `id` = 101;
UPDATE `category` SET `name` = '功能手机'   WHERE `id` = 102;
UPDATE `category` SET `name` = '对讲机'     WHERE `id` = 103;

-- 2.3 二级分类（电脑办公 → 子分类）
UPDATE `category` SET `name` = '笔记本电脑' WHERE `id` = 201;
UPDATE `category` SET `name` = '台式电脑'   WHERE `id` = 202;
UPDATE `category` SET `name` = '平板电脑'   WHERE `id` = 203;

-- 2.4 二级分类（数码影音 → 子分类）
UPDATE `category` SET `name` = '耳机/音箱'  WHERE `id` = 301;
UPDATE `category` SET `name` = '相机/摄像机' WHERE `id` = 302;

-- 2.5 二级分类（智能穿戴 → 子分类）
UPDATE `category` SET `name` = '智能手表'   WHERE `id` = 401;
UPDATE `category` SET `name` = '智能手环'   WHERE `id` = 402;

-- ============================================================
-- 第三部分：更新轮播图标题
-- ============================================================

UPDATE `banner` SET `title` = '新机上市 数码盛宴', `link` = '/category' WHERE `id` = 1;
UPDATE `banner` SET `title` = '笔记本 办公利器',   `link` = '/category' WHERE `id` = 2;
UPDATE `banner` SET `title` = '影音娱乐 沉浸体验', `link` = '/category' WHERE `id` = 3;
UPDATE `banner` SET `title` = '智能穿戴 健康随行', `link` = '/category' WHERE `id` = 4;
UPDATE `banner` SET `title` = '数码配件 全场特惠', `link` = '/category' WHERE `id` = 5;
UPDATE `banner` SET `title` = '限时秒杀 数码狂欢', `link` = '/sale'    WHERE `id` = 6;

-- ============================================================
-- 第四部分：插入数码商品示例数据
-- ============================================================

-- 智能手机（category_id=101）
INSERT INTO `goods`(`category_id`,`name`,`brand`,`cover`,`images`,`description`,`detail`,`price`,`original_price`,`stock`,`sales`,`view_count`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
(101,'iPhone 15 Pro 256G','Apple','/assets/products/goods-1.svg','[]','A17 Pro芯片，钛金属设计，4800万像素主摄',NULL,8999.00,9999.00,500,3200,0,1,1,1,NOW(),NOW()),
(101,'HUAWEI Mate 60 Pro','HUAWEI','/assets/products/goods-2.svg','[]','卫星通话，昆仑玻璃，麒麟芯片',NULL,6999.00,7999.00,500,2800,0,1,1,1,NOW(),NOW()),
(101,'小米14 Ultra','Xiaomi','/assets/products/goods-3.svg','[]','骁龙8Gen3，徕卡光学，一英寸大底',NULL,5999.00,6999.00,500,2100,0,1,1,0,NOW(),NOW()),
(101,'Samsung Galaxy S24 Ultra','Samsung','/assets/products/goods-4.svg','[]','Galaxy AI，钛金属框架，S Pen',NULL,10999.00,12999.00,300,1500,0,1,1,1,NOW(),NOW()),
(101,'iPhone SE 第三代','Apple','/assets/products/goods-8.svg','[]','A15芯片，4.7英寸，Touch ID',NULL,3499.00,4299.00,600,1800,0,1,0,0,NOW(),NOW());

-- 笔记本电脑（category_id=201）
INSERT INTO `goods`(`category_id`,`name`,`brand`,`cover`,`images`,`description`,`detail`,`price`,`original_price`,`stock`,`sales`,`view_count`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
(201,'MacBook Air M3','Apple','/assets/products/goods-9.svg','[]','M3芯片，13.6英寸，18小时续航',NULL,9499.00,10999.00,300,2100,0,1,1,1,NOW(),NOW()),
(201,'ThinkPad X1 Carbon','Lenovo','/assets/products/goods-10.svg','[]','第14代酷睿，14英寸2.8K OLED',NULL,10999.00,12999.00,200,980,0,1,1,0,NOW(),NOW()),
(201,'HUAWEI MateBook X Pro','HUAWEI','/assets/products/goods-11.svg','[]','3.1K原色屏，超级终端',NULL,9999.00,11999.00,250,1200,0,1,1,1,NOW(),NOW()),
(201,'ASUS ROG 幻16','ASUS','/assets/products/goods-12.svg','[]','i9-13900H，RTX4070，2.5K 240Hz',NULL,12999.00,14999.00,150,680,0,1,1,1,NOW(),NOW());

-- 平板电脑（category_id=203）
INSERT INTO `goods`(`category_id`,`name`,`brand`,`cover`,`images`,`description`,`detail`,`price`,`original_price`,`stock`,`sales`,`view_count`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
(203,'iPad Pro M4','Apple','/assets/products/goods-16.svg','[]','M4芯片，超XDR显示屏，超轻薄',NULL,6499.00,7999.00,400,1800,0,1,1,1,NOW(),NOW()),
(203,'iPad Air M2','Apple','/assets/products/goods-17.svg','[]','M2芯片，11英寸 Liquid 视网膜屏',NULL,4799.00,5999.00,500,1500,0,1,1,0,NOW(),NOW()),
(203,'HUAWEI MatePad Pro','HUAWEI','/assets/products/goods-18.svg','[]','13.2英寸 OLED，星闪连接',NULL,4299.00,5299.00,300,890,0,1,0,1,NOW(),NOW());

-- 耳机/音箱（category_id=301）
INSERT INTO `goods`(`category_id`,`name`,`brand`,`cover`,`images`,`description`,`detail`,`price`,`original_price`,`stock`,`sales`,`view_count`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
(301,'Sony WH-1000XM5','Sony','/assets/products/goods-22.svg','[]','行业标杆降噪，30小时续航',NULL,2499.00,2999.00,400,3500,0,1,1,1,NOW(),NOW()),
(301,'AirPods Pro 2','Apple','/assets/products/goods-23.svg','[]','H2芯片，自适应降噪，USB-C',NULL,1899.00,1999.00,600,5800,0,1,1,1,NOW(),NOW()),
(301,'Bose QC Ultra','Bose','/assets/products/goods-24.svg','[]','沉浸空间音频，CustomTune技术',NULL,2999.00,3499.00,300,1600,0,1,1,0,NOW(),NOW()),
(301,'Marshall Kilburn II','Marshall','/assets/products/goods-27.svg','[]','便携蓝牙音箱，30W功率，20小时续航',NULL,2299.00,2799.00,250,1200,0,1,0,0,NOW(),NOW());

-- 智能穿戴（category_id=401）
INSERT INTO `goods`(`category_id`,`name`,`brand`,`cover`,`images`,`description`,`detail`,`price`,`original_price`,`stock`,`sales`,`view_count`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
(401,'Apple Watch Series 9','Apple','/assets/products/goods-29.svg','[]','S9芯片，全天候视网膜屏，血氧检测',NULL,2999.00,3499.00,500,2800,0,1,1,1,NOW(),NOW()),
(401,'Galaxy Watch6 Classic','Samsung','/assets/products/goods-30.svg','[]','旋转表圈，体成分分析，睡眠监测',NULL,2799.00,3299.00,300,1200,0,1,1,0,NOW(),NOW()),
(401,'小米手环 9 Pro','Xiaomi','/assets/products/goods-33.svg','[]','1.74英寸AMOLED，21天续航',NULL,399.00,499.00,1000,8900,0,1,0,1,NOW(),NOW());

-- 相机/摄像机（category_id=302）
INSERT INTO `goods`(`category_id`,`name`,`brand`,`cover`,`images`,`description`,`detail`,`price`,`original_price`,`stock`,`sales`,`view_count`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
(302,'Sony A7M4 全画幅微单','Sony','/assets/products/goods-36.svg','[]','3300万像素，4K60p，实时追踪',NULL,15999.00,18999.00,100,560,0,1,1,1,NOW(),NOW()),
(302,'DJI Osmo Pocket 3','DJI','/assets/products/goods-38.svg','[]','1英寸CMOS，4K120fps，三轴云台',NULL,3499.00,3999.00,300,2100,0,1,1,1,NOW(),NOW()),
(302,'GoPro HERO 12','GoPro','/assets/products/goods-39.svg','[]','5.3K视频，HyperSmooth 6.0',NULL,3198.00,3998.00,200,1300,0,1,0,0,NOW(),NOW());

-- ============================================================
-- 第五部分：插入 SKU 数据
-- ============================================================

INSERT INTO `sku`(`goods_id`,`spec`,`price`,`stock`,`sales`,`image`,`sort`,`create_time`,`update_time`)
SELECT `id`,'default',`price`,`stock`,0,`cover`,0,NOW(),NOW() FROM `goods`;

-- ============================================================
-- 第六部分：更新统计（完成标记）
-- ============================================================

SELECT CONCAT('迁移完成：', COUNT(*), ' 件数码商品已插入') AS result FROM `goods`;
