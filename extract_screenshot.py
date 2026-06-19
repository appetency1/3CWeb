import base64

with open(r'C:\Users\ADMINI~1\AppData\Local\Temp\trae\toolcall-output\dec35cb6-4729-487f-a66a-cdfe87eaa422.txt', 'r', encoding='utf-8') as f:
    content = f.read()

idx = content.find('","data":"')
if idx != -1:
    b64 = content[idx+8:]
    b64 = b64.rstrip('"}\n')
    img = base64.b64decode(b64)
    with open(r'd:\AI Code\ClothesDemo\demo-category-native-desktop.png', 'wb') as f:
        f.write(img)
    print('saved', len(img), 'bytes')
else:
    print('not found')
