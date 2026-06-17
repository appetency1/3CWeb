-- ============================================================
--  ClothesDemo 商品数据扩展脚本 v2
--  素材清单完整版：64个商品 + 完整 detail HTML + SKU 规格
--  数据库: clothes_demo
-- ============================================================

USE clothes_demo;

-- ============================================================
-- 1. 删除旧数据（可选，取消注释可清空重建）
-- ============================================================
-- DELETE FROM sku WHERE goods_id > 12;
-- DELETE FROM goods WHERE id > 12;
-- DELETE FROM comment;

-- ============================================================
-- 2. 商品 SPU 数据 (ID 1-64)
-- ============================================================

INSERT INTO goods (id, category_id, name, brand, cover, images, description, detail, price, original_price, stock, sales, status, is_hot, is_new) VALUES

-- ==================== 男上装 Men's Tops (ID 1-8) ====================

(1, 101, '莫兰迪色系纯棉T恤', 'H&M',
 '/assets/products/goods-1-molan-di-mian-t.jpg', '[]',
 '柔软透气面料，经典圆领设计，夏季必备单品。精选新疆长绒棉，舒适亲肤。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-1-molan-di-mian-t.jpg" alt="莫兰迪色系纯棉T恤" /></div><div class="detail-info"><h2>莫兰迪色系纯棉T恤</h2><p class="sub">H&amp;M 品牌正品</p></div><div class="detail-desc"><p>精选新疆长绒棉面料，柔软透气，上身舒适无刺激。经典圆领设计，修饰脖颈线条，百搭不挑人。</p><p>莫兰迪色系低饱和配色，柔和高级，彰显品味。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>H&amp;M</td></tr><tr><td>材质</td><td>100%纯棉</td></tr><tr><td>袖长</td><td>短袖</td></tr><tr><td>领型</td><td>圆领</td></tr><tr><td>厚度</td><td>轻薄</td></tr><tr><td>款式</td><td>休闲百搭</td></tr></table></div><div class="detail-size"><h3>尺码说明</h3><table><tr><td>尺码</td><td>胸围(cm)</td><td>肩宽(cm)</td><td>衣长(cm)</td></tr><tr><td>M</td><td>100</td><td>44</td><td>68</td></tr><tr><td>L</td><td>104</td><td>46</td><td>70</td></tr><tr><td>XL</td><td>108</td><td>48</td><td>72</td></tr><tr><td>XXL</td><td>112</td><td>50</td><td>74</td></tr></table></div><div class="detail-notice"><p>* 以上尺码为手工测量，可能存在1-2cm误差</p><p>* 深色衣物建议分开洗涤，避免染色</p></div></div>',
 89.00, 159.00, 500, 1200, 1, 1, 0),

(2, 101, '条纹休闲Polo衫', 'GXG',
 '/assets/products/goods-2-tiao-wen-polo.jpg', '[]',
 '商务休闲两不误，珠地网眼面料，透气舒适。经典条纹设计，时尚有型。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-2-tiao-wen-polo.jpg" alt="条纹休闲Polo衫" /></div><div class="detail-info"><h2>条纹休闲Polo衫</h2><p class="sub">GXG 品牌正品</p></div><div class="detail-desc"><p>珠地网眼面料，透气排汗性能优越，夏日穿着不闷热。</p><p>经典条纹撞色设计，商务与休闲风格兼具，适合多种场合。</p><p>翻领设计，修饰脸型，提升整体气质。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>GXG</td></tr><tr><td>材质</td><td>珠地棉</td></tr><tr><td>袖长</td><td>短袖</td></tr><tr><td>领型</td><td>翻领Polo</td></tr><tr><td>厚度</td><td>适中</td></tr><tr><td>款式</td><td>商务休闲</td></tr></table></div><div class="detail-size"><h3>尺码说明</h3><table><tr><td>尺码</td><td>胸围(cm)</td><td>肩宽(cm)</td><td>衣长(cm)</td></tr><tr><td>M</td><td>104</td><td>46</td><td>68</td></tr><tr><td>L</td><td>108</td><td>48</td><td>70</td></tr><tr><td>XL</td><td>112</td><td>50</td><td>72</td></tr></table></div></div>',
 129.00, 229.00, 300, 680, 1, 1, 1),

(3, 101, '纯棉白色圆领T恤', 'Uniqlo',
 '/assets/products/goods-3-chun-mian-bai-t.jpg', '[]',
 '极简主义设计，100%纯棉面料，基础百搭款衣橱必备。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-3-chun-mian-bai-t.jpg" alt="纯棉白色圆领T恤" /></div><div class="detail-info"><h2>纯棉白色圆领T恤</h2><p class="sub">Uniqlo 基础系列</p></div><div class="detail-desc"><p>极简白色T恤，百搭经典款，适合作为打底或单穿。</p><p>选用优质纯棉面料，柔软亲肤，透气吸汗。精细车线工艺，走线均匀平整。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>Uniqlo</td></tr><tr><td>材质</td><td>100%纯棉</td></tr><tr><td>袖长</td><td>短袖</td></tr><tr><td>领型</td><td>圆领</td></tr><tr><td>厚度</td><td>轻薄</td></tr><tr><td>款式</td><td>极简百搭</td></tr></table></div><div class="detail-size"><h3>尺码说明</h3><table><tr><td>尺码</td><td>胸围(cm)</td><td>肩宽(cm)</td><td>衣长(cm)</td></tr><tr><td>M</td><td>96</td><td>42</td><td>66</td></tr><tr><td>L</td><td>100</td><td>44</td><td>68</td></tr><tr><td>XL</td><td>104</td><td>46</td><td>70</td></tr></table></div></div>',
 69.00, 129.00, 600, 2100, 1, 0, 0),

(4, 101, '黑色酷炫宽松T恤', 'Supreme',
 '/assets/products/goods-4-hei-se-ku-tong-chang-t.jpg', '[]',
 '宽松OVERSIZE版型，街头风格设计，个性十足。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-4-hei-se-ku-tong-chang-t.jpg" alt="黑色酷炫宽松T恤" /></div><div class="detail-info"><h2>黑色酷炫宽松T恤</h2><p class="sub">Supreme 街头系列</p></div><div class="detail-desc"><p>OVERSIZED宽松版型设计，对各种身材友好，街头潮流感十足。</p><p>纯黑配色低调神秘，胸前个性图案设计彰显态度。</p><p>高品质面料，手感厚实有质感。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>Supreme</td></tr><tr><td>材质</td><td>纯棉</td></tr><tr><td>袖长</td><td>短袖</td></tr><tr><td>版型</td><td>OVERSIZED宽松</td></tr><tr><td>款式</td><td>街头潮流</td></tr></table></div></div>',
 119.00, 199.00, 350, 950, 1, 1, 0),

(5, 101, '奶茶色系Polo衫', '太平鸟',
 '/assets/products/goods-5-nai-nai-yan-polo.jpg', '[]',
 '温柔奶茶色系，低饱和配色高级感十足，棉质Polo面料。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-5-nai-nai-yan-polo.jpg" alt="奶茶色系Polo衫" /></div><div class="detail-info"><h2>奶茶色系Polo衫</h2><p class="sub">太平鸟 联名款</p></div><div class="detail-desc"><p>莫兰迪奶茶色系，低饱和配色，高级感满满。</p><p>精选棉质珠地布面料，透气舒适，夏日穿着清爽。</p><p>Polo领设计，可正式可休闲。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>太平鸟</td></tr><tr><td>材质</td><td>棉质珠地布</td></tr><tr><td>袖长</td><td>短袖</td></tr><tr><td>领型</td><td>Polo翻领</td></tr><tr><td>款式</td><td>温柔休闲</td></tr></table></div></div>',
 149.00, 259.00, 280, 420, 1, 0, 1),

(6, 101, '休闲棉质衬衫', 'GAP',
 '/assets/products/goods-6-cotton-shirting.jpg', '[]',
 '休闲棉质衬衫，透气面料，适合春夏秋三季穿搭。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-6-cotton-shirting.jpg" alt="休闲棉质衬衫" /></div><div class="detail-info"><h2>休闲棉质衬衫</h2><p class="sub">GAP 经典系列</p></div><div class="detail-desc"><p>全棉面料，柔软透气，亲肤舒适。</p><p>经典衬衫款式，可单穿可叠穿，适合多种搭配场景。</p><p>标准版型，不挑身材。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>GAP</td></tr><tr><td>材质</td><td>100%纯棉</td></tr><tr><td>袖长</td><td>长袖</td></tr><tr><td>领型</td><td>标准领</td></tr><tr><td>款式</td><td>休闲百搭</td></tr></table></div><div class="detail-size"><h3>尺码说明</h3><table><tr><td>尺码</td><td>胸围(cm)</td><td>肩宽(cm)</td><td>衣长(cm)</td></tr><tr><td>M</td><td>106</td><td>45</td><td>72</td></tr><tr><td>L</td><td>110</td><td>47</td><td>74</td></tr><tr><td>XL</td><td>114</td><td>49</td><td>76</td></tr></table></div></div>',
 139.00, 239.00, 400, 760, 1, 0, 0),

(7, 101, '亨利领短袖T恤', '杰克琼斯',
 '/assets/products/goods-7-hen-nai-ka-huang-t.jpg', '[]',
 '亨利领设计，复古休闲风格，棉质面料舒适透气。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-7-hen-nai-ka-huang-t.jpg" alt="亨利领短袖T恤" /></div><div class="detail-info"><h2>亨利领短袖T恤</h2><p class="sub">杰克琼斯 复古系列</p></div><div class="detail-desc"><p>亨利领（半开领）设计，复古休闲风格独特。</p><p>精选棉质面料，柔软透气，上身舒适。</p><p>适合追求个性的男士穿着。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>杰克琼斯</td></tr><tr><td>材质</td><td>纯棉</td></tr><tr><td>袖长</td><td>短袖</td></tr><tr><td>领型</td><td>亨利领</td></tr><tr><td>款式</td><td>复古休闲</td></tr></table></div></div>',
 99.00, 169.00, 450, 580, 1, 0, 0),

(8, 101, '长袖简约针织衫', 'HM',
 '/assets/products/goods-8-chang-xu-jian-jie.jpg', '[]',
 '春秋必备长袖针织衫，简约设计，百搭实穿。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-8-chang-xu-jian-jie.jpg" alt="长袖简约针织衫" /></div><div class="detail-info"><h2>长袖简约针织衫</h2><p class="sub">HM 秋季新款</p></div><div class="detail-desc"><p>精纺针织面料，柔软细腻，春秋穿着温暖舒适。</p><p>简约纯色设计，经典百搭，可搭配各种裤装。</p><p>罗纹袖口和下摆，不易变形。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>HM</td></tr><tr><td>材质</td><td>针织棉</td></tr><tr><td>袖长</td><td>长袖</td></tr><tr><td>领型</td><td>圆领</td></tr><tr><td>款式</td><td>简约百搭</td></tr></table></div><div class="detail-size"><h3>尺码说明</h3><table><tr><td>尺码</td><td>胸围(cm)</td><td>肩宽(cm)</td><td>衣长(cm)</td></tr><tr><td>M</td><td>100</td><td>44</td><td>66</td></tr><tr><td>L</td><td>104</td><td>46</td><td>68</td></tr><tr><td>XL</td><td>108</td><td>48</td><td>70</td></tr></table></div></div>',
 159.00, 279.00, 320, 340, 1, 0, 1),

-- ==================== 男裤装 Men's Bottoms (ID 9-15) ====================

(9, 102, '修身直筒牛仔裤', 'Jack&Jones',
 '/assets/products/goods-9-xiu-shen-zhi-tong-niu-zai.jpg', '[]',
 '水洗工艺处理，舒适弹力面料，修身版型显腿长。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-9-xiu-shen-zhi-tong-niu-zai.jpg" alt="修身直筒牛仔裤" /></div><div class="detail-info"><h2>修身直筒牛仔裤</h2><p class="sub">Jack&amp;Jones 经典款</p></div><div class="detail-desc"><p>水洗工艺处理，呈现自然复古质感。</p><p>含少量弹性纤维，穿着舒适不紧绷，蹲坐自如。</p><p>修身直筒版型，修饰腿型，拉长身材比例。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>Jack&amp;Jones</td></tr><tr><td>材质</td><td>98%棉 2%氨纶</td></tr><tr><td>版型</td><td>修身直筒</td></tr><tr><td>厚度</td><td>适中</td></tr><tr><td>腰型</td><td>中腰</td></tr></table></div><div class="detail-size"><h3>尺码说明</h3><table><tr><td>尺码</td><td>腰围(cm)</td><td>臀围(cm)</td><td>裤长(cm)</td></tr><tr><td>30</td><td>76</td><td>100</td><td>102</td></tr><tr><td>32</td><td>81</td><td>104</td><td>104</td></tr><tr><td>34</td><td>86</td><td>108</td><td>106</td></tr></table></div></div>',
 199.00, 399.00, 400, 920, 1, 0, 0),

