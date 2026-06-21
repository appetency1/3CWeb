package org.example.clothesback.interceptor;

import com.alibaba.fastjson2.JSON;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.clothesback.entity.Admin;
import org.example.clothesback.util.TokenManager;

import java.io.PrintWriter;
import java.util.Map;

/**
 * 管理员鉴权:同 AuthInterceptor 但要求 Admin,且 status=1。
 */
public class AdminInterceptor {

    public static boolean preHandle(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        // 优先从 Cookie 取 token（HttpOnly Cookie 方式）
        String token = readTokenFromCookie(req);
        if (token == null) {
            String header = req.getHeader("Authorization");
            if (header != null) {
                String h = header.trim();
                if (h.regionMatches(true, 0, "Bearer ", 0, 7)) token = h.substring(7).trim();
            }
        }
        if (token == null) {
            writeForbidden(resp, 401, "未登录");
            return false;
        }
        Admin a = TokenManager.get(token);
        if (a == null) {
            writeForbidden(resp, 401, "token失效");
            return false;
        }
        if (a.getStatus() == null || a.getStatus() != 1) {
            writeForbidden(resp, 403, "账号已禁用");
            return false;
        }
        req.setAttribute("currentAdmin", a);
        req.setAttribute("currentToken", token);
        return true;
    }

    private static void writeForbidden(HttpServletResponse resp, int code, String msg) throws Exception {
        resp.setStatus(code);
        resp.setContentType("application/json;charset=UTF-8");
        try (PrintWriter w = resp.getWriter()) {
            w.write(JSON.toJSONString(Map.of("code", code, "message", msg, "data", null)));
        }
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
}
