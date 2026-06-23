#!/usr/bin/env python3
"""生成数码/3C 主题占位图 - 型号命名 + 同型号共用"""

import os

PRODUCTS_DIR = "ClothesUser/public/assets/products"
BANNERS_DIR = "ClothesUser/public/assets/banners"

CATEGORY_STYLES = {
    "phones":    {"gradient": "linear-gradient(135deg, #1a1a2e, #16213e)", "icon": "📱", "accent": "#e94560"},
    "laptops":   {"gradient": "linear-gradient(135deg, #0f3443, #34e89e)", "icon": "💻", "accent": "#34e89e"},
    "tablets":   {"gradient": "linear-gradient(135deg, #667eea, #764ba2)", "icon": "📱", "accent": "#a78bfa"},
    "audio":     {"gradient": "linear-gradient(135deg, #232526, #414345)", "icon": "🎧", "accent": "#f59e0b"},
    "wearable":  {"gradient": "linear-gradient(135deg, #0f0c29, #302b63)", "icon": "⌚", "accent": "#06b6d4"},
    "camera":    {"gradient": "linear-gradient(135deg, #000428, #004e92)", "icon": "📷", "accent": "#3b82f6"},
    "gaming":    {"gradient": "linear-gradient(135deg, #200122, #6f0000)", "icon": "🎮", "accent": "#ef4444"},
    "accessories":{"gradient": "linear-gradient(135deg, #141e30, #243b55)", "icon": "🔌", "accent": "#10b981"},
}

