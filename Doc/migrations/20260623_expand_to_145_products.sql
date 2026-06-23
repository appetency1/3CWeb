-- ============================================================
-- 商品扩充：从65件扩充到145+件，覆盖更全品类
-- ============================================================

-- ============================================================
-- 一、智能手机（+8 → 16件）
-- ============================================================
INSERT INTO `spu`(`name`,`brand`,`cover`,`description`,`category_id`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
('一加 12','OnePlus','/assets/products/goods-oneplus-12.svg','骁龙8Gen3，2K东方屏，哈苏影像',101,1,1,1,NOW(),NOW()),
('荣耀 Magic6 Pro','Honor','/assets/products/goods-honor-magic6.svg','骁龙8Gen3，鹰眼相机，青海湖电池',101,1,1,1,NOW(),NOW()),
('Google Pixel 9 Pro','Google','/assets/products/goods-google-pixel9.svg','Tensor G4芯片，AI相机，7年系统更新',101,1,0,1,NOW(),NOW()),
('Nothing Phone 3','Nothing','/assets/products/goods-nothing-phone3.svg','Glyph灯带，透明设计，骁龙8Gen2',101,1,0,0,NOW(),NOW()),
('索尼 Xperia 1 VI','Sony','/assets/products/goods-sony-xperia1.svg','4K OLED，微单级相机，3.5mm耳机孔',101,1,1,0,NOW(),NOW()),
('中兴 Axon 60 Ultra','ZTE','/assets/products/goods-zte-axon60.svg','屏下摄像头，卫星通信，IP68',101,1,0,1,NOW(),NOW()),
('魅族 21 Pro','Meizu','/assets/products/goods-meizu-21pro.svg','骁龙8Gen3，无界设计，超声波指纹',101,1,0,0,NOW(),NOW()),
('ROG Phone 8 Pro','ASUS','/assets/products/goods-asus-rog8.svg','骁龙8Gen3，165Hz AMOLED，肩键散热',101,1,1,1,NOW(),NOW());

SET @s = LAST_INSERT_ID();
INSERT INTO `goods`(`spu_id`,`category_id`,`name`,`brand`,`cover`,`description`,`price`,`original_price`,`stock`,`sales`,`specs`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
(@s,101,'一加 12 16+512G','OnePlus','/assets/products/goods-oneplus-12.svg','骁龙8Gen3，2K东方屏，哈苏影像',4999.00,5999.00,500,3200,'{"颜色":"留白","存储":"512G"}',1,1,1,NOW(),NOW()),
(@s+1,101,'荣耀 Magic6 Pro 512G','Honor','/assets/products/goods-honor-magic6.svg','骁龙8Gen3，鹰眼相机，青海湖电池',5699.00,6699.00,400,2800,'{"颜色":"海湖青","存储":"512G"}',1,1,1,NOW(),NOW()),
(@s+2,101,'Google Pixel 9 Pro 256G','Google','/assets/products/goods-google-pixel9.svg','Tensor G4芯片，AI相机',8999.00,9999.00,300,1500,'{"颜色":"曜石黑","存储":"256G"}',1,0,1,NOW(),NOW()),
(@s+3,101,'Nothing Phone 3 12+256G','Nothing','/assets/products/goods-nothing-phone3.svg','Glyph灯带，透明设计',3999.00,4999.00,350,1800,'{"颜色":"白色","存储":"256G"}',1,0,0,NOW(),NOW()),
(@s+4,101,'索尼 Xperia 1 VI 256G','Sony','/assets/products/goods-sony-xperia1.svg','4K OLED，微单级相机',7999.00,8999.00,200,1200,'{"颜色":"雾银","存储":"256G"}',1,1,0,NOW(),NOW()),
(@s+5,101,'中兴 Axon 60 Ultra 512G','ZTE','/assets/products/goods-zte-axon60.svg','屏下摄像头，卫星通信',6999.00,7999.00,300,900,'{"颜色":"暗影","存储":"512G"}',1,0,1,NOW(),NOW()),
(@s+6,101,'魅族 21 Pro 16+512G','Meizu','/assets/products/goods-meizu-21pro.svg','骁龙8Gen3，无界设计',4799.00,5799.00,400,1600,'{"颜色":"星夜","存储":"512G"}',1,0,0,NOW(),NOW()),
(@s+7,101,'ROG Phone 8 Pro 16+512G','ASUS','/assets/products/goods-asus-rog8.svg','骁龙8Gen3，165Hz，肩键',6999.00,7999.00,300,1100,'{"颜色":"暗黑","存储":"512G"}',1,1,1,NOW(),NOW());

-- SKU
INSERT INTO `sku`(`goods_id`,`spec`,`price`,`stock`,`sales`,`image`,`sort`,`create_time`,`update_time`)
SELECT `id`,'default',`price`,`stock`,0,`cover`,0,NOW(),NOW() FROM `goods` WHERE `id` >= (SELECT MIN(id) FROM goods WHERE spu_id >= @s) AND `spu_id` >= @s;

-- ============================================================
-- 二、笔记本电脑（+8 → 16件）
-- ============================================================
INSERT INTO `spu`(`name`,`brand`,`cover`,`description`,`category_id`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
('惠普 Spectre x360 14','HP','/assets/products/goods-hp-spectre.svg','EVO认证，OLED触控屏，翻转本',201,1,1,1,NOW(),NOW()),
('荣耀 MagicBook Pro 16','Honor','/assets/products/goods-honor-magicbook.svg','3K高刷屏，OS Turbo，轻薄性能',201,1,1,1,NOW(),NOW()),
('机械革命 耀世15 Pro','Mechrevo','/assets/products/goods-mechrevo-15pro.svg','i7-14650HX，RTX4060，2.5K240Hz',201,1,1,0,NOW(),NOW()),
('雷蛇 灵刃16','Razer','/assets/products/goods-razer-blade16.svg','i9-14900HX，RTX4090，4K MiniLED',201,1,0,1,NOW(),NOW()),
('LG Gram 17','LG','/assets/products/goods-lg-gram17.svg','17英寸仅1.35kg，80Wh大电池',201,1,0,0,NOW(),NOW()),
('华为 MateBook D16','HUAWEI','/assets/products/goods-huawei-matebook-d16.svg','16英寸护眼屏，超级终端',201,1,0,0,NOW(),NOW()),
('惠普 暗影精灵10','HP','/assets/products/goods-hp-omni10.svg','i9-14900HX，RTX4070，2.5K240Hz',201,1,1,1,NOW(),NOW()),
('ThinkBook 16+ 2024','Lenovo','/assets/products/goods-lenovo-thinkbook16.svg','Ultra 9，32G内存，3.2K高刷',201,1,0,1,NOW(),NOW());

SET @s = LAST_INSERT_ID();
INSERT INTO `goods`(`spu_id`,`category_id`,`name`,`brand`,`cover`,`description`,`price`,`original_price`,`stock`,`sales`,`specs`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
(@s,201,'惠普 Spectre x360 14 Ultra 7','HP','/assets/products/goods-hp-spectre.svg','EVO认证，2.8K OLED，16G+1TB',9999.00,11999.00,200,1200,'{"颜色":"夜蓝","存储":"1TB"}',1,1,1,NOW(),NOW()),
(@s+1,201,'荣耀 MagicBook Pro 16 Ultra 7','Honor','/assets/products/goods-honor-magicbook.svg','3K高刷，OS Turbo，32G+1TB',6999.00,7999.00,350,1800,'{"颜色":"星空灰","存储":"1TB"}',1,1,1,NOW(),NOW()),
(@s+2,201,'机械革命 耀世15 Pro i7+4060','Mechrevo','/assets/products/goods-mechrevo-15pro.svg','i7-14650HX，RTX4060，16G+1TB',6999.00,7999.00,250,1400,'{"颜色":"钛白","存储":"1TB"}',1,1,0,NOW(),NOW()),
(@s+3,201,'雷蛇 灵刃16 i9+4090','Razer','/assets/products/goods-razer-blade16.svg','i9-14900HX，RTX4090，32G+1TB',29999.00,34999.00,80,450,'{"颜色":"黑","存储":"1TB"}',1,0,1,NOW(),NOW()),
(@s+4,201,'LG Gram 17 i7','LG','/assets/products/goods-lg-gram17.svg','17英寸，1.35kg，16G+512G',8499.00,9999.00,150,780,'{"颜色":"白","存储":"512G"}',1,0,0,NOW(),NOW()),
(@s+5,201,'华为 MateBook D16 i5','HUAWEI','/assets/products/goods-huawei-matebook-d16.svg','16英寸，i5-13500H，16G+512G',4999.00,5999.00,400,2400,'{"颜色":"深空灰","存储":"512G"}',1,0,0,NOW(),NOW()),
(@s+6,201,'惠普 暗影精灵10 i9+4070','HP','/assets/products/goods-hp-omni10.svg','i9-14900HX，RTX4070，16G+1TB',9999.00,11999.00,200,890,'{"颜色":"黑","存储":"1TB"}',1,1,1,NOW(),NOW()),
(@s+7,201,'ThinkBook 16+ Ultra 9','Lenovo','/assets/products/goods-lenovo-thinkbook16.svg','Ultra 9，3.2K，32G+1TB',6999.00,7999.00,300,1300,'{"颜色":"灰","存储":"1TB"}',1,0,1,NOW(),NOW());

INSERT INTO `sku`(`goods_id`,`spec`,`price`,`stock`,`sales`,`image`,`sort`,`create_time`,`update_time`)
SELECT `id`,'default',`price`,`stock`,0,`cover`,0,NOW(),NOW() FROM `goods` WHERE `id` >= (SELECT MIN(id) FROM goods WHERE spu_id >= @s) AND `spu_id` >= @s;

-- ============================================================
-- 三、耳机/音箱（+8 → 16件）
-- ============================================================
INSERT INTO `spu`(`name`,`brand`,`cover`,`description`,`category_id`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
('森海塞尔 Momentum 4','Sennheiser','/assets/products/goods-sennheiser-momentum4.svg','旗舰降噪，60小时续航，高保真音质',301,1,1,1,NOW(),NOW()),
('拜亚动力 Free BYRD','Beyerdynamic','/assets/products/goods-beyerdynamic-freebyrd.svg','真无线降噪，HiFi音质，佩戴舒适',301,1,0,0,NOW(),NOW()),
('华为 Sound X 2024','HUAWEI','/assets/products/goods-huawei-soundx.svg','帝瓦雷联合调音，三分频，鸿蒙连接',301,1,1,1,NOW(),NOW()),
('小米 Sound Pro','Xiaomi','/assets/products/goods-xiaomi-soundpro.svg','哈曼调音，Hi-Res，立体声组网',301,1,0,0,NOW(),NOW()),
('漫步者 S2000MKIII','Edifier','/assets/products/goods-edifier-s2000.svg','Hi-Fi书架箱，5.5英寸低音，蓝牙5.3',301,1,0,1,NOW(),NOW()),
('索尼 WF-1000XM5','Sony','/assets/products/goods-sony-wf1000xm5.svg','旗舰真无线降噪，LDAC，双芯降噪',301,1,1,1,NOW(),NOW()),
('AKG N5005','AKG','/assets/products/goods-akg-n5005.svg','一圈四铁，参考级HiFi，可换线',301,1,0,0,NOW(),NOW()),
('JBL Flip 7','JBL','/assets/products/goods-jbl-flip7.svg','便携蓝牙，IP68防水，16小时续航',301,1,0,1,NOW(),NOW());

SET @s = LAST_INSERT_ID();
INSERT INTO `goods`(`spu_id`,`category_id`,`name`,`brand`,`cover`,`description`,`price`,`original_price`,`stock`,`sales`,`specs`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
(@s,301,'森海塞尔 Momentum 4 无线降噪','Sennheiser','/assets/products/goods-sennheiser-momentum4.svg','旗舰降噪，60h续航，高保真',2999.00,3499.00,300,2100,'{"颜色":"黑","类型":"头戴式"}',1,1,1,NOW(),NOW()),
(@s+1,301,'拜亚动力 Free BYRD 真无线','Beyerdynamic','/assets/products/goods-beyerdynamic-freebyrd.svg','HiFi真无线，降噪，佩戴舒适',2299.00,2799.00,200,890,'{"颜色":"黑","类型":"真无线"}',1,0,0,NOW(),NOW()),
(@s+2,301,'华为 Sound X 2024 智能音箱','HUAWEI','/assets/products/goods-huawei-soundx.svg','帝瓦雷三分频，鸿蒙连接',1999.00,2499.00,400,3200,'{"颜色":"黑","类型":"智能音箱"}',1,1,1,NOW(),NOW()),
(@s+3,301,'小米 Sound Pro 智能音箱','Xiaomi','/assets/products/goods-xiaomi-soundpro.svg','哈曼调音，Hi-Res，立体声',999.00,1299.00,500,4500,'{"颜色":"黑","类型":"智能音箱"}',1,0,0,NOW(),NOW()),
(@s+4,301,'漫步者 S2000MKIII 书架箱','Edifier','/assets/products/goods-edifier-s2000.svg','Hi-Fi书架箱，5.5英寸低音',1899.00,2299.00,200,1200,'{"颜色":"胡桃木","类型":"书架音箱"}',1,0,1,NOW(),NOW()),
(@s+5,301,'索尼 WF-1000XM5 降噪耳机','Sony','/assets/products/goods-sony-wf1000xm5.svg','旗舰真无线，LDAC，双芯降噪',2399.00,2799.00,450,3800,'{"颜色":"黑","类型":"真无线"}',1,1,1,NOW(),NOW()),
(@s+6,301,'AKG N5005 圈铁耳塞','AKG','/assets/products/goods-akg-n5005.svg','一圈四铁参考级，可换线',4999.00,5999.00,150,580,'{"颜色":"黑","类型":"有线耳塞"}',1,0,0,NOW(),NOW()),
(@s+7,301,'JBL Flip 7 便携音箱','JBL','/assets/products/goods-jbl-flip7.svg','IP68防水，16h续航，低音增强',1199.00,1499.00,400,2800,'{"颜色":"蓝","类型":"便携音箱"}',1,0,1,NOW(),NOW());

INSERT INTO `sku`(`goods_id`,`spec`,`price`,`stock`,`sales`,`image`,`sort`,`create_time`,`update_time`)
SELECT `id`,'default',`price`,`stock`,0,`cover`,0,NOW(),NOW() FROM `goods` WHERE `id` >= (SELECT MIN(id) FROM goods WHERE spu_id >= @s) AND `spu_id` >= @s;

-- ============================================================
-- 四、手机配件（+12 → 18件）
-- ============================================================
INSERT INTO `spu`(`name`,`brand`,`cover`,`description`,`category_id`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
('小米 20000mAh 移动电源 3','Xiaomi','/assets/products/goods-xiaomi-powerbank.svg','20000mAh，50W双向快充，三口输出',501,1,1,1,NOW(),NOW()),
('倍思 65W 氮化镓充电器','Baseus','/assets/products/goods-baseus-65wgan.svg','65W，2C1A，氮化镓，可折叠插脚',501,1,1,0,NOW(),NOW()),
('闪迪 Extreme Pro 256G U盘','SanDisk','/assets/products/goods-sandisk-extremepro.svg','256G，USB3.2，400MB/s，金属外壳',501,1,0,0,NOW(),NOW()),
('金士顿 Canvas Select 128G','Kingston','/assets/products/goods-kingston-sd128.svg','128G，U3，V30，4K视频专用',501,1,0,0,NOW(),NOW()),
('绿联 手机支架 MagSafe','UGREEN','/assets/products/goods-ugreen-stand.svg','MagSafe磁吸，铝合金，桌面支架',501,1,0,1,NOW(),NOW()),
('倍思 磁吸手机支架','Baseus','/assets/products/goods-baseus-stand.svg','磁吸车载，360°旋转，单手操作',501,1,0,0,NOW(),NOW()),
('罗马仕 30000mAh 充电宝','Romoss','/assets/products/goods-romoss-30000.svg','30000mAh，22.5W快充，可上飞机',501,1,1,1,NOW(),NOW()),
('小米 55W 无线充电器','Xiaomi','/assets/products/goods-xiaomi-wireless55w.svg','55W立式无线充，风冷散热，双线圈',501,1,0,1,NOW(),NOW()),
('倍思 100W 编织数据线 1.5m','Baseus','/assets/products/goods-baseus-cable.svg','100W PD，编织线身，E-Marker芯片',501,1,0,0,NOW(),NOW()),
('苹果 MagSafe 充电器','Apple','/assets/products/goods-apple-magsafe.svg','苹果原装MagSafe，15W无线充',501,1,0,0,NOW(),NOW()),
('闪迪 1TB 移动固态','SanDisk','/assets/products/goods-sandisk-ssd1t.svg','1TB，1050MB/s，IP55防水',501,1,0,1,NOW(),NOW()),
('PITAKA 凯夫拉手机壳','PITAKA','/assets/products/goods-pitaka-case.svg','600D凯夫拉，磁吸，轻薄至0.8mm',501,1,0,1,NOW(),NOW());

SET @s = LAST_INSERT_ID();
INSERT INTO `goods`(`spu_id`,`category_id`,`name`,`brand`,`cover`,`description`,`price`,`original_price`,`stock`,`sales`,`specs`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
(@s,501,'小米 20000mAh 移动电源 3','Xiaomi','/assets/products/goods-xiaomi-powerbank.svg','20000mAh，50W双向快充',199.00,249.00,2000,12000,'{"容量":"20000mAh"}',1,1,1,NOW(),NOW()),
(@s+1,501,'倍思 65W 氮化镓充电器','Baseus','/assets/products/goods-baseus-65wgan.svg','65W，2C1A，氮化镓',129.00,169.00,1500,8900,'{"功率":"65W"}',1,1,0,NOW(),NOW()),
(@s+2,501,'闪迪 Extreme Pro 256G U盘','SanDisk','/assets/products/goods-sandisk-extremepro.svg','256G，USB3.2，400MB/s',299.00,399.00,1000,4500,'{"容量":"256G"}',1,0,0,NOW(),NOW()),
(@s+3,501,'金士顿 Canvas Select 128G','Kingston','/assets/products/goods-kingston-sd128.svg','128G SD卡，U3，V30',119.00,159.00,2000,7800,'{"容量":"128G"}',1,0,0,NOW(),NOW()),
(@s+4,501,'绿联 MagSafe 手机支架','UGREEN','/assets/products/goods-ugreen-stand.svg','MagSafe磁吸，铝合金桌面支架',89.00,129.00,1000,5600,'{"类型":"桌面支架"}',1,0,1,NOW(),NOW()),
(@s+5,501,'倍思 磁吸车载手机支架','Baseus','/assets/products/goods-baseus-stand.svg','磁吸车载，360°旋转',69.00,99.00,1200,6800,'{"类型":"车载支架"}',1,0,0,NOW(),NOW()),
(@s+6,501,'罗马仕 30000mAh 充电宝','Romoss','/assets/products/goods-romoss-30000.svg','30000mAh，22.5W快充',139.00,179.00,3000,15000,'{"容量":"30000mAh"}',1,1,1,NOW(),NOW()),
(@s+7,501,'小米 55W 无线充电器','Xiaomi','/assets/products/goods-xiaomi-wireless55w.svg','55W立式无线充，风冷',249.00,299.00,800,3200,'{"功率":"55W"}',1,0,1,NOW(),NOW()),
(@s+8,501,'倍思 100W 编织数据线','Baseus','/assets/products/goods-baseus-cable.svg','100W PD，编织，1.5m',59.00,79.00,3000,18000,'{"长度":"1.5m","功率":"100W"}',1,0,0,NOW(),NOW()),
(@s+9,501,'苹果 MagSafe 充电器','Apple','/assets/products/goods-apple-magsafe.svg','原装MagSafe，15W无线充',329.00,399.00,800,5600,'{"类型":"无线充电"}',1,1,0,NOW(),NOW()),
(@s+10,501,'闪迪 1TB 移动固态 便携','SanDisk','/assets/products/goods-sandisk-ssd1t.svg','1TB，1050MB/s，IP55',899.00,1099.00,500,3400,'{"容量":"1TB"}',1,0,1,NOW(),NOW()),
(@s+11,501,'PITAKA 凯夫拉手机壳','PITAKA','/assets/products/goods-pitaka-case.svg','600D凯夫拉，磁吸，0.8mm',399.00,499.00,600,2800,'{"材质":"凯夫拉"}',1,0,1,NOW(),NOW());

INSERT INTO `sku`(`goods_id`,`spec`,`price`,`stock`,`sales`,`image`,`sort`,`create_time`,`update_time`)
SELECT `id`,'default',`price`,`stock`,0,`cover`,0,NOW(),NOW() FROM `goods` WHERE `id` >= (SELECT MIN(id) FROM goods WHERE spu_id >= @s) AND `spu_id` >= @s;

-- ============================================================
-- 五、平板电脑（+4 → 10件）
-- ============================================================
INSERT INTO `spu`(`name`,`brand`,`cover`,`description`,`category_id`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
('联想 小新 Pad Pro 12.7','Lenovo','/assets/products/goods-lenovo-xiaoxin.svg','12.7英寸2.9K，骁龙870，10200mAh',203,1,1,1,NOW(),NOW()),
('荣耀 Pad 9','Honor','/assets/products/goods-honor-pad9.svg','12.1英寸2.5K，骁龙6Gen1，8扬声器',203,1,0,0,NOW(),NOW()),
('小米 Pad 5 Pro 12.4','Xiaomi','/assets/products/goods-xiaomi-pad5.svg','12.4英寸2.5K，骁龙870，67W快充',203,1,0,1,NOW(),NOW()),
('华为 MatePad SE 11','HUAWEI','/assets/products/goods-huawei-matepad-se.svg','11英寸2K，鸿蒙系统，教育中心',203,1,0,1,NOW(),NOW());

SET @s = LAST_INSERT_ID();
INSERT INTO `goods`(`spu_id`,`category_id`,`name`,`brand`,`cover`,`description`,`price`,`original_price`,`stock`,`sales`,`specs`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
(@s,203,'联想 小新 Pad Pro 12.7 8+256G','Lenovo','/assets/products/goods-lenovo-xiaoxin.svg','12.7英寸2.9K，骁龙870，10200mAh',1599.00,1999.00,500,3400,'{"颜色":"灰","存储":"256G"}',1,1,1,NOW(),NOW()),
(@s+1,203,'荣耀 Pad 9 12+512G','Honor','/assets/products/goods-honor-pad9.svg','12.1英寸2.5K，骁龙6Gen1，8扬声器',1999.00,2499.00,400,2100,'{"颜色":"青","存储":"512G"}',1,0,0,NOW(),NOW()),
(@s+2,203,'小米 Pad 5 Pro 12.4 8+256G','Xiaomi','/assets/products/goods-xiaomi-pad5.svg','12.4英寸2.5K，骁龙870，67W快充',2499.00,2999.00,350,2800,'{"颜色":"黑","存储":"256G"}',1,0,1,NOW(),NOW()),
(@s+3,203,'华为 MatePad SE 11 6+128G','HUAWEI','/assets/products/goods-huawei-matepad-se.svg','11英寸2K，鸿蒙系统，教育中心',1299.00,1599.00,600,4500,'{"颜色":"蓝","存储":"128G"}',1,0,1,NOW(),NOW());

INSERT INTO `sku`(`goods_id`,`spec`,`price`,`stock`,`sales`,`image`,`sort`,`create_time`,`update_time`)
SELECT `id`,'default',`price`,`stock`,0,`cover`,0,NOW(),NOW() FROM `goods` WHERE `id` >= (SELECT MIN(id) FROM goods WHERE spu_id >= @s) AND `spu_id` >= @s;

-- ============================================================
-- 六、相机/摄像机（+4 → 10件）
-- ============================================================
INSERT INTO `spu`(`name`,`brand`,`cover`,`description`,`category_id`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
('尼康 Z6 III','Nikon','/assets/products/goods-nikon-z6iii.svg','全画幅微单，2450万，6K N-RAW',302,1,1,1,NOW(),NOW()),
('松下 Lumix S5 II','Panasonic','/assets/products/goods-panasonic-s5ii.svg','全画幅，2420万，相位对焦，6K30p',302,1,0,0,NOW(),NOW()),
('大疆 Mini 4 Pro 畅飞套装','DJI','/assets/products/goods-dji-mini4pro.svg','249g，4K100fps，全向避障，45min续航',302,1,1,1,NOW(),NOW()),
('大疆 Air 3 畅飞套装','DJI','/assets/products/goods-dji-air3.svg','双主摄，46min续航，全向避障',302,1,1,1,NOW(),NOW());

SET @s = LAST_INSERT_ID();
INSERT INTO `goods`(`spu_id`,`category_id`,`name`,`brand`,`cover`,`description`,`price`,`original_price`,`stock`,`sales`,`specs`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
(@s,302,'尼康 Z6 III 机身','Nikon','/assets/products/goods-nikon-z6iii.svg','全画幅微单，2450万，6K N-RAW',16999.00,19999.00,80,560,'{"类型":"机身"}',1,1,1,NOW(),NOW()),
(@s+1,302,'松下 Lumix S5 II + 20-60mm','Panasonic','/assets/products/goods-panasonic-s5ii.svg','全画幅，2420万，相位对焦，6K',12499.00,14999.00,100,680,'{"类型":"套机"}',1,0,0,NOW(),NOW()),
(@s+2,302,'大疆 Mini 4 Pro 畅飞套装','DJI','/assets/products/goods-dji-mini4pro.svg','249g，全向避障，45min续航',7388.00,8388.00,200,1500,'{"类型":"畅飞套装"}',1,1,1,NOW(),NOW()),
(@s+3,302,'大疆 Air 3 畅飞套装','DJI','/assets/products/goods-dji-air3.svg','双主摄，46min续航，全向避障',9688.00,11688.00,150,980,'{"类型":"畅飞套装"}',1,1,1,NOW(),NOW());

INSERT INTO `sku`(`goods_id`,`spec`,`price`,`stock`,`sales`,`image`,`sort`,`create_time`,`update_time`)
SELECT `id`,'default',`price`,`stock`,0,`cover`,0,NOW(),NOW() FROM `goods` WHERE `id` >= (SELECT MIN(id) FROM goods WHERE spu_id >= @s) AND `spu_id` >= @s;

-- ============================================================
-- 七、其他分类补齐
-- ============================================================
-- 台式电脑(+4), 智能穿戴(+4), 网络设备(+4), 智能手环(+4), 对讲机(+2), 功能手机(+2)
INSERT INTO `spu`(`name`,`brand`,`cover`,`description`,`category_id`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
-- 台式电脑
('惠普 暗影精灵 台式机','HP','/assets/products/goods-hp-desktop.svg','i7-14700F，RTX4060，32G DDR5',202,1,1,1,NOW(),NOW()),
('华硕 ROG 魔刃X','ASUS','/assets/products/goods-asus-rog-desktop.svg','i9-14900KF，RTX4090，64G+2T',202,1,0,1,NOW(),NOW()),
('华为 MateStation S','HUAWEI','/assets/products/goods-huawei-matests.svg','i7-13700H，16G，1TB SSD',202,1,0,0,NOW(),NOW()),
('联想 小新 Mini 2024','Lenovo','/assets/products/goods-lenovo-xiaoxin-mini.svg','Ultra 5，迷你主机，1L体积',202,1,0,0,NOW(),NOW()),
-- 网络设备
('小米 AX9000 三频WiFi6','Xiaomi','/assets/products/goods-xiaomi-ax9000.svg','三频9000Mbps，2.5G口，Mesh',502,1,1,1,NOW(),NOW()),
('华为 AX6 WiFi6','HUAWEI','/assets/products/goods-huawei-ax6.svg','AX7200，4根天线，鸿蒙Mesh',502,1,0,0,NOW(),NOW()),
('TP-Link BE65 WiFi7','TP-Link','/assets/products/goods-tplink-be65.svg','BE6500，2个2.5G口，WiFi7',502,1,1,1,NOW(),NOW()),
('水星 SG108P 交换机','MERCURY','/assets/products/goods-mercury-sg108p.svg','8口千兆PoE，65W，铁壳',502,1,0,0,NOW(),NOW()),
-- 智能手环
('小米手环 8 Pro','Xiaomi','/assets/products/goods-xiaomi-band8.svg','1.74英寸AMOLED，8通道心率',402,1,1,1,NOW(),NOW()),
('OPPO 手环 2','OPPO','/assets/products/goods-oppo-band2.svg','1.57英寸3D曲面，14天续航',402,1,0,0,NOW(),NOW()),
('华为手环 8','HUAWEI','/assets/products/goods-huawei-band8.svg','1.47英寸，14天续航，血氧',402,1,0,0,NOW(),NOW()),
('荣耀手环 9','Honor','/assets/products/goods-honor-band9.svg','1.57英寸AMOLED，14天续航',402,1,0,1,NOW(),NOW()),
-- 对讲机
('小米对讲机 2S','Xiaomi','/assets/products/goods-xiaomi-talkie2s.svg','4G全网通，5000km对讲，IP67',103,1,1,0,NOW(),NOW()),
('北峰 BF-518','Beifeng','/assets/products/goods-beifeng-bf518.svg','专业对讲，5W，16频道，超长续航',103,1,0,0,NOW(),NOW()),
-- 功能手机
('AGM M7 三防手机','AGM','/assets/products/goods-agm-m7.svg','IP68三防，4G全网通，超长待机',102,1,1,1,NOW(),NOW());

SET @s = LAST_INSERT_ID();
INSERT INTO `goods`(`spu_id`,`category_id`,`name`,`brand`,`cover`,`description`,`price`,`original_price`,`stock`,`sales`,`specs`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
-- 台式电脑
(@s,202,'惠普 暗影精灵 台式机 i7+4060','HP','/assets/products/goods-hp-desktop.svg','i7-14700F，RTX4060，32G DDR5',6999.00,8499.00,150,780,'{"配置":"i7+4060"}',1,1,1,NOW(),NOW()),
(@s+1,202,'华硕 ROG 魔刃X i9+4090','ASUS','/assets/products/goods-asus-rog-desktop.svg','i9-14900KF，RTX4090，64G+2T',29999.00,35999.00,50,230,'{"配置":"i9+4090"}',1,0,1,NOW(),NOW()),
(@s+2,202,'华为 MateStation S i7','HUAWEI','/assets/products/goods-huawei-matests.svg','i7-13700H，16G，1TB SSD',4999.00,5999.00,200,560,'{"配置":"i7+16G"}',1,0,0,NOW(),NOW()),
(@s+3,202,'联想 小新 Mini Ultra 5','Lenovo','/assets/products/goods-lenovo-xiaoxin-mini.svg','Ultra 5，迷你主机，1L体积',3999.00,4999.00,300,1200,'{"配置":"Ultra 5+16G"}',1,0,0,NOW(),NOW()),
-- 网络设备
(@s+4,502,'小米 AX9000 三频WiFi6','Xiaomi','/assets/products/goods-xiaomi-ax9000.svg','三频9000Mbps，2.5G口，Mesh',999.00,1299.00,600,3400,'{"规格":"AX9000"}',1,1,1,NOW(),NOW()),
(@s+5,502,'华为 AX6 WiFi6 路由器','HUAWEI','/assets/products/goods-huawei-ax6.svg','AX7200，4天线，鸿蒙Mesh',599.00,799.00,800,4500,'{"规格":"AX6"}',1,0,0,NOW(),NOW()),
(@s+6,502,'TP-Link BE65 WiFi7','TP-Link','/assets/products/goods-tplink-be65.svg','BE6500，2.5G口，WiFi7',599.00,799.00,500,2100,'{"规格":"BE65"}',1,1,1,NOW(),NOW()),
(@s+7,502,'水星 SG108P PoE交换机','MERCURY','/assets/products/goods-mercury-sg108p.svg','8口千兆PoE，65W，铁壳',269.00,329.00,600,2800,'{"规格":"8口PoE"}',1,0,0,NOW(),NOW()),
-- 智能手环
(@s+8,402,'小米手环 8 Pro','Xiaomi','/assets/products/goods-xiaomi-band8.svg','1.74英寸AMOLED，8通道心率',379.00,449.00,1200,7800,'{"颜色":"黑"}',1,1,1,NOW(),NOW()),
(@s+9,402,'OPPO 手环 2','OPPO','/assets/products/goods-oppo-band2.svg','1.57英寸3D曲面，14天续航',249.00,299.00,800,4500,'{"颜色":"黑"}',1,0,0,NOW(),NOW()),
(@s+10,402,'华为手环 8','HUAWEI','/assets/products/goods-huawei-band8.svg','1.47英寸，14天续航，血氧',269.00,329.00,900,5600,'{"颜色":"黑"}',1,0,0,NOW(),NOW()),
(@s+11,402,'荣耀手环 9','Honor','/assets/products/goods-honor-band9.svg','1.57英寸AMOLED，14天续航',229.00,299.00,800,3400,'{"颜色":"黑"}',1,0,1,NOW(),NOW()),
-- 对讲机
(@s+12,103,'小米对讲机 2S 4G版','Xiaomi','/assets/products/goods-xiaomi-talkie2s.svg','4G全网通，5000km对讲，IP67',499.00,599.00,600,2300,'{"类型":"4G全网通"}',1,1,0,NOW(),NOW()),
(@s+13,103,'北峰 BF-518 专业对讲','Beifeng','/assets/products/goods-beifeng-bf518.svg','5W，16频道，超长续航',299.00,399.00,800,3400,'{"功率":"5W"}',1,0,0,NOW(),NOW()),
-- 功能手机
(@s+14,102,'AGM M7 三防手机','AGM','/assets/products/goods-agm-m7.svg','IP68三防，4G全网通，超长待机',899.00,1099.00,400,1200,'{"防护":"IP68"}',1,1,1,NOW(),NOW());

INSERT INTO `sku`(`goods_id`,`spec`,`price`,`stock`,`sales`,`image`,`sort`,`create_time`,`update_time`)
SELECT `id`,'default',`price`,`stock`,0,`cover`,0,NOW(),NOW() FROM `goods` WHERE `id` >= (SELECT MIN(id) FROM goods WHERE spu_id >= @s) AND `spu_id` >= @s;

-- ============================================================
-- 统计
-- ============================================================
SELECT CONCAT('SPU: ', (SELECT COUNT(*) FROM spu)) AS stats;
SELECT CONCAT('SKU(goods): ', (SELECT COUNT(*) FROM goods)) AS stats;
SELECT CONCAT('新增商品: ', (SELECT COUNT(*) FROM goods WHERE id > 65)) AS stats;
