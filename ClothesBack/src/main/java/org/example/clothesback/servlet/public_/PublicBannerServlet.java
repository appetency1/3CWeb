package org.example.clothesback.servlet.public_;

import jakarta.servlet.annotation.WebServlet;
import org.example.clothesback.common.PageResult;
import org.example.clothesback.service.BannerService;
import org.example.clothesback.servlet.BaseServlet;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.util.List;
import java.util.Map;

@WebServlet("/api/public/banner")
public class PublicBannerServlet extends BaseServlet {
    private final BannerService service = new BannerService();

    @Override
    protected void doDispatch(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        List<Map<String, Object>> data = service.listEnabled();
        writeOk(resp, data);
    }
}
