package org.example.clothesback.util;

import java.lang.reflect.Field;
import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * ResultSet / Map → Bean 工具。支持驼峰/下划线列名,基本类型自动转换。
 */
public final class BeanUtils {
    private BeanUtils() {}

    public static <T> T mapToBean(Map<String, Object> row, Class<T> clazz) {
        if (row == null) return null;
        try {
            T bean = clazz.getDeclaredConstructor().newInstance();
            for (Map.Entry<String, Object> e : row.entrySet()) {
                String col = e.getKey();
                Object val = e.getValue();
                if (val == null) continue;
                String fieldName = camelize(col);
                Field f = findField(clazz, fieldName);
                if (f == null) continue;
                f.setAccessible(true);
                f.set(bean, convert(val, f.getType()));
            }
            return bean;
        } catch (Exception ex) {
            throw new RuntimeException("Map → Bean 失败: " + clazz.getSimpleName(), ex);
        }
    }

    public static <T> T rsToBean(ResultSet rs, Class<T> clazz) throws SQLException {
        Map<String, Object> row = rsToMap(rs);
        return mapToBean(row, clazz);
    }

    public static Map<String, Object> rsToMap(ResultSet rs) throws SQLException {
        ResultSetMetaData md = rs.getMetaData();
        int cols = md.getColumnCount();
        Map<String, Object> row = new LinkedHashMap<>();
        for (int i = 1; i <= cols; i++) {
            row.put(md.getColumnLabel(i), rs.getObject(i));
        }
        return row;
    }

    private static Field findField(Class<?> clazz, String name) {
        for (Class<?> c = clazz; c != null && c != Object.class; c = c.getSuperclass()) {
            try {
                return c.getDeclaredField(name);
            } catch (NoSuchFieldException ignored) {}
        }
        return null;
    }

    private static String camelize(String s) {
        if (s == null) return null;
        StringBuilder sb = new StringBuilder(s.length());
        boolean upper = false;
        for (int i = 0; i < s.length(); i++) {
            char ch = s.charAt(i);
            if (ch == '_') { upper = true; continue; }
            sb.append(upper ? Character.toUpperCase(ch) : Character.toLowerCase(ch));
            upper = false;
        }
        return sb.toString();
    }

    private static Object convert(Object val, Class<?> target) {
        if (val == null) return null;
        if (target.isInstance(val)) return val;
        if (val instanceof Timestamp ts) {
            if (target == LocalDateTime.class) return ts.toLocalDateTime();
            if (target == LocalDate.class) return ts.toLocalDateTime().toLocalDate();
            if (target == LocalTime.class) return ts.toLocalDateTime().toLocalTime();
            if (target == java.util.Date.class) return ts;
        }
        if (val instanceof java.sql.Date d) {
            if (target == LocalDate.class) return d.toLocalDate();
            if (target == java.util.Date.class) return d;
        }
        if (val instanceof Number n) {
            if (target == Integer.class || target == int.class) return n.intValue();
            if (target == Long.class || target == long.class) return n.longValue();
            if (target == Double.class || target == double.class) return n.doubleValue();
            if (target == Float.class || target == float.class) return n.floatValue();
            if (target == Short.class || target == short.class) return n.shortValue();
            if (target == Byte.class || target == byte.class) return n.byteValue();
            if (target == BigDecimal.class) {
                if (val instanceof BigDecimal bd) return bd;
                return new BigDecimal(n.toString());
            }
        }
        if (target == Integer.class || target == int.class) return Integer.parseInt(val.toString());
        if (target == Long.class || target == long.class) return Long.parseLong(val.toString());
        if (target == BigDecimal.class) return new BigDecimal(val.toString());
        if (target == Boolean.class || target == boolean.class) {
            if (val instanceof Number n) return n.intValue() != 0;
            return Boolean.parseBoolean(val.toString());
        }
        if (target == LocalDateTime.class) {
            if (val instanceof java.util.Date d) return LocalDateTime.ofInstant(d.toInstant(), java.time.ZoneId.systemDefault());
        }
        return val;
    }
}
