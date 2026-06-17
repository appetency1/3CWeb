package org.example.clothesback.util;

import java.security.MessageDigest;

/**
 * MD5 工具。统一用 UTF-8,返回 32 位小写十六进制(项目里 admin 默认密码 `e10adc3949ba59abbe56e057f20f883e` 匹配)。
 */
public final class MD5Utils {
    private static final char[] HEX = "0123456789abcdef".toCharArray();

    private MD5Utils() {}

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
