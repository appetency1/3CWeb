package org.example.clothesback.dao;

import org.example.clothesback.util.JdbcUtils;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class OrderItemDao {

    public List<Map<String, Object>> listByOrder(Long orderId) throws SQLException {
        return JdbcUtils.query("SELECT * FROM order_item WHERE order_id=? ORDER BY id ASC", orderId);
    }

    public List<Map<String, Object>> listByOrderIds(List<Long> orderIds) throws SQLException {
        if (orderIds == null || orderIds.isEmpty()) return new ArrayList<>();
        StringBuilder sb = new StringBuilder("SELECT * FROM order_item WHERE order_id IN (");
        for (int i = 0; i < orderIds.size(); i++) sb.append(i == 0 ? "?" : ",?");
        sb.append(") ORDER BY order_id ASC, id ASC");
        return JdbcUtils.query(sb.toString(), orderIds.toArray());
    }

    public int insert(Connection conn, Long orderId, Long goodsId, Long skuId, String goodsName,
                      String goodsCover, String spec, BigDecimal price, int quantity, BigDecimal subtotal) throws SQLException {
        return JdbcUtils.update(conn,
            "INSERT INTO order_item (order_id, goods_id, sku_id, goods_name, goods_cover, spec, price, quantity, subtotal) " +
            "VALUES (?,?,?,?,?,?,?,?,?)",
            orderId, goodsId, skuId, goodsName, goodsCover, spec, price, quantity, subtotal);
    }
}
