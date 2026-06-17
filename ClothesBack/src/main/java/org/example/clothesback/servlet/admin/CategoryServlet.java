package org.example.clothesback.servlet.admin;

import com.alibaba.fastjson2.JSONObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.clothesback.dto.CategoryDTO;
import org.example.clothesback.interceptor.AdminInterceptor;
import org.example.clothesback.service.CategoryService;
import org.example.clothesback.servlet.BaseServlet;

@WebServlet("/api/admin/category/*")
public class CategoryServlet extends BaseServlet {
    private final CategoryService service = new CategoryService();

    @Override
    protected void doDispatch(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        if (!AdminInterceptor.preHandle(req, resp)) return;
        String path = req.getPathInfo();
        String method = req.getMethod();
        if (path == null || path.isEmpty() || "/".equals(path)) {
            if ("GET".equalsIgnoreCase(method)) { writeOk(resp, service.listAllFlat()); return; }
            if ("POST".equalsIgnoreCase(method)) { create(req, resp); return; }
            writeJson(resp, 405, "方法不允许"); return;
        }
        if (path.startsWith("/")) {
            Long id = Long.parseLong(path.substring(1));
            if ("PUT".equalsIgnoreCase(method)) { update(id, req, resp); return; }
            if ("DELETE".equalsIgnoreCase(method)) { service.delete(id); writeOk(resp, "删除成功", null); return; }
        }
        writeJson(resp, 404, "接口不存在");
    }

    private void create(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        JSONObject b = readJson(req);
        CategoryDTO dto = new CategoryDTO(b.getLong("parentId"), b.getString("name"),
            b.getString("icon"), b.getInteger("sort"), b.getInteger("status"));
        service.create(dto);
        writeOk(resp, "新增成功", null);
    }

    private void update(Long id, HttpServletRequest req, HttpServletResponse resp) throws Exception {
        JSONObject b = readJson(req);
        CategoryDTO dto = new CategoryDTO(b.getLong("parentId"), b.getString("name"),
            b.getString("icon"), b.getInteger("sort"), b.getInteger("status"));
        service.update(id, dto);
        writeOk(resp, "修改成功", null);
    }
}
