-- ============================================================
--  衣服商城 数据库表结构设计
--  数据库: clothes_demo
--  字符集: utf8mb4
--  排序规则: utf8mb4_general_ci
--  MySQL 版本: 8.0+
-- ============================================================

DROP DATABASE IF EXISTS clothes_demo;
CREATE DATABASE clothes_demo DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;
USE clothes_demo;

-- ============================================================
-- 1. 管理员表 (admin)
-- ============================================================
DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `username`    VARCHAR(50)  NOT NULL                COMMENT '登录账号',
    `password`    VARCHAR(100) NOT NULL                COMMENT '密码(MD5加密)',
    `nickname`    VARCHAR(50)                          COMMENT '昵称',
    `avatar`      VARCHAR(255)                         COMMENT '头像URL',
    `email`       VARCHAR(100)                         COMMENT '邮箱',
    `status`      TINYINT      NOT NULL DEFAULT 1      COMMENT '状态: 0禁用 1正常',
    `last_login`  DATETIME                              COMMENT '最后登录时间',
    `create_time` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='管理员表';

-- ============================================================
-- 2. 用户表 (user)
-- ============================================================
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `username`    VARCHAR(50)  NOT NULL                COMMENT '登录账号',
    `password`    VARCHAR(100) NOT NULL                COMMENT '密码(MD5加密)',
    `nickname`    VARCHAR(50)                          COMMENT '昵称',
    `avatar`      VARCHAR(255)                         COMMENT '头像URL',
    `phone`       VARCHAR(20)                          COMMENT '手机号',
    `email`       VARCHAR(100)                         COMMENT '邮箱',
    `gender`      TINYINT      NOT NULL DEFAULT 0      COMMENT '性别: 0未知 1男 2女',
    `birthday`    DATE                                 COMMENT '生日',
    `status`      TINYINT      NOT NULL DEFAULT 1      COMMENT '状态: 0禁用 1正常',
    `create_time` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`),
    KEY `idx_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ============================================================
-- 3. 分类表 (category) - 支持两级分类
-- ============================================================
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `parent_id`   BIGINT       NOT NULL DEFAULT 0      COMMENT '父分类ID, 0表示一级',
    `name`        VARCHAR(50)  NOT NULL                COMMENT '分类名称',
    `icon`        VARCHAR(255)                         COMMENT '分类图标',
    `sort`        INT          NOT NULL DEFAULT 0      COMMENT '排序, 升序',
    `status`      TINYINT      NOT NULL DEFAULT 1      COMMENT '状态: 0隐藏 1显示',
    `create_time` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `update_time` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品分类表';

