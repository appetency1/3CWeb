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
        String header = req.getHeader("Authorization");
        String token = null;
        if (header != null) {
            String h = header.trim();
            if (h.regionMatches(true, 0, "Bearer ", 0, 7)) token = h.substring(7).trim();
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
}
