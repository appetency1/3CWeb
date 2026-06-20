package org.example.clothesback.servlet.admin;

import com.alibaba.fastjson2.JSONObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.clothesback.dto.LoginDTO;
import org.example.clothesback.dto.UpdatePasswordDTO;
import org.example.clothesback.interceptor.AdminInterceptor;
import org.example.clothesback.service.AdminService;
import org.example.clothesback.servlet.BaseServlet;
import org.example.clothesback.util.MD5Utils;
import org.example.clothesback.util.TokenManager;

@WebServlet("/api/admin/*")
public class AdminServlet extends BaseServlet {
    private final AdminService adminService = new AdminService();

    @Override
    protected void doDispatch(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String path = req.getPathInfo();
        if (path == null) { writeJson(resp, 404, "接口不存在"); return; }
        switch (path) {
            case "/login":    doLogin(req, resp); break;
            case "/logout":   doLogout(req, resp); break;
            case "/info":     doInfo(req, resp); break;
            case "/password": doPassword(req, resp); break;
            default: writeJson(resp, 404, "接口不存在");
        }
    }

    private void doLogin(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        JSONObject b = readJson(req);
        LoginDTO dto = new LoginDTO(b.getString("username"), b.getString("password"));
        var vo = adminService.login(dto);
        jakarta.servlet.http.Cookie cookie = new jakarta.servlet.http.Cookie("token", vo.token());
        cookie.setHttpOnly(true);
        cookie.setSecure(false);
        cookie.setPath("/");
        cookie.setMaxAge(7 * 24 * 3600);
        resp.addCookie(cookie);
        writeOk(resp, "登录成功", vo);
    }

    private void doLogout(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        if (AdminInterceptor.preHandle(req, resp)) {
            adminService.logout(currentToken(req));
            // 清除 Cookie
            jakarta.servlet.http.Cookie c = new jakarta.servlet.http.Cookie("token", "");
            c.setPath("/"); c.setMaxAge(0);
            resp.addCookie(c);
            writeOk(resp, "退出成功", null);
        }
    }

    private void doInfo(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        if (!AdminInterceptor.preHandle(req, resp)) return;
        writeOk(resp, adminService.current(currentAdmin(req).getId()));
    }

    private void doPassword(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        if (!AdminInterceptor.preHandle(req, resp)) return;
        JSONObject b = readJson(req);
        UpdatePasswordDTO dto = new UpdatePasswordDTO(b.getString("oldPassword"), b.getString("newPassword"));
        // 管理员修改密码:复用 UserService 风格直接调
        // 这里为了简明,直接用 adminDao 改
        try {
            var admin = currentAdmin(req);
            var adminDao = new org.example.clothesback.dao.AdminDao();
            var row = adminDao.findByUsernameWithPwd(admin.getUsername());
            if (row == null) throw new org.example.clothesback.common.BizException(404, "管理员不存在");
            if (!MD5Utils.verify(dto.oldPassword(), String.valueOf(row.get("password")))) {
                throw new org.example.clothesback.common.BizException(400, "原密码错误");
            }
            org.example.clothesback.util.JdbcUtils.update(
                "UPDATE admin SET password=? WHERE id=?", MD5Utils.hash(dto.newPassword()), admin.getId());
            TokenManager.remove(currentToken(req));
            writeOk(resp, "修改成功", null);
        } catch (java.sql.SQLException e) {
            writeJson(resp, 500, "修改失败");
        }
    }

}
