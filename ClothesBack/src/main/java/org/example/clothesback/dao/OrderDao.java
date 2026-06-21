package org.example.clothesback.dao;

import org.example.clothesback.util.JdbcUtils;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class OrderDao {

    private static final Set<String> ALLOWED_ORDER_BY = Set.of("create_time", "pay_amount", "status");

    public Map<String, Object> findById(Long id) throws SQLException {
        List<Map<String, Object>> rows = JdbcUtils.query("SELECT * FROM orders WHERE id=? LIMIT 1", id);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public Map<String, Object> findByOrderNo(String orderNo) throws SQLException {
        List<Map<String, Object>> rows = JdbcUtils.query("SELECT * FROM orders WHERE order_no=? LIMIT 1", orderNo);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public List<Map<String, Object>> listByUser(Long userId, Integer status, int offset, int size) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT * FROM orders WHERE user_id=?");
        List<Object> params = new java.util.ArrayList<>();
        params.add(userId);
        if (status != null) { sql.append(" AND status=?"); params.add(status); }
        sql.append(" ORDER BY id DESC LIMIT ? OFFSET ?");
        params.add(size); params.add(offset);
        return JdbcUtils.query(sql.toString(), params.toArray());
    }

    public long countByUser(Long userId, Integer status) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM orders WHERE user_id=?");
        List<Object> params = new java.util.ArrayList<>();
        params.add(userId);
        if (status != null) { sql.append(" AND status=?"); params.add(status); }
        return JdbcUtils.queryLong(sql.toString(), params.toArray());
    }

    public List<Map<String, Object>> listAdmin(Integer status, String keyword, int offset, int size) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT o.id,o.order_no AS orderNo,o.user_id,o.pay_amount AS payAmount," +
            "o.total_amount AS totalAmount,o.status,o.create_time AS createTime," +
            "u.nickname AS customer," +
            "(SELECT GROUP_CONCAT(oi.goods_name SEPARATOR '、') FROM order_item oi WHERE oi.order_id = o.id) AS goods " +
            "FROM orders o LEFT JOIN user u ON o.user_id = u.id WHERE 1=1");
        List<Object> params = new java.util.ArrayList<>();
        if (status != null) { sql.append(" AND o.status=?"); params.add(status); }
        if (keyword != null && !keyword.isBlank()) { sql.append(" AND o.order_no LIKE ?"); params.add("%" + keyword + "%"); }
        sql.append(" ORDER BY o.id DESC LIMIT ? OFFSET ?");
        params.add(size); params.add(offset);
        return JdbcUtils.query(sql.toString(), params.toArray());
    }

    public long countAdmin(Integer status, String keyword) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM orders WHERE 1=1");
        List<Object> params = new java.util.ArrayList<>();
        if (status != null) { sql.append(" AND status=?"); params.add(status); }
        if (keyword != null && !keyword.isBlank()) { sql.append(" AND order_no LIKE ?"); params.add("%" + keyword + "%"); }
        return JdbcUtils.queryLong(sql.toString(), params.toArray());
    }

    public int insert(Connection conn, String orderNo, Long userId, BigDecimal totalAmount, BigDecimal payAmount,
                      BigDecimal freightAmount, BigDecimal discountAmount, String receiver, String phone,
                      String address, String remark) throws SQLException {
        return JdbcUtils.update(conn,
            "INSERT INTO orders (order_no,user_id,total_amount,pay_amount,freight_amount,discount_amount,receiver,phone,address,remark,status) " +
            "VALUES (?,?,?,?,?,?,?,?,?,?,0)",
            orderNo, userId, totalAmount, payAmount, freightAmount, discountAmount, receiver, phone, address, remark);
    }

    public Long lastInsertId(Connection conn) throws SQLException {
        return JdbcUtils.queryLong(conn, "SELECT LAST_INSERT_ID()");
    }

    public int updateStatus(Connection conn, Long id, int newStatus) throws SQLException {
        return JdbcUtils.update(conn, "UPDATE orders SET status=? WHERE id=?", newStatus, id);
    }

    public int updateStatusWithTime(Connection conn, Long id, int newStatus, String timeColumn) throws SQLException {
        if (!Set.of("pay_time", "ship_time", "finish_time", "cancel_time").contains(timeColumn)) {
            throw new IllegalArgumentException("非法时间列: " + timeColumn);
        }
        return JdbcUtils.update(conn, "UPDATE orders SET status=?," + timeColumn + "=NOW() WHERE id=?", newStatus, id);
    }

    /** 锁单行,返回 1 存在/0 不存在。 */
    public int lockById(Connection conn, Long id) throws SQLException {
        List<Map<String, Object>> rows = JdbcUtils.query(conn, "SELECT id FROM orders WHERE id=? FOR UPDATE", id);
        return rows.isEmpty() ? 0 : 1;
    }
}
