package org.example.clothesback.servlet.public_;

import com.alibaba.fastjson2.JSON;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import org.example.clothesback.config.AppConfig;
import org.example.clothesback.servlet.BaseServlet;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@WebServlet("/api/public/upload")
@MultipartConfig(maxFileSize = 10L * 1024 * 1024)
public class UploadServlet extends BaseServlet {

    @Override
    protected void doDispatch(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        Part part = req.getPart("file");
        if (part == null || part.getSize() == 0) {
            writeJson(resp, 400, "文件不能为空");
            return;
        }
        if (part.getSize() > AppConfig.getMaxUploadBytes()) {
            writeJson(resp, 400, "文件过大");
            return;
        }
        String original = part.getSubmittedFileName();
        String ext = "";
        if (original != null && original.contains(".")) {
            ext = original.substring(original.lastIndexOf('.')).toLowerCase();
            if (!Set.of(".jpg", ".jpeg", ".png", ".gif", ".webp").contains(ext)) {
                writeJson(resp, 400, "仅支持 jpg/png/gif/webp");
                return;
            }
        }
        String dateDir = LocalDate.now().toString().replace("-", "/");
        String name = UUID.randomUUID().toString().replace("-", "") + ext;
        Path target = Paths.get(AppConfig.getUploadDir(), dateDir, name);
        Files.createDirectories(target.getParent());
        try (InputStream in = part.getInputStream()) {
            Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
        }
        String url = "/uploads/" + dateDir + "/" + name;
        writeOk(resp, Map.of("url", url, "name", original == null ? name : original, "size", part.getSize()));
    }
}
