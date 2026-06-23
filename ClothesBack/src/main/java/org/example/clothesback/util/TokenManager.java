package org.example.clothesback.util;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;
import org.example.clothesback.dao.AdminDao;
import org.example.clothesback.dao.UserDao;
import org.example.clothesback.entity.Admin;
import org.example.clothesback.entity.User;
import org.example.clothesback.util.BeanUtils;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Token 管理:登录态存储在文件中，服务重启不丢失。
 * 文件路径: ${user.home}/.digit_tokens.json
 */
public final class TokenManager {
    private static final ConcurrentHashMap<String, Object> STORE = new ConcurrentHashMap<>();
    private static final Path FILE_PATH = Paths.get(System.getProperty("user.home"), ".digit_tokens.json");
    private static final UserDao USER_DAO = new UserDao();
    private static final AdminDao ADMIN_DAO = new AdminDao();
    private static boolean loaded = false;

    private TokenManager() {}

    public static String generate() {
        return UUID.randomUUID().toString().replace("-", "");
    }

    public static void put(String token, Object principal) {
        STORE.put(token, principal);
        saveToFile();
    }

    @SuppressWarnings("unchecked")
    public static <T> T get(String token) {
        if (token == null) return null;
        // 内存中有，直接返回
        Object cached = STORE.get(token);
        if (cached != null) return (T) cached;
        // 尝试从文件恢复
        loadFromFile();
        Object restored = STORE.get(token);
        return (T) restored;
    }

    public static void remove(String token) {
        if (token != null) {
            STORE.remove(token);
            saveToFile();
        }
    }

    private static synchronized void loadFromFile() {
        if (loaded) return;
        loaded = true;
        try {
            File f = FILE_PATH.toFile();
            if (!f.exists()) return;
            String json = Files.readString(FILE_PATH);
            JSONObject map = JSON.parseObject(json);
            if (map == null) return;
            for (Map.Entry<String, Object> e : map.entrySet()) {
                String token = e.getKey();
                JSONObject info = (JSONObject) e.getValue();
                if (info == null) continue;
                String type = info.getString("type");
                Long id = info.getLong("id");
                if (type == null || id == null) continue;
                try {
                    if ("user".equals(type)) {
                        var row = USER_DAO.findByIdWithPwd(id);
                        if (row != null) {
                            User u = BeanUtils.mapToBean(row, User.class);
                            STORE.put(token, u);
                        }
                    } else if ("admin".equals(type)) {
                        var row = ADMIN_DAO.findById(id);
                        if (row != null) {
                            Admin a = BeanUtils.mapToBean(row, Admin.class);
                            STORE.put(token, a);
                        }
                    }
                } catch (Exception ignored) {}
            }
        } catch (Exception ignored) {}
    }

    private static void saveToFile() {
        try {
            JSONObject map = new JSONObject();
            for (Map.Entry<String, Object> e : STORE.entrySet()) {
                Object p = e.getValue();
                if (p == null) continue;
                JSONObject info = new JSONObject();
                if (p instanceof User u) {
                    info.put("type", "user");
                    info.put("id", u.getId());
                } else if (p instanceof Admin a) {
                    info.put("type", "admin");
                    info.put("id", a.getId());
                } else {
                    continue;
                }
                map.put(e.getKey(), info);
            }
            Files.createDirectories(FILE_PATH.getParent());
            Files.writeString(FILE_PATH, JSON.toJSONString(map));
        } catch (Exception ignored) {}
    }
}