(10, 102, '黑色水洗休闲裤', 'GXG',
 '/assets/products/goods-10-hei-se-shui-fan-ku.jpg', '[]',
 '黑色水洗休闲裤，舒适面料，百搭款式。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-10-hei-se-shui-fan-ku.jpg" alt="黑色水洗休闲裤" /></div><div class="detail-info"><h2>黑色水洗休闲裤</h2><p class="sub">GXG 休闲系列</p></div><div class="detail-desc"><p>黑色水洗工艺，呈现细腻质感，低调百搭。</p><p>休闲直筒版型，适合日常出行穿着。</p><p>棉质面料，透气舒适。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>GXG</td></tr><tr><td>材质</td><td>纯棉</td></tr><tr><td>版型</td><td>休闲直筒</td></tr><tr><td>款式</td><td>百搭休闲</td></tr></table></div></div>',
 159.00, 299.00, 380, 650, 1, 0, 0),

(11, 102, '深蓝修身西裤', '雅戈尔',
 '/assets/products/goods-11-shen-lan-xiu-shen-xi-ku.jpg', '[]',
 '深蓝配色稳重商务，修身版型显气质。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-11-shen-lan-xiu-shen-xi-ku.jpg" alt="深蓝修身西裤" /></div><div class="detail-info"><h2>深蓝修身西裤</h2><p class="sub">雅戈尔 正装系列</p></div><div class="detail-desc"><p>深蓝色调，稳重而不沉闷，适合商务场合。</p><p>修身版型剪裁，凸显腿部线条，提升整体气质。</p><p>面料挺括有型，不易起皱。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>雅戈尔</td></tr><tr><td>材质</td><td>聚酯纤维 粘胶</td></tr><tr><td>版型</td><td>修身</td></tr><tr><td>腰型</td><td>中腰</td></tr><tr><td>款式</td><td>商务正装</td></tr></table></div></div>',
 229.00, 429.00, 250, 380, 1, 1, 0),

(12, 102, '宽松大摆工装裤', 'CAT',
 '/assets/products/goods-12-kuan-song-da-ban-gong-zhuang-ku.jpg', '[]',
 '工装风格大口袋设计，宽松版型，户外休闲首选。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-12-kuan-song-da-ban-gong-zhuang-ku.jpg" alt="宽松大摆工装裤" /></div><div class="detail-info"><h2>宽松大摆工装裤</h2><p class="sub">CAT 工装系列</p></div><div class="detail-desc"><p>经典工装裤款式，多口袋设计，实用性强。</p><p>宽松直筒版型，穿着无束缚感，适合户外活动。</p><p>厚实棉质面料，耐磨耐穿。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>CAT</td></tr><tr><td>材质</td><td>全棉斜纹</td></tr><tr><td>版型</td><td>宽松工装</td></tr><tr><td>口袋</td><td>多口袋设计</td></tr><tr><td>款式</td><td>工装休闲</td></tr></table></div></div>',
 269.00, 459.00, 200, 290, 1, 0, 1),

(13, 102, '白色系带西装裤', '太平鸟',
 '/assets/products/goods-13-bai-se-xi-dai-xi-zhuang-ku.jpg', '[]',
 '白色干净利落，系带设计时尚有型，正式休闲两相宜。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-13-bai-se-xi-dai-xi-zhuang-ku.jpg" alt="白色系带西装裤" /></div><div class="detail-info"><h2>白色系带西装裤</h2><p class="sub">太平鸟 时尚系列</p></div><div class="detail-desc"><p>纯净白色调，干净利落，视觉上拉长腿部线条。</p><p>侧边系带设计增加时尚感，面料垂感好。</p><p>可搭配衬衫、西装外套，适应多种场合。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>太平鸟</td></tr><tr><td>材质</td><td>TR面料</td></tr><tr><td>版型</td><td>修身</td></tr><tr><td>款式</td><td>商务时尚</td></tr></table></div></div>',
 239.00, 399.00, 180, 210, 1, 0, 0),

(14, 102, '浅色沙弗裤', '森马',
 '/assets/products/goods-14-qian-se-sha-fu-ku.jpg', '[]',
 '浅色沙弗裤，夏日清爽面料，舒适透气。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-14-qian-se-sha-fu-ku.jpg" alt="浅色沙弗裤" /></div><div class="detail-info"><h2>浅色沙弗裤</h2><p class="sub">森马 夏季系列</p></div><div class="detail-desc"><p>浅色系沙弗面料，清爽透气，适合炎热夏季。</p><p>轻薄面料，垂感好，穿着轻盈不闷热。</p><p>休闲直筒版型，百搭实穿。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>森马</td></tr><tr><td>材质</td><td>沙弗面料</td></tr><tr><td>版型</td><td>休闲直筒</td></tr><tr><td>款式</td><td>夏季轻薄</td></tr></table></div></div>',
 129.00, 229.00, 350, 480, 1, 0, 0),

(15, 102, '黑色五分休闲短裤', '优衣库',
 '/assets/products/goods-15-hei-se-wu-fen-xiu-xi-duan-ku.jpg', '[]',
 '黑色五分裤，夏季清凉必备，百搭休闲款式。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-15-hei-se-wu-fen-xiu-xi-duan-ku.jpg" alt="黑色五分休闲短裤" /></div><div class="detail-info"><h2>黑色五分休闲短裤</h2><p class="sub">优衣库 夏季必备</p></div><div class="detail-desc"><p>经典黑色五分裤，清爽利落。</p><p>纯棉面料，透气吸汗，适合运动和日常。</p><p>松紧腰设计，穿着舒适不勒腰。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>优衣库</td></tr><tr><td>材质</td><td>纯棉</td></tr><tr><td>长度</td><td>五分</td></tr><tr><td>腰型</td><td>松紧腰</td></tr><tr><td>款式</td><td>休闲运动</td></tr></table></div></div>',
 79.00, 129.00, 500, 1680, 1, 0, 0),

-- ==================== 男外套 Men's Outerwear (ID 16-21) ====================

(16, 103, '轻薄透气夹克', '优衣库',
 '/assets/products/goods-16-qing-bao-tou-qi-jia-ke.jpg', '[]',
 '防泼水面料，适合春秋季穿着，轻薄便携。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-16-qing-bao-tou-qi-jia-ke.jpg" alt="轻薄透气夹克" /></div><div class="detail-info"><h2>轻薄透气夹克</h2><p class="sub">优衣库 轻便系列</p></div><div class="detail-desc"><p>采用防泼水面料，偶遇小雨也不怕。</p><p>轻薄设计，便于收纳携带，春秋出行必备。</p><p>透气孔设计，加速空气流通，不闷热。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>优衣库</td></tr><tr><td>材质</td><td>锦纶+聚酯纤维</td></tr><tr><td>厚度</td><td>轻薄</td></tr><tr><td>功能</td><td>防泼水 透气</td></tr><tr><td>款式</td><td>休闲运动</td></tr></table></div><div class="detail-size"><h3>尺码说明</h3><table><tr><td>尺码</td><td>胸围(cm)</td><td>肩宽(cm)</td><td>衣长(cm)</td></tr><tr><td>M</td><td>112</td><td>46</td><td>68</td></tr><tr><td>L</td><td>116</td><td>48</td><td>70</td></tr><tr><td>XL</td><td>120</td><td>50</td><td>72</td></tr></table></div></div>',
 299.00, 499.00, 200, 450, 1, 1, 1),

(17, 103, '黑色毛呢大衣', '九牧王',
 '/assets/products/goods-17-hei-se-mao-ning-da-yi.jpg', '[]',
 '优质毛呢面料，保暖挡风，秋冬绅士之选。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-17-hei-se-mao-ning-da-yi.jpg" alt="黑色毛呢大衣" /></div><div class="detail-info"><h2>黑色毛呢大衣</h2><p class="sub">九牧王 秋冬新款</p></div><div class="detail-desc"><p>精选优质毛呢面料，厚实保暖，质感高级。</p><p>经典黑色设计，简约大气，商务休闲皆可。</p><p>精密车缝工艺，走线平整，品质感强。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>九牧王</td></tr><tr><td>材质</td><td>羊毛呢</td></tr><tr><td>厚度</td><td>厚实</td></tr><tr><td>款式</td><td>经典大衣</td></tr></table></div></div>',
 599.00, 999.00, 120, 180, 1, 1, 0),

(18, 103, '军官棉服外套', '骆驼',
 '/assets/products/goods-18-jun-guan-mian-fu-wai-tao.jpg', '[]',
 '军装风格棉服外套，保暖厚实，户外防寒首选。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-18-jun-guan-mian-fu-wai-tao.jpg" alt="军官棉服外套" /></div><div class="detail-info"><h2>军官棉服外套</h2><p class="sub">骆驼 户外系列</p></div><div class="detail-desc"><p>军装风格设计，粗犷硬朗，男性魅力十足。</p><p>加厚棉填充，保暖性能优越，零下也能轻松应对。</p><p>多口袋设计，实用性强。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>骆驼</td></tr><tr><td>填充物</td><td>优质棉</td></tr><tr><td>厚度</td><td>加厚</td></tr><tr><td>款式</td><td>军装工装</td></tr></table></div></div>',
 399.00, 699.00, 150, 220, 1, 0, 1),

(19, 103, '织物流开衫外套', '播',
 '/assets/products/goods-19-zhi-wu-liu-kai-shan-wai-tao.jpg', '[]',
 '针织开衫外套，春秋薄款，慵懒休闲风格。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-19-zhi-wu-liu-kai-shan-wai-tao.jpg" alt="织物流开衫外套" /></div><div class="detail-info"><h2>织物流开衫外套</h2><p class="sub">播 文艺系列</p></div><div class="detail-desc"><p>针织面料开衫外套，柔软亲肤，慵懒文艺风。</p><p>薄款设计，适合春秋早晚温差穿着。</p><p>可单穿或叠穿，百变造型。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>播</td></tr><tr><td>材质</td><td>针织棉</td></tr><tr><td>厚度</td><td>薄款</td></tr><tr><td>款式</td><td>文艺慵懒</td></tr></table></div></div>',
 259.00, 399.00, 180, 260, 1, 0, 0),

(20, 103, '絮绒运动羽绒服', '安踏',
 '/assets/products/goods-20-xu-rong-yun-dong-yu-rong-fu.jpg', '[]',
 '絮绒填充运动羽绒服，轻便保暖，运动出行两相宜。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-20-xu-rong-yun-dong-yu-rong-fu.jpg" alt="絮绒运动羽绒服" /></div><div class="detail-info"><h2>絮绒运动羽绒服</h2><p class="sub">安踏 冬季运动</p></div><div class="detail-desc"><p>精选白鸭绒填充，含绒量高达80%，保暖性能优越。</p><p>轻便设计，不臃肿，运动穿着无负担。</p><p>防风面料，锁住温度。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>安踏</td></tr><tr><td>填充物</td><td>白鸭绒 80%</td></tr><tr><td>面料</td><td>防风尼龙</td></tr><tr><td>厚度</td><td>加厚保暖</td></tr><tr><td>款式</td><td>运动休闲</td></tr></table></div></div>',
 459.00, 799.00, 100, 350, 1, 1, 1),

(21, 103, '工装多口袋夹克', 'Dickies',
 '/assets/products/goods-21-gong-zhuang-duo-kou-dai-jia-ke.jpg', '[]',
 '工装风格多口袋设计夹克，实用帅气两不误。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-21-gong-zhuang-duo-kou-dai-jia-ke.jpg" alt="工装多口袋夹克" /></div><div class="detail-info"><h2>工装多口袋夹克</h2><p class="sub">Dickies 经典工装</p></div><div class="detail-desc"><p>工装风格设计，多口袋设计增加储物空间。</p><p>厚实面料，耐磨耐穿，适合各种户外场景。</p><p>经典款式，永不过时。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>Dickies</td></tr><tr><td>材质</td><td>全棉斜纹</td></tr><tr><td>厚度</td><td>适中偏厚</td></tr><tr><td>款式</td><td>工装休闲</td></tr></table></div></div>',
 349.00, 549.00, 160, 290, 1, 0, 0),

