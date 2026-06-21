import json

s = r'{"name":"\u9423\udcaa\u7efe\u8fa9\u6f6f\u7441\u6b11\u6f6f\u741b\uff45\udca5\u6944\udca3\udc85"}'
d = json.loads(s)
mangled = d['name']
correct = "法式碎花雪纺连衣裙"

# 输出到文件避免终端编码问题，surrogate 用 backslashreplace
with open('d:/AI Code/ClothesDemo/test_decode_result.txt', 'w', encoding='utf-8', errors='backslashreplace') as f:
    f.write(f'mangled: {mangled}\n')
    f.write(f'correct: {correct}\n')
    f.write(f'mangled repr: {repr(mangled)}\n')
    f.write(f'correct repr: {repr(correct)}\n')
    
    # 正确的 GBK 字节
    correct_gbk = correct.encode('gbk')
    f.write(f'correct gbk bytes: {correct_gbk.hex()}\n')
    
    # mangled 的 code points
    code_points = [hex(ord(c)) for c in mangled]
    f.write(f'mangled code points: {code_points}\n')
    
    # mangled 的 UTF-16 BE 字节（包含 surrogate）
    try:
        mangled_utf16be = mangled.encode('utf-16-be', 'surrogatepass')
        f.write(f'mangled utf16be bytes: {mangled_utf16be.hex()}\n')
        f.write(f'match correct gbk: {mangled_utf16be == correct_gbk}\n')
    except Exception as e:
        f.write(f'mangled utf16be error: {e}\n')

print('done, see test_decode_result.txt')
