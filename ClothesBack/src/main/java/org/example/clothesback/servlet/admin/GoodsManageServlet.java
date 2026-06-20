package org.example.clothesback.servlet.admin;

import com.alibaba.fastjson2.JSONArray;
import com.alibaba.fastjson2.JSONObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.clothesback.common.PageResult;
import org.example.clothesback.dto.GoodsSaveDTO;
import org.example.clothesback.interceptor.AdminInterceptor;
import org.example.clothesback.service.GoodsService;
import org.example.clothesback.service.SkuService;
import org.example.clothesback.servlet.BaseServlet;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet("/api/admin/goods/*")
public class GoodsManageServlet extends BaseServlet {
    private final GoodsService goodsService = new GoodsService();
    private final SkuService skuService = new SkuService();

    @Override
    protected void doDispatch(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        if (!AdminInterceptor.preHandle(req, resp)) return;
        String path = req.getPathInfo();
        String method = req.getMethod();
        if (path == null || path.isEmpty() || "/".equals(path)) {
            if ("GET".equalsIgnoreCase(method)) { doList(req, resp); return; }
            if ("POST".equalsIgnoreCase(method)) { create(req, resp); return; }
            writeJson(resp, 405, "方法不允许"); return;
        }
        if (path.startsWith("/")) {
            String rest = path.substring(1);
            String[] segs = rest.split("/");
            Long id = parseLong(segs[0], -1);
            if (id > 0) {
                if (segs.length == 1) {
                    if ("GET".equalsIgnoreCase(method)) {
                        writeOk(resp, Map.of("goods", goodsService.detailAdmin(id), "skus", skuService.listByGoods(id)));
                        return;
                    }
                    if ("PUT".equalsIgnoreCase(method)) { update(id, req, resp); return; }
                    if ("DELETE".equalsIgnoreCase(method)) { goodsService.delete(id); writeOk(resp, "删除成功", null); return; }
                }
                if (segs.length == 2 && "status".equals(segs[1]) && "PUT".equalsIgnoreCase(method)) {
                    int status = parseInt(req.getParameter("status"), 1);
                    goodsService.changeStatus(id, status);
                    writeOk(resp, "操作成功", null);
                    return;
                }
            }
        }
        writeJson(resp, 404, "接口不存在");
    }

    private void doList(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        Long categoryId = req.getParameter("categoryId") == null ? null : Long.parseLong(req.getParameter("categoryId"));
        String keyword = req.getParameter("keyword");
        Integer status = req.getParameter("status") == null ? null : Integer.parseInt(req.getParameter("status"));
        int page = parseInt(req.getParameter("page"), 1);
        int size = Math.min(parseInt(req.getParameter("size"), 20), 100);
        PageResult<Map<String, Object>> data = goodsService.listAdmin(categoryId, keyword, status, page, size);
        writeOk(resp, data);
    }

    /** 安全将 Object 转 Integer：接受 Boolean → 0/1，null → null，Number → int */
    private Integer toInt(Object v) {
        if (v == null) return null;
        if (v instanceof Boolean) return ((Boolean) v) ? 1 : 0;
        if (v instanceof Number) return ((Number) v).intValue();
        try { return Integer.parseInt(v.toString()); } catch (Exception e) { return null; }
    }

    private GoodsSaveDTO parseDto(JSONObject b) {
        JSONArray arr = b.getJSONArray("skus");
        List<GoodsSaveDTO.SkuDTO> skus = new ArrayList<>();
        if (arr != null) for (int i = 0; i < arr.size(); i++) {
            JSONObject s = arr.getJSONObject(i);
            skus.add(new GoodsSaveDTO.SkuDTO(s.getString("spec"), s.getBigDecimal("price"),
                s.getInteger("stock"), s.getString("image"), s.getInteger("sort")));
        }
        return new GoodsSaveDTO(
            b.getLong("categoryId"), b.getString("name"), b.getString("brand"), b.getString("cover"),
            b.getString("images"), b.getString("description"), b.getString("detail"),
            b.getBigDecimal("price"), b.getBigDecimal("originalPrice"),
            toInt(b.get("stock")), toInt(b.get("isHot")), toInt(b.get("isNew")), skus);
    }

    private void create(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        Long id = goodsService.create(parseDto(readJson(req)));
        writeOk(resp, "新增成功", id == null ? null : Map.of("id", id));
    }

    private void update(Long id, HttpServletRequest req, HttpServletResponse resp) throws Exception {
        goodsService.update(id, parseDto(readJson(req)));
        writeOk(resp, "修改成功", null);
    }
}
