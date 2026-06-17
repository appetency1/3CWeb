package org.example.clothesback.servlet.admin;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.clothesback.common.PageResult;
import org.example.clothesback.interceptor.AdminInterceptor;
import org.example.clothesback.service.OrderService;
import org.example.clothesback.servlet.BaseServlet;

import java.util.Map;

@WebServlet("/api/admin/order/*")
public class OrderManageServlet extends BaseServlet {
    private final OrderService service = new OrderService();

    @Override
    protected void doDispatch(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        if (!AdminInterceptor.preHandle(req, resp)) return;
        String path = req.getPathInfo();
        String method = req.getMethod();
        if (path == null || path.isEmpty() || "/".equals(path)) {
            if ("GET".equalsIgnoreCase(method)) {
                Integer status = req.getParameter("status") == null ? null : Integer.parseInt(req.getParameter("status"));
                String keyword = req.getParameter("keyword");
                int page = parseInt(req.getParameter("page"), 1);
                int size = Math.min(parseInt(req.getParameter("size"), 20), 100);
                PageResult<Map<String, Object>> data = service.listAdmin(status, keyword, page, size);
                writeOk(resp, data);
                return;
            }
        }
        if (path != null && path.startsWith("/")) {
            String[] segs = path.substring(1).split("/");
            if (segs.length >= 1) {
                Long id = parseLong(segs[0], -1);
                if (id > 0 && segs.length == 1 && "GET".equalsIgnoreCase(method)) {
                    writeOk(resp, service.detail(null, id, true));
                    return;
                }
                if (id > 0 && segs.length == 2 && "POST".equalsIgnoreCase(method)) {
                    switch (segs[1]) {
                        case "ship":   service.ship(id);   writeOk(resp, "已发货", null); return;
                        case "refund": service.refund(id); writeOk(resp, "已退款", null); return;
                    }
                }
            }
        }
        writeJson(resp, 404, "接口不存在");
    }
}
