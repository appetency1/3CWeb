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
import java.util.Arrays;
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
        // 读全部字节（避免流被消耗后无法复制）
        byte[] fileBytes;
        try (InputStream in = part.getInputStream()) {
            fileBytes = in.readAllBytes();
        }
        if (fileBytes.length < 4) { writeJson(resp, 400, "文件内容无效"); return; }

        // 校验魔数（防止伪装扩展名）
        boolean validMagic = fileBytes[0] == (byte)0xFF && fileBytes[1] == (byte)0xD8 && fileBytes[2] == (byte)0xFF     // JPEG
            || fileBytes[0] == (byte)0x89 && fileBytes[1] == 0x50 && fileBytes[2] == 0x4E && fileBytes[3] == 0x47      // PNG
            || fileBytes[0] == 0x47 && fileBytes[1] == 0x49 && fileBytes[2] == 0x46 && fileBytes[3] == 0x38            // GIF
            || fileBytes[0] == 0x52 && fileBytes[1] == 0x49 && fileBytes[2] == 0x46 && fileBytes[3] == 0x46;          // WebP(RIFF...)
        if (!validMagic) { writeJson(resp, 400, "文件格式校验失败"); return; }

        String dateDir = LocalDate.now().toString().replace("-", "/");
        String name = UUID.randomUUID().toString().replace("-", "") + ext;
        Path target = Paths.get(AppConfig.getUploadDir(), dateDir, name);
        Files.createDirectories(target.getParent());
        Files.write(target, fileBytes);
        String url = "/uploads/" + dateDir + "/" + name;
        writeOk(resp, Map.of("url", url, "name", original == null ? name : original, "size", part.getSize()));
    }
}
