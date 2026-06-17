package org.example.clothesback.servlet.user;

import com.alibaba.fastjson2.JSONObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.clothesback.common.PageResult;
import org.example.clothesback.interceptor.AuthInterceptor;
import org.example.clothesback.service.FavoriteService;
import org.example.clothesback.servlet.BaseServlet;

import java.util.List;
import java.util.Map;

@WebServlet("/api/user/favorite/*")
public class FavoriteServlet extends BaseServlet {
    private final FavoriteService service = new FavoriteService();

    @Override
    protected void doDispatch(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        if (!AuthInterceptor.preHandle(req, resp)) return;
        Long userId = currentUser(req).getId();
        String path = req.getPathInfo();
        String method = req.getMethod();
        if (path == null || path.isEmpty() || "/".equals(path)) {
            if ("GET".equalsIgnoreCase(method)) {
                int page = parseInt(req.getParameter("page"), 1);
                int size = Math.min(parseInt(req.getParameter("size"), 20), 100);
                PageResult<Map<String, Object>> data = service.listByUser(userId, page, size);
                writeOk(resp, data);
                return;
            }
            if ("POST".equalsIgnoreCase(method)) {
                JSONObject b = readJson(req);
                service.add(userId, b.getLong("goodsId"));
                writeOk(resp, "收藏成功", null);
                return;
            }
        }
        if (path.startsWith("/") && "DELETE".equalsIgnoreCase(method)) {
            Long goodsId = Long.parseLong(path.substring(1));
            service.remove(userId, goodsId);
            writeOk(resp, "取消成功", null);
            return;
        }
        writeJson(resp, 404, "接口不存在");
    }
}
