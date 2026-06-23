package org.example.clothesback.servlet.public_;

import jakarta.servlet.annotation.WebServlet;
import org.example.clothesback.dao.SpuDao;
import org.example.clothesback.servlet.BaseServlet;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.clothesback.common.PageResult;

import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

/**
 * GET /api/public/spu       -> SPU 列表
 * GET /api/public/spu/{id}  -> SPU 详情（含所有 SKU）
 * GET /api/public/spu/hot   -> 热门 SPU
 * GET /api/public/spu/new   -> 新品 SPU
 *
 * 兼容旧路径：/api/public/goods/* 重定向到 /api/public/spu/*
 */
@WebServlet({"/api/public/spu/*", "/api/public/goods/*"})
public class PublicGoodsServlet extends BaseServlet {
    private final SpuDao spuDao = new SpuDao();

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

    /** SPU 列表：每个 SPU 一条，含最低价/最高价/SKU数 */
    private void doList(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        Long categoryId = req.getParameter("categoryId") == null ? null : Long.parseLong(req.getParameter("categoryId"));
        String keyword = decodeKeyword(req);
        String sort = req.getParameter("sort");
        int page = parseInt(req.getParameter("page"), 1);
        int size = Math.min(parseInt(req.getParameter("size"), 20), 100);
        int offset = (page - 1) * size;
        List<Map<String, Object>> rows = spuDao.listPublic(categoryId, keyword, sort, offset, size);
        long total = spuDao.countPublic(categoryId, keyword);
        writeOk(resp, new PageResult<>(rows, total, page, size));
    }

    /** SPU 详情：SPU 信息 + 该 SPU 下所有 SKU */
    private void doDetail(Long id, HttpServletRequest req, HttpServletResponse resp) throws Exception {
        Map<String, Object> spu = spuDao.findById(id);
        if (spu == null) {
            // 兼容：如果 id 是 goods_id，尝试查找所属 SPU
            spu = spuDao.findByGoodsId(id);
            if (spu == null) { writeJson(resp, 404, "商品不存在"); return; }
        }
        List<Map<String, Object>> skus = spuDao.listSkusBySpu((Long) spu.get("id"));
        spu.put("skus", skus);
        writeOk(resp, spu);
    }

    /** 热门 SPU */
    private void doHot(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        List<Map<String, Object>> data = spuDao.listHot(10);
        writeOk(resp, data);
    }

    /** 新品 SPU */
    private void doNew(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        List<Map<String, Object>> data = spuDao.listNew(10);
        writeOk(resp, data);
    }

    private String decodeKeyword(HttpServletRequest req) {
        String qs = req.getQueryString();
        if (qs == null || qs.isEmpty()) return null;
        for (String pair : qs.split("&")) {
            int idx = pair.indexOf('=');
            if (idx > 0 && "keyword".equals(pair.substring(0, idx))) {
                String value = pair.substring(idx + 1);
                try { return URLDecoder.decode(value, StandardCharsets.UTF_8); }
                catch (Exception e) { return value; }
            }
        }
        return null;
    }
}
