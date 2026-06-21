package org.example.clothesback;

import org.example.clothesback.util.JdbcUtils;
import java.util.List;
import java.util.Map;

public class JdbcEncodingTest {
    public static void main(String[] args) throws Exception {
        System.out.println("file.encoding=" + System.getProperty("file.encoding"));
        List<Map<String, Object>> rows = JdbcUtils.query(
            "SELECT id, name, brand, description FROM goods WHERE id IN (22, 24, 64)"
        );
        for (Map<String, Object> row : rows) {
            System.out.println("id=" + row.get("id"));
            System.out.println("name=" + row.get("name"));
            System.out.println("brand=" + row.get("brand"));
            System.out.println("desc=" + row.get("description"));
            System.out.println("---");
        }
    }
}
