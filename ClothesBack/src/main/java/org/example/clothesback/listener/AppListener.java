package org.example.clothesback.listener;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import org.example.clothesback.util.JdbcUtils;

import java.util.logging.Logger;

/**
 * 应用启动监听:触发 {@link JdbcUtils} 静态块加载 db.properties,提前发现配置错误。
 */
@WebListener
public class AppListener implements ServletContextListener {
    private static final Logger log = Logger.getLogger(AppListener.class.getName());

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        log.info("DigitBack 启动中...");
        try {
            Class.forName(JdbcUtils.class.getName());
            log.info("数据库配置加载成功");
        } catch (ClassNotFoundException e) {
            log.severe("JdbcUtils 加载失败: " + e.getMessage());
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        log.info("DigitBack 关闭");
    }
}
