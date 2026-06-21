package org.example.clothesback.servlet.public_;

import jakarta.servlet.annotation.WebServlet;
import org.example.clothesback.servlet.BaseServlet;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.clothesback.common.PageResult;
import org.example.clothesback.service.GoodsService;

import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

/** GET /api/public/goods  -> list
 *  GET /api/public/goods/{id} -> detail
 *  GET /api/public/goods/hot
 *  GET /api/public/goods/new */
@WebServlet("/api/public/goods/*")
public class PublicGoodsServlet extends BaseServlet {
    private final GoodsService goodsService = new GoodsService();

    @Override
    protected void doDispatch(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String path = req.getPathInfo();
        if (path == null || "/".equals(path)) { doList(req, resp); return; }
        if ("/hot".equals(path)) { doHot(req, resp); return; }
        if ("/new".equals(path)) { doNew(req, resp); return; }
        if (path.startsWith("/")) {
            Long id = parseLong(path.substring(1), -1);
            if (id > 0) { doDetail(id, req, resp); return; }
        }
        writeJson(resp, 404, "接口不存在");
    }

    private void doList(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        Long categoryId = req.getParameter("categoryId") == null ? null : Long.parseLong(req.getParameter("categoryId"));
        String keyword = decodeKeyword(req);
        String sort = req.getParameter("sort");
        int page = parseInt(req.getParameter("page"), 1);
        int size = Math.min(parseInt(req.getParameter("size"), 20), 100);
        PageResult<Map<String, Object>> data = goodsService.listPublic(categoryId, keyword, sort, page, size);
        writeOk(resp, data);
    }

    /**
     * 从原始查询字符串中按 UTF-8 解码 keyword，避免 Tomcat URIEncoding 未配置 UTF-8
     * 导致中文参数被 ISO-8859-1 解码成乱码。
     */
    private String decodeKeyword(HttpServletRequest req) {
        String qs = req.getQueryString();
        if (qs == null || qs.isEmpty()) return null;
        for (String pair : qs.split("&")) {
            int idx = pair.indexOf('=');
            if (idx > 0 && "keyword".equals(pair.substring(0, idx))) {
                String value = pair.substring(idx + 1);
                try {
                    return URLDecoder.decode(value, StandardCharsets.UTF_8);
                } catch (Exception e) {
                    return value;
                }
            }
        }
        return null;
    }

    private void doHot(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        List<Map<String, Object>> data = goodsService.listHot();
        writeOk(resp, data);
    }

    private void doNew(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        List<Map<String, Object>> data = goodsService.listNew();
        writeOk(resp, data);
    }

    private void doDetail(Long id, HttpServletRequest req, HttpServletResponse resp) throws Exception {
        writeOk(resp, goodsService.detail(id));
    }
}
