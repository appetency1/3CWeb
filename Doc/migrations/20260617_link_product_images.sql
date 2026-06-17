-- ============================================================
-- 更新 1~15 号商品的 cover 为真实 JPG
-- 16~64 保持 /assets/placeholders/product-placeholder.svg 占位
-- 需要 schema.sql 跑过（建好 goods 表 + 初始数据）
-- ============================================================

USE clothes_demo;

UPDATE `goods` SET `cover` = '/assets/products/goods-1-molan-di-mian-t.jpg' WHERE `id` = 1;
UPDATE `goods` SET `cover` = '/assets/products/goods-2-tiao-wen-polo.jpg'    WHERE `id` = 2;
UPDATE `goods` SET `cover` = '/assets/products/goods-3-chun-mian-bai-t.jpg'  WHERE `id` = 3;
UPDATE `goods` SET `cover` = '/assets/products/goods-4-hei-se-ku-tong-chang.jpg' WHERE `id` = 4;
UPDATE `goods` SET `cover` = '/assets/products/goods-5-nai-nai-yan-polo.jpg'  WHERE `id` = 5;
UPDATE `goods` SET `cover` = '/assets/products/goods-6-cotton-shirting.jpg'   WHERE `id` = 6;
UPDATE `goods` SET `cover` = '/assets/products/goods-7-hen-nai-ka-huang-t.jpg' WHERE `id` = 7;
UPDATE `goods` SET `cover` = '/assets/products/goods-8-chang-xu-zong-jie.jpg' WHERE `id` = 8;
UPDATE `goods` SET `cover` = '/assets/products/goods-9-xiu-shen-zhi-tong-niu-zai.jpg' WHERE `id` = 9;
UPDATE `goods` SET `cover` = '/assets/products/goods-10-hei-se-shui-fan-ku.jpg' WHERE `id` = 10;
UPDATE `goods` SET `cover` = '/assets/products/goods-11-shan-lan-xiu-tong-ku.jpg' WHERE `id` = 11;
UPDATE `goods` SET `cover` = '/assets/products/goods-12-kuan-song-da-ban-ku.jpg' WHERE `id` = 12;
UPDATE `goods` SET `cover` = '/assets/products/goods-13-bai-se-xi-bai-ku.jpg' WHERE `id` = 13;
UPDATE `goods` SET `cover` = '/assets/products/goods-14-qian-se-sha-fu-ku.jpg' WHERE `id` = 14;
UPDATE `goods` SET `cover` = '/assets/products/goods-15-hei-se-duan-ku.jpg'  WHERE `id` = 15;

-- 验证
SELECT id, name, cover FROM goods WHERE id BETWEEN 1 AND 15 ORDER BY id;
