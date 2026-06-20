package org.example.clothesback.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.Arrays;

/**
 * 跨域:只允许白名单来源。默认允许 localhost 开发端口。
 * 白名单在 app.properties 中 cors.origins 配置。
 */
@WebFilter("/*")
public class CorsFilter implements Filter {
    private Set<String> allowedOrigins;

    @Override
    public void init(FilterConfig filterConfig) {
        allowedOrigins = loadAllowedOrigins();
    }

    private Set<String> loadAllowedOrigins() {
        try (InputStream in = getClass().getClassLoader().getResourceAsStream("app.properties")) {
            if (in == null) return Set.of("http://localhost:5173", "http://localhost:5174");
            Properties p = new Properties();
            p.load(in);
            String raw = p.getProperty("cors.origins", "");
            if (raw.isBlank()) return Set.of("http://localhost:5173", "http://localhost:5174");
            return Arrays.stream(raw.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .collect(Collectors.toSet());
        } catch (Exception e) {
            return Set.of("http://localhost:5173", "http://localhost:5174");
        }
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
        HttpServletResponse resp = (HttpServletResponse) res;
        HttpServletRequest httpReq = (HttpServletRequest) req;

        String origin = httpReq.getHeader("Origin");
        if (origin != null && allowedOrigins.contains(origin)) {
            resp.setHeader("Access-Control-Allow-Origin", origin);
        }
        resp.setHeader("Access-Control-Allow-Methods", "GET,POST,PUT,DELETE,OPTIONS");
        resp.setHeader("Access-Control-Allow-Headers", "Content-Type,Authorization");
        resp.setHeader("Access-Control-Allow-Credentials", "true");
        resp.setHeader("Access-Control-Max-Age", "3600");

        if ("OPTIONS".equalsIgnoreCase(httpReq.getMethod())) {
            resp.setStatus(HttpServletResponse.SC_NO_CONTENT);
            return;
        }
        chain.doFilter(req, res);
    }

    @Override
    public void destroy() {}
}
