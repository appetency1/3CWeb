package org.example.clothesback.servlet.user;

import com.alibaba.fastjson2.JSONArray;
import com.alibaba.fastjson2.JSONObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.clothesback.common.PageResult;
import org.example.clothesback.dto.CreateOrderDTO;
import org.example.clothesback.interceptor.AuthInterceptor;
import org.example.clothesback.service.OrderService;
import org.example.clothesback.servlet.BaseServlet;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet("/api/user/order/*")
public class OrderServlet extends BaseServlet {
    private final OrderService service = new OrderService();

    @Override
    protected void doDispatch(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        if (!AuthInterceptor.preHandle(req, resp)) return;
        Long userId = currentUser(req).getId();
        String path = req.getPathInfo();
        String method = req.getMethod();
        if (path == null || path.isEmpty() || "/".equals(path)) {
            if ("GET".equalsIgnoreCase(method)) { doList(userId, req, resp); return; }
            if ("POST".equalsIgnoreCase(method)) { doCreate(userId, req, resp); return; }
        }
        if (path.startsWith("/")) {
            String rest = path.substring(1);
            String[] segs = rest.split("/");
            Long id = parseLong(segs[0], -1);
            if (id > 0) {
                if (segs.length == 1) {
                    if ("GET".equalsIgnoreCase(method)) { writeOk(resp, service.detail(userId, id, false)); return; }
                }
                if (segs.length == 2) {
                    String action = segs[1];
                    if ("POST".equalsIgnoreCase(method)) {
                        switch (action) {
                            case "pay":     service.pay(userId, id);     writeOk(resp, "支付成功", null); return;
                            case "cancel":  service.cancel(userId, id);  writeOk(resp, "取消成功", null); return;
                            case "confirm": service.confirm(userId, id); writeOk(resp, "确认收货成功", null); return;
                        }
                    }
                }
            }
        }
        writeJson(resp, 404, "接口不存在");
    }

    private void doList(Long userId, HttpServletRequest req, HttpServletResponse resp) throws Exception {
        Integer status = req.getParameter("status") == null ? null : Integer.parseInt(req.getParameter("status"));
        int page = parseInt(req.getParameter("page"), 1);
        int size = Math.min(parseInt(req.getParameter("size"), 10), 100);
        PageResult<Map<String, Object>> data = service.listByUser(userId, status, page, size);
        writeOk(resp, data);
    }

    private void doCreate(Long userId, HttpServletRequest req, HttpServletResponse resp) throws Exception {
        JSONObject b = readJson(req);
        JSONArray arr = b.getJSONArray("cartIds");
        List<Long> cartIds = new ArrayList<>();
        if (arr != null) for (int i = 0; i < arr.size(); i++) cartIds.add(arr.getLong(i));
        CreateOrderDTO dto = new CreateOrderDTO(b.getLong("addressId"), cartIds, b.getString("remark"));
        String orderNo = service.create(userId, dto);
        writeOk(resp, "下单成功", java.util.Map.of("orderNo", orderNo));
    }
}