-- ==================== 女裙装 Women's Dresses (ID 22-28) ====================

(22, 201, '法式碎花雪纺连衣裙', 'ZARA',
 '/assets/products/goods-22-fa-shi-sui-hua-xue-fang-lian-yi-qun.jpg', '[]',
 '飘逸雪纺材质，法式优雅风格，碎花设计浪漫唯美。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-22-fa-shi-sui-hua-xue-fang-lian-yi-qun.jpg" alt="法式碎花雪纺连衣裙" /></div><div class="detail-info"><h2>法式碎花雪纺连衣裙</h2><p class="sub">ZARA 春夏新款</p></div><div class="detail-desc"><p>轻盈雪纺面料，飘逸灵动，夏季穿着凉爽舒适。</p><p>精致碎花图案，法式浪漫风情，优雅不死板。</p><p>V领设计修饰脸型，腰部系带收腰显瘦。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>ZARA</td></tr><tr><td>材质</td><td>雪纺</td></tr><tr><td>裙长</td><td>中长裙</td></tr><tr><td>领型</td><td>V领</td></tr><tr><td>款式</td><td>法式浪漫</td></tr></table></div><div class="detail-size"><h3>尺码说明</h3><table><tr><td>尺码</td><td>胸围(cm)</td><td>腰围(cm)</td><td>裙长(cm)</td></tr><tr><td>S</td><td>84</td><td>68</td><td>118</td></tr><tr><td>M</td><td>88</td><td>72</td><td>120</td></tr><tr><td>L</td><td>92</td><td>76</td><td>122</td></tr></table></div></div>',
 299.00, 499.00, 200, 850, 1, 1, 1),

(23, 201, '黑色修身晚礼服', '哥弟',
 '/assets/products/goods-23-hei-se-xiu-shen-wan-li-fu.jpg', '[]',
 '黑色修身晚礼服，优雅显瘦，重要场合首选。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-23-hei-se-xiu-shen-wan-li-fu.jpg" alt="黑色修身晚礼服" /></div><div class="detail-info"><h2>黑色修身晚礼服</h2><p class="sub">哥弟 高端系列</p></div><div class="detail-desc"><p>经典小黑裙设计，优雅永不过时。</p><p>修身版型勾勒身材曲线，显瘦效果一流。</p><p>适合晚宴、派对、约会等正式场合。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>哥弟</td></tr><tr><td>材质</td><td>缎面聚酯</td></tr><tr><td>裙长</td><td>及膝/长裙</td></tr><tr><td>款式</td><td>优雅礼服</td></tr></table></div></div>',
 459.00, 799.00, 80, 120, 1, 1, 0),

(24, 201, '白色蕾丝连衣裙', '欧时力',
 '/assets/products/goods-24-bai-se-lei-si-lian-yi-qun.jpg', '[]',
 '精致蕾丝面料，纯净白色调，优雅名媛气质。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-24-bai-se-lei-si-lian-yi-qun.jpg" alt="白色蕾丝连衣裙" /></div><div class="detail-info"><h2>白色蕾丝连衣裙</h2><p class="sub">欧时力 优雅系列</p></div><div class="detail-desc"><p>精致蕾丝面料，细腻镂空花纹，高级感十足。</p><p>纯净白色调，清新脱俗，提升气质。</p><p>内衬设计避免走光，穿着安心。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>欧时力</td></tr><tr><td>材质</td><td>蕾丝+内衬</td></tr><tr><td>裙长</td><td>中长裙</td></tr><tr><td>款式</td><td>优雅名媛</td></tr></table></div></div>',
 399.00, 699.00, 100, 180, 1, 0, 1),

(25, 201, '粉色波点A字裙', '拉夏贝尔',
 '/assets/products/goods-25-fen-se-bo-dian-A-zi-qun.jpg', '[]',
 '可爱波点图案，粉色少女心，A字版型显瘦。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-25-fen-se-bo-dian-A-zi-qun.jpg" alt="粉色波点A字裙" /></div><div class="detail-info"><h2>粉色波点A字裙</h2><p class="sub">拉夏贝尔 可爱系列</p></div><div class="detail-desc"><p>经典波点图案，活泼可爱，减龄神器。</p><p>A字版型设计，遮胯显瘦，梨形身材友好。</p><p>粉色系少女心爆棚，春夏必备款。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>拉夏贝尔</td></tr><tr><td>材质</td><td>雪纺</td></tr><tr><td>版型</td><td>A字裙</td></tr><tr><td>款式</td><td>可爱减龄</td></tr></table></div></div>',
 199.00, 349.00, 250, 420, 1, 0, 0),

(26, 201, '夜幕几何锥形裙', 'Dizzit',
 '/assets/products/goods-26-ye-mu-ji-he-zhui-xing-qun.jpg', '[]',
 '深色几何图案，个性前卫，锥形设计修饰身形。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-26-ye-mu-ji-he-zhui-xing-qun.jpg" alt="夜幕几何锥形裙" /></div><div class="detail-info"><h2>夜幕几何锥形裙</h2><p class="sub">Dizzit 设计师款</p></div><div class="detail-desc"><p>深色基调，几何图案设计，前卫个性。</p><p>锥形版型，上窄下宽，修饰臀部和大腿线条。</p><p>适合追求独特风格的都市女性。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>Dizzit</td></tr><tr><td>材质</td><td>针织</td></tr><tr><td>版型</td><td>锥形裙</td></tr><tr><td>款式</td><td>前卫个性</td></tr></table></div></div>',
 279.00, 459.00, 150, 200, 1, 0, 0),

(27, 201, '沙龙吊带连衣裙', 'Five Plus',
 '/assets/products/goods-27-sha-long-diao-dai-lian-yi-qun.jpg', '[]',
 '吊带设计清凉性感，沙滩度假风，优雅海岛风情。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-27-sha-long-diao-dai-lian-yi-qun.jpg" alt="沙龙吊带连衣裙" /></div><div class="detail-info"><h2>沙龙吊带连衣裙</h2><p class="sub">Five Plus 度假系列</p></div><div class="detail-desc"><p>吊带设计，清凉透气，适合夏日和海边度假。</p><p>飘逸面料，走动间裙摆灵动，优雅动人。</p><p>可外搭防晒衫，一衣多穿。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>Five Plus</td></tr><tr><td>材质</td><td>雪纺</td></tr><tr><td>裙长</td><td>长裙</td></tr><tr><td>款式</td><td>度假风</td></tr></table></div></div>',
 259.00, 399.00, 180, 310, 1, 0, 0),

(28, 201, '奶茶色吊带长裙', '乐町',
 '/assets/products/goods-28-nai-nai-se-diao-dai-chang-qun.jpg', '[]',
 '温柔奶茶色，吊带设计，简约高级感。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-28-nai-nai-se-diao-dai-chang-qun.jpg" alt="奶茶色吊带长裙" /></div><div class="detail-info"><h2>奶茶色吊带长裙</h2><p class="sub">乐町 简约系列</p></div><div class="detail-desc"><p>温柔的奶茶色调，低饱和高级感。</p><p>吊带设计，清凉简约，叠穿或单穿皆可。</p><p>适合日常通勤、周末出游等多种场景。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>乐町</td></tr><tr><td>材质</td><td>针织棉</td></tr><tr><td>裙长</td><td>长裙</td></tr><tr><td>款式</td><td>简约高级</td></tr></table></div></div>',
 229.00, 359.00, 200, 380, 1, 0, 1),

-- ==================== 女上装 Women's Tops (ID 29-35) ====================

(29, 202, 'V领针织开衫', 'JNBY',
 '/assets/products/goods-29-v-ling-zhen-shan-kai-shan.jpg', '[]',
 '亲肤羊绒混纺，多色可选，V领设计优雅显瘦。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-29-v-ling-zhen-shan-kai-shan.jpg" alt="V领针织开衫" /></div><div class="detail-info"><h2>V领针织开衫</h2><p class="sub">JNBY 品质系列</p></div><div class="detail-desc"><p>羊绒混纺面料，柔软亲肤，保暖不扎肤。</p><p>V领设计拉长脖颈线条，视觉上显瘦。</p><p>多色可选，总有一款适合你。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>JNBY</td></tr><tr><td>材质</td><td>羊绒混纺</td></tr><tr><td>袖长</td><td>长袖</td></tr><tr><td>领型</td><td>V领开衫</td></tr><tr><td>款式</td><td>优雅通勤</td></tr></table></div><div class="detail-size"><h3>尺码说明</h3><table><tr><td>尺码</td><td>胸围(cm)</td><td>肩宽(cm)</td><td>衣长(cm)</td></tr><tr><td>M</td><td>96</td><td>38</td><td>60</td></tr><tr><td>L</td><td>100</td><td>40</td><td>62</td></tr><tr><td>XL</td><td>104</td><td>42</td><td>64</td></tr></table></div></div>',
 259.00, 399.00, 350, 620, 1, 0, 0),

(30, 202, '宽松慵懒风针织衫', 'UR',
 '/assets/products/goods-30-kuan-song-yong-lai-feng-jin-zhi-shan.jpg', '[]',
 'oversize版型，慵懒时尚，舒适宽松穿着无束缚。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-30-kuan-song-yong-lai-feng-jin-zhi-shan.jpg" alt="宽松慵懒风针织衫" /></div><div class="detail-info"><h2>宽松慵懒风针织衫</h2><p class="sub">UR 慵懒系列</p></div><div class="detail-desc"><p>OVERSIZE宽松版型，对身材包容度极高，不挑人。</p><p>慵懒休闲风格，随性自在，时尚感满满。</p><p>柔软针织面料，上身舒适零负担。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>UR</td></tr><tr><td>材质</td><td>针织棉</td></tr><tr><td>版型</td><td>OVERSIZE</td></tr><tr><td>款式</td><td>慵懒休闲</td></tr></table></div></div>',
 179.00, 299.00, 600, 1100, 1, 1, 0),

(31, 202, '纯色娃娃领衬衫', '伊芙丽',
 '/assets/products/goods-31-chun-se-wa-wa-ling-chu-shan.jpg', '[]',
 '可爱娃娃领设计，少女感十足，纯色简约大方。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-31-chun-se-wa-wa-ling-chu-shan.jpg" alt="纯色娃娃领衬衫" /></div><div class="detail-info"><h2>纯色娃娃领衬衫</h2><p class="sub">伊芙丽 少女系列</p></div><div class="detail-desc"><p>娃娃领设计，可爱减龄，少女感爆棚。</p><p>纯色简约设计，好搭配不挑下装。</p><p>优质棉质面料，透气舒适。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>伊芙丽</td></tr><tr><td>材质</td><td>纯棉</td></tr><tr><td>领型</td><td>娃娃领</td></tr><tr><td>款式</td><td>可爱少女</td></tr></table></div></div>',
 149.00, 259.00, 400, 560, 1, 0, 0),

(32, 202, '黑色星星刺绣衬衫', '红袖',
 '/assets/products/goods-32-hei-se-xing-xing-ci-xiu-chu-shan.jpg', '[]',
 '黑色底色搭配精致星星刺绣，个性甜美两不误。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-32-hei-se-xing-xing-ci-xiu-chu-shan.jpg" alt="黑色星星刺绣衬衫" /></div><div class="detail-info"><h2>黑色星星刺绣衬衫</h2><p class="sub">红袖 甜美系列</p></div><div class="detail-desc"><p>黑色底色，精致星星刺绣点缀，酷感与甜美兼具。</p><p>优质面料，舒适透气。</p><p>适合日常约会、逛街等多种场景。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>红袖</td></tr><tr><td>材质</td><td>棉质</td></tr><tr><td>领型</td><td>标准领</td></tr><tr><td>款式</td><td>甜美酷感</td></tr></table></div></div>',
 169.00, 289.00, 320, 420, 1, 0, 0),

