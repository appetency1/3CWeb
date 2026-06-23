/*
 Navicat Premium Dump SQL

 Source Server         : my_sql
 Source Server Type    : MySQL
 Source Server Version : 90200 (9.2.0)
 Source Host           : localhost:3306
 Source Schema         : clothes_demo

 Target Server Type    : MySQL
 Target Server Version : 90200 (9.2.0)
 File Encoding         : 65001

 Date: 21/06/2026 20:55:38
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for address
-- ----------------------------
DROP TABLE IF EXISTS `address`;
CREATE TABLE `address`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `receiver` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '收货人',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '收货电话',
  `province` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '省',
  `city` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '市',
  `district` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '区/县',
  `detail` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '详细地址',
  `is_default` tinyint NOT NULL DEFAULT 0 COMMENT '是否默认: 0否 1是',
  `tag` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '地址标签: 家/公司/学校等',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '收货地址表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of address
-- ----------------------------
INSERT INTO `address` VALUES (1, 1, 'demo', '17616599913', '北京市', '北京市', '东城区', 'dd', 1, NULL, '2026-06-20 20:10:41', '2026-06-20 20:10:41');
INSERT INTO `address` VALUES (2, 1, 'test1', '1', '北京市', '北京市', '东城区', '1', 0, NULL, '2026-06-21 15:34:09', '2026-06-21 15:34:09');
INSERT INTO `address` VALUES (4, 3, 'ra', '17616599913', '北京市', '北京市', '东城区', 'd', 1, '家', '2026-06-21 20:17:15', '2026-06-21 20:17:15');
INSERT INTO `address` VALUES (7, 3, 'rafa', '17616599913', '北京市', '北京市', '东城区', 'd', 0, '家', '2026-06-21 20:17:29', '2026-06-21 20:17:29');
INSERT INTO `address` VALUES (8, 3, 'rafa', '17616599913', '上海市', '上海市', '黄浦区', 'd', 0, '家', '2026-06-21 20:17:29', '2026-06-21 20:25:32');

-- ----------------------------
-- Table structure for admin
-- ----------------------------
DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录账号',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码(MD5加密)',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像URL',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0禁用 1正常',
  `last_login` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '管理员表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of admin
-- ----------------------------
INSERT INTO `admin` VALUES (1, 'admin', '$2a$10$JZRWUgI5cwvHcKcAuLl6euoAblzi7b7URoAkiLG8sJOo/XAeohzuK', 'Admin', NULL, NULL, 1, '2026-06-21 19:55:35', '2026-06-20 19:42:53', '2026-06-21 19:55:34');

-- ----------------------------
-- Table structure for banner
-- ----------------------------
DROP TABLE IF EXISTS `banner`;
CREATE TABLE `banner`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标题',
  `image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '图片',
  `link` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '跳转链接',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0隐藏 1显示',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '轮播图表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of banner
-- ----------------------------
INSERT INTO `banner` VALUES (1, '夏季新品 清爽上市', '/assets/banners/banner-1.svg', '/category', 1, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `banner` VALUES (2, '精品女装 时尚专区', '/assets/banners/banner-2.svg', '/category', 2, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `banner` VALUES (3, '优雅连衣裙 海滨风情', '/assets/banners/banner-3.svg', '/category', 3, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `banner` VALUES (4, '时尚穿搭 都市优雅', '/assets/banners/banner-4.svg', '/category', 4, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `banner` VALUES (5, '潮流男装 街头风格', '/assets/banners/banner-5.svg', '/user', 5, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `banner` VALUES (6, 'test', '/uploads/2026/06/21/c7946777ba794564a472f6ab597688af.jpg', '', 1, 1, '2026-06-21 19:50:05', '2026-06-21 19:50:05');

-- ----------------------------
-- Table structure for cart
-- ----------------------------
DROP TABLE IF EXISTS `cart`;
CREATE TABLE `cart`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `goods_id` bigint NOT NULL COMMENT '商品ID',
  `sku_id` bigint NOT NULL COMMENT 'SKU ID',
  `quantity` int NOT NULL DEFAULT 1 COMMENT '数量',
  `selected` tinyint NOT NULL DEFAULT 1 COMMENT '是否选中: 0否 1是',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_sku`(`user_id` ASC, `sku_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '购物车表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cart
-- ----------------------------
INSERT INTO `cart` VALUES (5, 3, 41, 41, 1, 1, '2026-06-21 19:23:34', '2026-06-21 19:23:34');

-- ----------------------------
-- Table structure for category
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `parent_id` bigint NOT NULL DEFAULT 0 COMMENT '父分类ID, 0表示一级',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分类名称',
  `icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分类图标',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序, 升序',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0隐藏 1显示',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 503 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商品分类表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of category
-- ----------------------------
INSERT INTO `category` VALUES (1, 0, '男装', '/assets/icons/cat-tops.svg', 1, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `category` VALUES (2, 0, '女装', '/assets/icons/cat-dresses.svg', 2, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `category` VALUES (3, 0, '鞋靴', '/assets/icons/cat-shoes.svg', 3, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `category` VALUES (4, 0, '配饰', '/assets/icons/cat-accessories.svg', 4, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `category` VALUES (101, 1, '上衣', '/assets/icons/cat-tops.svg', 1, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `category` VALUES (102, 1, '裤装', '/assets/icons/cat-bottoms.svg', 2, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `category` VALUES (103, 1, '外套', '/assets/icons/cat-sports.svg', 3, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `category` VALUES (201, 2, '裙装', '/assets/icons/cat-dresses.svg', 1, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `category` VALUES (202, 2, '上衣', '/assets/icons/cat-tops.svg', 2, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `category` VALUES (203, 2, '裤装', '/assets/icons/cat-bottoms.svg', 3, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `category` VALUES (301, 3, '男鞋', '/assets/icons/cat-shoes.svg', 1, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `category` VALUES (302, 3, '女鞋', '/assets/icons/cat-shoes.svg', 2, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `category` VALUES (401, 4, '帽子', '/assets/icons/cat-accessories.svg', 1, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `category` VALUES (402, 4, '包包', '/assets/icons/cat-bags.svg', 2, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `category` VALUES (501, 0, '内衣', '/assets/icons/cat-underwear.svg', 5, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `category` VALUES (502, 0, '家居', '/assets/icons/cat-homewear.svg', 6, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');

-- ----------------------------
-- Table structure for comment
-- ----------------------------
DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `goods_id` bigint NOT NULL COMMENT '商品ID',
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `content` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '评价内容',
  `rating` tinyint NOT NULL DEFAULT 5 COMMENT '评分 1-5',
  `images` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '评价图片, JSON数组',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_goods_id`(`goods_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商品评价表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of comment
-- ----------------------------

-- ----------------------------
-- Table structure for favorite
-- ----------------------------
DROP TABLE IF EXISTS `favorite`;
CREATE TABLE `favorite`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `goods_id` bigint NOT NULL COMMENT '商品ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_goods`(`user_id` ASC, `goods_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商品收藏表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of favorite
-- ----------------------------
INSERT INTO `favorite` VALUES (1, 1, 45, '2026-06-20 20:10:14');

-- ----------------------------
-- Table structure for goods
-- ----------------------------
DROP TABLE IF EXISTS `goods`;
CREATE TABLE `goods`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `category_id` bigint NOT NULL COMMENT '分类ID',
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品名称',
  `brand` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '品牌',
  `cover` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '封面图',
  `images` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '商品图册, JSON数组',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '商品描述',
  `detail` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '商品详情(Html)',
  `price` decimal(10, 2) NOT NULL COMMENT '销售价(展示价)',
  `original_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '原价/划线价',
  `stock` int NOT NULL DEFAULT 0 COMMENT '总库存(SKU汇总)',
  `sales` int NOT NULL DEFAULT 0 COMMENT '销量',
  `view_count` int NOT NULL DEFAULT 0 COMMENT '浏览量',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0下架 1上架',
  `is_hot` tinyint NOT NULL DEFAULT 0 COMMENT '是否热门',
  `is_new` tinyint NOT NULL DEFAULT 0 COMMENT '是否新品',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_category_id`(`category_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE,
  FULLTEXT INDEX `ft_search`(`name`, `brand`, `description`) WITH PARSER `ngram`
) ENGINE = InnoDB AUTO_INCREMENT = 65 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商品SPU表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of goods
-- ----------------------------
INSERT INTO `goods` VALUES (1, 101, '莫兰迪色系纯棉T恤', 'H&M', '/assets/products/goods-1-molan-di-mian-t.jpg', '[]', '柔软透气面料，经典圆领设计', NULL, 89.00, 159.00, 500, 1200, 0, 1, 1, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `goods` VALUES (2, 101, '条纹休闲Polo衫', 'GXG', '/assets/products/goods-2-tiao-wen-polo.jpg', '[]', '商务休闲两不误', NULL, 129.00, 229.00, 300, 680, 0, 1, 1, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `goods` VALUES (3, 101, '纯棉白色圆领T恤', '优衣库', '/assets/products/goods-3-chun-mian-bai-t.jpg', '[]', '百搭基础款，100%纯棉', NULL, 79.00, 129.00, 600, 1500, 0, 1, 0, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `goods` VALUES (4, 101, '黑色酷炫宽松T恤', '太平鸟', '/assets/products/goods-4-hei-se-ku-tong-chang.jpg', '[]', 'OVERSIZE版型，街头风格', NULL, 99.00, 199.00, 400, 900, 0, 1, 1, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `goods` VALUES (5, 101, '奶茶色系Polo衫', '森马', '/assets/products/goods-5-nai-nai-yan-polo.jpg', '[]', '低饱和奶茶色，简约大气', NULL, 119.00, 199.00, 350, 560, 0, 1, 0, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `goods` VALUES (6, 101, '休闲棉质衬衫', '七匹狼', '/assets/products/goods-6-cotton-shirting.jpg', '[]', '透气棉质面料，休闲百搭', NULL, 139.00, 259.00, 280, 420, 0, 1, 0, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `goods` VALUES (7, 101, '亨利领短袖T恤', '杰克琼斯', '/assets/products/goods-7-hen-nai-ka-huang-t.jpg', '[]', '复古亨利领设计', NULL, 109.00, 189.00, 320, 680, 0, 1, 1, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `goods` VALUES (8, 101, '长袖简约针织衫', '恒源祥', '/assets/products/goods-8-chang-xu-zong-jie.jpg', '[]', '春秋必备基础针织', NULL, 159.00, 279.00, 250, 390, 0, 1, 0, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `goods` VALUES (9, 102, '修身直筒牛仔裤', '杰克琼斯', '/assets/products/goods-9-xiu-shen-zhi-tong-niu-zai.jpg', '[]', '水洗工艺处理', NULL, 199.00, 399.00, 400, 920, 0, 1, 0, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `goods` VALUES (10, 102, '黑色水洗休闲裤', 'GXG', '/assets/products/goods-10-hei-se-shui-fan-ku.jpg', '[]', '水洗黑面料，休闲风格', NULL, 179.00, 299.00, 350, 580, 0, 1, 0, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `goods` VALUES (11, 102, '深蓝修身西裤', '七匹狼', '/assets/products/goods-11-shan-lan-xiu-tong-ku.jpg', '[]', '商务场合首选', NULL, 229.00, 399.00, 300, 460, 0, 1, 1, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `goods` VALUES (12, 102, '宽松大摆工装裤', '马登工装', '/assets/products/goods-12-kuan-song-da-ban-ku.jpg', '[]', '多口袋设计，工装风格', NULL, 189.00, 329.00, 280, 710, 0, 1, 1, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `goods` VALUES (13, 102, '白色系带西装裤', '红豆', '/assets/products/goods-13-bai-se-xi-bai-ku.jpg', '[]', '简约白，清爽百搭', NULL, 199.00, 359.00, 220, 330, 0, 1, 0, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `goods` VALUES (14, 102, '浅色沙弗裤', '九牧王', '/assets/products/goods-14-qian-se-sha-fu-ku.jpg', '[]', '轻盈面料，春夏必备', NULL, 169.00, 299.00, 380, 590, 0, 1, 0, 1, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `goods` VALUES (15, 102, '黑色五分休闲短裤', '花花公子', '/assets/products/goods-15-hei-se-duan-ku.jpg', '[]', '夏季透气五分裤', NULL, 89.00, 159.00, 450, 1100, 0, 1, 1, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `goods` VALUES (16, 103, '轻薄透气夹克', '优衣库', '/assets/products/goods-16-qing-bao-tou-ku.jpg', '[]', '防泼水面料', NULL, 299.00, 499.00, 200, 450, 0, 1, 1, 1, '2026-06-20 19:42:53', '2026-06-20 19:57:31');
INSERT INTO `goods` VALUES (17, 103, '黑色毛呢大衣', '利郎', '/assets/products/goods-17-hei-se-mao-ning-wai-tao.jpg', '[]', '高端毛呢面料', NULL, 599.00, 999.00, 150, 320, 0, 1, 1, 0, '2026-06-20 19:42:53', '2026-06-20 19:57:31');
INSERT INTO `goods` VALUES (18, 103, '军官棉服外套', '战地吉普', '/assets/products/goods-18-guan-cuang-mian-fu.jpg', '[]', '军工品质，保暖性强', NULL, 399.00, 699.00, 180, 280, 0, 1, 0, 0, '2026-06-20 19:42:53', '2026-06-20 19:57:31');
INSERT INTO `goods` VALUES (19, 103, '织物流开衫外套', '七匹狼', '/assets/products/goods-19-zhi-wu-ka-dan-wai-tao.jpg', '[]', '轻薄开衫，春秋百搭', NULL, 229.00, 399.00, 220, 510, 0, 1, 0, 1, '2026-06-20 19:42:53', '2026-06-20 19:57:31');
INSERT INTO `goods` VALUES (20, 103, '絮绒运动羽绒服', '波司登', '/assets/products/goods-20-xu-xing-pu-er-fu.jpg', '[]', '90%白鸭绒，轻便保暖', NULL, 499.00, 899.00, 120, 640, 0, 1, 1, 1, '2026-06-20 19:42:53', '2026-06-20 19:57:31');
INSERT INTO `goods` VALUES (21, 103, '工装多口袋夹克', '马登工装', '/assets/products/goods-21-fan-ku-die-jia.jpg', '[]', '多口袋实用设计', NULL, 259.00, 429.00, 200, 380, 1, 1, 0, 0, '2026-06-20 19:42:53', '2026-06-21 14:22:42');
INSERT INTO `goods` VALUES (22, 201, '法式碎花雪纺连衣裙', 'ZARA', '/assets/products/goods-22-fa-shi-sui-hua-qun.jpg', '[]', '飘逸雪纺材质', NULL, 299.00, 499.00, 200, 850, 0, 1, 1, 1, '2026-06-20 19:42:53', '2026-06-20 19:57:31');
INSERT INTO `goods` VALUES (23, 201, '黑色修身晚礼服', '哥弟', '/assets/products/goods-23-hei-se-xiu-shen-qun.jpg', '[]', '优雅晚宴必备', NULL, 459.00, 799.00, 100, 220, 0, 1, 0, 0, '2026-06-20 19:42:53', '2026-06-20 19:57:31');
INSERT INTO `goods` VALUES (24, 201, '白色蕾丝连衣裙', '朗姿', '/assets/products/goods-24-bai-se-luo-yi-qun.jpg', '[]', '精致蕾丝面料', NULL, 399.00, 699.00, 150, 430, 0, 1, 1, 1, '2026-06-20 19:42:53', '2026-06-20 19:57:31');
INSERT INTO `goods` VALUES (25, 201, '粉色波点A字裙', '红袖', '/assets/products/goods-25-fen-se-bo-dian-qun.jpg', '[]', '俏皮波点，少女感', NULL, 189.00, 329.00, 300, 720, 0, 1, 0, 1, '2026-06-20 19:42:53', '2026-06-20 19:57:31');
INSERT INTO `goods` VALUES (26, 201, '几何锥形裙', '地素', '/assets/products/goods-26-ye-mian-ji-zhui-qun.jpg', '[]', '前卫几何图案', NULL, 259.00, 429.00, 180, 340, 0, 1, 0, 0, '2026-06-20 19:42:53', '2026-06-20 19:57:41');
INSERT INTO `goods` VALUES (27, 201, '沙龙吊带连衣裙', 'ochirly', '/assets/products/goods-27-sha-long-die-jia-qun.jpg', '[]', '丝滑吊带裙', NULL, 279.00, 479.00, 220, 560, 0, 1, 1, 0, '2026-06-20 19:42:53', '2026-06-20 19:57:41');
INSERT INTO `goods` VALUES (28, 201, '奶茶色吊带长裙', 'VERO MODA', '/assets/products/goods-28-nai-nai-chaung-qun.jpg', '[]', '奶茶色调，温婉大气', NULL, 329.00, 549.00, 160, 410, 0, 1, 0, 1, '2026-06-20 19:42:53', '2026-06-20 19:57:41');
INSERT INTO `goods` VALUES (29, 202, 'V领针织开衫', 'JNBY', '/assets/products/goods-29-v-ling-zhen-shan-kai-shan.jpg', '[]', '亲肤羊绒混纺', NULL, 259.00, 399.00, 350, 620, 0, 1, 0, 0, '2026-06-20 19:42:53', '2026-06-20 19:57:41');
INSERT INTO `goods` VALUES (30, 202, '宽松慵懒风针织衫', 'UR', '/assets/products/goods-30-kuan-song-lang-fei-fu.jpg', '[]', 'oversize版型', NULL, 179.00, 299.00, 599, 1, 3, 1, 1, 0, '2026-06-20 19:42:53', '2026-06-21 14:23:16');
INSERT INTO `goods` VALUES (31, 202, '纯色娃娃领衬衫', '红袖', '/assets/products/goods-31-chuan-dai-shi-chu-shan.jpg', '[]', '减龄娃娃领设计', NULL, 149.00, 259.00, 400, 780, 0, 1, 0, 1, '2026-06-20 19:42:53', '2026-06-20 19:57:41');
INSERT INTO `goods` VALUES (32, 202, '黑色星星刺绣衬衫', 'Five Plus', '/assets/products/goods-32-hei-se-xing-xing-ci-xiu-chen-shan.jpg', '[]', '星星刺绣装饰', NULL, 169.00, 299.00, 320, 540, 0, 1, 0, 0, '2026-06-20 19:42:53', '2026-06-20 19:57:41');
INSERT INTO `goods` VALUES (33, 202, '白色带扭结上衣', 'AMII', '/assets/products/goods-33-bai-se-dai-niu-jie-shang-yi.jpg', '[]', '腰部扭结设计', NULL, 159.00, 279.00, 350, 490, 0, 1, 0, 1, '2026-06-20 19:42:53', '2026-06-20 19:57:41');
INSERT INTO `goods` VALUES (34, 202, '奢华蓝衬衫', '播', '/assets/products/goods-34-she-hua-lan-chen-shan.jpg', '[]', '静谧蓝显白配色', NULL, 199.00, 349.00, 280, 370, 0, 1, 1, 0, '2026-06-20 19:42:53', '2026-06-20 19:57:41');
INSERT INTO `goods` VALUES (35, 202, '花灰色毛衣', '麦娜斯', '/assets/products/goods-35-hua-hui-se-mian-mao-yi.jpg', '[]', '高级花灰色调', NULL, 219.00, 379.00, 300, 450, 0, 1, 0, 1, '2026-06-20 19:42:53', '2026-06-20 19:57:41');
INSERT INTO `goods` VALUES (36, 203, '高腰阔腿休闲裤', 'Lily', '/assets/products/goods-36-gao-yao-kuo-tui-xiu-xian-ku.jpg', '[]', '垂坠感面料', NULL, 189.00, 329.00, 450, 780, 0, 1, 0, 1, '2026-06-20 19:42:53', '2026-06-20 19:57:51');
INSERT INTO `goods` VALUES (37, 203, '白色直筒长裤', 'VERO MODA', '/assets/products/goods-37-bai-se-zhi-tong-chang-ku.jpg', '[]', '利落直筒版型', NULL, 179.00, 299.00, 380, 620, 0, 1, 0, 0, '2026-06-20 19:42:53', '2026-06-20 19:57:51');
INSERT INTO `goods` VALUES (38, 203, '黑色小脚裤', 'Only', '/assets/products/goods-38-hei-se-xiao-jiao-ku.jpg', '[]', '显瘦小脚设计', NULL, 169.00, 289.00, 420, 890, 0, 1, 1, 0, '2026-06-20 19:42:53', '2026-06-20 19:57:51');
INSERT INTO `goods` VALUES (39, 203, '蓝色高腰百褶裙', '伊芙丽', '/assets/products/goods-39-lan-se-gao-yao-bai-zhe-qun.jpg', '[]', '经典百褶款式', NULL, 199.00, 349.00, 300, 540, 0, 1, 0, 1, '2026-06-20 19:42:53', '2026-06-20 19:57:51');
INSERT INTO `goods` VALUES (40, 203, '转色直摆裙', '地素', '/assets/products/goods-40-zhuan-se-zhi-bai-qun.jpg', '[]', '渐变转色设计', NULL, 229.00, 399.00, 250, 360, 0, 1, 0, 0, '2026-06-20 19:42:53', '2026-06-20 19:57:51');
INSERT INTO `goods` VALUES (41, 203, '卡其迷你裙', '红袖', '/assets/products/goods-41-ka-qi-mi-ni-qun.jpg', '[]', '休闲百搭卡其裙', NULL, 149.00, 259.00, 380, 670, 1, 1, 1, 0, '2026-06-20 19:42:53', '2026-06-21 19:23:32');
INSERT INTO `goods` VALUES (42, 301, '复古运动跑步鞋', 'Nike', '/assets/products/goods-42-fu-gu-yun-dong-xie.jpg', '[]', '轻量化设计', NULL, 459.00, 699.00, 299, 1, 2, 1, 1, 0, '2026-06-20 19:42:53', '2026-06-21 17:14:47');
INSERT INTO `goods` VALUES (43, 301, '黑白拼接篮球鞋', 'Nike', '/assets/products/goods-43-hei-bai-jiao-se-xie.jpg', '[]', '经典黑白撞色', NULL, 699.00, 999.00, 200, 820, 0, 1, 1, 1, '2026-06-20 19:42:53', '2026-06-20 19:57:51');
INSERT INTO `goods` VALUES (44, 301, '硬岩登山徒步鞋', 'Columbia', '/assets/products/goods-44-ying-yan-bu-deng-xie.jpg', '[]', '防滑耐磨鞋底', NULL, 499.00, 799.00, 150, 430, 0, 1, 0, 0, '2026-06-20 19:42:53', '2026-06-20 19:57:51');
INSERT INTO `goods` VALUES (45, 301, '泡棉减震跑鞋', 'Adidas', '/assets/products/goods-45-pao-mian-jian-zhen-xie.jpg', '[]', 'Cloudfoam缓震技术', NULL, 399.00, 599.00, 350, 0, 1, 1, 1, 1, '2026-06-20 19:42:53', '2026-06-20 20:27:38');
INSERT INTO `goods` VALUES (46, 301, '网球训练帆布鞋', 'Converse', '/assets/products/goods-46-wang-qiu-xun-lian-fan-bu-xie.jpg', '[]', '经典帆布鞋款', NULL, 299.00, 459.00, 280, 920, 0, 1, 0, 0, '2026-06-20 19:42:53', '2026-06-20 19:58:02');
INSERT INTO `goods` VALUES (47, 301, '黑色缓震训练鞋', 'Puma', '/assets/products/goods-47-hei-se-huan-zhen-xun-lian-xie.jpg', '[]', '综合训练适用', NULL, 429.00, 649.00, 220, 570, 0, 1, 0, 1, '2026-06-20 19:42:53', '2026-06-20 19:58:02');
INSERT INTO `goods` VALUES (48, 302, '尖头细跟通勤高跟鞋', '热风', '/assets/products/goods-48-jian-tou-xi-gen-tong-qun-gao-gen.jpg', '[]', '5cm跟高', NULL, 259.00, 399.00, 250, 920, 0, 1, 1, 1, '2026-06-20 19:42:53', '2026-06-20 19:58:02');
INSERT INTO `goods` VALUES (49, 302, '坡跟平底休闲淑女鞋', '卓诗尼', '/assets/products/goods-49-po-gen-ping-di-shu-nv-xie.jpg', '[]', '舒适坡跟设计', NULL, 199.00, 329.00, 300, 730, 0, 1, 0, 0, '2026-06-20 19:42:53', '2026-06-20 19:58:02');
INSERT INTO `goods` VALUES (50, 302, '纯皮系带英伦皮鞋', '天美意', '/assets/products/goods-50-chun-pi-xi-dai-ying-lun-pi-xie.jpg', '[]', '头层牛皮材质', NULL, 349.00, 549.00, 180, 480, 0, 1, 1, 1, '2026-06-20 19:42:53', '2026-06-20 19:58:02');
INSERT INTO `goods` VALUES (51, 302, '夏花流苏凉鞋', 'Kiss Kitty', '/assets/products/goods-51-xia-hua-liu-su-liang-xie.jpg', '[]', '流苏装饰夏日凉鞋', NULL, 229.00, 379.00, 220, 560, 0, 1, 0, 1, '2026-06-20 19:42:53', '2026-06-20 19:58:02');
INSERT INTO `goods` VALUES (52, 302, '水晶粗头鞋', '百丽', '/assets/products/goods-52-shui-jing-cu-gen-xie.jpg', '[]', '水晶装饰粗头设计', NULL, 279.00, 449.00, 200, 340, 1, 1, 0, 0, '2026-06-20 19:42:53', '2026-06-21 20:52:37');
INSERT INTO `goods` VALUES (53, 401, '韩版百搭棒球帽', 'MLB', '/assets/products/goods-53-han-ban-bai-da-baseball-mao.jpg', '[]', '纯棉面料', NULL, 89.00, 149.00, 800, 2300, 0, 1, 0, 0, '2026-06-20 19:42:53', '2026-06-20 19:58:02');
INSERT INTO `goods` VALUES (54, 401, '织物小球毛线帽', '正是', '/assets/products/goods-54-zhi-wu-xiao-qiu-mao-xian-mao.jpg', '[]', '保暖毛线帽', NULL, 59.00, 99.00, 600, 1200, 0, 1, 0, 1, '2026-06-20 19:42:53', '2026-06-20 19:58:02');
INSERT INTO `goods` VALUES (55, 402, '通勤手提单肩两用包', '小CK', '/assets/products/goods-55-tong-yong-shou-ti-dan-jian-liang-yong-bao.jpg', '[]', 'PU材质大容量', NULL, 229.00, 399.00, 399, 1, 1, 1, 1, 1, '2026-06-20 19:42:53', '2026-06-20 20:44:05');
INSERT INTO `goods` VALUES (56, 402, '背套小方框链条包', 'CHARLES&KEITH', '/assets/products/goods-56-xiao-fang-kuang-lian-tiao-bao.jpg', '[]', '链条肩带设计', NULL, 299.00, 499.00, 280, 920, 0, 1, 1, 0, '2026-06-20 19:42:53', '2026-06-20 19:58:13');
INSERT INTO `goods` VALUES (57, 402, '皮带葡萄石手包', '迪桑娜', '/assets/products/goods-57-pi-dai-pu-tao-shou-bao.jpg', '[]', '时尚手拿包', NULL, 189.00, 329.00, 320, 640, 0, 1, 0, 1, '2026-06-20 19:42:53', '2026-06-20 19:58:13');
INSERT INTO `goods` VALUES (58, 402, '简约黑色手拿包', '山水集', '/assets/products/goods-58-jian-yue-hei-se-shou-na-bao.jpg', '[]', '极简手拿设计', NULL, 149.00, 259.00, 380, 890, 0, 1, 0, 0, '2026-06-20 19:42:53', '2026-06-20 19:58:13');
INSERT INTO `goods` VALUES (59, 402, '羊皮圆件手提贝壳包', 'GALASSIA', '/assets/products/goods-59-yang-pi-yuan-xing-shou-ti-bei-ke-bao.jpg', '[]', '头层羊皮贝壳造型', NULL, 359.00, 599.00, 150, 280, 0, 1, 0, 1, '2026-06-20 19:42:53', '2026-06-20 19:58:13');
INSERT INTO `goods` VALUES (60, 501, '无痕棉质秋衣套装', '舒雅', '/assets/products/goods-60-wu-hen-mian-zhi-qiu-yi-tao-zhuang.jpg', '[]', '无痕贴合技术', NULL, 169.00, 269.00, 500, 1100, 0, 1, 0, 0, '2026-06-20 19:42:53', '2026-06-20 19:58:13');
INSERT INTO `goods` VALUES (61, 501, '童裤细蕾丝内衣套装', '华歌尔', '/assets/products/goods-61-tong-kuan-xi-lei-si-nei-yi-tao-zhuang.jpg', '[]', '蕾丝装饰内衣套装', NULL, 199.00, 329.00, 400, 780, 0, 1, 1, 1, '2026-06-20 19:42:53', '2026-06-20 19:58:13');
INSERT INTO `goods` VALUES (62, 501, '家树童裤两件套装', '三枪', '/assets/products/goods-62-jia-shu-tong-ku-liang-jian-tao-zhuang.jpg', '[]', '纯棉透气两件套', NULL, 129.00, 219.00, 600, 1450, 0, 1, 0, 0, '2026-06-20 19:42:53', '2026-06-20 19:58:13');
INSERT INTO `goods` VALUES (63, 502, '晨莫新款居家服', '芬腾', '/assets/products/goods-63-chen-mo-xin-kuan-jia-ju-fu.jpg', '[]', '亲肤棉质居家服', NULL, 139.00, 239.00, 450, 980, 0, 1, 0, 1, '2026-06-20 19:42:53', '2026-06-20 19:58:13');
INSERT INTO `goods` VALUES (64, 502, '番纱睡裙睡衣套装', '红豆居家', '/assets/products/goods-64-fan-sha-shui-qun-shui-yi-tao-zhuang.jpg', '[]', '轻薄纱质睡裙', NULL, 159.00, 279.00, 380, 760, 0, 1, 1, 0, '2026-06-20 19:42:53', '2026-06-20 19:58:13');

-- ----------------------------
-- Table structure for order_item
-- ----------------------------
DROP TABLE IF EXISTS `order_item`;
CREATE TABLE `order_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `goods_id` bigint NOT NULL COMMENT '商品ID',
  `sku_id` bigint NOT NULL COMMENT 'SKU ID',
  `goods_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品名称(快照)',
  `goods_cover` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品封面(快照)',
  `spec` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '规格(快照)',
  `price` decimal(10, 2) NOT NULL COMMENT '单价(快照)',
  `quantity` int NOT NULL COMMENT '购买数量',
  `subtotal` decimal(10, 2) NOT NULL COMMENT '小计金额',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单详情表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of order_item
-- ----------------------------
INSERT INTO `order_item` VALUES (1, 1, 45, 45, '泡棉减震跑鞋', '/assets/products/goods-45-pao-mian-jian-zhen-xie.jpg', 'default', 399.00, 1, 399.00);
INSERT INTO `order_item` VALUES (2, 2, 55, 55, '通勤手提单肩两用包', '/assets/products/goods-55-tong-yong-shou-ti-dan-jian-liang-yong-bao.jpg', 'default', 229.00, 1, 229.00);
INSERT INTO `order_item` VALUES (3, 3, 30, 30, '宽松慵懒风针织衫', '/assets/products/goods-30-kuan-song-lang-fei-fu.jpg', 'default', 179.00, 1, 179.00);
INSERT INTO `order_item` VALUES (4, 4, 42, 42, '复古运动跑步鞋', '/assets/products/goods-42-fu-gu-yun-dong-xie.jpg', 'default', 459.00, 1, 459.00);

-- ----------------------------
-- Table structure for orders
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '订单号',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `total_amount` decimal(10, 2) NOT NULL COMMENT '订单总金额',
  `pay_amount` decimal(10, 2) NOT NULL COMMENT '实付金额',
  `freight_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '运费',
  `discount_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '优惠金额',
  `receiver` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '收货人',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '收货电话',
  `address` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '完整收货地址',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '订单备注',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '订单状态: 0待付款 1待发货 2待收货 3已完成 4已取消',
  `pay_time` datetime NULL DEFAULT NULL COMMENT '支付时间',
  `ship_time` datetime NULL DEFAULT NULL COMMENT '发货时间',
  `finish_time` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `cancel_time` datetime NULL DEFAULT NULL COMMENT '取消时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_order_no`(`order_no` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of orders
-- ----------------------------
INSERT INTO `orders` VALUES (1, '202606202010453781', 1, 399.00, 349.00, 0.00, 50.00, 'demo', '17616599913', '北京市 北京市 东城区 dd', NULL, 4, '2026-06-20 20:10:48', NULL, NULL, '2026-06-20 20:27:38', '2026-06-20 20:10:45', '2026-06-20 20:27:38');
INSERT INTO `orders` VALUES (2, '202606202044051236', 1, 229.00, 229.00, 0.00, 0.00, 'demo', '17616599913', '北京市 北京市 东城区 dd', NULL, 3, '2026-06-20 20:44:07', '2026-06-20 20:47:25', '2026-06-20 20:50:03', NULL, '2026-06-20 20:44:05', '2026-06-20 20:50:03');
INSERT INTO `orders` VALUES (3, '202606211423105708', 1, 179.00, 179.00, 0.00, 0.00, 'demo', '17616599913', '北京市 北京市 东城区 dd', NULL, 3, '2026-06-21 14:23:12', '2026-06-21 14:53:03', '2026-06-21 16:59:56', NULL, '2026-06-21 14:23:10', '2026-06-21 16:59:56');
INSERT INTO `orders` VALUES (4, '202606211714433292', 1, 459.00, 409.00, 0.00, 50.00, 'demo', '17616599913', '北京市 北京市 东城区 dd', NULL, 3, '2026-06-21 17:14:44', '2026-06-21 17:15:10', '2026-06-21 17:15:32', NULL, '2026-06-21 17:14:43', '2026-06-21 17:15:32');

-- ----------------------------
-- Table structure for sku
-- ----------------------------
DROP TABLE IF EXISTS `sku`;
CREATE TABLE `sku`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `goods_id` bigint NOT NULL COMMENT '所属商品ID',
  `spec` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '规格JSON, e.g. {\"颜色\":\"红色\",\"尺码\":\"XL\"}',
  `price` decimal(10, 2) NOT NULL COMMENT 'SKU价格',
  `stock` int NOT NULL DEFAULT 0 COMMENT 'SKU库存',
  `sales` int NOT NULL DEFAULT 0 COMMENT 'SKU销量',
  `image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'SKU图片',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_goods_id`(`goods_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 65 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商品SKU表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sku
-- ----------------------------
INSERT INTO `sku` VALUES (1, 1, 'default', 89.00, 500, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (2, 2, 'default', 129.00, 300, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (3, 3, 'default', 79.00, 600, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (4, 4, 'default', 99.00, 400, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (5, 5, 'default', 119.00, 350, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (6, 6, 'default', 139.00, 280, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (7, 7, 'default', 109.00, 320, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (8, 8, 'default', 159.00, 250, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (9, 9, 'default', 199.00, 400, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (10, 10, 'default', 179.00, 350, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (11, 11, 'default', 229.00, 300, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (12, 12, 'default', 189.00, 280, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (13, 13, 'default', 199.00, 220, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (14, 14, 'default', 169.00, 380, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (15, 15, 'default', 89.00, 450, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (16, 16, 'default', 299.00, 200, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (17, 17, 'default', 599.00, 150, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (18, 18, 'default', 399.00, 180, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (19, 19, 'default', 229.00, 220, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (20, 20, 'default', 499.00, 120, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (21, 21, 'default', 259.00, 200, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (22, 22, 'default', 299.00, 200, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (23, 23, 'default', 459.00, 100, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (24, 24, 'default', 399.00, 150, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (25, 25, 'default', 189.00, 300, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (26, 26, 'default', 259.00, 180, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (27, 27, 'default', 279.00, 220, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (28, 28, 'default', 329.00, 160, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (29, 29, 'default', 259.00, 350, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (30, 30, 'default', 179.00, 599, 1, NULL, 0, '2026-06-20 19:42:53', '2026-06-21 14:23:10');
INSERT INTO `sku` VALUES (31, 31, 'default', 149.00, 400, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (32, 32, 'default', 169.00, 320, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (33, 33, 'default', 159.00, 350, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (34, 34, 'default', 199.00, 280, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (35, 35, 'default', 219.00, 300, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (36, 36, 'default', 189.00, 450, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (37, 37, 'default', 179.00, 380, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (38, 38, 'default', 169.00, 420, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (39, 39, 'default', 199.00, 300, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (40, 40, 'default', 229.00, 250, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (41, 41, 'default', 149.00, 380, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (42, 42, 'default', 459.00, 299, 1, NULL, 0, '2026-06-20 19:42:53', '2026-06-21 17:14:43');
INSERT INTO `sku` VALUES (43, 43, 'default', 699.00, 200, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (44, 44, 'default', 499.00, 150, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (45, 45, 'default', 399.00, 350, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 20:27:38');
INSERT INTO `sku` VALUES (46, 46, 'default', 299.00, 280, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (47, 47, 'default', 429.00, 220, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (48, 48, 'default', 259.00, 250, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (49, 49, 'default', 199.00, 300, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (50, 50, 'default', 349.00, 180, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (51, 51, 'default', 229.00, 220, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (52, 52, 'default', 279.00, 200, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (53, 53, 'default', 89.00, 800, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (54, 54, 'default', 59.00, 600, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (55, 55, 'default', 229.00, 399, 1, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 20:44:05');
INSERT INTO `sku` VALUES (56, 56, 'default', 299.00, 280, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (57, 57, 'default', 189.00, 320, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (58, 58, 'default', 149.00, 380, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (59, 59, 'default', 359.00, 150, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (60, 60, 'default', 169.00, 500, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (61, 61, 'default', 199.00, 400, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (62, 62, 'default', 129.00, 600, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (63, 63, 'default', 139.00, 450, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');
INSERT INTO `sku` VALUES (64, 64, 'default', 159.00, 380, 0, NULL, 0, '2026-06-20 19:42:53', '2026-06-20 19:42:53');

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录账号',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码(MD5加密)',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像URL',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `gender` tinyint NOT NULL DEFAULT 0 COMMENT '性别: 0未知 1男 2女',
  `birthday` date NULL DEFAULT NULL COMMENT '生日',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0禁用 1正常',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  INDEX `idx_phone`(`phone` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (2, 'test', '$2a$10$k5zFc0ToXiDpVyXl0dh7XOHQTxe4sWfPBhL0rzOD5K6bgMXpZeH3m', NULL, NULL, NULL, NULL, 0, NULL, 1, '2026-06-21 19:17:44', '2026-06-21 19:17:44');
INSERT INTO `user` VALUES (3, 'rafa', '$2a$10$gIMxTDdoJFRGsgJeY2zO9eqrdNW7mWvQW66As1aKshVtS1asp5qOK', NULL, '/uploads/2026/06/21/e7f71f32965c415ea1c32b18b960b999.jpg', NULL, NULL, 0, NULL, 1, '2026-06-21 19:20:14', '2026-06-21 19:21:53');

SET FOREIGN_KEY_CHECKS = 1;
