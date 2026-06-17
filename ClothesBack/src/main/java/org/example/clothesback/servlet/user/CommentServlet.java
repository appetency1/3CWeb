package org.example.clothesback.servlet.user;

import com.alibaba.fastjson2.JSONArray;
import com.alibaba.fastjson2.JSONObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.clothesback.common.PageResult;
import org.example.clothesback.dto.CommentDTO;
import org.example.clothesback.interceptor.AuthInterceptor;
import org.example.clothesback.service.CommentService;
import org.example.clothesback.servlet.BaseServlet;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet("/api/user/comment/*")
public class CommentServlet extends BaseServlet {
    private final CommentService service = new CommentService();

    @Override
    protected void doDispatch(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        if (!AuthInterceptor.preHandle(req, resp)) return;
        Long userId = currentUser(req).getId();
        String path = req.getPathInfo();
        String method = req.getMethod();
        if (path == null || path.isEmpty() || "/".equals(path)) {
            if ("GET".equalsIgnoreCase(method)) {
                int page = parseInt(req.getParameter("page"), 1);
                int size = Math.min(parseInt(req.getParameter("size"), 10), 100);
                PageResult<Map<String, Object>> data = service.listByUser(userId, page, size);
                writeOk(resp, data);
                return;
            }
            if ("POST".equalsIgnoreCase(method)) {
                JSONObject b = readJson(req);
                JSONArray imgArr = b.getJSONArray("images");
                List<String> images = new ArrayList<>();
                if (imgArr != null) for (int i = 0; i < imgArr.size(); i++) images.add(imgArr.getString(i));
                CommentDTO dto = new CommentDTO(b.getLong("orderId"), b.getLong("goodsId"),
                    b.getString("content"), b.getInteger("rating"), images);
                service.add(userId, dto);
                writeOk(resp, "评价成功", null);
                return;
            }
        }
        writeJson(resp, 404, "接口不存在");
    }
}
