<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>ClothesBack</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
               max-width: 760px; margin: 60px auto; padding: 0 24px; color: #1f2329; }
        h1 { font-size: 28px; }
        .card { border: 1px solid #e5e6eb; border-radius: 8px; padding: 16px 20px; margin: 12px 0; }
        code { background: #f2f3f5; padding: 2px 6px; border-radius: 4px; font-size: 13px; }
        .ok { color: #00b42a; }
    </style>
</head>
<body>
    <h1>ClothesBack 已启动</h1>
    <p class="ok">Servlet 6.1 + 原生 JDBC + MySQL 8 + Fastjson2</p>
    <div class="card">
        <p>默认管理员: <code>admin / 123456</code></p>
        <p>登录: <code>POST /api/admin/login</code></p>
        <p>注册: <code>POST /api/user/register</code></p>
        <p>商品: <code>GET  /api/public/goods</code></p>
    </div>
    <p style="color:#86909c;font-size:13px;">更多接口见 <code>Doc/API_DESIGN.md</code></p>
</body>
</html>