(33, 202, '白色带扭结上衣', 'Cocoon',
 '/assets/products/goods-33-bai-se-dai-niu-jie-shang-yi.jpg', '[]',
 '白色扭结设计，简约而不简单，优雅独特。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-33-bai-se-dai-niu-jie-shang-yi.jpg" alt="白色带扭结上衣" /></div><div class="detail-info"><h2>白色带扭结上衣</h2><p class="sub">Cocoon 设计师款</p></div><div class="detail-desc"><p>腰部扭结设计，增加设计感，打破单调。</p><p>纯净白色调，简约大气。</p><p>搭配裙装或裤装都很出彩。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>Cocoon</td></tr><tr><td>材质</td><td>雪纺</td></tr><tr><td>款式</td><td>设计感通勤</td></tr></table></div></div>',
 199.00, 329.00, 280, 340, 1, 0, 0),

(34, 202, '奢华蓝衬衫', '诗篇',
 '/assets/products/goods-34-she-hao-lan-chu-shan.jpg', '[]',
 '深邃蓝色调，轻奢面料，气质通勤首选。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-34-she-hao-lan-chu-shan.jpg" alt="奢华蓝衬衫" /></div><div class="detail-info"><h2>奢华蓝衬衫</h2><p class="sub">诗篇 通勤系列</p></div><div class="detail-desc"><p>深邃蓝色调，低调奢华，提升气场。</p><p>优质面料，挺括有型，彰显品质。</p><p>适合职场通勤、商务会议等正式场合。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>诗篇</td></tr><tr><td>材质</td><td>缎面</td></tr><tr><td>领型</td><td>翻领</td></tr><tr><td>款式</td><td>轻奢通勤</td></tr></table></div></div>',
 289.00, 489.00, 180, 240, 1, 1, 0),

(35, 202, '花灰色毛衣', '之禾',
 '/assets/products/goods-35-hua-hui-se-mao-yi.jpg', '[]',
 '花灰色时尚配色，粗棒针毛衣，温暖慵懒。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-35-hua-hui-se-mao-yi.jpg" alt="花灰色毛衣" /></div><div class="detail-info"><h2>花灰色毛衣</h2><p class="sub">之禾 温暖系列</p></div><div class="detail-desc"><p>花灰色配色，时尚低调，粗棒针织法有质感。</p><p>厚实保暖，秋冬季节温暖与时尚兼具。</p><p>慵懒风格，舒适无束缚感。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>之禾</td></tr><tr><td>材质</td><td>羊毛混纺</td></tr><tr><td>袖长</td><td>长袖</td></tr><tr><td>款式</td><td>慵懒保暖</td></tr></table></div></div>',
 329.00, 529.00, 150, 190, 1, 0, 0),

-- ==================== 女裤装 Women's Bottoms (ID 36-41) ====================

(36, 203, '高腰阔腿休闲裤', 'Lily',
 '/assets/products/goods-36-gao-yao-kuo-tui-xiu-xian-ku.jpg', '[]',
 '垂坠感面料，修饰腿型显瘦，高腰设计显腰细。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-36-gao-yao-kuo-tui-xiu-xian-ku.jpg" alt="高腰阔腿休闲裤" /></div><div class="detail-info"><h2>高腰阔腿休闲裤</h2><p class="sub">Lily 显瘦系列</p></div><div class="detail-desc"><p>高腰设计，提升腰线，显腿长效果一流。</p><p>阔腿版型遮肉显瘦，对各种身材友好。</p><p>垂坠感面料，行走间飘逸灵动。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>Lily</td></tr><tr><td>材质</td><td>西装面料</td></tr><tr><td>版型</td><td>高腰阔腿</td></tr><tr><td>腰型</td><td>高腰</td></tr><tr><td>款式</td><td>显瘦百搭</td></tr></table></div><div class="detail-size"><h3>尺码说明</h3><table><tr><td>尺码</td><td>腰围(cm)</td><td>臀围(cm)</td><td>裤长(cm)</td></tr><tr><td>S</td><td>64</td><td>92</td><td>98</td></tr><tr><td>M</td><td>68</td><td>96</td><td>100</td></tr><tr><td>L</td><td>72</td><td>100</td><td>102</td></tr></table></div></div>',
 189.00, 329.00, 450, 780, 1, 0, 1),

(37, 203, '白色直筒长裤', '伊芙丽',
 '/assets/products/goods-37-bai-se-zhi-tong-chang-ku.jpg', '[]',
 '纯净白色直筒裤，简约百搭，通勤休闲两用。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-37-bai-se-zhi-tong-chang-ku.jpg" alt="白色直筒长裤" /></div><div class="detail-info"><h2>白色直筒长裤</h2><p class="sub">伊芙丽 百搭系列</p></div><div class="detail-desc"><p>纯净白色调，清爽干净，春夏秋三季可穿。</p><p>直筒版型，不挑腿型，利落干练。</p><p>百搭款式，可搭配各种上衣。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>伊芙丽</td></tr><tr><td>材质</td><td>TR面料</td></tr><tr><td>版型</td><td>直筒</td></tr><tr><td>款式</td><td>百搭通勤</td></tr></table></div></div>',
 169.00, 299.00, 380, 520, 1, 0, 0),

(38, 203, '黑色小脚裤', 'Five Plus',
 '/assets/products/goods-38-hei-se-xiao-jiao-ku.jpg', '[]',
 '黑色小脚裤，修身显瘦，百搭经典款。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-38-hei-se-xiao-jiao-ku.jpg" alt="黑色小脚裤" /></div><div class="detail-info"><h2>黑色小脚裤</h2><p class="sub">Five Plus 经典款</p></div><div class="detail-desc"><p>经典黑色小脚裤，显瘦百搭，衣橱必备款。</p><p>修身版型勾勒腿部线条，拉长身材比例。</p><p>弹性面料，穿着舒适不紧绷。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>Five Plus</td></tr><tr><td>材质</td><td>棉+氨纶</td></tr><tr><td>版型</td><td>修身小脚</td></tr><tr><td>款式</td><td>百搭经典</td></tr></table></div></div>',
 179.00, 299.00, 420, 680, 1, 0, 0),

(39, 203, '蓝色高腰百褶裙', '乐町',
 '/assets/products/goods-39-lan-se-gao-yao-bai-zhe-qun.jpg', '[]',
 '蓝色高腰百褶裙，优雅灵动，修饰腰腹显瘦。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-39-lan-se-gao-yao-bai-zhe-qun.jpg" alt="蓝色高腰百褶裙" /></div><div class="detail-info"><h2>蓝色高腰百褶裙</h2><p class="sub">乐町 优雅系列</p></div><div class="detail-desc"><p>高腰设计，提升腰线，优化身材比例。</p><p>百褶裙摆，灵动优雅，行走间女人味十足。</p><p>蓝色调清新脱俗，春夏秋皆可穿。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>乐町</td></tr><tr><td>材质</td><td>雪纺/针织</td></tr><tr><td>版型</td><td>高腰百褶</td></tr><tr><td>款式</td><td>优雅灵动</td></tr></table></div></div>',
 219.00, 369.00, 280, 390, 1, 0, 0),

(40, 203, '转色直摆裙', 'Cocoon',
 '/assets/products/goods-40-zhuan-se-zhi-bai-qun.jpg', '[]',
 '渐变转色设计，直摆裙型，时尚有个性。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-40-zhuan-se-zhi-bai-qun.jpg" alt="转色直摆裙" /></div><div class="detail-info"><h2>转色直摆裙</h2><p class="sub">Cocoon 设计师款</p></div><div class="detail-desc"><p>渐变转色设计，独特别致，吸睛度满分。</p><p>直摆版型，利落干练，适合职场女性。</p><p>设计师款，撞衫率极低。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>Cocoon</td></tr><tr><td>材质</td><td>针织</td></tr><tr><td>版型</td><td>直摆裙</td></tr><tr><td>款式</td><td>设计师款</td></tr></table></div></div>',
 259.00, 429.00, 120, 150, 1, 0, 0),

(41, 203, '卡其迷你裙', '太平鸟',
 '/assets/products/goods-41-ka-qi-mi-ni-qun.jpg', '[]',
 '经典卡其色，迷你短裙，清爽百搭。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-41-ka-qi-mi-ni-qun.jpg" alt="卡其迷你裙" /></div><div class="detail-info"><h2>卡其迷你裙</h2><p class="sub">太平鸟 活力系列</p></div><div class="detail-desc"><p>经典卡其色调，百搭不出错。</p><p>迷你短裙长度，清爽显腿长。</p><p>适合春夏秋三季，可搭配T恤、衬衫等多种上衣。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>太平鸟</td></tr><tr><td>材质</td><td>棉质</td></tr><tr><td>裙长</td><td>迷你短裙</td></tr><tr><td>款式</td><td>百搭活力</td></tr></table></div></div>',
 149.00, 259.00, 350, 480, 1, 0, 0),

-- ==================== 运动鞋 Sports Shoes (ID 42-47) ====================

(42, 301, '复古运动跑步鞋', 'Nike',
 '/assets/products/goods-42-fu-gu-yun-dong-pao-bu-xie.jpg', '[]',
 '轻量化设计，缓震科技底，复古时尚与性能兼顾。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-42-fu-gu-yun-dong-pao-bu-xie.jpg" alt="复古运动跑步鞋" /></div><div class="detail-info"><h2>复古运动跑步鞋</h2><p class="sub">Nike Air 系列</p></div><div class="detail-desc"><p>复古造型，时尚百搭，街头与运动皆可。</p><p>AIR缓震科技，减轻运动冲击，保护膝盖。</p><p>透气网面设计，保持脚部干爽。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>Nike</td></tr><tr><td>鞋面</td><td>透气网布+合成革</td></tr><tr><td>鞋底</td><td>Air缓震橡胶</td></tr><tr><td>功能</td><td>减震 透气 轻便</td></tr><tr><td>款式</td><td>复古运动</td></tr></table></div><div class="detail-size"><h3>尺码说明</h3><table><tr><td>尺码</td><td>脚长(cm)</td></tr><tr><td>40</td><td>25.0</td></tr><tr><td>41</td><td>25.5</td></tr><tr><td>42</td><td>26.0</td></tr><tr><td>43</td><td>26.5</td></tr><tr><td>44</td><td>27.0</td></tr></table></div></div>',
 459.00, 699.00, 300, 1350, 1, 1, 0),

(43, 301, '黑白拼接篮球鞋', 'Adidas',
 '/assets/products/goods-43-hei-bai-pin-jie-lan-qiu-xie.jpg', '[]',
 '经典黑白配色，篮球场上的时尚焦点。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-43-hei-bai-pin-jie-lan-qiu-xie.jpg" alt="黑白拼接篮球鞋" /></div><div class="detail-info"><h2>黑白拼接篮球鞋</h2><p class="sub">Adidas 篮球系列</p></div><div class="detail-desc"><p>经典黑白撞色，简洁有力，时尚感强。</p><p>专业篮球鞋设计，抓地力强，支撑性好。</p><p>高帮设计保护脚踝，适合篮球运动。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>Adidas</td></tr><tr><td>鞋面</td><td>皮革+合成材料</td></tr><tr><td>鞋帮</td><td>高帮</td></tr><tr><td>功能</td><td>抓地 支撑 保护</td></tr><tr><td>款式</td><td>专业篮球</td></tr></table></div></div>',
 599.00, 899.00, 150, 520, 1, 0, 1),

(44, 301, '硬岩登山徒步鞋', '探路者',
 '/assets/products/goods-44-ying-yan-deng-shan-tu-bu-xie.jpg', '[]',
 '硬核户外风格，防滑耐磨，登山徒步全能选手。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-44-ying-yan-deng-shan-tu-bu-xie.jpg" alt="硬岩登山徒步鞋" /></div><div class="detail-info"><h2>硬岩登山徒步鞋</h2><p class="sub">探路者 户外系列</p></div><div class="detail-desc"><p>专业户外鞋底，抓地力强，适合各种地形。</p><p>耐磨鞋面，经久耐用。</p><p>防水内衬设计，雨天山路也能应对。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>探路者</td></tr><tr><td>鞋面</td><td>耐磨反绒皮+网布</td></tr><tr><td>鞋底</td><td>橡胶防滑底</td></tr><tr><td>功能</td><td>防水 防滑 耐磨</td></tr><tr><td>款式</td><td>户外登山</td></tr></table></div></div>',
 389.00, 599.00, 100, 180, 1, 0, 0),

