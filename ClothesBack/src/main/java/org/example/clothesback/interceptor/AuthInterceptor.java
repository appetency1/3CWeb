package org.example.clothesback.interceptor;

import com.alibaba.fastjson2.JSON;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.clothesback.entity.User;
import org.example.clothesback.util.TokenManager;

import java.io.PrintWriter;
import java.util.Map;

/**
 * 用户端鉴权:解析 {@code Authorization: Bearer <token>},从 {@link TokenManager} 取 User 放入 request。
 * 失败统一写 {@code {code:401, message:...}} 并返回 false,由调用方(Filter)中止链。
 */
public class AuthInterceptor {

    public static boolean preHandle(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        // 优先从 Cookie 取 token（HttpOnly Cookie 方式），兼容旧版 Authorization header
        String token = readTokenFromCookie(req);
        if (token == null) {
            String header = req.getHeader("Authorization");
            token = stripBearer(header);
        }
        if (token == null) {
            writeUnauthorized(resp, "未登录");
            return false;
        }
        User u = TokenManager.get(token);
        if (u == null) {
            writeUnauthorized(resp, "token失效");
            return false;
        }
        req.setAttribute("currentUser", u);
        req.setAttribute("currentToken", token);
        return true;
    }

    /** 从 Cookie 中读取 token（名称为 token）。 */
    private static String readTokenFromCookie(HttpServletRequest req) {
        jakarta.servlet.http.Cookie[] cookies = req.getCookies();
        if (cookies == null) return null;
        for (var c : cookies) {
            if ("token".equals(c.getName())) {
                String val = c.getValue();
                if (val != null && !val.isEmpty()) return val;
            }
        }
        return null;
    }

    private static String stripBearer(String header) {
        if (header == null) return null;
        String h = header.trim();
        if (h.regionMatches(true, 0, "Bearer ", 0, 7)) return h.substring(7).trim();
        return h;
    }

    private static void writeUnauthorized(HttpServletResponse resp, String msg) throws Exception {
        resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        resp.setContentType("application/json;charset=UTF-8");
        try (PrintWriter w = resp.getWriter()) {
            w.write(JSON.toJSONString(Map.of("code", 401, "message", msg, "data", null)));
        }
    }
}
