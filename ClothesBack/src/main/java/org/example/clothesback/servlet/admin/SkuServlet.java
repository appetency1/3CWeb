package org.example.clothesback.servlet.admin;

import com.alibaba.fastjson2.JSONObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.clothesback.dto.SkuDTO;
import org.example.clothesback.interceptor.AdminInterceptor;
import org.example.clothesback.service.SkuService;
import org.example.clothesback.servlet.BaseServlet;

@WebServlet("/api/admin/sku/*")
public class SkuServlet extends BaseServlet {
    private final SkuService service = new SkuService();

    @Override
    protected void doDispatch(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        if (!AdminInterceptor.preHandle(req, resp)) return;
        String path = req.getPathInfo();
        String method = req.getMethod();
        // POST /api/admin/sku?goodsId=xx  -> 新增
        if (path == null || path.isEmpty() || "/".equals(path)) {
            if ("POST".equalsIgnoreCase(method)) {
                String gid = req.getParameter("goodsId");
                if (gid == null) { writeJson(resp, 400, "goodsId必填"); return; }
                Long goodsId = Long.parseLong(gid);
                JSONObject b = readJson(req);
                service.create(goodsId, new SkuDTO(null, b.getString("spec"), b.getBigDecimal("price"),
                    b.getInteger("stock"), b.getString("image"), b.getInteger("sort")));
                writeOk(resp, "新增成功", null);
                return;
            }
            writeJson(resp, 405, "方法不允许");
            return;
        }
        if (path.startsWith("/")) {
            String rest = path.substring(1);
            String[] segs = rest.split("/");
            if (segs.length == 1) {
                Long goodsId = Long.parseLong(segs[0]);
                if ("GET".equalsIgnoreCase(method)) { writeOk(resp, service.listByGoods(goodsId)); return; }
            }
            if (segs.length == 2) {
                Long id = Long.parseLong(segs[0]);
                if ("PUT".equalsIgnoreCase(method)) {
                    JSONObject b = readJson(req);
                    service.update(id, new SkuDTO(id, b.getString("spec"), b.getBigDecimal("price"),
                        b.getInteger("stock"), b.getString("image"), b.getInteger("sort")));
                    writeOk(resp, "修改成功", null); return;
                }
                if ("DELETE".equalsIgnoreCase(method)) {
                    service.delete(id); writeOk(resp, "删除成功", null); return;
                }
            }
        }
        writeJson(resp, 404, "接口不存在");
    }
}