(45, 301, '泡棉减震跑鞋', '安踏',
 '/assets/products/goods-45-pao-mian-jian-zhen-pao-xie.jpg', '[]',
 '泡棉中底缓震技术，轻盈回弹，跑步更轻松。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-45-pao-mian-jian-zhen-pao-xie.jpg" alt="泡棉减震跑鞋" /></div><div class="detail-info"><h2>泡棉减震跑鞋</h2><p class="sub">安踏 跑步系列</p></div><div class="detail-desc"><p>创新泡棉中底，轻盈柔软，回弹力强。</p><p>透气网面设计，排汗透气不闷脚。</p><p>适合日常跑步和健身训练。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>安踏</td></tr><tr><td>鞋面</td><td>透气网布</td></tr><tr><td>中底</td><td>泡棉缓震</td></tr><tr><td>功能</td><td>减震 回弹 透气</td></tr><tr><td>款式</td><td>跑步训练</td></tr></table></div></div>',
 299.00, 499.00, 250, 680, 1, 0, 0),

(46, 301, '网球训练帆布鞋', '回力',
 '/assets/products/goods-46-wang-qiu-xun-lian-fan-bu-xie.jpg', '[]',
 '经典帆布鞋型，平价百搭，训练休闲两用。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-46-wang-qiu-xun-lian-fan-bu-xie.jpg" alt="网球训练帆布鞋" /></div><div class="detail-info"><h2>网球训练帆布鞋</h2><p class="sub">回力 经典系列</p></div><div class="detail-desc"><p>经典帆布鞋型，透气舒适，价格实惠。</p><p>橡胶鞋底，防滑耐磨。</p><p>适合网球训练、日常休闲等多种场景。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>可知</td><td>回力</td></tr><tr><td>鞋面</td><td>帆布</td></tr><tr><td>鞋底</td><td>橡胶底</td></tr><tr><td>款式</td><td>训练休闲</td></tr></table></div></div>',
 89.00, 159.00, 500, 2200, 1, 0, 0),

(47, 301, '黑色缓震训练鞋', '李宁',
 '/assets/products/goods-47-hei-se-huan-zhen-xun-lian-xie.jpg', '[]',
 '专业训练鞋设计，缓震支撑，健身房必备。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-47-hei-se-huan-zhen-xun-lian-xie.jpg" alt="黑色缓震训练鞋" /></div><div class="detail-info"><h2>黑色缓震训练鞋</h2><p class="sub">李宁 训练系列</p></div><div class="detail-desc"><p>训练专用鞋底，多方向抓地力强。</p><p>缓震中底，保护关节，适合各种健身动作。</p><p>黑色简约设计，百搭实穿。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>李宁</td></tr><tr><td>鞋面</td><td>合成革+网布</td></tr><tr><td>中底</td><td>缓震科技</td></tr><tr><td>功能</td><td>缓震 支撑 多向抓地</td></tr><tr><td>款式</td><td>健身训练</td></tr></table></div></div>',
 279.00, 459.00, 300, 890, 1, 1, 0),

-- ==================== 女鞋 Women's Shoes (ID 48-52) ====================

(48, 302, '尖头细跟通勤高跟鞋', '热风',
 '/assets/products/goods-48-jian-tou-xi-gen-tong-qin-gao-gen.jpg', '[]',
 '5cm跟高，久站不累，优雅通勤之选。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-48-jian-tou-xi-gen-tong-qin-gao-gen.jpg" alt="尖头细跟通勤高跟鞋" /></div><div class="detail-info"><h2>尖头细跟通勤高跟鞋</h2><p class="sub">热风 通勤系列</p></div><div class="detail-desc"><p>尖头设计，视觉上拉长腿部线条，显瘦显高。</p><p>5cm细跟，优雅舒适，久站也不累脚。</p><p>优质PU材质，柔软不磨脚。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>热风</td></tr><tr><td>材质</td><td>PU+合成革</td></tr><tr><td>跟高</td><td>5cm细跟</td></tr><tr><td>鞋头</td><td>尖头</td></tr><tr><td>款式</td><td>通勤优雅</td></tr></table></div><div class="detail-size"><h3>尺码说明</h3><table><tr><td>尺码</td><td>脚长(cm)</td></tr><tr><td>35</td><td>22.5</td></tr><tr><td>36</td><td>23.0</td></tr><tr><td>37</td><td>23.5</td></tr><tr><td>38</td><td>24.0</td></tr></table></div></div>',
 259.00, 399.00, 250, 920, 1, 1, 1),

(49, 302, '坡跟平底休闲淑女鞋', '卓诗尼',
 '/assets/products/goods-49-po-gen-ping-di-xiu-xiu-shu-nv-xie.jpg', '[]',
 '坡跟设计舒适增高，平底款式健步如飞。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-49-po-gen-ping-di-xiu-xiu-shu-nv-xie.jpg" alt="坡跟平底休闲淑女鞋" /></div><div class="detail-info"><h2>坡跟平底休闲淑女鞋</h2><p class="sub">卓诗尼 舒适系列</p></div><div class="detail-desc"><p>坡跟设计，舒适增高，行走更稳。</p><p>平底款式，柔软鞋垫，久走不累。</p><p>优雅淑女风格，适合日常通勤和逛街。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>卓诗尼</td></tr><tr><td>材质</td><td>PU</td></tr><tr><td>跟高</td><td>坡跟3cm</td></tr><tr><td>款式</td><td>舒适淑女</td></tr></table></div></div>',
 199.00, 329.00, 300, 750, 1, 0, 0),

(50, 302, '纯皮系带英伦皮鞋', '红蜻蜓',
 '/assets/products/goods-50-chun-pi-xi-dai-ying-lun-pi-xie.jpg', '[]',
 '头层牛皮材质，英伦风格，商务休闲两相宜。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-50-chun-pi-xi-dai-ying-lun-pi-xie.jpg" alt="纯皮系带英伦皮鞋" /></div><div class="detail-info"><h2>纯皮系带英伦皮鞋</h2><p class="sub">红蜻蜓 商务系列</p></div><div class="detail-desc"><p>头层牛皮材质，质感高级，透气舒适。</p><p>英伦风格设计，系带款正式感强。</p><p>适合商务场合和正式场合穿着。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>红蜻蜓</td></tr><tr><td>材质</td><td>头层牛皮</td></tr><tr><td>跟高</td><td>平底</td></tr><tr><td>款式</td><td>英伦商务</td></tr></table></div></div>',
 329.00, 529.00, 180, 380, 1, 1, 0),

(51, 302, '夏花流苏凉鞋', '他她',
 '/assets/products/goods-51-xia-hua-liu-su-liang-xie.jpg', '[]',
 '流苏装饰夏日凉鞋，时尚优雅，度假必备。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-51-xia-hua-liu-su-liang-xie.jpg" alt="夏花流苏凉鞋" /></div><div class="detail-info"><h2>夏花流苏凉鞋</h2><p class="sub">他她 夏季系列</p></div><div class="detail-desc"><p>精致流苏装饰，灵动优雅，夏日气息满满。</p><p>细带设计，修饰脚型，露出纤细脚踝。</p><p>适合海边度假、约会逛街等多种场合。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>他她</td></tr><tr><td>材质</td><td>PU+流苏</td></tr><tr><td>跟型</td><td>平底/低跟</td></tr><tr><td>款式</td><td>优雅度假</td></tr></table></div></div>',
 219.00, 359.00, 220, 420, 1, 0, 1),

(52, 302, '水晶粗头鞋', '珂卡芙',
 '/assets/products/goods-52-shui-jing-cu-tou-xie.jpg', '[]',
 '水晶装饰粗头设计，复古时尚，舒适好走。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-52-shui-jing-cu-tou-xie.jpg" alt="水晶粗头鞋" /></div><div class="detail-info"><h2>水晶粗头鞋</h2><p class="sub">珂卡芙 复古系列</p></div><div class="detail-desc"><p>水晶装饰点缀，低调奢华，增添时尚感。</p><p>粗头设计，复古回潮，穿着舒适。</p><p>粗跟设计，稳固好走，不累脚。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>珂卡芙</td></tr><tr><td>材质</td><td>PU+水晶</td></tr><tr><td>跟型</td><td>粗跟4cm</td></tr><tr><td>款式</td><td>复古时尚</td></tr></table></div></div>',
 239.00, 399.00, 200, 360, 1, 0, 0),

-- ==================== 配件 Accessories (ID 53-59) ====================

(53, 401, '韩版百搭棒球帽', 'MLB',
 '/assets/products/goods-53-han-ban-bai-da-mang-mao.jpg', '[]',
 '纯棉面料，可调节帽围，经典棒球帽款式。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-53-han-ban-bai-da-mang-mao.jpg" alt="韩版百搭棒球帽" /></div><div class="detail-info"><h2>韩版百搭棒球帽</h2><p class="sub">MLB 潮流系列</p></div><div class="detail-desc"><p>经典棒球帽版型，帽檐可调节，适应不同头围。</p><p>精选纯棉面料，透气吸汗，佩戴舒适。</p><p>简约百搭，可搭配各种穿搭风格。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>MLB</td></tr><tr><td>材质</td><td>纯棉</td></tr><tr><td>帽围</td><td>可调节(56-60cm)</td></tr><tr><td>款式</td><td>经典百搭</td></tr></table></div></div>',
 89.00, 149.00, 800, 2300, 1, 0, 0),

(54, 401, '织物小球毛线帽', '飞跃',
 '/assets/products/goods-54-zhi-wu-xiao-qiu-mao-xian-mao.jpg', '[]',
 '可爱小球装饰毛线帽，秋冬保暖，俏皮减龄。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-54-zhi-wu-xiao-qiu-mao-xian-mao.jpg" alt="织物小球毛线帽" /></div><div class="detail-info"><h2>织物小球毛线帽</h2><p class="sub">飞跃 秋冬系列</p></div><div class="detail-desc"><p>可爱毛线球装饰，俏皮灵动，少女感十足。</p><p>优质毛线面料，厚实保暖，秋冬必备。</p><p>均码设计，弹力适中，各种头围都能戴。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>飞跃</td></tr><tr><td>材质</td><td>毛线</td></tr><tr><td>尺码</td><td>均码</td></tr><tr><td>款式</td><td>可爱保暖</td></tr></table></div></div>',
 49.00, 89.00, 600, 1680, 1, 0, 0),

(55, 302, '通勤手提单肩两用包', '小CK',
 '/assets/products/goods-55-tong-yong-shou-ti-dan-jian-liang-yong-bao.jpg', '[]',
 'PU材质，大容量分层设计，通勤首选。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-55-tong-yong-shou-ti-dan-jian-liang-yong-bao.jpg" alt="通勤手提单肩两用包" /></div><div class="detail-info"><h2>通勤手提单肩两用包</h2><p class="sub">小CK 通勤系列</p></div><div class="detail-desc"><p>手提+单肩两用设计，适应不同场合需求。</p><p>大容量主袋+多个分层口袋，收纳有序。</p><p>简约设计，优雅大气，通勤必备。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>小CK</td></tr><tr><td>材质</td><td>PU</td></tr><tr><td>尺寸</td><td>约30x22x12cm</td></tr><tr><td>款式</td><td>通勤两用</td></tr></table></div></div>',
 229.00, 399.00, 400, 1680, 1, 1, 1),

(56, 402, '背套小方框链条包', '红蜻蜓',
 '/assets/products/goods-56-bei-tao-xiao-fang-kuang-lian-tiao-bao.jpg', '[]',
 '链条装饰小方包，精致时尚，可斜挎可单肩。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-56-bei-tao-xiao-fang-kuang-lian-tiao-bao.jpg" alt="背套小方框链条包" /></div><div class="detail-info"><h2>背套小方框链条包</h2><p class="sub">红蜻蜓 时尚系列</p></div><div class="detail-desc"><p>精致链条装饰，时尚感强，提升整体造型感。</p><p>小方包设计，简约大气，斜挎单肩都好看。</p><p>优质PU材质，耐磨耐用。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>红蜻蜓</td></tr><tr><td>材质</td><td>PU+金属链条</td></tr><tr><td>尺寸</td><td>约22x15x8cm</td></tr><tr><td>款式</td><td>精致时尚</td></tr></table></div></div>',
 189.00, 329.00, 350, 980, 1, 0, 0),

