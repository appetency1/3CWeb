package org.example.clothesback.servlet.admin;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.clothesback.interceptor.AdminInterceptor;
import org.example.clothesback.service.DashboardService;
import org.example.clothesback.servlet.BaseServlet;

@WebServlet("/api/admin/dashboard")
public class DashboardServlet extends BaseServlet {
    private final DashboardService service = new DashboardService();

    @Override
    protected void doDispatch(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        if (!AdminInterceptor.preHandle(req, resp)) return;
        writeOk(resp, service.stats());
    }
}
