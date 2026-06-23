package org.example.clothesback.config;

import java.io.InputStream;
import java.util.Properties;
import java.util.logging.Logger;

/**
 * 应用配置。从 classpath 加载 app.properties(可选,不存在则用默认值)。
 */
public final class AppConfig {
    private static final Logger log = Logger.getLogger(AppConfig.class.getName());

    private static String uploadDir = System.getProperty("user.home") + "/digit-uploads";
    private static long maxUploadBytes = 5L * 1024 * 1024;

    static {
        try (InputStream in = AppConfig.class.getClassLoader().getResourceAsStream("app.properties")) {
            if (in != null) {
                Properties p = new Properties();
                p.load(in);
                if (p.getProperty("upload.dir") != null) uploadDir = p.getProperty("upload.dir");
                if (p.getProperty("upload.maxBytes") != null) {
                    maxUploadBytes = Long.parseLong(p.getProperty("upload.maxBytes"));
                }
            }
        } catch (Exception e) {
            log.warning("加载 app.properties 失败,使用默认配置: " + e.getMessage());
        }
    }

    private AppConfig() {}

    public static String getUploadDir() { return uploadDir; }
    public static long getMaxUploadBytes() { return maxUploadBytes; }
}