(57, 402, '皮带葡萄石手包', '啄木鸟',
 '/assets/products/goods-57-pi-dai-pu-tao-shi-shou-bao.jpg', '[]',
 '皮带装饰配葡萄石点缀，高端大气，晚宴首选。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-57-pi-dai-pu-tao-shi-shou-bao.jpg" alt="皮带葡萄石手包" /></div><div class="detail-info"><h2>皮带葡萄石手包</h2><p class="sub">啄木鸟 高端系列</p></div><div class="detail-desc"><p>皮带装饰设计，葡萄石点缀，高级感满满。</p><p>手拿款式，适合晚宴、派对等正式场合。</p><p>精致做工，彰显品质与品味。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>啄木鸟</td></tr><tr><td>材质</td><td>PU+金属</td></tr><tr><td>款式</td><td>晚宴手包</td></tr></table></div></div>',
 299.00, 499.00, 120, 280, 1, 0, 0),

(58, 402, '简约黑色手拿包', '蔻驰',
 '/assets/products/goods-58-jian-yue-hei-se-shou-na-bao.jpg', '[]',
 '极简黑色手拿包，商务休闲两用，低调有质感。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-58-jian-yue-hei-se-shou-na-bao.jpg" alt="简约黑色手拿包" /></div><div class="detail-info"><h2>简约黑色手拿包</h2><p class="sub">蔻驰 经典系列</p></div><div class="detail-desc"><p>极简黑色设计，低调大气，永不过时。</p><p>手拿或夹持皆可，商务休闲两用。</p><p>优质皮革材质，手感细腻有质感。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>蔻驰</td></tr><tr><td>材质</td><td>PVC/皮革</td></tr><tr><td>尺寸</td><td>约28x18x5cm</td></tr><tr><td>款式</td><td>简约商务</td></tr></table></div></div>',
 459.00, 799.00, 80, 160, 1, 1, 0),

(59, 402, '羊皮圆件手提贝壳包', '迪桑娜',
 '/assets/products/goods-59-yang-pi-yuan-jian-shou-ti-bei-ke-bao.jpg', '[]',
 '头层羊皮材质，贝壳造型独特，手提优雅大方。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-59-yang-pi-yuan-jian-shou-ti-bei-ke-bao.jpg" alt="羊皮圆件手提贝壳包" /></div><div class="detail-info"><h2>羊皮圆件手提贝壳包</h2><p class="sub">迪桑娜 高端系列</p></div><div class="detail-desc"><p>头层羊皮材质，柔软细腻，质感奢华。</p><p>贝壳造型独特设计，优雅吸睛。</p><p>手提款式，大方得体，适合多种场合。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>迪桑娜</td></tr><tr><td>材质</td><td>头层羊皮</td></tr><tr><td>尺寸</td><td>约32x24x14cm</td></tr><tr><td>款式</td><td>优雅高端</td></tr></table></div></div>',
 599.00, 999.00, 60, 90, 1, 0, 1),

-- ==================== 内衣/家居 Underwear & Loungewear (ID 60-64) ====================

(60, 0, '无痕棉质秋衣套装', '红豆',
 '/assets/products/goods-60-wu-hen-mian-zhi-qiu-yi-tao-zhuang.jpg', '[]',
 '无痕设计亲肤舒适，纯棉面料保暖透气，家居必备。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-60-wu-hen-mian-zhi-qiu-yi-tao-zhuang.jpg" alt="无痕棉质秋衣套装" /></div><div class="detail-info"><h2>无痕棉质秋衣套装</h2><p class="sub">红豆 家居系列</p></div><div class="detail-desc"><p>无痕工艺，无异物感，穿着舒适如无物。</p><p>纯棉面料，吸汗透气，保暖不闷热。</p><p>上下套装设计，方便家居穿着。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>红豆</td></tr><tr><td>材质</td><td>95%棉 5%氨纶</td></tr><tr><td>款式</td><td>无痕保暖套装</td></tr><tr><td>尺码</td><td>M/L/XL/XXL</td></tr></table></div></div>',
 99.00, 179.00, 500, 980, 1, 0, 0),

(61, 0, '童裤细蕾丝内衣套装', '安莉芳',
 '/assets/products/goods-61-tong-kua-xi-lei-si-nei-yi-tao-zhuang.jpg', '[]',
 '精致蕾丝装饰，可爱又舒适，亲子家居首选。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-61-tong-kua-xi-lei-si-nei-yi-tao-zhuang.jpg" alt="童裤细蕾丝内衣套装" /></div><div class="detail-info"><h2>童裤细蕾丝内衣套装</h2><p class="sub">安莉芳 亲子系列</p></div><div class="detail-desc"><p>精致蕾丝装饰，优雅可爱，少女心满满。</p><p>柔软面料，贴身舒适，无刺激感。</p><p>适合作为亲子装或家居服穿着。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>安莉芳</td></tr><tr><td>材质</td><td>棉质+蕾丝</td></tr><tr><td>款式</td><td>蕾丝套装</td></tr><tr><td>尺码</td><td>M/L/XL</td></tr></table></div></div>',
 129.00, 229.00, 350, 520, 1, 0, 0),

(62, 0, '家树童裤两件套装', '三枪',
 '/assets/products/goods-62-jia-shu-tong-kua-liang-jian-tao-zhuang.jpg', '[]',
 '两件套装经济实惠，舒适面料，家居实用之选。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-62-jia-shu-tong-kua-liang-jian-tao-zhuang.jpg" alt="家树童裤两件套装" /></div><div class="detail-info"><h2>家树童裤两件套装</h2><p class="sub">三枪 家居系列</p></div><div class="detail-desc"><p>两件套装组合，购买实惠换洗方便。</p><p>柔软棉质面料，亲肤舒适。</p><p>经典款式，居家外出皆可穿。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>三枪</td></tr><tr><td>材质</td><td>纯棉</td></tr><tr><td>件数</td><td>2件套</td></tr><tr><td>款式</td><td>实用家居</td></tr></table></div></div>',
 89.00, 159.00, 450, 680, 1, 0, 0),

(63, 0, '晨莫新款居家服', '芬腾',
 '/assets/goods-63-chen-mo-xin-kuan-ju-jia-fu.jpg', '[]',
 '莫兰迪色系居家服，柔软舒适，优雅居家。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-63-chen-mo-xin-kuan-ju-jia-fu.jpg" alt="晨莫新款居家服" /></div><div class="detail-info"><h2>晨莫新款居家服</h2><p class="sub">芬腾 居家系列</p></div><div class="detail-desc"><p>莫兰迪配色，温柔优雅，居家也要美美哒。</p><p>优质针织面料，柔软透气，穿着舒适。</p><p>分体套装设计，活动方便。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>芬腾</td></tr><tr><td>材质</td><td>针织棉</td></tr><tr><td>款式</td><td>优雅居家</td></tr><tr><td>尺码</td><td>M/L/XL</td></tr></table></div></div>',
 139.00, 239.00, 380, 540, 1, 0, 1),

(64, 0, '番纱睡裙睡衣套装', '秋鹿',
 '/assets/products/goods-64-fan-sha-shui-qun-shui-yi-tao-zhuang.jpg', '[]',
 '番纱面料轻盈飘逸，优雅睡裙套装，睡眠也是一种仪式感。',
 '<div class="goods-detail"><div class="detail-banner"><img src="/assets/products/goods-64-fan-sha-shui-qun-shui-yi-tao-zhuang.jpg" alt="番纱睡裙睡衣套装" /></div><div class="detail-info"><h2>番纱睡裙睡衣套装</h2><p class="sub">秋鹿 睡眠系列</p></div><div class="detail-desc"><p>番纱面料，轻盈飘逸，触感丝滑。</p><p>优雅设计，睡眠也是一种享受。</p><p>套装设计，实用美观，礼盒包装适合送礼。</p></div><div class="detail-specs"><h3>商品参数</h3><table><tr><td>品牌</td><td>秋鹿</td></tr><tr><td>材质</td><td>番纱</td></tr><tr><td>款式</td><td>优雅睡裙套装</td></tr><tr><td>尺码</td><td>M/L/XL</td></tr></table></div></div>',
 159.00, 269.00, 300, 420, 1, 0, 0);

-- ============================================================
-- 3. 商品 SKU 数据
-- ============================================================

INSERT INTO sku (goods_id, spec, price, stock, sales) VALUES

-- T恤(1) SKU: 颜色x尺码
('1', '{"颜色":"白色","尺码":"M"}', 89.00, 100, 300),
('1', '{"颜色":"白色","尺码":"L"}', 89.00, 100, 400),
('1', '{"颜色":"白色","尺码":"XL"}', 89.00, 80, 200),
('1', '{"颜色":"黑色","尺码":"M"}', 89.00, 100, 300),
('1', '{"颜色":"黑色","尺码":"L"}', 89.00, 100, 200),
('1', '{"颜色":"浅灰","尺码":"M"}', 89.00, 60, 80),
('1', '{"颜色":"浅灰","尺码":"XL"}', 89.00, 60, 20),

-- Polo衫(2) SKU
('2', '{"颜色":"藏青","尺码":"M"}', 129.00, 80, 200),
('2', '{"颜色":"藏青","尺码":"L"}', 129.00, 80, 200),
('2', '{"颜色":"藏青","尺码":"XL"}', 129.00, 60, 150),
('2', '{"颜色":"白色","尺码":"M"}', 129.00, 70, 180),
('2', '{"颜色":"白色","尺码":"L"}', 129.00, 70, 100),

-- 纯棉白色T恤(3) SKU
('3', '{"颜色":"白色","尺码":"M"}', 69.00, 150, 600),
('3', '{"颜色":"白色","尺码":"L"}', 69.00, 150, 700),
('3', '{"颜色":"白色","尺码":"XL"}', 69.00, 150, 500),
('3', '{"颜色":"白色","尺码":"XXL"}', 69.00, 150, 300),

-- 黑色宽松T恤(4) SKU
('4', '{"颜色":"黑色","尺码":"M"}', 119.00, 90, 280),
('4', '{"颜色":"黑色","尺码":"L"}', 119.00, 90, 320),
('4', '{"颜色":"黑色","尺码":"XL"}', 119.00, 90, 250),
('4', '{"颜色":"黑色","尺码":"XXL"}', 119.00, 80, 100),

-- 奶茶色Polo(5) SKU
('5', '{"颜色":"奶茶色","尺码":"M"}', 149.00, 70, 120),
('5', '{"颜色":"奶茶色","尺码":"L"}', 149.00, 70, 150),
('5', '{"颜色":"奶茶色","尺码":"XL"}', 149.00, 70, 100),
('5', '{"颜色":"米色","尺码":"M"}', 149.00, 70, 50),

-- 休闲棉质衬衫(6) SKU
('6', '{"颜色":"浅蓝","尺码":"M"}', 139.00, 100, 220),
('6', '{"颜色":"浅蓝","尺码":"L"}', 139.00, 100, 260),
('6', '{"颜色":"浅蓝","尺码":"XL"}', 139.00, 100, 180),
('6', '{"颜色":"白色","尺码":"M"}', 139.00, 100, 100),

-- 亨利领T恤(7) SKU
('7', '{"颜色":"藏青","尺码":"M"}', 99.00, 120, 180),
('7', '{"颜色":"藏青","尺码":"L"}', 99.00, 120, 200),
('7', '{"颜色":"藏青","尺码":"XL"}', 99.00, 110, 120),
('7', '{"颜色":"灰色","尺码":"M"}', 99.00, 100, 80),

-- 长袖针织衫(8) SKU
('8', '{"颜色":"深灰","尺码":"M"}', 159.00, 80, 100),
('8', '{"颜色":"深灰","尺码":"L"}', 159.00, 80, 120),
('8', '{"颜色":"深灰","尺码":"XL"}', 159.00, 80, 80),
('8', '{"颜色":"黑色","尺码":"M"}', 159.00, 80, 40),

-- 牛仔裤(9) SKU
('9', '{"颜色":"深蓝","尺码":"30"}', 199.00, 80, 250),
('9', '{"颜色":"深蓝","尺码":"32"}', 199.00, 80, 300),
('9', '{"颜色":"深蓝","尺码":"34"}', 199.00, 80, 200),
('9', '{"颜色":"浅蓝","尺码":"30"}', 199.00, 80, 100),
('9', '{"颜色":"浅蓝","尺码":"32"}', 199.00, 80, 70),

