package org.example.clothesback.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;

import java.io.IOException;

/**
 * 字符编码:请求/响应统一 UTF-8。已用 getReader/getWriter 读 JSON body 的不需要额外处理。
 */
@WebFilter("/*")
public class EncodingFilter implements Filter {
    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
        req.setCharacterEncoding("UTF-8");
        res.setCharacterEncoding("UTF-8");
        // Tomcat 10 默认 Content-Type 是 text/plain;charset=ISO-8859-1，导致前端 axios 当 latin1 解码
        // 显式声明 application/json;charset=UTF-8
        if (res instanceof jakarta.servlet.http.HttpServletResponse hres) {
            if (hres.getContentType() == null) {
                hres.setContentType("application/json;charset=UTF-8");
            } else if (!hres.getContentType().toLowerCase().contains("charset")) {
                hres.setContentType(hres.getContentType() + ";charset=UTF-8");
            }
        }
        chain.doFilter(req, res);
    }
}
