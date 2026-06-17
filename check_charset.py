import subprocess
import os

mysql = r'C:\Program Files\MySQL\MySQL Server 9.2\bin\mysql.exe'

def q(sql, db='clothes_demo'):
    env = os.environ.copy()
    env['MYSQL_PWD'] = '000000'
    r = subprocess.run(
        [mysql, '-u', 'root', '--default-character-set=utf8mb4', db, '-e', sql],
        capture_output=True, text=True, encoding='utf-8', errors='replace', env=env, timeout=30,
    )
    return r.stdout, r.stderr, r.returncode

# Step 1: check the column charset
print('=== 1. Column charset of goods ===')
out, _, _ = q("""
SELECT TABLE_NAME, COLUMN_NAME, CHARACTER_SET_NAME, COLLATION_NAME
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA='clothes_demo' AND TABLE_NAME='goods' AND CHARACTER_SET_NAME IS NOT NULL
""")
print(out)

# Step 2: check table charset
print('=== 2. Table charset ===')
out, _, _ = q("""
SELECT TABLE_NAME, TABLE_COLLATION
FROM information_schema.TABLES
WHERE TABLE_SCHEMA='clothes_demo' AND TABLE_NAME='goods'
""")
print(out)