-- 黑色休闲裤(10) SKU
('10', '{"颜色":"黑色","尺码":"M"}', 159.00, 100, 200),
('10', '{"颜色":"黑色","尺码":"L"}', 159.00, 100, 250),
('10', '{"颜色":"黑色","尺码":"XL"}', 159.00, 90, 150),
('10', '{"颜色":"黑色","尺码":"XXL"}', 159.00, 90, 50),

-- 深蓝西裤(11) SKU
('11', '{"颜色":"深蓝","尺码":"M"}', 229.00, 60, 120),
('11', '{"颜色":"深蓝","尺码":"L"}', 229.00, 60, 140),
('11', '{"颜色":"深蓝","尺码":"XL"}', 229.00, 60, 80),
('11', '{"颜色":"藏青","尺码":"L"}', 229.00, 70, 40),

-- 工装裤(12) SKU
('12', '{"颜色":"卡其","尺码":"M"}', 269.00, 50, 90),
('12', '{"颜色":"卡其","尺码":"L"}', 269.00, 50, 100),
('12', '{"颜色":"卡其","尺码":"XL"}', 269.00, 50, 60),
('12', '{"颜色":"军绿","尺码":"L"}', 269.00, 50, 40),

-- 白色西装裤(13) SKU
('13', '{"颜色":"白色","尺码":"M"}', 239.00, 50, 80),
('13', '{"颜色":"白色","尺码":"L"}', 239.00, 50, 70),
('13', '{"颜色":"白色","尺码":"XL"}', 239.00, 40, 40),
('13', '{"颜色":"米白","尺码":"L"}', 239.00, 40, 20),

-- 沙弗裤(14) SKU
('14', '{"颜色":"沙色","尺码":"M"}', 129.00, 90, 150),
('14', '{"颜色":"沙色","尺码":"L"}', 129.00, 90, 180),
('14', '{"颜色":"沙色","尺码":"XL"}', 129.00, 90, 100),
('14', '{"颜色":"浅卡其","尺码":"L"}', 129.00, 80, 50),

-- 五分短裤(15) SKU
('15', '{"颜色":"黑色","尺码":"M"}', 79.00, 130, 480),
('15', '{"颜色":"黑色","尺码":"L"}', 79.00, 130, 520),
('15', '{"颜色":"黑色","尺码":"XL"}', 79.00, 120, 400),
('15', '{"颜色":"黑色","尺码":"XXL"}', 79.00, 120, 280),

-- 轻薄夹克(16) SKU
('16', '{"颜色":"黑色","尺码":"M"}', 299.00, 50, 150),
('16', '{"颜色":"黑色","尺码":"L"}', 299.00, 50, 150),
('16', '{"颜色":"军绿","尺码":"M"}', 299.00, 50, 80),
('16', '{"颜色":"军绿","尺码":"L"}', 299.00, 50, 70),

-- 毛呢大衣(17) SKU
('17', '{"颜色":"黑色","尺码":"M"}', 599.00, 30, 60),
('17', '{"颜色":"黑色","尺码":"L"}', 599.00, 30, 70),
('17', '{"颜色":"黑色","尺码":"XL"}', 599.00, 30, 40),
('17', '{"颜色":"灰色","尺码":"L"}', 599.00, 30, 10),

-- 军官棉服(18) SKU
('18', '{"颜色":"军绿","尺码":"M"}', 399.00, 40, 70),
('18', '{"颜色":"军绿","尺码":"L"}', 399.00, 40, 80),
('18', '{"颜色":"军绿","尺码":"XL"}', 399.00, 40, 50),
('18', '{"颜色":"黑色","尺码":"L"}', 399.00, 30, 20),

-- 针织开衫外套(19) SKU
('19', '{"颜色":"米白","尺码":"M"}', 259.00, 50, 80),
('19', '{"颜色":"米白","尺码":"L"}', 259.00, 50, 90),
('19', '{"颜色":"雾霾蓝","尺码":"M"}', 259.00, 40, 50),
('19', '{"颜色":"雾霾蓝","尺码":"L"}', 259.00, 40, 40),

-- 羽绒服(20) SKU
('20', '{"颜色":"黑色","尺码":"M"}', 459.00, 25, 100),
('20', '{"颜色":"黑色","尺码":"L"}', 459.00, 25, 120),
('20', '{"颜色":"黑色","尺码":"XL"}', 459.00, 25, 80),
('20', '{"颜色":"深灰","尺码":"L"}', 459.00, 25, 50),

-- 工装夹克(21) SKU
('21', '{"颜色":"卡其","尺码":"M"}', 349.00, 40, 90),
('21', '{"颜色":"卡其","尺码":"L"}', 349.00, 40, 100),
('21', '{"颜色":"卡其","尺码":"XL"}', 349.00, 40, 60),
('21', '{"颜色":"军绿","尺码":"L"}', 349.00, 40, 40),

-- 碎花连衣裙(22) SKU
('22', '{"颜色":"碎花","尺码":"S"}', 299.00, 50, 250),
('22', '{"颜色":"碎花","尺码":"M"}', 299.00, 50, 300),
('22', '{"颜色":"碎花","尺码":"L"}', 299.00, 50, 200),
('22', '{"颜色":"纯色","尺码":"S"}', 299.00, 50, 100),

-- 黑色晚礼服(23) SKU
('23', '{"颜色":"黑色","尺码":"S"}', 459.00, 20, 40),
('23', '{"颜色":"黑色","尺码":"M"}', 459.00, 20, 50),
('23', '{"颜色":"黑色","尺码":"L"}', 459.00, 20, 30),

-- 白色蕾丝裙(24) SKU
('24', '{"颜色":"白色","尺码":"S"}', 399.00, 30, 60),
('24', '{"颜色":"白色","尺码":"M"}', 399.00, 30, 70),
('24', '{"颜色":"白色","尺码":"L"}', 399.00, 40, 50),

-- 粉色波点裙(25) SKU
('25', '{"颜色":"粉色","尺码":"S"}', 199.00, 70, 150),
('25', '{"颜色":"粉色","尺码":"M"}', 199.00, 70, 170),
('25', '{"颜色":"粉色","尺码":"L"}', 199.00, 60, 100),
('25', '{"颜色":"红色","尺码":"M"}', 199.00, 50, 0),

-- 几何锥形裙(26) SKU
('26', '{"颜色":"深灰","尺码":"S"}', 279.00, 40, 60),
('26', '{"颜色":"深灰","尺码":"M"}', 279.00, 50, 80),
('26', '{"颜色":"深灰","尺码":"L"}', 279.00, 60, 60),

-- 吊带连衣裙(27) SKU
('27', '{"颜色":"奶茶色","尺码":"S"}', 259.00, 50, 100),
('27', '{"颜色":"奶茶色","尺码":"M"}', 259.00, 50, 120),
('27', '{"颜色":"奶茶色","尺码":"L"}', 259.00, 40, 60),
('27', '{"颜色":"黑色","尺码":"M"}', 259.00, 40, 30),

-- 奶茶色吊带长裙(28) SKU
('28', '{"颜色":"奶茶色","尺码":"S"}', 229.00, 60, 120),
('28', '{"颜色":"奶茶色","尺码":"M"}', 229.00, 60, 140),
('28', '{"颜色":"奶茶色","尺码":"L"}', 229.00, 50, 80),
('28', '{"颜色":"米色","尺码":"M"}', 229.00, 30, 40),

-- V领针织开衫(29) SKU
('29', '{"颜色":"米白","尺码":"M"}', 259.00, 90, 180),
('29', '{"颜色":"米白","尺码":"L"}', 259.00, 90, 200),
('29', '{"颜色":"米白","尺码":"XL"}', 259.00, 80, 120),
('29', '{"颜色":"雾霾蓝","尺码":"M"}', 259.00, 90, 120),

-- 慵懒风针织衫(30) SKU
('30', '{"颜色":"奶茶色","尺码":"均码"}', 179.00, 150, 400),
('30', '{"颜色":"焦糖色","尺码":"均码"}', 179.00, 150, 350),
('30', '{"颜色":"黑色","尺码":"均码"}', 179.00, 150, 200),
('30', '{"颜色":"灰色","尺码":"均码"}', 179.00, 150, 150),

-- 娃娃领衬衫(31) SKU
('31', '{"颜色":"白色","尺码":"S"}', 149.00, 100, 180),
('31', '{"颜色":"白色","尺码":"M"}', 149.00, 100, 200),
('31', '{"颜色":"白色","尺码":"L"}', 149.00, 100, 140),
('31', '{"颜色":"浅蓝","尺码":"M"}', 149.00, 100, 40),

-- 星星刺绣衬衫(32) SKU
('32', '{"颜色":"黑色","尺码":"S"}', 169.00, 80, 120),
('32', '{"颜色":"黑色","尺码":"M"}', 169.00, 80, 150),
('32', '{"颜色":"黑色","尺码":"L"}', 169.00, 80, 100),
('32', '{"颜色":"深灰","尺码":"M"}', 169.00, 80, 50),

-- 白色扭结上衣(33) SKU
('33', '{"颜色":"白色","尺码":"S"}', 199.00, 70, 100),
('33', '{"颜色":"白色","尺码":"M"}', 199.00, 70, 120),
('33', '{"颜色":"白色","尺码":"L"}', 199.00, 70, 80),
('33', '{"颜色":"黑色","尺码":"M"}', 199.00, 70, 40),

-- 奢华蓝衬衫(34) SKU
('34', '{"颜色":"蓝色","尺码":"S"}', 289.00, 50, 80),
('34', '{"颜色":"蓝色","尺码":"M"}', 289.00, 50, 90),
('34', '{"颜色":"蓝色","尺码":"L"}', 289.00, 50, 50),
('34', '{"颜色":"深蓝","尺码":"M"}', 289.00, 30, 20),

-- 花灰色毛衣(35) SKU
('35', '{"颜色":"花灰","尺码":"M"}', 329.00, 40, 60),
('35', '{"颜色":"花灰","尺码":"L"}', 329.00, 40, 70),
('35', '{"颜色":"花灰","尺码":"XL"}', 329.00, 40, 40),
('35', '{"颜色":"灰色","尺码":"L"}', 329.00, 30, 20),

-- 高腰阔腿裤(36) SKU
('36', '{"颜色":"卡其","尺码":"S"}', 189.00, 80, 200),
('36', '{"颜色":"卡其","尺码":"M"}', 189.00, 80, 280),
('36', '{"颜色":"卡其","尺码":"L"}', 189.00, 80, 180),
('36', '{"颜色":"黑色","尺码":"S"}', 189.00, 80, 80),
('36', '{"颜色":"黑色","尺码":"M"}', 189.00, 80, 80),
('36', '{"颜色":"黑色","尺码":"L"}', 189.00, 50, 40),

-- 白色直筒长裤(37) SKU
('37', '{"颜色":"白色","尺码":"S"}', 169.00, 80, 150),
('37', '{"颜色":"白色","尺码":"M"}', 169.00, 80, 180),
('37', '{"颜色":"白色","尺码":"L"}', 169.00, 80, 120),
('37', '{"颜色":"米白","尺码":"M"}', 169.00, 60, 70),

-- 黑色小脚裤(38) SKU
('38', '{"颜色":"黑色","尺码":"S"}', 179.00, 100, 200),
('38', '{"颜色":"黑色","尺码":"M"}', 179.00, 100, 250),
('38', '{"颜色":"黑色","尺码":"L"}', 179.00, 100, 150),
('38', '{"颜色":"深灰","尺码":"M"}', 179.00, 80, 80),

-- 蓝色百褶裙(39) SKU
('39', '{"颜色":"蓝色","尺码":"S"}', 219.00, 70, 120),
('39', '{"颜色":"蓝色","尺码":"M"}', 219.00, 70, 150),
('39', '{"颜色":"蓝色","尺码":"L"}', 219.00, 70, 80),
('39', '{"颜色":"浅蓝","尺码":"M"}', 219.00, 70, 40),

-- 转色直摆裙(40) SKU
('40', '{"颜色":"渐变蓝","尺码":"S"}', 259.00, 30, 50),
('40', '{"颜色":"渐变蓝","尺码":"M"}', 259.00, 40, 60),
('40', '{"颜色":"渐变粉","尺码":"M"}', 259.00, 50, 40),

-- 卡其迷你裙(41) SKU
('41', '{"颜色":"卡其","尺码":"S"}', 149.00, 80, 150),
('41', '{"颜色":"卡其","尺码":"M"}', 149.00, 90, 180),
('41', '{"颜色":"卡其","尺码":"L"}', 149.00, 90, 100),
('41', '{"颜色":"军绿","尺码":"M"}', 149.00, 90, 50),