# 不重复的商品图（同型号共用一张图）
# (filename_without_ext, name, brand, category, price)
UNIQUE_IMAGES = [
    # 智能手机（6张）
    ("goods-apple-iphone15-pro-max", "iPhone 15 Pro Max", "Apple", "phones", 12999),
    ("goods-apple-iphone15-pro", "iPhone 15 Pro", "Apple", "phones", 8999),
    ("goods-huawei-mate60-pro", "HUAWEI Mate 60 Pro", "HUAWEI", "phones", 6999),
    ("goods-xiaomi-14-ultra", "Xiaomi 14 Ultra", "Xiaomi", "phones", 5999),
    ("goods-samsung-s24-ultra", "Samsung Galaxy S24 Ultra", "Samsung", "phones", 10999),
    ("goods-oppo-find-x7-ultra", "OPPO Find X7 Ultra", "OPPO", "phones", 5999),
    ("goods-vivo-x100-pro", "vivo X100 Pro", "vivo", "phones", 4999),
    ("goods-apple-iphone-se", "iPhone SE 3rd Gen", "Apple", "phones", 3499),
    # 笔记本电脑（7张）
    ("goods-apple-macbook-air-m3", "MacBook Air M3", "Apple", "laptops", 9499),
    ("goods-apple-macbook-pro-16", "MacBook Pro 16 M3 Max", "Apple", "laptops", 27999),
    ("goods-lenovo-thinkpad-x1", "ThinkPad X1 Carbon", "Lenovo", "laptops", 10999),
    ("goods-huawei-matebook-x-pro", "HUAWEI MateBook X Pro", "HUAWEI", "laptops", 9999),
    ("goods-asus-rog-zephyrus-16", "ASUS ROG Zephyrus 16", "ASUS", "laptops", 12999),
    ("goods-dell-xps-16", "Dell XPS 16", "Dell", "laptops", 11499),
    ("goods-microsoft-surface-laptop-6", "Surface Laptop 6", "Microsoft", "laptops", 10688),
    ("goods-xiaomi-redmibook-16", "RedmiBook Pro 16", "Xiaomi", "laptops", 5999),
    # 平板电脑（5张）
    ("goods-apple-ipad-pro-m4", "iPad Pro M4", "Apple", "tablets", 8799),
    ("goods-apple-ipad-air-m2", "iPad Air M2", "Apple", "tablets", 4799),
    ("goods-huawei-matepad-pro", "HUAWEI MatePad Pro", "HUAWEI", "tablets", 4299),
    ("goods-samsung-tab-s9-ultra", "Samsung Tab S9 Ultra", "Samsung", "tablets", 7999),
    ("goods-xiaomi-pad-6s-pro", "Xiaomi Pad 6S Pro", "Xiaomi", "tablets", 3299),
    # 耳机/音箱（7张）
    ("goods-sony-wh-1000xm5", "Sony WH-1000XM5", "Sony", "audio", 2499),
    ("goods-apple-airpods-pro-2", "AirPods Pro 2", "Apple", "audio", 1899),
    ("goods-apple-airpods-max", "AirPods Max", "Apple", "audio", 3999),
    ("goods-bose-qc-ultra", "Bose QC Ultra", "Bose", "audio", 2999),
    ("goods-samsung-buds2-pro", "Galaxy Buds2 Pro", "Samsung", "audio", 1599),
    ("goods-huawei-freebuds-pro-3", "HUAWEI FreeBuds Pro 3", "HUAWEI", "audio", 1299),
    ("goods-marshall-kilburn-ii", "Marshall Kilburn II", "Marshall", "audio", 2299),
    ("goods-jbl-charge-5", "JBL Charge 5", "JBL", "audio", 1499),
    # 相机/摄像机（5张）
    ("goods-sony-a7m4", "Sony A7M4 / A7C2", "Sony", "camera", 15999),
    ("goods-canon-eos-r6-ii", "Canon EOS R6 II", "Canon", "camera", 15999),
    ("goods-dji-osmo-pocket-3", "DJI Osmo Pocket 3", "DJI", "camera", 3499),
    ("goods-gopro-hero-12", "GoPro HERO 12", "GoPro", "camera", 3198),
    ("goods-fujifilm-instax-mini-12", "Instax Mini 12", "Fujifilm", "camera", 699),
    # 智能手表（5张）
    ("goods-apple-watch-s9", "Apple Watch Series 9", "Apple", "wearable", 2999),
    ("goods-apple-watch-ultra-2", "Apple Watch Ultra 2", "Apple", "wearable", 5999),
    ("goods-samsung-watch6-classic", "Galaxy Watch6 Classic", "Samsung", "wearable", 2799),
    ("goods-huawei-watch-gt-4", "HUAWEI Watch GT 4", "HUAWEI", "wearable", 1599),
    ("goods-garmin-fenix-7x-pro", "Garmin Fenix 7X Pro", "Garmin", "wearable", 5480),
    ("goods-amazfit-trex-3", "Amazfit T-Rex 3", "Amazfit", "wearable", 1799),
    # 功能手机（3张）
    ("goods-nokia-3210", "Nokia 3210", "Nokia", "phones", 399),
    ("goods-philips-e2620", "Philips E2620", "Philips", "phones", 199),
    ("goods-ktouch-g88", "K-Touch G88", "K-Touch", "phones", 159),
    # 台式电脑（4张）
    ("goods-apple-imac-24", "iMac 24-inch M3", "Apple", "laptops", 10999),
    ("goods-apple-mac-studio", "Mac Studio M2 Ultra", "Apple", "laptops", 32999),
    ("goods-lenovo-legion-7000k", "Lenovo Legion 7000K", "Lenovo", "gaming", 8999),
    ("goods-dell-optiplex-plus", "Dell OptiPlex Plus", "Dell", "gaming", 5999),
    # 对讲机（2张）
    ("goods-xiaomi-talkie-3", "Xiaomi Talkie 3", "Xiaomi", "accessories", 399),
    ("goods-baofeng-uv5r", "Baofeng UV-5R", "Baofeng", "accessories", 139),
    # 手环（2张 - 共用）
    ("goods-xiaomi-band-9-pro", "Xiaomi Band 9 Pro", "Xiaomi", "wearable", 399),
    ("goods-xiaomi-band-9", "Xiaomi Band 9 Series", "Xiaomi", "wearable", 249),
    # 手机配件（6张）
    ("goods-anker-100w-gan", "Anker 100W GaN Charger", "Anker", "accessories", 199),
    ("goods-samsung-t7-2tb", "Samsung T7 2TB SSD", "Samsung", "accessories", 1399),
    ("goods-logitech-mx-master-3s", "Logitech MX Master 3S", "Logitech", "accessories", 699),
    ("goods-belkin-7in1-hub", "Belkin 7-in-1 Hub", "Belkin", "accessories", 399),
    ("goods-ugreen-100w-cable", "UGREEN 100W Cable", "UGREEN", "accessories", 79),
    ("goods-spigen-iphone-case", "Spigen iPhone 15 Case", "Spigen", "accessories", 129),
    # 网络设备（4张）
    ("goods-tplink-ax6000", "TP-Link AX6000", "TP-Link", "accessories", 399),
    ("goods-xiaomi-be7000", "Xiaomi BE7000 Wi-Fi 7", "Xiaomi", "accessories", 699),
    ("goods-asus-rt-ax86u", "ASUS RT-AX86U", "ASUS", "accessories", 1599),
    ("goods-h3c-mini-s8gu", "H3C Mini S8G-U Switch", "H3C", "accessories", 199),
]


