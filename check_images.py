import urllib.request

urls = [
    "https://images.unsplash.com/photo-1525507119028-ed4c629a60a3?w=600&q=80",
    "https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=600&q=80",
    "https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?w=600&q=80",
    "https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600&q=80"
]

for u in urls:
    try:
        req = urllib.request.Request(u, method='HEAD')
        req.add_header('User-Agent', 'Mozilla/5.0')
        with urllib.request.urlopen(req, timeout=15) as r:
            print(r.status, u)
    except Exception as e:
        print('ERR', u, str(e)[:100])
