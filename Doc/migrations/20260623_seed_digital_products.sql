-- ============================================================
-- 数码商品示例数据（完整版 64 件）
-- ============================================================

-- 先清空并重置
DELETE FROM `sku`;
DELETE FROM `goods`;
ALTER TABLE `goods` AUTO_INCREMENT = 1;
ALTER TABLE `sku` AUTO_INCREMENT = 1;

-- ============================================================
-- 一、智能手机（category_id=101）8件
-- ============================================================
INSERT INTO `goods`(`category_id`,`name`,`brand`,`cover`,`images`,`description`,`price`,`original_price`,`stock`,`sales`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
(101,'iPhone 15 Pro Max 1TB','Apple','/assets/products/goods-1.svg','[]','A17 Pro芯片，钛合金，5倍光学变焦',12999.00,14999.00,200,1800,1,1,1,NOW(),NOW()),
(101,'iPhone 15 Pro 256G','Apple','/assets/products/goods-2.svg','[]','A17 Pro芯片，钛金属设计，4800万像素',8999.00,9999.00,500,3200,1,1,1,NOW(),NOW()),
(101,'HUAWEI Mate 60 Pro','HUAWEI','/assets/products/goods-3.svg','[]','卫星通话，昆仑玻璃，麒麟9000S',6999.00,7999.00,500,2800,1,1,1,NOW(),NOW()),
(101,'小米14 Ultra','Xiaomi','/assets/products/goods-4.svg','[]','骁龙8Gen3，徕卡光学，一英寸大底',5999.00,6999.00,500,2100,1,1,0,NOW(),NOW()),
(101,'Samsung Galaxy S24 Ultra','Samsung','/assets/products/goods-5.svg','[]','Galaxy AI，钛金属框架，S Pen手写笔',10999.00,12999.00,300,1500,1,1,1,NOW(),NOW()),
(101,'OPPO Find X7 Ultra','OPPO','/assets/products/goods-6.svg','[]','双潜望四摄，潮汐架构',5999.00,6999.00,350,1300,1,1,0,NOW(),NOW()),
(101,'vivo X100 Pro','vivo','/assets/products/goods-7.svg','[]','蔡司APO超级长焦，天玑9300',4999.00,5999.00,400,1600,1,0,0,NOW(),NOW()),
(101,'iPhone SE 第三代','Apple','/assets/products/goods-8.svg','[]','A15芯片，4.7英寸，Touch ID',3499.00,4299.00,600,1800,1,0,0,NOW(),NOW());

-- ============================================================
-- 二、笔记本电脑（category_id=201）8件
-- ============================================================
INSERT INTO `goods`(`category_id`,`name`,`brand`,`cover`,`images`,`description`,`price`,`original_price`,`stock`,`sales`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
(201,'MacBook Air M3 13英寸','Apple','/assets/products/goods-9.svg','[]','M3芯片，13.6英寸，18小时续航',9499.00,10999.00,300,2100,1,1,1,NOW(),NOW()),
(201,'MacBook Pro M3 Max 16英寸','Apple','/assets/products/goods-10.svg','[]','M3 Max芯片，16英寸，22小时续航',27999.00,31999.00,100,680,1,1,1,NOW(),NOW()),
(201,'ThinkPad X1 Carbon Gen12','Lenovo','/assets/products/goods-11.svg','[]','Ultra 7处理器，14英寸2.8K OLED',10999.00,12999.00,200,980,1,1,0,NOW(),NOW()),
(201,'HUAWEI MateBook X Pro 2024','HUAWEI','/assets/products/goods-12.svg','[]','3.1K原色屏，超级终端，酷睿Ultra',9999.00,11999.00,250,1200,1,1,1,NOW(),NOW()),
(201,'ASUS ROG 幻16 2024','ASUS','/assets/products/goods-13.svg','[]','i9-14900H，RTX4070，2.5K 240Hz',12999.00,14999.00,150,680,1,1,1,NOW(),NOW()),
(201,'Dell XPS 16','Dell','/assets/products/goods-14.svg','[]','Intel Core Ultra，4K OLED触控屏',11499.00,13999.00,180,560,1,0,0,NOW(),NOW()),
(201,'Surface Laptop 6','Microsoft','/assets/products/goods-15.svg','[]','骁龙X Elite，13.8英寸PixelSense',10688.00,12688.00,200,450,1,0,0,NOW(),NOW()),
(201,'RedmiBook Pro 16 2024','Xiaomi','/assets/products/goods-16.svg','[]','Ultra 5，3.2K高刷屏，高性能',5999.00,6999.00,350,1400,1,0,1,NOW(),NOW());

-- ============================================================
-- 三、平板电脑（category_id=203）6件
-- ============================================================
INSERT INTO `goods`(`category_id`,`name`,`brand`,`cover`,`images`,`description`,`price`,`original_price`,`stock`,`sales`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
(203,'iPad Pro M4 13英寸','Apple','/assets/products/goods-17.svg','[]','M4芯片，超XDR显示屏，超薄',8799.00,10499.00,300,1200,1,1,1,NOW(),NOW()),
(203,'iPad Pro M4 11英寸','Apple','/assets/products/goods-18.svg','[]','M4芯片，超XDR，支持Apple Pencil Pro',6499.00,7999.00,400,1800,1,1,1,NOW(),NOW()),
(203,'iPad Air M2','Apple','/assets/products/goods-19.svg','[]','M2芯片，11英寸 Liquid视网膜屏',4799.00,5999.00,500,1500,1,1,0,NOW(),NOW()),
(203,'HUAWEI MatePad Pro 13.2','HUAWEI','/assets/products/goods-20.svg','[]','13.2英寸OLED，星闪连接，天生会画',4299.00,5299.00,300,890,1,0,0,NOW(),NOW()),
(203,'Samsung Tab S9 Ultra','Samsung','/assets/products/goods-21.svg','[]','14.6英寸Dynamic AMOLED，IP68',7999.00,9599.00,200,650,1,0,0,NOW(),NOW()),
(203,'小米平板 6S Pro','Xiaomi','/assets/products/goods-22.svg','[]','12.4英寸3K，骁龙8Gen2，67W快充',3299.00,3999.00,400,1600,1,0,1,NOW(),NOW());

-- ============================================================
-- 四、耳机/音箱（category_id=301）8件
-- ============================================================
INSERT INTO `goods`(`category_id`,`name`,`brand`,`cover`,`images`,`description`,`price`,`original_price`,`stock`,`sales`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
(301,'Sony WH-1000XM5','Sony','/assets/products/goods-23.svg','[]','旗舰降噪，30小时续航，轻量化设计',2499.00,2999.00,400,3500,1,1,1,NOW(),NOW()),
(301,'AirPods Pro 2 USB-C','Apple','/assets/products/goods-24.svg','[]','H2芯片，自适应降噪，个性化空间音频',1899.00,1999.00,600,5800,1,1,1,NOW(),NOW()),
(301,'AirPods Max','Apple','/assets/products/goods-25.svg','[]','H1芯片，主动降噪，头戴式旗舰',3999.00,4399.00,200,1200,1,1,0,NOW(),NOW()),
(301,'Bose QC Ultra 头戴式','Bose','/assets/products/goods-26.svg','[]','沉浸空间音频，CustomTune降噪技术',2999.00,3499.00,300,1600,1,1,1,NOW(),NOW()),
(301,'Samsung Galaxy Buds2 Pro','Samsung','/assets/products/goods-27.svg','[]','HiFi音质，智能降噪，IPX7防水',1599.00,1999.00,400,2100,1,0,0,NOW(),NOW()),
(301,'HUAWEI FreeBuds Pro 3','HUAWEI','/assets/products/goods-28.svg','[]','超感知降噪，星闪连接，三重自适应',1299.00,1499.00,450,1800,1,0,0,NOW(),NOW()),
(301,'Marshall Kilburn II','Marshall','/assets/products/goods-29.svg','[]','便携蓝牙音箱，30W功率，20小时续航',2299.00,2799.00,250,1200,1,0,0,NOW(),NOW()),
(301,'JBL Charge 5','JBL','/assets/products/goods-30.svg','[]','IP67防水，20小时续航，内置充电宝',1499.00,1799.00,350,2400,1,0,1,NOW(),NOW());

-- ============================================================
-- 五、相机/摄像机（category_id=302）6件
-- ============================================================
INSERT INTO `goods`(`category_id`,`name`,`brand`,`cover`,`images`,`description`,`price`,`original_price`,`stock`,`sales`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
(302,'Sony A7M4 全画幅微单','Sony','/assets/products/goods-31.svg','[]','3300万像素，4K60p，实时追踪自动对焦',15999.00,18999.00,100,560,1,1,1,NOW(),NOW()),
(302,'Sony A7C2 全画幅微单','Sony','/assets/products/goods-32.svg','[]','小巧全画幅，3300万，AI对焦',12499.00,14999.00,120,380,1,1,0,NOW(),NOW()),
(302,'佳能 EOS R6 Mark II','Canon','/assets/products/goods-33.svg','[]','2420万，4K60p，机身防抖',15999.00,17999.00,80,340,1,0,0,NOW(),NOW()),
(302,'DJI Osmo Pocket 3','DJI','/assets/products/goods-34.svg','[]','1英寸CMOS，4K120fps，三轴云台',3499.00,3999.00,300,2100,1,1,1,NOW(),NOW()),
(302,'GoPro HERO 12 Black','GoPro','/assets/products/goods-35.svg','[]','5.3K视频，HyperSmooth 6.0，防水10米',3198.00,3998.00,200,1300,1,0,0,NOW(),NOW()),
(302,'Fujifilm Instax Mini 12','Fujifilm','/assets/products/goods-36.svg','[]','拍立得相机，自动曝光，自拍模式',699.00,899.00,600,3200,1,0,1,NOW(),NOW());

-- ============================================================
-- 六、智能手表（category_id=401）6件
-- ============================================================
INSERT INTO `goods`(`category_id`,`name`,`brand`,`cover`,`images`,`description`,`price`,`original_price`,`stock`,`sales`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
(401,'Apple Watch Series 9 45mm','Apple','/assets/products/goods-37.svg','[]','S9芯片，全天候视网膜屏，血氧检测',2999.00,3499.00,500,2800,1,1,1,NOW(),NOW()),
(401,'Apple Watch Ultra 2','Apple','/assets/products/goods-38.svg','[]','49mm钛金属，精确双频GPS，100m防水',5999.00,6999.00,200,890,1,1,1,NOW(),NOW()),
(401,'Galaxy Watch6 Classic 47mm','Samsung','/assets/products/goods-39.svg','[]','旋转表圈，体成分分析，睡眠监测',2799.00,3299.00,300,1200,1,1,0,NOW(),NOW()),
(401,'HUAWEI Watch GT 4','HUAWEI','/assets/products/goods-40.svg','[]','46mm，14天续航，脉搏波心率',1599.00,1999.00,450,1800,1,0,0,NOW(),NOW()),
(401,'Garmin Fenix 7X Pro','Garmin','/assets/products/goods-41.svg','[]','钛合金，37天续航，多频多星定位',5480.00,6980.00,150,560,1,0,0,NOW(),NOW()),
(401,'Amazfit T-Rex 3','Amazfit','/assets/products/goods-42.svg','[]','军规标准，45天超长续航，-30°C耐寒',1799.00,2299.00,300,950,1,0,1,NOW(),NOW());

-- ============================================================
-- 七、功能手机（category_id=102）3件
-- ============================================================
INSERT INTO `goods`(`category_id`,`name`,`brand`,`cover`,`images`,`description`,`price`,`original_price`,`stock`,`sales`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
(102,'诺基亚 3210 复刻版','Nokia','/assets/products/goods-43.svg','[]','经典复刻，超长待机，贪吃蛇',399.00,499.00,800,3000,1,0,1,NOW(),NOW()),
(102,'飞利浦 E2620 老人机','Philips','/assets/products/goods-44.svg','[]','大按键大音量，SOS一键求救',199.00,299.00,1000,2500,1,0,0,NOW(),NOW()),
(102,'天语 G88 4G 老人手机','K-Touch','/assets/products/goods-45.svg','[]','4G全网通，Type-C充电，大字体',159.00,259.00,1200,1800,1,0,0,NOW(),NOW());

-- ============================================================
-- 八、台式电脑（category_id=202）4件
-- ============================================================
INSERT INTO `goods`(`category_id`,`name`,`brand`,`cover`,`images`,`description`,`price`,`original_price`,`stock`,`sales`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
(202,'iMac 24英寸 M3','Apple','/assets/products/goods-46.svg','[]','M3芯片，4.5K视网膜屏，7种颜色',10999.00,12999.00,200,780,1,1,1,NOW(),NOW()),
(202,'Mac Studio M2 Ultra','Apple','/assets/products/goods-47.svg','[]','M2 Ultra 24核CPU，76核GPU',32999.00,37999.00,50,230,1,1,0,NOW(),NOW()),
(202,'联想 拯救者 刃7000K','Lenovo','/assets/products/goods-48.svg','[]','i7-14700KF，RTX4070，32G DDR5',8999.00,10999.00,150,560,1,0,0,NOW(),NOW()),
(202,'戴尔 OptiPlex Tower Plus','Dell','/assets/products/goods-49.svg','[]','商用台式机，i7，16G，512G',5999.00,6999.00,200,320,1,0,0,NOW(),NOW());

-- ============================================================
-- 九、对讲机（category_id=103）2件
-- ============================================================
INSERT INTO `goods`(`category_id`,`name`,`brand`,`cover`,`images`,`description`,`price`,`original_price`,`stock`,`sales`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
(103,'小米对讲机 3','Xiaomi','/assets/products/goods-50.svg','[]','蓝牙/WiFi写频，FM收音，5W功率',399.00,499.00,500,1200,1,0,0,NOW(),NOW()),
(103,'宝锋 UV-5R 对讲机','Baofeng','/assets/products/goods-51.svg','[]','双频双待，大功率，高性价比',139.00,199.00,800,3400,1,0,0,NOW(),NOW());

-- ============================================================
-- 十、智能手环（category_id=402）4件
-- ============================================================
INSERT INTO `goods`(`category_id`,`name`,`brand`,`cover`,`images`,`description`,`price`,`original_price`,`stock`,`sales`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
(402,'小米手环 9 Pro','Xiaomi','/assets/products/goods-52.svg','[]','1.74英寸AMOLED，21天续航',399.00,499.00,1000,8900,1,1,1,NOW(),NOW()),
(402,'小米手环 9','Xiaomi','/assets/products/goods-53.svg','[]','1.62英寸，16天续航，150+运动模式',249.00,329.00,1500,12000,1,1,0,NOW(),NOW()),
(402,'HUAWEI Band 9','HUAWEI','/assets/products/goods-54.svg','[]','1.47英寸，14天续航，血氧监测',289.00,369.00,800,4500,1,0,0,NOW(),NOW()),
(402,'Fitbit Charge 6','Fitbit','/assets/products/goods-55.svg','[]','7天续航，心率追踪，Google服务',1199.00,1399.00,300,890,1,0,0,NOW(),NOW());

-- ============================================================
-- 十一、手机配件（category_id=501）6件
-- ============================================================
INSERT INTO `goods`(`category_id`,`name`,`brand`,`cover`,`images`,`description`,`price`,`original_price`,`stock`,`sales`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
(501,'Anker 100W 氮化镓充电器','Anker','/assets/products/goods-56.svg','[]','三口快充，氮化镓GaN，折叠插脚',199.00,279.00,2000,8900,1,1,1,NOW(),NOW()),
(501,'三星 T7 移动固态硬盘 2TB','Samsung','/assets/products/goods-57.svg','[]','1050MB/s，IP65防水，AES加密',1399.00,1799.00,500,3200,1,1,0,NOW(),NOW()),
(501,'罗技 MX Master 3S 鼠标','Logitech','/assets/products/goods-58.svg','[]','8000DPI，静音按键，MagSpeed滚轮',699.00,899.00,600,4500,1,1,1,NOW(),NOW()),
(501,'Belkin 7合1 拓展坞','Belkin','/assets/products/goods-59.svg','[]','USB-C，4K HDMI，SD/TF卡，PD快充',399.00,499.00,400,2100,1,0,0,NOW(),NOW()),
(501,'绿联 100W 快充数据线 2米','UGREEN','/assets/products/goods-60.svg','[]','100W PD快充，编织线身，E-Marker',79.00,99.00,3000,15000,1,0,0,NOW(),NOW()),
(501,'Spigen iPhone 15 磁吸保护壳','Spigen','/assets/products/goods-61.svg','[]','MagSafe兼容，军事级防摔，液态硅胶',129.00,199.00,1500,6800,1,0,1,NOW(),NOW());

-- ============================================================
-- 十二、网络设备（category_id=502）4件
-- ============================================================
INSERT INTO `goods`(`category_id`,`name`,`brand`,`cover`,`images`,`description`,`price`,`original_price`,`stock`,`sales`,`status`,`is_hot`,`is_new`,`create_time`,`update_time`) VALUES
(502,'TP-Link AX6000 双频WiFi6','TP-Link','/assets/products/goods-62.svg','[]','6000Mbps，8根天线，OFDMA',399.00,499.00,800,5600,1,1,1,NOW(),NOW()),
(502,'小米 BE7000 Wi-Fi 7 路由器','Xiaomi','/assets/products/goods-63.svg','[]','四核高通，4个2.5G口，Mesh组网',699.00,899.00,500,2300,1,1,0,NOW(),NOW()),
(502,'华硕 RT-AX86U 游戏路由器','ASUS','/assets/products/goods-64.svg','[]','AX5700，AiMesh，2.5G口，网游加速',1599.00,1999.00,200,890,1,0,0,NOW(),NOW()),
(502,'H3C 千兆交换机 Mini S8G-U','H3C','/assets/products/goods-65.svg','[]','8口千兆，即插即用，铁壳散热',199.00,259.00,600,3400,1,0,0,NOW(),NOW());

-- ============================================================
-- SKU：为所有商品插入默认 SKU
-- ============================================================
INSERT INTO `sku`(`goods_id`,`spec`,`price`,`stock`,`sales`,`image`,`sort`,`create_time`,`update_time`)
SELECT `id`,'default',`price`,`stock`,0,`cover`,0,NOW(),NOW() FROM `goods`;

SELECT CONCAT('数据插入完成：共 ', COUNT(*), ' 件数码商品') AS result FROM `goods`;
