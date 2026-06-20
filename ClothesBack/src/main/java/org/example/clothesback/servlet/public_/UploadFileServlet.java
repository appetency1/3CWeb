package org.example.clothesback.servlet.public_;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.clothesback.config.AppConfig;
import org.example.clothesback.servlet.BaseServlet;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URLDecoder;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * 提供上传文件的静态访问。
 * 将 /uploads/* 映射到 AppConfig.getUploadDir() 下的文件。
 */
@WebServlet("/uploads/*")
public class UploadFileServlet extends BaseServlet {

    @Override
    protected void doDispatch(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String pathInfo = req.getPathInfo();
        if (pathInfo == null || pathInfo.isEmpty() || "/".equals(pathInfo)) {
            writeJson(resp, 404, "文件不存在");
            return;
        }

        // 安全过滤: 拒绝 ../
        String decoded = URLDecoder.decode(pathInfo, "UTF-8");
        if (decoded.contains("..")) {
            writeJson(resp, 400, "非法路径");
            return;
        }

        Path filePath = Paths.get(AppConfig.getUploadDir(), decoded);
        File file = filePath.toFile();

        if (!file.exists() || !file.isFile()) {
            writeJson(resp, 404, "文件不存在");
            return;
        }

        // 根据扩展名推断 Content-Type
        String name = file.getName().toLowerCase();
        String contentType = "application/octet-stream";
        if (name.endsWith(".jpg") || name.endsWith(".jpeg")) contentType = "image/jpeg";
        else if (name.endsWith(".png")) contentType = "image/png";
        else if (name.endsWith(".gif")) contentType = "image/gif";
        else if (name.endsWith(".webp")) contentType = "image/webp";
        else if (name.endsWith(".svg")) contentType = "image/svg+xml";

        resp.setContentType(contentType);
        resp.setContentLengthLong(file.length());
        resp.setHeader("Cache-Control", "public, max-age=31536000");

        try (InputStream in = new FileInputStream(file);
             OutputStream out = resp.getOutputStream()) {
            byte[] buf = new byte[8192];
            int len;
            while ((len = in.read(buf)) != -1) {
                out.write(buf, 0, len);
            }
        }
    }
}
