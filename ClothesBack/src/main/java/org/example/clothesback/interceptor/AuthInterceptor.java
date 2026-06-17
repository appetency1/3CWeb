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
        String header = req.getHeader("Authorization");
        String token = stripBearer(header);
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
