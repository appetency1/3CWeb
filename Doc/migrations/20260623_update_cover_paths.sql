-- 更新商品封面路径为产品型号命名（同型号共用图）
-- 格式：/assets/products/goods-{品牌}-{型号}.svg（占位图用svg，正式替换为jpg）

-- 智能手机
UPDATE `goods` SET `cover`='/assets/products/goods-apple-iphone15-pro-max.svg' WHERE `id`=1;
UPDATE `goods` SET `cover`='/assets/products/goods-apple-iphone15-pro.svg' WHERE `id`=2;
UPDATE `goods` SET `cover`='/assets/products/goods-huawei-mate60-pro.svg' WHERE `id`=3;
UPDATE `goods` SET `cover`='/assets/products/goods-xiaomi-14-ultra.svg' WHERE `id`=4;
UPDATE `goods` SET `cover`='/assets/products/goods-samsung-s24-ultra.svg' WHERE `id`=5;
UPDATE `goods` SET `cover`='/assets/products/goods-oppo-find-x7-ultra.svg' WHERE `id`=6;
UPDATE `goods` SET `cover`='/assets/products/goods-vivo-x100-pro.svg' WHERE `id`=7;
UPDATE `goods` SET `cover`='/assets/products/goods-apple-iphone-se.svg' WHERE `id`=8;

-- 笔记本电脑
UPDATE `goods` SET `cover`='/assets/products/goods-apple-macbook-air-m3.svg' WHERE `id`=9;
UPDATE `goods` SET `cover`='/assets/products/goods-apple-macbook-pro-16.svg' WHERE `id`=10;
UPDATE `goods` SET `cover`='/assets/products/goods-lenovo-thinkpad-x1.svg' WHERE `id`=11;
UPDATE `goods` SET `cover`='/assets/products/goods-huawei-matebook-x-pro.svg' WHERE `id`=12;
UPDATE `goods` SET `cover`='/assets/products/goods-asus-rog-zephyrus-16.svg' WHERE `id`=13;
UPDATE `goods` SET `cover`='/assets/products/goods-dell-xps-16.svg' WHERE `id`=14;
UPDATE `goods` SET `cover`='/assets/products/goods-microsoft-surface-laptop-6.svg' WHERE `id`=15;
UPDATE `goods` SET `cover`='/assets/products/goods-xiaomi-redmibook-16.svg' WHERE `id`=16;

-- 平板电脑（iPad Pro M4 13" 和 11" 共用图）
UPDATE `goods` SET `cover`='/assets/products/goods-apple-ipad-pro-m4.svg' WHERE `id` IN (17,18);
UPDATE `goods` SET `cover`='/assets/products/goods-apple-ipad-air-m2.svg' WHERE `id`=19;
UPDATE `goods` SET `cover`='/assets/products/goods-huawei-matepad-pro.svg' WHERE `id`=20;
UPDATE `goods` SET `cover`='/assets/products/goods-samsung-tab-s9-ultra.svg' WHERE `id`=21;
UPDATE `goods` SET `cover`='/assets/products/goods-xiaomi-pad-6s-pro.svg' WHERE `id`=22;

-- 耳机/音箱
UPDATE `goods` SET `cover`='/assets/products/goods-sony-wh-1000xm5.svg' WHERE `id`=23;
UPDATE `goods` SET `cover`='/assets/products/goods-apple-airpods-pro-2.svg' WHERE `id`=24;
UPDATE `goods` SET `cover`='/assets/products/goods-apple-airpods-max.svg' WHERE `id`=25;
UPDATE `goods` SET `cover`='/assets/products/goods-bose-qc-ultra.svg' WHERE `id`=26;
UPDATE `goods` SET `cover`='/assets/products/goods-samsung-buds2-pro.svg' WHERE `id`=27;
UPDATE `goods` SET `cover`='/assets/products/goods-huawei-freebuds-pro-3.svg' WHERE `id`=28;
UPDATE `goods` SET `cover`='/assets/products/goods-marshall-kilburn-ii.svg' WHERE `id`=29;
UPDATE `goods` SET `cover`='/assets/products/goods-jbl-charge-5.svg' WHERE `id`=30;

