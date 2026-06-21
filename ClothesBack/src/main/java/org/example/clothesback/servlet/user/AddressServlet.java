package org.example.clothesback.servlet.user;

import com.alibaba.fastjson2.JSONObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.clothesback.dto.AddressDTO;
import org.example.clothesback.interceptor.AuthInterceptor;
import org.example.clothesback.service.AddressService;
import org.example.clothesback.servlet.BaseServlet;

@WebServlet("/api/user/address/*")
public class AddressServlet extends BaseServlet {
    private final AddressService service = new AddressService();

    @Override
    protected void doDispatch(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        if (!AuthInterceptor.preHandle(req, resp)) return;
        Long userId = currentUser(req).getId();
        String path = req.getPathInfo();
        String method = req.getMethod();
        if (path == null || "/".equals(path) || path.isEmpty()) {
            if ("GET".equalsIgnoreCase(method)) { writeOk(resp, service.listByUser(userId)); return; }
            if ("POST".equalsIgnoreCase(method)) { create(userId, req, resp); return; }
            writeJson(resp, 405, "方法不允许");
            return;
        }
        if (path.endsWith("/default")) {
            Long id = Long.parseLong(path.substring(1, path.length() - "/default".length()));
            service.setDefault(userId, id);
            writeOk(resp, "设置成功", null);
            return;
        }
        if (path.startsWith("/")) {
            Long id = Long.parseLong(path.substring(1));
            if ("PUT".equalsIgnoreCase(method)) { update(userId, id, req, resp); return; }
            if ("DELETE".equalsIgnoreCase(method)) { service.delete(userId, id); writeOk(resp, "删除成功", null); return; }
        }
        writeJson(resp, 404, "接口不存在");
    }

    private void create(Long userId, HttpServletRequest req, HttpServletResponse resp) throws Exception {
        JSONObject b = readJson(req);
        AddressDTO dto = new AddressDTO(b.getString("receiver"), b.getString("phone"),
            b.getString("province"), b.getString("city"), b.getString("district"), b.getString("detail"),
            b.getIntValue("isDefault", 0), b.getString("tag"));
        java.util.Map<String, Object> address = service.create(userId, dto);
        writeOk(resp, "新增成功", address);
    }

    private void update(Long userId, Long id, HttpServletRequest req, HttpServletResponse resp) throws Exception {
        JSONObject b = readJson(req);
        AddressDTO dto = new AddressDTO(b.getString("receiver"), b.getString("phone"),
            b.getString("province"), b.getString("city"), b.getString("district"), b.getString("detail"),
            b.getIntValue("isDefault", 0), b.getString("tag"));
        service.update(userId, id, dto);
        writeOk(resp, "修改成功", null);
    }
}
