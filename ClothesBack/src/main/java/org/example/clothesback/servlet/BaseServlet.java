package org.example.clothesback.servlet;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.clothesback.common.BizException;
import org.example.clothesback.common.Result;
import org.example.clothesback.entity.Admin;
import org.example.clothesback.entity.User;
import org.example.clothesback.util.MapKeyConverter;

import java.io.BufferedReader;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.logging.Logger;

/**
 * 公共 Servlet 基类:统一 JSON 解析/写出/错误兜底。子类只需实现 {@link #doDispatch}。
 */
public abstract class BaseServlet extends HttpServlet {
    protected final Logger log = Logger.getLogger(getClass().getName());

    @Override
    protected final void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        handle(req, resp);
    }

    @Override
    protected final void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        handle(req, resp);
    }

    @Override
    protected final void doPut(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        handle(req, resp);
    }

    @Override
    protected final void doDelete(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        handle(req, resp);
    }

    private void handle(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        try {
            req.setCharacterEncoding("UTF-8");
            resp.setCharacterEncoding("UTF-8");
            doDispatch(req, resp);
        } catch (BizException e) {
            writeJson(resp, Result.error(e.getCode(), e.getMessage()));
        } catch (Exception e) {
            log.severe("unhandled: " + e);
            log.severe(java.util.Arrays.toString(e.getStackTrace()));
            writeJson(resp, Result.error(500, "服务器繁忙，请稍后重试"));
        }
    }

    /** 子类实现具体路由。 */
    protected abstract void doDispatch(HttpServletRequest req, HttpServletResponse resp) throws Exception;

    /** 读取 JSON 请求体。读不到内容时返回空对象(避免后续 NPE)。 */
    protected JSONObject readJson(HttpServletRequest req) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader r = req.getReader()) {
            String line;
            while ((line = r.readLine()) != null) sb.append(line);
        }
        if (sb.length() == 0) return new JSONObject();
        return JSONObject.parseObject(sb.toString());
    }

    protected void writeJson(HttpServletResponse resp, Object data) throws IOException {
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");
        // 两阶段: 序列化 → 解析 → 转换 snake_case → 再序列化
        // 确保 POJO(Result/PageResult/VO)内部嵌套的 Map key 也被转换
        String json = JSON.toJSONString(data);
        Object parsed = JSON.parse(json);
        resp.getWriter().write(JSON.toJSONString(MapKeyConverter.toCamelCase(parsed)));
    }

    protected void writeJson(HttpServletResponse resp, int code, String message) throws IOException {
        writeJson(resp, Result.error(code, message));
    }

    protected void writeJson(HttpServletResponse resp, int code, String message, Object data) throws IOException {
        writeJson(resp, new Result<>(code, message, data));
    }

    protected void writeOk(HttpServletResponse resp, Object data) throws IOException {
        writeJson(resp, Result.success(data));
    }

    protected void writeOk(HttpServletResponse resp, String message, Object data) throws IOException {
        writeJson(resp, Result.success(message, data));
    }

    protected User currentUser(HttpServletRequest req) {
        return (User) req.getAttribute("currentUser");
    }

    protected Admin currentAdmin(HttpServletRequest req) {
        return (Admin) req.getAttribute("currentAdmin");
    }

    protected String currentToken(HttpServletRequest req) {
        Object t = req.getAttribute("currentToken");
        return t == null ? null : t.toString();
    }

    protected int parseInt(String s, int def) {
        if (s == null) return def;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return def; }
    }

    protected long parseLong(String s, long def) {
        if (s == null) return def;
        try { return Long.parseLong(s.trim()); } catch (NumberFormatException e) { return def; }
    }
}
