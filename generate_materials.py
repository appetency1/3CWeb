import json
import random

banners = [
    {"id": 1, "name": "春季新品", "description": "2025春季新品上市", "image": "https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=1200&q=80", "link": "/category/women"},
    {"id": 2, "name": "连衣裙专场", "description": "优雅连衣裙精选", "image": "https://images.unsplash.com/photo-1485968579580-b6d095142e6e?w=1200&q=80", "link": "/category/dresses"},
    {"id": 3, "name": "夏日清凉", "description": "清爽夏日穿搭", "image": "https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=1200&q=80", "link": "/category/tops"},
    {"id": 4, "name": "品牌特惠", "description": "精选品牌折扣", "image": "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=1200&q=80", "link": "/sale"},
    {"id": 5, "name": "职场穿搭", "description": "专业通勤装", "image": "https://images.unsplash.com/photo-1582142839970-2b9e04b60f65?w=1200&q=80", "link": "/category/suits"},
    {"id": 6, "name": "运动休闲", "description": "舒适运动风", "image": "https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=1200&q=80", "link": "/category/sports"},
    {"id": 7, "name": "鞋包配饰", "description": "精致搭配", "image": "https://images.unsplash.com/photo-1543544176-141782ddb702?w=1200&q=80", "link": "/category/accessories"},
    {"id": 8, "name": "针织暖意", "description": "温暖针织系列", "image": "https://images.unsplash.com/photo-1551163943-3f6a29e39426?w=1200&q=80", "link": "/category/knitwear"},
    {"id": 9, "name": "牛仔风尚", "description": "经典牛仔系列", "image": "https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=1200&q=80", "link": "/category/denim"},
    {"id": 10, "name": "内衣家居", "description": "舒适居家体验", "image": "https://images.unsplash.com/photo-1525507119028-ed4c629a60a3?w=1200&q=80", "link": "/category/lingerie"}
]

image_urls = [
    "https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600&q=80",
    "https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600&q=80",
    "https://images.unsplash.com/photo-1525507119028-ed4c629a60a3?w=600&q=80",
    "https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?w=600&q=80",
    "https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600&q=80",
    "https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=600&q=80",
    "https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=600&q=80",
    "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600&q=80"
]

categories = ["tops", "bottoms", "dresses", "outerwear", "shoes", "bags", "accessories", "lingerie", "sports"]
brands = ["ZARA", "UNIQLO", "MUJI", "COS", "UR", "PEACEBIRD", "SEZANE", "LEVI'S", "NIKE", "ADIDAS", "COACH", "CHARLES & KEITH", "CLARKS", "NEW BALANCE"]

product_names = [
    "T恤", "衬衫", "针织衫", "毛衣", "卫衣", "Polo衫", "雪纺衫", "吊带衫", "背心", "开衫",
    "牛仔裤", "休闲裤", "西裤", "阔腿裤", "短裤", "半身裙", "百褶裙", "A字裙", "长裙", "迷你裙",
    "连衣裙", "连体裤", "风衣", "外套", "夹克", "羽绒服", "棉服", "西装", "针织外套", "皮衣",
    "运动鞋", "休闲鞋", "高跟鞋", "平底鞋", "凉鞋", "靴子", "乐福鞋", "帆布鞋", "马丁靴", "板鞋",
    "手提包", "单肩包", "斜挎包", "双肩包", "钱包", "托特包", "链条包", "手拿包", "水桶包", "背包",
    "围巾", "帽子", "耳环", "项链", "手链", "戒指", "手表", "墨镜", "发饰", "腰带",
    "内衣", "睡衣", "家居服", "泳衣", "保暖套装", "运动套装", "瑜伽服", "跑步服", "健身服", "骑行服"
]

products = []
for i in range(1, 129):
    cat = random.choice(categories)
    brand = random.choice(brands)
    price = random.randint(79, 999)
    original_price = price + random.randint(0, 300) if random.random() > 0.6 else None
    sold = random.randint(300, 5000)
    rating = round(random.uniform(4.5, 4.9), 1)
    stock = random.randint(10, 250)
    
    products.append({
        "id": i,
        "name": f"{random.choice(['黑色', '白色', '米色', '蓝色', '灰色', '粉色', '卡其', '藏蓝', '浅咖', '酒红'])}" + random.choice(product_names),
        "category": cat,
        "price": price,
        "originalPrice": original_price,
        "brand": brand,
        "image": random.choice(image_urls),
        "sold": sold,
        "rating": rating,
        "stock": stock
    })

data = {"banners": banners, "products": products}

with open("d:/AI Code/ClothesDemo/ClothesUser/public/assets/data/materials.json", "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f"Generated {len(products)} products and {len(banners)} banners")
