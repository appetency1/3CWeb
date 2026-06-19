import urllib.request
import os

output_dir = "demo-logos"
os.makedirs(output_dir, exist_ok=True)

brands = [
    ("mlb", "MLB", "mlb.com"),
    ("warrior", "回力", "warriorshoes.com"),
    ("uniqlo", "Uniqlo", "uniqlo.com"),
    ("charleskeith", "小CK", "charleskeith.com"),
    ("feiyue", "飞跃", "feiyue-shoes.com"),
    ("nike", "Nike", "nike.com"),
    ("hm", "H&M", "hm.com"),
    ("ur", "UR", "urbanrevivo.com"),
    ("hongdou", "红豆", "hongdou.com"),
    ("red-dragonfly", "红蜻蜓", "reddragonfly.com.cn"),
    ("supreme", "Supreme", "supremenewyork.com"),
    ("adidas", "Adidas", "adidas.com"),
    ("zara", "ZARA", "zara.com"),
    ("muji", "MUJI", "muji.com"),
    ("gap", "GAP", "gap.com"),
    ("gucci", "GUCCI", "gucci.com"),
    ("prada", "PRADA", "prada.com"),
    ("dior", "DIOR", "dior.com"),
    ("lv", "LV", "louisvuitton.com"),
    ("chanel", "CHANEL", "chanel.com"),
    ("hermes", "HERMES", "hermes.com"),
    ("burberry", "BURBERRY", "burberry.com"),
    ("coach", "COACH", "coach.com"),
    ("fendi", "FENDI", "fendi.com"),
    ("celine", "CELINE", "celine.com"),
    ("balenciaga", "BALENCIAGA", "balenciaga.com"),
    ("ysl", "YSL", "ysl.com"),
]

downloaded = 0
failed = []

for file, name, domain in brands:
    url = f"https://logo.clearbit.com/{domain}"
    path = os.path.join(output_dir, f"{file}.png")
    try:
        urllib.request.urlretrieve(url, path)
        size = os.path.getsize(path)
        if size < 200:
            os.remove(path)
            print(f"TOO_SMALL: {name}")
            failed.append((file, name))
        else:
            downloaded += 1
            print(f"OK: {name}")
    except Exception as e:
        print(f"FAIL: {name} - {e}")
        failed.append((file, name))

print(f"\nDownloaded: {downloaded} / {len(brands)}")
if failed:
    print("Failed:")
    for f, n in failed:
        print(f"  {n}")
