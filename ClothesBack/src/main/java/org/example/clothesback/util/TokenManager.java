package org.example.clothesback.util;

import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Token 管理:登录态保存在内存 ConcurrentHashMap,key=token,value=用户/管理员引用。
 *
 * 教学项目简化:服务重启即清空,无 TTL、无持久化。
 */
public final class TokenManager {
    private static final ConcurrentHashMap<String, Object> STORE = new ConcurrentHashMap<>();

    private TokenManager() {}

    public static String generate() {
        return UUID.randomUUID().toString().replace("-", "");
    }

    public static void put(String token, Object principal) {
        STORE.put(token, principal);
    }

    public static <T> T get(String token) {
        if (token == null) return null;
        @SuppressWarnings("unchecked")
        T v = (T) STORE.get(token);
        return v;
    }

    public static void remove(String token) {
        if (token != null) STORE.remove(token);
    }
}