-- 相机（Sony A7M4 和 A7C2 共用图）
UPDATE `goods` SET `cover`='/assets/products/goods-sony-a7m4.svg' WHERE `id` IN (31,32);
UPDATE `goods` SET `cover`='/assets/products/goods-canon-eos-r6-ii.svg' WHERE `id`=33;
UPDATE `goods` SET `cover`='/assets/products/goods-dji-osmo-pocket-3.svg' WHERE `id`=34;
UPDATE `goods` SET `cover`='/assets/products/goods-gopro-hero-12.svg' WHERE `id`=35;
UPDATE `goods` SET `cover`='/assets/products/goods-fujifilm-instax-mini-12.svg' WHERE `id`=36;

-- 智能手表
UPDATE `goods` SET `cover`='/assets/products/goods-apple-watch-s9.svg' WHERE `id`=37;
UPDATE `goods` SET `cover`='/assets/products/goods-apple-watch-ultra-2.svg' WHERE `id`=38;
UPDATE `goods` SET `cover`='/assets/products/goods-samsung-watch6-classic.svg' WHERE `id`=39;
UPDATE `goods` SET `cover`='/assets/products/goods-huawei-watch-gt-4.svg' WHERE `id`=40;
UPDATE `goods` SET `cover`='/assets/products/goods-garmin-fenix-7x-pro.svg' WHERE `id`=41;
UPDATE `goods` SET `cover`='/assets/products/goods-amazfit-trex-3.svg' WHERE `id`=42;

-- 功能手机
UPDATE `goods` SET `cover`='/assets/products/goods-nokia-3210.svg' WHERE `id`=43;
UPDATE `goods` SET `cover`='/assets/products/goods-philips-e2620.svg' WHERE `id`=44;
UPDATE `goods` SET `cover`='/assets/products/goods-ktouch-g88.svg' WHERE `id`=45;

-- 台式电脑
UPDATE `goods` SET `cover`='/assets/products/goods-apple-imac-24.svg' WHERE `id`=46;
UPDATE `goods` SET `cover`='/assets/products/goods-apple-mac-studio.svg' WHERE `id`=47;
UPDATE `goods` SET `cover`='/assets/products/goods-lenovo-legion-7000k.svg' WHERE `id`=48;
UPDATE `goods` SET `cover`='/assets/products/goods-dell-optiplex-plus.svg' WHERE `id`=49;

-- 对讲机
UPDATE `goods` SET `cover`='/assets/products/goods-xiaomi-talkie-3.svg' WHERE `id`=50;
UPDATE `goods` SET `cover`='/assets/products/goods-baofeng-uv5r.svg' WHERE `id`=51;

-- 手环（4种手环各独立图，但素材清单标记为共用2张图，这里按实际各有图片）
UPDATE `goods` SET `cover`='/assets/products/goods-xiaomi-band-9-pro.svg' WHERE `id`=52;
UPDATE `goods` SET `cover`='/assets/products/goods-xiaomi-band-9.svg' WHERE `id`=53;
UPDATE `goods` SET `cover`='/assets/products/goods-xiaomi-band-9.svg' WHERE `id`=54;
UPDATE `goods` SET `cover`='/assets/products/goods-xiaomi-band-9.svg' WHERE `id`=55;

-- 手机配件
UPDATE `goods` SET `cover`='/assets/products/goods-anker-100w-gan.svg' WHERE `id`=56;
UPDATE `goods` SET `cover`='/assets/products/goods-samsung-t7-2tb.svg' WHERE `id`=57;
UPDATE `goods` SET `cover`='/assets/products/goods-logitech-mx-master-3s.svg' WHERE `id`=58;
UPDATE `goods` SET `cover`='/assets/products/goods-belkin-7in1-hub.svg' WHERE `id`=59;
UPDATE `goods` SET `cover`='/assets/products/goods-ugreen-100w-cable.svg' WHERE `id`=60;
UPDATE `goods` SET `cover`='/assets/products/goods-spigen-iphone-case.svg' WHERE `id`=61;

-- 网络设备
UPDATE `goods` SET `cover`='/assets/products/goods-tplink-ax6000.svg' WHERE `id`=62;
UPDATE `goods` SET `cover`='/assets/products/goods-xiaomi-be7000.svg' WHERE `id`=63;
UPDATE `goods` SET `cover`='/assets/products/goods-asus-rt-ax86u.svg' WHERE `id`=64;
UPDATE `goods` SET `cover`='/assets/products/goods-h3c-mini-s8gu.svg' WHERE `id`=65;

-- 更新SKU图片同步
UPDATE `sku` s JOIN `goods` g ON s.`goods_id`=g.`id` SET s.`image`=g.`cover`;

SELECT CONCAT('已更新 ', COUNT(*), ' 件商品的封面路径') AS result FROM `goods`;
