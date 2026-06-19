package org.example.clothesback.service;

import org.example.clothesback.common.BizException;
import org.example.clothesback.common.ResultCode;
import org.example.clothesback.util.JdbcUtils;

import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

public class DashboardService {

    public Map<String, Object> stats() {
        try {
            Map<String, Object> out = new HashMap<>();
            out.put("userCount", JdbcUtils.queryLong("SELECT COUNT(*) FROM user"));
            out.put("orderCount", JdbcUtils.queryLong("SELECT COUNT(*) FROM orders"));
            out.put("goodsCount", JdbcUtils.queryLong("SELECT COUNT(*) FROM goods"));
            out.put("totalSales", sumSales(null));
            LocalDate today = LocalDate.now();
            LocalDateTime start = today.atStartOfDay();
            LocalDateTime end = today.plusDays(1).atStartOfDay();
            out.put("todayOrders", JdbcUtils.queryLong(
                "SELECT COUNT(*) FROM orders WHERE create_time >= ? AND create_time < ?", start, end));
            out.put("todaySales", sumSales("AND create_time >= ? AND create_time < ?"));
            return out;
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "查询失败");
        }
    }

    private Object sumSales(String where) throws SQLException {
        if (where == null) {
            return JdbcUtils.query("SELECT IFNULL(SUM(pay_amount),0) AS s FROM orders WHERE status IN (1,2,3)")
                .get(0).get("s");
        }
        if (where.contains("?")) {
            return JdbcUtils.query("SELECT IFNULL(SUM(pay_amount),0) AS s FROM orders WHERE status IN (1,2,3) " + where,
                    java.time.LocalDate.now().atStartOfDay(),
                    java.time.LocalDate.now().plusDays(1).atStartOfDay())
                .get(0).get("s");
        }
        return 0;
    }
}
