package org.example.clothesback.servlet.admin;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.clothesback.common.BizException;
import org.example.clothesback.common.PageResult;
import org.example.clothesback.common.ResultCode;
import org.example.clothesback.interceptor.AdminInterceptor;
import org.example.clothesback.servlet.BaseServlet;
import org.example.clothesback.util.JdbcUtils;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

@WebServlet("/api/admin/user/*")
public class UserManageServlet extends BaseServlet {
    @Override
    protected void doDispatch(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        if (!AdminInterceptor.preHandle(req, resp)) return;
        String path = req.getPathInfo();
        String method = req.getMethod();
        if (path == null || path.isEmpty() || "/".equals(path)) {
            if ("GET".equalsIgnoreCase(method)) { doList(req, resp); return; }
        }
        if (path != null && path.startsWith("/")) {
            String[] segs = path.substring(1).split("/");
            if (segs.length >= 1) {
                Long id = parseLong(segs[0], -1);
                if (id > 0) {
                    if (segs.length == 1 && "GET".equalsIgnoreCase(method)) {
                        try {
                            Map<String, Object> row = JdbcUtils.query("SELECT id, username, nickname, avatar, phone, email, gender, birthday, status, create_time FROM user WHERE id=? LIMIT 1", id)
                                .stream().findFirst().orElse(null);
                            if (row == null) throw new BizException(ResultCode.NOT_FOUND, "用户不存在");
                            writeOk(resp, row);
                        } catch (SQLException e) { writeJson(resp, 500, "查询失败"); }
                        return;
                    }
                    if (segs.length == 2 && "status".equals(segs[1]) && "PUT".equalsIgnoreCase(method)) {
                        int status = parseInt(req.getParameter("status"), 1);
                        try {
                            int n = JdbcUtils.update("UPDATE user SET status=? WHERE id=?", status, id);
                            if (n == 0) throw new BizException(ResultCode.NOT_FOUND, "用户不存在");
                            writeOk(resp, "操作成功", null);
                        } catch (SQLException e) { writeJson(resp, 500, "操作失败"); }
                        return;
                    }
                }
            }
        }
        writeJson(resp, 404, "接口不存在");
    }

    private void doList(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String keyword = req.getParameter("keyword");
        Integer status = req.getParameter("status") == null ? null : Integer.parseInt(req.getParameter("status"));
        int page = parseInt(req.getParameter("page"), 1);
        int size = Math.min(parseInt(req.getParameter("size"), 20), 100);
        int offset = (page - 1) * size;
        StringBuilder where = new StringBuilder(" WHERE 1=1");
        java.util.List<Object> params = new java.util.ArrayList<>();
        if (keyword != null && !keyword.isBlank()) {
            where.append(" AND (username LIKE ? OR nickname LIKE ? OR phone LIKE ?)");
            String kw = "%" + keyword + "%";
            params.add(kw); params.add(kw); params.add(kw);
        }
        if (status != null) { where.append(" AND status=?"); params.add(status); }
        try {
            long total = JdbcUtils.queryLong("SELECT COUNT(*) FROM user" + where, params.toArray());
            String sql = "SELECT id, username, nickname, avatar, phone, email, gender, birthday, status, create_time FROM user" + where + " ORDER BY id DESC LIMIT ? OFFSET ?";
            params.add(size); params.add(offset);
            List<Map<String, Object>> rows = JdbcUtils.query(sql, params.toArray());
            writeOk(resp, new PageResult<>(rows, total, page, size));
        } catch (SQLException e) { writeJson(resp, 500, "查询失败"); }
    }
}
