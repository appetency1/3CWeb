package org.example.clothesback.servlet.public_;

import jakarta.servlet.annotation.WebServlet;
import org.example.clothesback.service.CategoryService;
import org.example.clothesback.servlet.BaseServlet;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.util.List;
import java.util.Map;

@WebServlet("/api/public/category")
public class PublicCategoryServlet extends BaseServlet {
    private final CategoryService service = new CategoryService();

    @Override
    protected void doDispatch(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        List<Map<String, Object>> data = service.listEnabledTree();
        writeOk(resp, data);
    }
}
