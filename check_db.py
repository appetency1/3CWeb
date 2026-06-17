import subprocess
import os

mysql = r'C:\Program Files\MySQL\MySQL Server 9.2\bin\mysql.exe'

def q(sql):
    env = os.environ.copy()
    env['MYSQL_PWD'] = '000000'
    r = subprocess.run(
        [mysql, '-u', 'root', '--default-character-set=utf8mb4', 'clothes_demo', '-e', sql],
        capture_output=True, text=True, encoding='utf-8', errors='replace', env=env, timeout=10,
    )
    return r.stdout, r.stderr, r.returncode

# 1. Check current state - first 10 goods
print('=== 1. Current goods 1-10 ===')
out, err, rc = q("SELECT id, name, brand, cover, LEFT(description, 30) as desc_short FROM goods ORDER BY id LIMIT 10")
print(out)
if err: print('ERR:', err)

# 2. Total count
print('=== 2. Total count ===')
out, _, _ = q("SELECT COUNT(*) as cnt FROM goods")
print(out)

# 3. Check distinct covers
print('=== 3. Distinct cover paths ===')
out, _, _ = q("SELECT cover, COUNT(*) as cnt FROM goods GROUP BY cover ORDER BY cnt DESC")
print(out)