-- 复古跑鞋(42) SKU
('42', '{"颜色":"白黑","尺码":"40"}', 459.00, 40, 350),
('42', '{"颜色":"白黑","尺码":"41"}', 459.00, 40, 350),
('42', '{"颜色":"白黑","尺码":"42"}', 459.00, 40, 300),
('42', '{"颜色":"全白","尺码":"40"}', 459.00, 40, 150),
('42', '{"颜色":"全白","尺码":"41"}', 459.00, 40, 100),
('42', '{"颜色":"灰蓝","尺码":"40"}', 459.00, 40, 50),
('42', '{"颜色":"灰蓝","尺码":"41"}', 459.00, 40, 50),

-- 篮球鞋(43) SKU
('43', '{"颜色":"黑白","尺码":"40"}', 599.00, 30, 150),
('43', '{"颜色":"黑白","尺码":"41"}', 599.00, 30, 160),
('43', '{"颜色":"黑白","尺码":"42"}', 599.00, 30, 120),
('43', '{"颜色":"黑白","尺码":"43"}', 599.00, 30, 60),
('43', '{"颜色":"白红","尺码":"41"}', 599.00, 30, 30),

-- 登山鞋(44) SKU
('44', '{"颜色":"深棕","尺码":"40"}', 389.00, 25, 50),
('44', '{"颜色":"深棕","尺码":"41"}', 389.00, 25, 60),
('44', '{"颜色":"深棕","尺码":"42"}', 389.00, 25, 40),
('44', '{"颜色":"黑色","尺码":"41"}', 389.00, 25, 30),

-- 减震跑鞋(45) SKU
('45', '{"颜色":"白蓝","尺码":"40"}', 299.00, 50, 180),
('45', '{"颜色":"白蓝","尺码":"41"}', 299.00, 50, 200),
('45', '{"颜色":"白蓝","尺码":"42"}', 299.00, 50, 150),
('45', '{"颜色":"黑色","尺码":"40"}', 299.00, 50, 80),
('45', '{"颜色":"黑色","尺码":"41"}', 299.00, 50, 70),

-- 帆布鞋(46) SKU
('46', '{"颜色":"白色","尺码":"38"}', 89.00, 100, 500),
('46', '{"颜色":"白色","尺码":"39"}', 89.00, 100, 550),
('46', '{"颜色":"白色","尺码":"40"}', 89.00, 100, 580),
('46', '{"颜色":"白色","尺码":"41"}', 89.00, 100, 400),
('46', '{"颜色":"黑色","尺码":"40"}', 89.00, 100, 170),

-- 缓震训练鞋(47) SKU
('47', '{"颜色":"黑色","尺码":"40"}', 279.00, 60, 250),
('47', '{"颜色":"黑色","尺码":"41"}', 279.00, 60, 280),
('47', '{"颜色":"黑色","尺码":"42"}', 279.00, 60, 200),
('47', '{"颜色":"黑色","尺码":"43"}', 279.00, 60, 100),
('47', '{"颜色":"灰色","尺码":"41"}', 279.00, 60, 60),

-- 高跟鞋(48) SKU
('48', '{"颜色":"黑色","尺码":"35"}', 259.00, 40, 200),
('48', '{"颜色":"黑色","尺码":"36"}', 259.00, 40, 300),
('48', '{"颜色":"黑色","尺码":"37"}', 259.00, 40, 220),
('48', '{"颜色":"米色","尺码":"36"}', 259.00, 40, 100),
('48', '{"颜色":"米色","尺码":"37"}', 259.00, 40, 100),

-- 坡跟淑女鞋(49) SKU
('49', '{"颜色":"黑色","尺码":"35"}', 199.00, 60, 180),
('49', '{"颜色":"黑色","尺码":"36"}', 199.00, 60, 220),
('49', '{"颜色":"黑色","尺码":"37"}', 199.00, 60, 180),
('49', '{"颜色":"米色","尺码":"36"}', 199.00, 60, 100),
('49', '{"颜色":"米色","尺码":"37"}', 199.00, 60, 70),

-- 英伦皮鞋(50) SKU
('50', '{"颜色":"黑色","尺码":"35"}', 329.00, 40, 100),
('50', '{"颜色":"黑色","尺码":"36"}', 329.00, 40, 120),
('50', '{"颜色":"黑色","尺码":"37"}', 329.00, 40, 80),
('50', '{"颜色":"棕色","尺码":"36"}', 329.00, 40, 50),
('50', '{"颜色":"棕色","尺码":"37"}', 329.00, 40, 30),

-- 流苏凉鞋(51) SKU
('51', '{"颜色":"金色","尺码":"35"}', 219.00, 50, 120),
('51', '{"颜色":"金色","尺码":"36"}', 219.00, 50, 130),
('51', '{"颜色":"金色","尺码":"37"}', 219.00, 50, 90),
('51', '{"颜色":"银色","尺码":"36"}', 219.00, 40, 50),
('51', '{"颜色":"银色","尺码":"37"}', 219.00, 40, 30),

-- 水晶粗头鞋(52) SKU
('52', '{"颜色":"黑色","尺码":"35"}', 239.00, 40, 90),
('52', '{"颜色":"黑色","尺码":"36"}', 239.00, 50, 110),
('52', '{"颜色":"黑色","尺码":"37"}', 239.00, 50, 90),
('52', '{"颜色":"白色","尺码":"36"}', 239.00, 40, 50),
('52', '{"颜色":"白色","尺码":"37"}', 239.00, 20, 20),

-- 棒球帽(53) SKU
('53', '{"颜色":"黑色","尺码":"均码"}', 89.00, 200, 600),
('53', '{"颜色":"白色","尺码":"均码"}', 89.00, 200, 550),
('53', '{"颜色":"藏青","尺码":"均码"}', 89.00, 200, 550),
('53', '{"颜色":"粉色","尺码":"均码"}', 89.00, 200, 600),

-- 毛线帽(54) SKU
('54', '{"颜色":"米白","尺码":"均码"}', 49.00, 150, 450),
('54', '{"颜色":"灰色","尺码":"均码"}', 49.00, 150, 420),
('54', '{"颜色":"黑色","尺码":"均码"}', 49.00, 150, 480),
('54', '{"颜色":"粉色","尺码":"均码"}', 49.00, 150, 330),

-- 两用包(55) SKU
('55', '{"颜色":"黑色","款式":"手提"}', 229.00, 100, 500),
('55', '{"颜色":"黑色","款式":"单肩"}', 229.00, 100, 480),
('55', '{"颜色":"米白","款式":"手提"}', 229.00, 100, 350),
('55', '{"颜色":"米白","款式":"单肩"}', 229.00, 100, 350),

-- 链条包(56) SKU
('56', '{"颜色":"黑色","款式":"斜挎"}', 189.00, 90, 300),
('56', '{"颜色":"黑色","款式":"单肩"}', 189.00, 90, 280),
('56', '{"颜色":"酒红","款式":"斜挎"}', 189.00, 80, 200),
('56', '{"颜色":"酒红","款式":"单肩"}', 189.00, 90, 200),

-- 手包(57) SKU
('57', '{"颜色":"黑色","款式":"手拿"}', 299.00, 40, 100),
('57', '{"颜色":"黑色","款式":"单肩"}', 299.00, 40, 90),
('57', '{"颜色":"金色","款式":"手拿"}', 299.00, 40, 90),

-- 简约手拿包(58) SKU
('58', '{"颜色":"黑色","款式":"手拿"}', 459.00, 25, 60),
('58', '{"颜色":"黑色","款式":"斜挎"}', 459.00, 25, 50),
('58', '{"颜色":"棕色","款式":"手拿"}', 459.00, 30, 50),

-- 贝壳包(59) SKU
('59', '{"颜色":"米白","款式":"手提"}', 599.00, 20, 40),
('59', '{"颜色":"米白","款式":"单肩"}', 599.00, 20, 30),
('59', '{"颜色":"粉色","款式":"手提"}', 599.00, 20, 20),

-- 秋衣套装(60) SKU
('60', '{"颜色":"肤色","尺码":"M"}', 99.00, 130, 280),
('60', '{"颜色":"肤色","尺码":"L"}', 99.00, 130, 320),
('60', '{"颜色":"肤色","尺码":"XL"}', 99.00, 120, 200),
('60', '{"颜色":"黑色","尺码":"L"}', 99.00, 120, 180),

-- 蕾丝套装(61) SKU
('61', '{"颜色":"肤色","尺码":"M"}', 129.00, 90, 160),
('61', '{"颜色":"肤色","尺码":"L"}', 129.00, 90, 180),
('61', '{"颜色":"肤色","尺码":"XL"}', 129.00, 80, 120),
('61', '{"颜色":"粉色","尺码":"L"}', 129.00, 90, 60),

-- 两件套装(62) SKU
('62', '{"颜色":"浅蓝","尺码":"M"}', 89.00, 120, 200),
('62', '{"颜色":"浅蓝","尺码":"L"}', 89.00, 120, 240),
('62', '{"颜色":"浅蓝","尺码":"XL"}', 89.00, 110, 150),
('62', '{"颜色":"白色","尺码":"L"}', 89.00, 100, 90),

-- 居家服(63) SKU
('63', '{"颜色":"奶茶色","尺码":"M"}', 139.00, 100, 160),
('63', '{"颜色":"奶茶色","尺码":"L"}', 139.00, 100, 180),
('63', '{"颜色":"奶茶色","尺码":"XL"}', 139.00, 90, 120),
('63', '{"颜色":"浅灰","尺码":"L"}', 139.00, 90, 80),

-- 睡裙套装(64) SKU
('64', '{"颜色":"粉色","尺码":"M"}', 159.00, 80, 120),
('64', '{"颜色":"粉色","尺码":"L"}', 159.00, 80, 140),
('64', '{"颜色":"粉色","尺码":"XL"}', 159.00, 70, 90),
('64', '{"颜色":"香槟色","尺码":"L"}', 159.00, 70, 70);

-- ============================================================
-- 4. 更新 goods 表的总库存 stock 字段（根据 SKU 汇总）
-- ============================================================
UPDATE goods g SET stock = (
  SELECT COALESCE(SUM(stock), 0) FROM sku WHERE goods_id = g.id
);

-- ============================================================
-- 5. 添加测试用户评价
-- ============================================================

INSERT INTO comment (user_id, goods_id, order_id, content, rating, create_time) VALUES
(2, 1, 1, '质量很好，面料很舒服，会回购！', 5, '2026-06-01 10:30:00'),
(3, 1, 2, '尺码标准，穿着很合身，推荐购买。', 5, '2026-06-02 14:20:00'),
(4, 1, 3, '性价比很高，包装也很好看。', 4, '2026-06-03 09:15:00'),
(5, 5, 4, '裙子很美，穿着很有气质，朋友都说好看！', 5, '2026-06-01 16:45:00'),
(6, 5, 5, '雪纺面料很轻薄，夏天穿正合适。', 5, '2026-06-02 11:30:00'),
(2, 22, 6, '法式风格太爱了！上身效果超好，拍照很出片~', 5, '2026-06-05 20:00:00'),
(3, 22, 7, '做工精细，颜色也没有色差，很满意。', 5, '2026-06-06 15:30:00'),
(4, 42, 8, '鞋子很舒服，跑步穿很轻便，缓震效果不错。', 5, '2026-06-03 18:00:00'),
(5, 42, 9, '颜值与实力并存，推荐给喜欢运动的朋友。', 4, '2026-06-04 12:00:00'),
(6, 16, 10, '春秋天穿刚刚好，轻薄便携，风衣质量不错。', 5, '2026-06-05 10:00:00'),
(2, 30, 11, '慵懒风绝了！超级宽松舒服，颜色也超美。', 5, '2026-06-06 09:30:00'),
(3, 36, 12, '阔腿裤显瘦效果一流，高腰设计太贴心了。', 5, '2026-06-07 14:00:00'),
(4, 53, 13, '帽子质量很好，戴着很舒服，百搭款。', 5, '2026-06-04 16:00:00'),
(5, 55, 14, '包包容量大，分层设计很实用，通勤必备！', 5, '2026-06-08 11:00:00'),
(6, 2, 15, 'Polo衫很有质感，珠地面料透气性好。', 5, '2026-06-09 10:00:00');
