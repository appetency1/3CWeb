package org.example.clothesback.util;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;
import com.alibaba.fastjson2.JSONReader;
import com.alibaba.fastjson2.JSONWriter;

/**
 * Fastjson2 工具。统一序列化特性(写出 null + 驼峰),便于前端稳定解析。
 */
public final class JsonUtils {
    private JsonUtils() {}

    public static String toJson(Object obj) {
        return JSON.toJSONString(obj, JSONWriter.Feature.WriteNulls);
    }

    public static JSONObject parseObject(String json) {
        if (json == null || json.isBlank()) return new JSONObject();
        return JSON.parseObject(json, JSONObject.class, JSONReader.Feature.SupportSmartMatch);
    }

    public static <T> T parseObject(String json, Class<T> clazz) {
        if (json == null || json.isBlank()) return null;
        return JSON.parseObject(json, clazz, JSONReader.Feature.SupportSmartMatch);
    }
}
