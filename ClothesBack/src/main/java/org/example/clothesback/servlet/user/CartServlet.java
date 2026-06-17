package org.example.clothesback.servlet.user;

import com.alibaba.fastjson2.JSONObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.clothesback.dto.CartAddDTO;
import org.example.clothesback.interceptor.AuthInterceptor;
import org.example.clothesback.service.CartService;
import org.example.clothesback.servlet.BaseServlet;

@WebServlet("/api/user/cart/*")
public class CartServlet extends BaseServlet {
    private final CartService service = new CartService();

    @Override
    protected void doDispatch(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        if (!AuthInterceptor.preHandle(req, resp)) return;
        Long userId = currentUser(req).getId();
        String path = req.getPathInfo();
        String method = req.getMethod();
        if (path == null || path.isEmpty() || "/".equals(path)) {
            if ("GET".equalsIgnoreCase(method)) { writeOk(resp, service.listByUser(userId)); return; }
            if ("POST".equalsIgnoreCase(method)) {
                JSONObject b = readJson(req);
                service.add(userId, new CartAddDTO(b.getLong("skuId"), b.getInteger("quantity")));
                writeOk(resp, "加入成功", null);
                return;
            }
        }
        if ("/select-all".equals(path) && "PUT".equalsIgnoreCase(method)) {
            int selected = parseInt(req.getParameter("selected"), 1);
            service.selectAll(userId, selected);
            writeOk(resp, "操作成功", null); return;
        }
        if ("/selected".equals(path) && "DELETE".equalsIgnoreCase(method)) {
            service.deleteSelected(userId); writeOk(resp, "删除成功", null); return;
        }
        if (path.startsWith("/")) {
            String rest = path.substring(1);
            String[] segs = rest.split("/");
            Long id = parseLong(segs[0], -1);
            if (id > 0) {
                if (segs.length == 1) {
                    if ("PUT".equalsIgnoreCase(method)) {
                        int qty = parseInt(req.getParameter("quantity"), 1);
                        service.updateQuantity(userId, id, qty);
                        writeOk(resp, "修改成功", null); return;
                    }
                    if ("DELETE".equalsIgnoreCase(method)) {
                        service.delete(userId, id);
                        writeOk(resp, "删除成功", null); return;
                    }
                }
                if (segs.length == 2 && "/select".equals("/" + segs[1]) && "PUT".equalsIgnoreCase(method)) {
                    int selected = parseInt(req.getParameter("selected"), 1);
                    service.toggleSelect(userId, id, selected);
                    writeOk(resp, "操作成功", null); return;
                }
            }
        }
        writeJson(resp, 404, "接口不存在");
    }
}
