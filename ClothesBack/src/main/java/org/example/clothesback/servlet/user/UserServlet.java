package org.example.clothesback.servlet.user;

import com.alibaba.fastjson2.JSONObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.clothesback.common.BizException;
import org.example.clothesback.dto.LoginDTO;
import org.example.clothesback.dto.RegisterDTO;
import org.example.clothesback.dto.UpdatePasswordDTO;
import org.example.clothesback.dto.UpdateUserDTO;
import org.example.clothesback.entity.User;
import org.example.clothesback.interceptor.AuthInterceptor;
import org.example.clothesback.service.UserService;
import org.example.clothesback.servlet.BaseServlet;
import org.example.clothesback.util.TokenManager;

import java.time.LocalDate;

@WebServlet("/api/user/*")
public class UserServlet extends BaseServlet {
    private final UserService userService = new UserService();

    @Override
    protected void doDispatch(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String path = req.getPathInfo();
        if (path == null) { writeJson(resp, 404, "接口不存在"); return; }
        switch (path) {
            case "/register": doRegister(req, resp); break;
            case "/login":    doLogin(req, resp); break;
            case "/logout":   doLogout(req, resp); break;
            case "/info":     doInfo(req, resp); break;
            case "/password": doUpdatePassword(req, resp); break;
            default: writeJson(resp, 404, "接口不存在");
        }
    }

    private void doRegister(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        JSONObject body = readJson(req);
        RegisterDTO dto = new RegisterDTO(
            body.getString("username"),
            body.getString("password"),
            body.getString("nickname"),
            body.getString("phone"),
            body.getString("email"));
        writeOk(resp, "注册成功", userService.register(dto));
    }

    private void doLogin(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        JSONObject body = readJson(req);
        LoginDTO dto = new LoginDTO(body.getString("username"), body.getString("password"));
        var vo = userService.login(dto);
        // HttpOnly Cookie（XSS 无法窃取），后端两种方式都支持
        jakarta.servlet.http.Cookie cookie = new jakarta.servlet.http.Cookie("token", vo.token());
        cookie.setHttpOnly(true);
        cookie.setSecure(false);
        cookie.setPath("/");
        cookie.setMaxAge(7 * 24 * 3600);
        resp.addCookie(cookie);
        writeOk(resp, "登录成功", vo);
    }

    private void doLogout(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        if (AuthInterceptor.preHandle(req, resp)) {
            userService.logout(currentToken(req));
            jakarta.servlet.http.Cookie c = new jakarta.servlet.http.Cookie("token", "");
            c.setPath("/"); c.setMaxAge(0);
            resp.addCookie(c);
            writeOk(resp, "退出成功", null);
        }
    }

    private void doInfo(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        if (!AuthInterceptor.preHandle(req, resp)) return;
        String method = req.getMethod();
        if ("PUT".equalsIgnoreCase(method)) {
            JSONObject body = readJson(req);
            UpdateUserDTO dto = new UpdateUserDTO(
                body.getString("nickname"),
                body.getString("avatar"),
                body.getString("phone"),
                body.getString("email"),
                body.getInteger("gender"),
                parseLocalDate(body.getString("birthday")));
            User u = currentUser(req);
            userService.updateProfile(u.getId(), dto);
            writeOk(resp, "修改成功", null);
        } else {
            User u = currentUser(req);
            writeOk(resp, userService.current(u.getId()));
        }
    }

    private void doUpdatePassword(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        if (!AuthInterceptor.preHandle(req, resp)) return;
        JSONObject body = readJson(req);
        UpdatePasswordDTO dto = new UpdatePasswordDTO(body.getString("oldPassword"), body.getString("newPassword"));
        userService.updatePassword(currentUser(req).getId(), dto);
        // 改完密码后让旧 token 失效(简单起见直接 remove)
        TokenManager.remove(currentToken(req));
        writeOk(resp, "修改成功", null);
    }

    /** 解析 yyyy-MM-dd 字符串 -> LocalDate,空或格式错误返回 null。 */
    private LocalDate parseLocalDate(String s) {
        if (s == null || s.isBlank()) return null;
        try { return LocalDate.parse(s.trim()); } catch (Exception e) { return null; }
    }
}
