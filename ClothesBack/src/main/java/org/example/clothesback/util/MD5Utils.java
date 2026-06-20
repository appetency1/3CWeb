package org.example.clothesback.util;

import at.favre.lib.crypto.bcrypt.BCrypt;
import java.security.MessageDigest;

/**
 * 密码工具类。新密码用 BCrypt 哈希，旧 MD5 密码登录时自动升级。
 * BCrypt hash 以 "$2a$" 开头，MD5 为 32 位小写十六进制。
 */
public final class MD5Utils {
    private static final char[] HEX = "0123456789abcdef".toCharArray();
    private static final int BCRYPT_COST = 10;

    private MD5Utils() {}

    /** BCrypt 哈希。 */
    public static String hash(String password) {
        if (password == null) return null;
        return BCrypt.withDefaults().hashToString(BCRYPT_COST, password.toCharArray());
    }

    /**
     * 验证密码。兼容旧 MD5 哈希和新 BCrypt 哈希。
     * @return true 如果密码匹配
     */
    public static boolean verify(String password, String storedHash) {
        if (password == null || storedHash == null) return false;
        // BCrypt hash 以 $2 开头
        if (storedHash.startsWith("$2")) {
            return BCrypt.verifyer().verify(password.toCharArray(), storedHash).verified;
        }
        // 旧 MD5
        return md5(password).equalsIgnoreCase(storedHash);
    }

    /**
     * 判断是否需要升级（旧 MD5 → BCrypt）。
     */
    public static boolean needsUpgrade(String storedHash) {
        return storedHash != null && !storedHash.startsWith("$2");
    }

    // ── 旧 MD5 兼容（新代码不要直接调） ──
    public static String md5(String input) {
        if (input == null) return null;
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] bytes = md.digest(input.getBytes("UTF-8"));
            char[] out = new char[bytes.length * 2];
            for (int i = 0, j = 0; i < bytes.length; i++) {
                out[j++] = HEX[(bytes[i] >> 4) & 0x0F];
                out[j++] = HEX[bytes[i] & 0x0F];
            }
            return new String(out);
        } catch (Exception e) {
            throw new RuntimeException("MD5 计算失败", e);
        }
    }
}
