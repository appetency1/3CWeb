package org.example.clothesback.util;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 递归将 Map 的 snake_case 键转换为 camelCase。
 * <p>用于 BaseServlet 写出 JSON 前统一转换，解决后端 DAO 返回 Map
 * （数据库 snake_case 列名）与前端 TS 类型（camelCase）不匹配的问题。</p>
 */
public class MapKeyConverter {

    /**
     * 递归转换对象中所有 Map 的 key：snake_case → camelCase。
     * 支持嵌套 Map / List / 普通对象。
     */
    @SuppressWarnings("unchecked")
    public static Object toCamelCase(Object obj) {
        if (obj == null) {
            return null;
        }
        if (obj instanceof Map) {
            Map<String, Object> map = (Map<String, Object>) obj;
            Map<String, Object> result = new HashMap<>(map.size());
            for (Map.Entry<String, Object> entry : map.entrySet()) {
                result.put(snakeToCamel(entry.getKey()), toCamelCase(entry.getValue()));
            }
            return result;
        }
        if (obj instanceof List) {
            List<Object> list = (List<Object>) obj;
            return list.stream()
                    .map(MapKeyConverter::toCamelCase)
                    .collect(Collectors.toCollection(ArrayList::new));
        }
        // 基本类型 / 普通对象 → 直接返回
        return obj;
    }

    /**
     * 将 snake_case 字符串转换为 camelCase。
     * <pre>
     *   "user_id"      → "userId"
     *   "created_at"   → "createdAt"
     *   "is_hot"       → "isHot"
     *   "goods_name"   → "goodsName"
     *   "order_no"     → "orderNo"
     * </pre>
     */
    static String snakeToCamel(String snake) {
        if (snake == null || snake.isEmpty() || !snake.contains("_")) {
            return snake;
        }
        StringBuilder sb = new StringBuilder(snake.length());
        boolean nextUpper = false;
        for (int i = 0; i < snake.length(); i++) {
            char c = snake.charAt(i);
            if (c == '_') {
                nextUpper = true;
            } else if (nextUpper) {
                sb.append(Character.toUpperCase(c));
                nextUpper = false;
            } else {
                sb.append(c);
            }
        }
        return sb.toString();
    }
}