-- ============================================================
-- 4. 商品SPU表 (goods) - Standard Product Unit
-- ============================================================
DROP TABLE IF EXISTS `goods`;
CREATE TABLE `goods` (
    `id`            BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
    `category_id`   BIGINT        NOT NULL                COMMENT '分类ID',
    `name`          VARCHAR(200)  NOT NULL                COMMENT '商品名称',
    `brand`         VARCHAR(50)                           COMMENT '品牌',
    `cover`         VARCHAR(255)  NOT NULL                COMMENT '封面图',
    `images`        TEXT                                   COMMENT '商品图册, JSON数组',
    `description`   TEXT                                   COMMENT '商品描述',
    `detail`        LONGTEXT                               COMMENT '商品详情(Html)',
    `price`         DECIMAL(10,2) NOT NULL                COMMENT '销售价(展示价)',
    `original_price` DECIMAL(10,2)                         COMMENT '原价/划线价',
    `stock`         INT           NOT NULL DEFAULT 0      COMMENT '总库存(SKU汇总)',
    `sales`         INT           NOT NULL DEFAULT 0      COMMENT '销量',
    `view_count`    INT           NOT NULL DEFAULT 0      COMMENT '浏览量',
    `status`        TINYINT       NOT NULL DEFAULT 1      COMMENT '状态: 0下架 1上架',
    `is_hot`        TINYINT       NOT NULL DEFAULT 0      COMMENT '是否热门',
    `is_new`        TINYINT       NOT NULL DEFAULT 0      COMMENT '是否新品',
    `create_time`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `update_time`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_category_id` (`category_id`),
    KEY `idx_status` (`status`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品SPU表';

-- ============================================================
-- 5. 商品SKU表 (sku) - Stock Keeping Unit
-- 同一SPU下不同规格(颜色/尺码)的库存
-- ============================================================
DROP TABLE IF EXISTS `sku`;
CREATE TABLE `sku` (
    `id`          BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
    `goods_id`    BIGINT        NOT NULL                COMMENT '所属商品ID',
    `spec`        VARCHAR(255)  NOT NULL                COMMENT '规格JSON, e.g. {"颜色":"红色","尺码":"XL"}',
    `price`       DECIMAL(10,2) NOT NULL                COMMENT 'SKU价格',
    `stock`       INT           NOT NULL DEFAULT 0      COMMENT 'SKU库存',
    `sales`       INT           NOT NULL DEFAULT 0      COMMENT 'SKU销量',
    `image`       VARCHAR(255)                           COMMENT 'SKU图片',
    `sort`        INT           NOT NULL DEFAULT 0      COMMENT '排序',
    `create_time` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `update_time` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_goods_id` (`goods_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品SKU表';

-- ============================================================
-- 6. 收货地址表 (address)
-- ============================================================
DROP TABLE IF EXISTS `address`;
CREATE TABLE `address` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `user_id`     BIGINT       NOT NULL                COMMENT '用户ID',
    `receiver`    VARCHAR(50)  NOT NULL                COMMENT '收货人',
    `phone`       VARCHAR(20)  NOT NULL                COMMENT '收货电话',
    `province`    VARCHAR(50)  NOT NULL                COMMENT '省',
    `city`        VARCHAR(50)  NOT NULL                COMMENT '市',
    `district`    VARCHAR(50)  NOT NULL                COMMENT '区/县',
    `detail`      VARCHAR(255) NOT NULL                COMMENT '详细地址',
    `is_default`  TINYINT      NOT NULL DEFAULT 0      COMMENT '是否默认: 0否 1是',
    `create_time` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `update_time` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收货地址表';

-- ============================================================
-- 7. 购物车表 (cart)
-- ============================================================
DROP TABLE IF EXISTS `cart`;
CREATE TABLE `cart` (
    `id`          BIGINT   NOT NULL AUTO_INCREMENT COMMENT '主键',
    `user_id`     BIGINT   NOT NULL                COMMENT '用户ID',
    `goods_id`    BIGINT   NOT NULL                COMMENT '商品ID',
    `sku_id`      BIGINT   NOT NULL                COMMENT 'SKU ID',
    `quantity`    INT      NOT NULL DEFAULT 1      COMMENT '数量',
    `selected`    TINYINT  NOT NULL DEFAULT 1      COMMENT '是否选中: 0否 1是',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_sku` (`user_id`, `sku_id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='购物车表';

-- ============================================================
-- 8. 订单表 (orders) - MySQL关键字orders
-- ============================================================
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
    `id`              BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
    `order_no`        VARCHAR(50)   NOT NULL                COMMENT '订单号',
    `user_id`         BIGINT        NOT NULL                COMMENT '用户ID',
    `total_amount`    DECIMAL(10,2) NOT NULL                COMMENT '订单总金额',
    `pay_amount`      DECIMAL(10,2) NOT NULL                COMMENT '实付金额',
    `freight_amount`  DECIMAL(10,2) NOT NULL DEFAULT 0.00   COMMENT '运费',
    `discount_amount` DECIMAL(10,2) NOT NULL DEFAULT 0.00   COMMENT '优惠金额',
    `receiver`        VARCHAR(50)   NOT NULL                COMMENT '收货人',
    `phone`           VARCHAR(20)   NOT NULL                COMMENT '收货电话',
    `address`         VARCHAR(500)  NOT NULL                COMMENT '完整收货地址',
    `remark`          VARCHAR(500)                           COMMENT '订单备注',
    `status`          TINYINT       NOT NULL DEFAULT 0      COMMENT '订单状态: 0待付款 1待发货 2待收货 3已完成 4已取消',
    `pay_time`        DATETIME                               COMMENT '支付时间',
    `ship_time`       DATETIME                               COMMENT '发货时间',
    `finish_time`     DATETIME                               COMMENT '完成时间',
    `cancel_time`     DATETIME                               COMMENT '取消时间',
    `create_time`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `update_time`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_order_no` (`order_no`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_status` (`status`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';

-- ============================================================
-- 9. 订单详情表 (order_item)
-- ============================================================
DROP TABLE IF EXISTS `order_item`;
CREATE TABLE `order_item` (
    `id`           BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
    `order_id`     BIGINT        NOT NULL                COMMENT '订单ID',
    `goods_id`     BIGINT        NOT NULL                COMMENT '商品ID',
    `sku_id`       BIGINT        NOT NULL                COMMENT 'SKU ID',
    `goods_name`   VARCHAR(200)  NOT NULL                COMMENT '商品名称(快照)',
    `goods_cover`  VARCHAR(255)  NOT NULL                COMMENT '商品封面(快照)',
    `spec`         VARCHAR(255)                           COMMENT '规格(快照)',
    `price`        DECIMAL(10,2) NOT NULL                COMMENT '单价(快照)',
    `quantity`     INT           NOT NULL                COMMENT '购买数量',
    `subtotal`     DECIMAL(10,2) NOT NULL                COMMENT '小计金额',
    PRIMARY KEY (`id`),
    KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单详情表';

-- ============================================================
-- 10. 轮播图表 (banner)
-- ============================================================
DROP TABLE IF EXISTS `banner`;
CREATE TABLE `banner` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `title`       VARCHAR(100) NOT NULL                COMMENT '标题',
    `image`       VARCHAR(255) NOT NULL                COMMENT '图片',
    `link`        VARCHAR(255)                         COMMENT '跳转链接',
    `sort`        INT          NOT NULL DEFAULT 0      COMMENT '排序',
    `status`      TINYINT      NOT NULL DEFAULT 1      COMMENT '状态: 0隐藏 1显示',
    `create_time` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `update_time` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='轮播图表';

-- ============================================================
-- 11. 收藏表 (favorite)
-- ============================================================
DROP TABLE IF EXISTS `favorite`;
CREATE TABLE `favorite` (
    `id`          BIGINT   NOT NULL AUTO_INCREMENT COMMENT '主键',
    `user_id`     BIGINT   NOT NULL                COMMENT '用户ID',
    `goods_id`    BIGINT   NOT NULL                COMMENT '商品ID',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_goods` (`user_id`, `goods_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品收藏表';

-- ============================================================
-- 12. 评价表 (comment)
-- ============================================================
DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `user_id`     BIGINT       NOT NULL                COMMENT '用户ID',
    `goods_id`    BIGINT       NOT NULL                COMMENT '商品ID',
    `order_id`    BIGINT       NOT NULL                COMMENT '订单ID',
    `content`     VARCHAR(500) NOT NULL                COMMENT '评价内容',
    `rating`      TINYINT      NOT NULL DEFAULT 5      COMMENT '评分 1-5',
    `images`      TEXT                                   COMMENT '评价图片, JSON数组',
    `create_time` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_goods_id` (`goods_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品评价表';

-- ============================================================
-- 初始数据 - 管理员账号
-- 密码: 123456  (MD5: e10adc3949ba59abbe56e057f20f883e)
-- 部署后首次登录请立即修改密码，系统会自动升级为 BCrypt
-- ============================================================
INSERT INTO `admin` (`username`, `password`, `nickname`, `status`) VALUES
('admin', 'e10adc3949ba59abbe56e057f20f883e', 'Admin', 1);

-- ============================================================
-- 初始数据 - 分类
-- ============================================================
INSERT INTO `category` (`id`, `parent_id`, `name`, `icon`, `sort`) VALUES
(1, 0, '男装',    '/assets/icons/cat-tops.svg',       1),
(2, 0, '女装',    '/assets/icons/cat-dresses.svg',     2),
(3, 0, '鞋靴',    '/assets/icons/cat-shoes.svg',       3),
(4, 0, '配饰',    '/assets/icons/cat-accessories.svg', 4),
(101, 1, '上衣',  '/assets/icons/cat-tops.svg',       1),
(102, 1, '裤装',  '/assets/icons/cat-bottoms.svg',     2),
(103, 1, '外套',  '/assets/icons/cat-sports.svg',      3),
(201, 2, '裙装',  '/assets/icons/cat-dresses.svg',     1),
(202, 2, '上衣',  '/assets/icons/cat-tops.svg',       2),
(203, 2, '裤装',  '/assets/icons/cat-bottoms.svg',     3),
(301, 3, '男鞋',  '/assets/icons/cat-shoes.svg',       1),
(302, 3, '女鞋',  '/assets/icons/cat-shoes.svg',       2),
(401, 4, '帽子',  '/assets/icons/cat-accessories.svg', 1),
(402, 4, '包包',  '/assets/icons/cat-bags.svg',         2),
(501, 0, '内衣',  '/assets/icons/cat-underwear.svg',    5),
(502, 0, '家居',  '/assets/icons/cat-homewear.svg',     6);

-- ============================================================
-- 初始数据 - 轮播图 (SVG 占位图)
-- ============================================================
INSERT INTO `banner` (`title`, `image`, `link`, `sort`, `status`) VALUES
('夏季新品 清爽上市', '/assets/banners/banner-1.svg', '/category', 1, 1),
('精品女装 时尚专区', '/assets/banners/banner-2.svg', '/category', 2, 1),
('优雅连衣裙 海滨风情', '/assets/banners/banner-3.svg', '/category', 3, 1),
('时尚穿搭 都市优雅', '/assets/banners/banner-4.svg', '/category', 4, 1),
('潮流男装 街头风格', '/assets/banners/banner-5.svg', '/user',     5, 1);

-- ============================================================
-- 初始数据 - 商品 SPU (共 64 个, cover 图待替换为真实图片)
-- 命名规范: /assets/products/goods-{ID}-{商品名拼音}.jpg
-- ============================================================
INSERT INTO `goods` (`id`, `category_id`, `name`, `brand`, `cover`, `images`, `description`, `price`, `original_price`, `stock`, `sales`, `status`, `is_hot`, `is_new`) VALUES
-- 男装·上衣 (101) - ID: 1~8
(1,  101, '莫兰迪色系纯棉T恤',    'H&M',        '/assets/products/goods-1-molan-di-mian-t.jpg', '[]', '柔软透气面料，经典圆领设计', 89.00,  159.00, 500, 1200, 1, 1, 0),
(2,  101, '条纹休闲Polo衫',        'GXG',        '/assets/products/goods-2-tiao-wen-polo.jpg',    '[]', '商务休闲两不误', 129.00, 229.00, 300, 680,  1, 1, 1),
(3,  101, '纯棉白色圆领T恤',       '优衣库',     '/assets/products/goods-3-chun-mian-bai-t.jpg',  '[]', '百搭基础款，100%纯棉', 79.00, 129.00, 600, 1500, 1, 0, 0),
(4,  101, '黑色酷炫宽松T恤',       '太平鸟',     '/assets/products/goods-4-hei-se-ku-tong-chang.jpg', '[]', 'OVERSIZE版型，街头风格', 99.00, 199.00, 400, 900,  1, 1, 1),
(5,  101, '奶茶色系Polo衫',        '森马',       '/assets/products/goods-5-nai-nai-yan-polo.jpg',  '[]', '低饱和奶茶色，简约大气', 119.00, 199.00, 350, 560,  1, 0, 1),
(6,  101, '休闲棉质衬衫',          '七匹狼',     '/assets/products/goods-6-cotton-shirting.jpg',   '[]', '透气棉质面料，休闲百搭', 139.00, 259.00, 280, 420,  1, 0, 0),
(7,  101, '亨利领短袖T恤',        '杰克琼斯',   '/assets/products/goods-7-hen-nai-ka-huang-t.jpg', '[]', '复古亨利领设计', 109.00, 189.00, 320, 680,  1, 1, 0),
(8,  101, '长袖简约针织衫',        '恒源祥',     '/assets/products/goods-8-chang-xu-zong-jie.jpg', '[]', '春秋必备基础针织', 159.00, 279.00, 250, 390,  1, 0, 0),
-- 男装·裤装 (102) - ID: 9~15
(9,  102, '修身直筒牛仔裤',        '杰克琼斯',   '/assets/products/goods-9-xiu-shen-zhi-tong-niu-zai.jpg', '[]', '水洗工艺处理', 199.00, 399.00, 400, 920,  1, 0, 0),
(10, 102, '黑色水洗休闲裤',        'GXG',        '/assets/products/goods-10-hei-se-shui-fan-ku.jpg',     '[]', '水洗黑面料，休闲风格', 179.00, 299.00, 350, 580,  1, 0, 1),
(11, 102, '深蓝修身西裤',          '七匹狼',     '/assets/products/goods-11-shan-lan-xiu-tong-ku.jpg',   '[]', '商务场合首选', 229.00, 399.00, 300, 460,  1, 1, 0),
(12, 102, '宽松大摆工装裤',        '马登工装',   '/assets/products/goods-12-kuan-song-da-ban-ku.jpg',    '[]', '多口袋设计，工装风格', 189.00, 329.00, 280, 710,  1, 1, 1),
(13, 102, '白色系带西装裤',        '红豆',       '/assets/products/goods-13-bai-se-xi-bai-ku.jpg',       '[]', '简约白，清爽百搭', 199.00, 359.00, 220, 330,  1, 0, 0),
(14, 102, '浅色沙弗裤',            '九牧王',     '/assets/products/goods-14-qian-se-sha-fu-ku.jpg',      '[]', '轻盈面料，春夏必备', 169.00, 299.00, 380, 590,  1, 0, 1),
(15, 102, '黑色五分休闲短裤',      '花花公子',   '/assets/products/goods-15-hei-se-duan-ku.jpg',         '[]', '夏季透气五分裤', 89.00, 159.00, 450, 1100, 1, 1, 0),
-- 男装·外套 (103) - ID: 16~21
(16, 103, '轻薄透气夹克',          '优衣库',     '/assets/placeholders/product-placeholder.svg', '[]', '防泼水面料', 299.00, 499.00, 200, 450,  1, 1, 1),
(17, 103, '黑色毛呢大衣',          '利郎',       '/assets/placeholders/product-placeholder.svg', '[]', '高端毛呢面料', 599.00, 999.00, 150, 320,  1, 1, 0),
(18, 103, '军官棉服外套',          '战地吉普',   '/assets/placeholders/product-placeholder.svg', '[]', '军工品质，保暖性强', 399.00, 699.00, 180, 280,  1, 0, 0),
(19, 103, '织物流开衫外套',        '七匹狼',     '/assets/placeholders/product-placeholder.svg', '[]', '轻薄开衫，春秋百搭', 229.00, 399.00, 220, 510,  1, 0, 1),
(20, 103, '絮绒运动羽绒服',        '波司登',     '/assets/placeholders/product-placeholder.svg', '[]', '90%白鸭绒，轻便保暖', 499.00, 899.00, 120, 640,  1, 1, 1),
(21, 103, '工装多口袋夹克',        '马登工装',   '/assets/placeholders/product-placeholder.svg', '[]', '多口袋实用设计', 259.00, 429.00, 200, 380,  1, 0, 0),
-- 女装·裙装 (201) - ID: 22~28
(22, 201, '法式碎花雪纺连衣裙',    'ZARA',       '/assets/placeholders/product-placeholder.svg', '[]', '飘逸雪纺材质', 299.00, 499.00, 200, 850,  1, 1, 1),
(23, 201, '黑色修身晚礼服',        '哥弟',       '/assets/placeholders/product-placeholder.svg', '[]', '优雅晚宴必备', 459.00, 799.00, 100, 220,  1, 0, 0),
(24, 201, '白色蕾丝连衣裙',        '朗姿',       '/assets/placeholders/product-placeholder.svg', '[]', '精致蕾丝面料', 399.00, 699.00, 150, 430,  1, 1, 1),
(25, 201, '粉色波点A字裙',        '红袖',       '/assets/placeholders/product-placeholder.svg', '[]', '俏皮波点，少女感', 189.00, 329.00, 300, 720,  1, 0, 1),
(26, 201, '几何锥形裙',            '地素',       '/assets/placeholders/product-placeholder.svg', '[]', '前卫几何图案', 259.00, 429.00, 180, 340,  1, 0, 0),
(27, 201, '沙龙吊带连衣裙',        'ochirly',    '/assets/placeholders/product-placeholder.svg', '[]', '丝滑吊带裙', 279.00, 479.00, 220, 560,  1, 1, 0),
(28, 201, '奶茶色吊带长裙',        'VERO MODA', '/assets/placeholders/product-placeholder.svg', '[]', '奶茶色调，温婉大气', 329.00, 549.00, 160, 410,  1, 0, 1),
-- 女装·上衣 (202) - ID: 29~35
(29, 202, 'V领针织开衫',           'JNBY',       '/assets/placeholders/product-placeholder.svg', '[]', '亲肤羊绒混纺', 259.00, 399.00, 350, 620,  1, 0, 0),
(30, 202, '宽松慵懒风针织衫',       'UR',         '/assets/placeholders/product-placeholder.svg', '[]', 'oversize版型', 179.00, 299.00, 600, 1100, 1, 1, 0),
(31, 202, '纯色娃娃领衬衫',        '红袖',       '/assets/placeholders/product-placeholder.svg', '[]', '减龄娃娃领设计', 149.00, 259.00, 400, 780,  1, 0, 1),
(32, 202, '黑色星星刺绣衬衫',      'Five Plus',  '/assets/placeholders/product-placeholder.svg', '[]', '星星刺绣装饰', 169.00, 299.00, 320, 540,  1, 0, 0),
(33, 202, '白色带扭结上衣',        'AMII',       '/assets/placeholders/product-placeholder.svg', '[]', '腰部扭结设计', 159.00, 279.00, 350, 490,  1, 0, 1),
(34, 202, '奢华蓝衬衫',            '播',         '/assets/placeholders/product-placeholder.svg', '[]', '静谧蓝显白配色', 199.00, 349.00, 280, 370,  1, 1, 0),
(35, 202, '花灰色毛衣',            '麦娜斯',     '/assets/placeholders/product-placeholder.svg', '[]', '高级花灰色调', 219.00, 379.00, 300, 450,  1, 0, 1),
-- 女装·裤装 (203) - ID: 36~41
(36, 203, '高腰阔腿休闲裤',        'Lily',       '/assets/placeholders/product-placeholder.svg', '[]', '垂坠感面料', 189.00, 329.00, 450, 780,  1, 0, 1),
(37, 203, '白色直筒长裤',          'VERO MODA', '/assets/placeholders/product-placeholder.svg', '[]', '利落直筒版型', 179.00, 299.00, 380, 620,  1, 0, 0),
(38, 203, '黑色小脚裤',            'Only',       '/assets/placeholders/product-placeholder.svg', '[]', '显瘦小脚设计', 169.00, 289.00, 420, 890,  1, 1, 0),
(39, 203, '蓝色高腰百褶裙',        '伊芙丽',     '/assets/placeholders/product-placeholder.svg', '[]', '经典百褶款式', 199.00, 349.00, 300, 540,  1, 0, 1),
(40, 203, '转色直摆裙',            '地素',       '/assets/placeholders/product-placeholder.svg', '[]', '渐变转色设计', 229.00, 399.00, 250, 360,  1, 0, 0),
(41, 203, '卡其迷你裙',            '红袖',       '/assets/placeholders/product-placeholder.svg', '[]', '休闲百搭卡其裙', 149.00, 259.00, 380, 670,  1, 1, 0),
-- 鞋靴·男鞋 (301) - ID: 42~47
(42, 301, '复古运动跑步鞋',        'Nike',       '/assets/placeholders/product-placeholder.svg', '[]', '轻量化设计', 459.00, 699.00, 300, 1350, 1, 1, 0),
(43, 301, '黑白拼接篮球鞋',        'Nike',       '/assets/placeholders/product-placeholder.svg', '[]', '经典黑白撞色', 699.00, 999.00, 200, 820,  1, 1, 1),
(44, 301, '硬岩登山徒步鞋',        'Columbia',   '/assets/placeholders/product-placeholder.svg', '[]', '防滑耐磨鞋底', 499.00, 799.00, 150, 430,  1, 0, 0),
(45, 301, '泡棉减震跑鞋',          'Adidas',     '/assets/placeholders/product-placeholder.svg', '[]', 'Cloudfoam缓震技术', 399.00, 599.00, 350, 1680, 1, 1, 1),
(46, 301, '网球训练帆布鞋',        'Converse',   '/assets/placeholders/product-placeholder.svg', '[]', '经典帆布鞋款', 299.00, 459.00, 280, 920,  1, 0, 0),
(47, 301, '黑色缓震训练鞋',        'Puma',       '/assets/placeholders/product-placeholder.svg', '[]', '综合训练适用', 429.00, 649.00, 220, 570,  1, 0, 1),
-- 鞋靴·女鞋 (302) - ID: 48~52
(48, 302, '尖头细跟通勤高跟鞋',    '热风',       '/assets/placeholders/product-placeholder.svg', '[]', '5cm跟高', 259.00, 399.00, 250, 920,  1, 1, 1),
(49, 302, '坡跟平底休闲淑女鞋',    '卓诗尼',     '/assets/placeholders/product-placeholder.svg', '[]', '舒适坡跟设计', 199.00, 329.00, 300, 730,  1, 0, 0),
(50, 302, '纯皮系带英伦皮鞋',      '天美意',     '/assets/placeholders/product-placeholder.svg', '[]', '头层牛皮材质', 349.00, 549.00, 180, 480,  1, 1, 1),
(51, 302, '夏花流苏凉鞋',          'Kiss Kitty', '/assets/placeholders/product-placeholder.svg', '[]', '流苏装饰夏日凉鞋', 229.00, 379.00, 220, 560,  1, 0, 1),
(52, 302, '水晶粗头鞋',            '百丽',       '/assets/placeholders/product-placeholder.svg', '[]', '水晶装饰粗头设计', 279.00, 449.00, 200, 340,  1, 0, 0),
-- 配饰·帽子 (401) - ID: 53~54
(53, 401, '韩版百搭棒球帽',        'MLB',        '/assets/placeholders/product-placeholder.svg', '[]', '纯棉面料', 89.00, 149.00, 800, 2300, 1, 0, 0),
(54, 401, '织物小球毛线帽',        '正是',       '/assets/placeholders/product-placeholder.svg', '[]', '保暖毛线帽', 59.00, 99.00, 600, 1200, 1, 0, 1),
-- 配饰·包包 (402) - ID: 55~59
(55, 402, '通勤手提单肩两用包',    '小CK',       '/assets/placeholders/product-placeholder.svg', '[]', 'PU材质大容量', 229.00, 399.00, 400, 1680, 1, 1, 1),
(56, 402, '背套小方框链条包',      'CHARLES&KEITH', '/assets/placeholders/product-placeholder.svg', '[]', '链条肩带设计', 299.00, 499.00, 280, 920,  1, 1, 0),
(57, 402, '皮带葡萄石手包',        '迪桑娜',     '/assets/placeholders/product-placeholder.svg', '[]', '时尚手拿包', 189.00, 329.00, 320, 640,  1, 0, 1),
(58, 402, '简约黑色手拿包',        '山水集',     '/assets/placeholders/product-placeholder.svg', '[]', '极简手拿设计', 149.00, 259.00, 380, 890,  1, 0, 0),
(59, 402, '羊皮圆件手提贝壳包',    'GALASSIA',   '/assets/placeholders/product-placeholder.svg', '[]', '头层羊皮贝壳造型', 359.00, 599.00, 150, 280,  1, 0, 1),
-- 内衣·家居 (501/502) - ID: 60~64
(60, 501, '无痕棉质秋衣套装',      '舒雅',       '/assets/placeholders/product-placeholder.svg', '[]', '无痕贴合技术', 169.00, 269.00, 500, 1100, 1, 0, 0),
(61, 501, '童裤细蕾丝内衣套装',    '华歌尔',     '/assets/placeholders/product-placeholder.svg', '[]', '蕾丝装饰内衣套装', 199.00, 329.00, 400, 780,  1, 1, 1),
(62, 501, '家树童裤两件套装',      '三枪',       '/assets/placeholders/product-placeholder.svg', '[]', '纯棉透气两件套', 129.00, 219.00, 600, 1450, 1, 0, 0),
(63, 502, '晨莫新款居家服',        '芬腾',       '/assets/placeholders/product-placeholder.svg', '[]', '亲肤棉质居家服', 139.00, 239.00, 450, 980,  1, 0, 1),
(64, 502, '番纱睡裙睡衣套装',      '红豆居家',   '/assets/placeholders/product-placeholder.svg', '[]', '轻薄纱质睡裙', 159.00, 279.00, 380, 760,  1, 1, 0);

-- ============================================================
-- 初始数据 - SKU（每个商品 1 条默认规格）
-- 命名规范: /assets/products/goods-{goods_id}-{name-pinyin}.jpg
-- ============================================================
INSERT INTO `sku` (`goods_id`, `spec`, `price`, `stock`, `sales`) VALUES
(1,'default',89.00,500,0),(2,'default',129.00,300,0),(3,'default',79.00,600,0),(4,'default',99.00,400,0),(5,'default',119.00,350,0),(6,'default',139.00,280,0),(7,'default',109.00,320,0),(8,'default',159.00,250,0),(9,'default',199.00,400,0),(10,'default',179.00,350,0),(11,'default',229.00,300,0),(12,'default',189.00,280,0),(13,'default',199.00,220,0),(14,'default',169.00,380,0),(15,'default',89.00,450,0),(16,'default',299.00,200,0),(17,'default',599.00,150,0),(18,'default',399.00,180,0),(19,'default',229.00,220,0),(20,'default',499.00,120,0),(21,'default',259.00,200,0),(22,'default',299.00,200,0),(23,'default',459.00,100,0),(24,'default',399.00,150,0),(25,'default',189.00,300,0),(26,'default',259.00,180,0),(27,'default',279.00,220,0),(28,'default',329.00,160,0),(29,'default',259.00,350,0),(30,'default',179.00,600,0),(31,'default',149.00,400,0),(32,'default',169.00,320,0),(33,'default',159.00,350,0),(34,'default',199.00,280,0),(35,'default',219.00,300,0),(36,'default',189.00,450,0),(37,'default',179.00,380,0),(38,'default',169.00,420,0),(39,'default',199.00,300,0),(40,'default',229.00,250,0),(41,'default',149.00,380,0),(42,'default',459.00,300,0),(43,'default',699.00,200,0),(44,'default',499.00,150,0),(45,'default',399.00,350,0),(46,'default',299.00,280,0),(47,'default',429.00,220,0),(48,'default',259.00,250,0),(49,'default',199.00,300,0),(50,'default',349.00,180,0),(51,'default',229.00,220,0),(52,'default',279.00,200,0),(53,'default',89.00,800,0),(54,'default',59.00,600,0),(55,'default',229.00,400,0),(56,'default',299.00,280,0),(57,'default',189.00,320,0),(58,'default',149.00,380,0),(59,'default',359.00,150,0),(60,'default',169.00,500,0),(61,'default',199.00,400,0),(62,'default',129.00,600,0),(63,'default',139.00,450,0),(64,'default',159.00,380,0);