def make_svg(filename, name, brand, category, price):
    style = CATEGORY_STYLES.get(category, CATEGORY_STYLES["phones"])
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="800" height="1000" viewBox="0 0 800 1000">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">{style["gradient"]}</linearGradient>
  </defs>
  <rect width="800" height="1000" fill="url(#bg)" rx="0"/>
  <rect x="40" y="40" width="720" height="720" rx="24" fill="rgba(255,255,255,0.06)"/>
  <text x="400" y="420" font-size="120" text-anchor="middle" font-family="Apple Color Emoji, Segoe UI Emoji">{style["icon"]}</text>
  <text x="400" y="520" font-size="32" font-weight="bold" fill="white" text-anchor="middle" font-family="system-ui,sans-serif">{name}</text>
  <text x="400" y="570" font-size="22" fill="rgba(255,255,255,0.5)" text-anchor="middle" font-family="system-ui,sans-serif">{brand}</text>
  <text x="400" y="640" font-size="36" font-weight="bold" fill="{style["accent"]}" text-anchor="middle" font-family="system-ui,sans-serif">¥{price}</text>
  <rect x="300" y="680" width="200" height="3" rx="1.5" fill="{style["accent"]}" opacity="0.3"/>
  <text x="400" y="880" font-size="18" fill="rgba(255,255,255,0.2)" text-anchor="middle" font-family="system-ui,sans-serif">MAISON Digital</text>
</svg>'''
    return svg


def make_banner_svg(title, subtitle, idx):
    gradients = [
        "linear-gradient(135deg, #0f0c29, #302b63, #24243e)",
        "linear-gradient(135deg, #000428, #004e92, #000428)",
        "linear-gradient(135deg, #1a1a2e, #16213e, #0f3460)",
        "linear-gradient(135deg, #0f3443, #0f3443, #34e89e)",
        "linear-gradient(135deg, #200122, #6f0000, #200122)",
        "linear-gradient(135deg, #141e30, #141e30, #243b55)",
        "linear-gradient(135deg, #1e130c, #9a8478)",
        "linear-gradient(135deg, #232526, #414345, #232526)",
    ]
    g = gradients[idx % len(gradients)]
    icons = ["📱", "💻", "🎧", "⌚", "📷", "🎮", "🔌", "🖥️"]
    icon = icons[idx % len(icons)]
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="1920" height="600" viewBox="0 0 1920 600">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">{g}</linearGradient>
  </defs>
  <rect width="1920" height="600" fill="url(#bg)"/>
  <rect x="80" y="80" width="640" height="440" rx="32" fill="rgba(255,255,255,0.04)"/>
  <text x="200" y="240" font-size="160" text-anchor="middle" font-family="Apple Color Emoji, Segoe UI Emoji">{icon}</text>
  <text x="400" y="340" font-size="56" font-weight="bold" fill="white" text-anchor="middle" font-family="system-ui,sans-serif">{title}</text>
  <text x="400" y="400" font-size="26" fill="rgba(255,255,255,0.5)" text-anchor="middle" font-family="system-ui,sans-serif">{subtitle}</text>
  <text x="1200" y="300" font-size="120" font-weight="bold" fill="rgba(255,255,255,0.03)" font-family="system-ui,sans-serif">{idx + 1}</text>
</svg>'''
    return svg


def main():
    base = os.path.join(os.path.dirname(__file__) or ".", "..", "ClothesDemo")
    products_dir = os.path.join(base, PRODUCTS_DIR)
    banners_dir = os.path.join(base, BANNERS_DIR)
    os.makedirs(products_dir, exist_ok=True)
    os.makedirs(banners_dir, exist_ok=True)

    # 商品图（55张不重复）
    for filename, name, brand, category, price in UNIQUE_IMAGES:
        svg = make_svg(filename, name, brand, category, price)
        filepath = os.path.join(products_dir, filename + ".svg")
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(svg)
        print(f"  [OK] {filename}.svg -- {name}")

    # 轮播图（8张）
    banners = [
        ("Xin Ji Shou Fa", "Flagship Phones"),
        ("Bi Ji Ben Zhuan Chang", "Laptops for Work"),
        ("Ying Ying Sheng Yan", "Immersive Audio"),
        ("Zhi Neng Chuan Dai", "Smart Wearables"),
        ("She Ying Zhuan Qu", "Capture the Moment"),
        ("You Xi Zhuang Bei", "Gaming Gear"),
        ("Shu Ma Pei Jian", "All Accessories"),
        ("Xian Shi Te Hui", "Sale Events"),
    ]
    for i, (title, subtitle) in enumerate(banners, 1):
        svg = make_banner_svg(title, subtitle, i)
        filepath = os.path.join(banners_dir, f"banner-{i}.svg")
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(svg)
        print(f"  [OK] banner-{i}.svg -- {title}")

    print(f"\nDone! Generated {len(UNIQUE_IMAGES)} unique product images + {len(banners)} banners")


if __name__ == "__main__":
    main()
