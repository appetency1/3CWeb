package org.example.clothesback.dao;

import org.example.clothesback.util.JdbcUtils;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class CartDao {

    public List<Map<String, Object>> listByUser(Long userId) throws SQLException {
        return JdbcUtils.query(
            "SELECT * FROM cart WHERE user_id=? ORDER BY id DESC", userId);
    }

    public Map<String, Object> findById(Long id) throws SQLException {
        List<Map<String, Object>> rows = JdbcUtils.query("SELECT * FROM cart WHERE id=? LIMIT 1", id);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public Map<String, Object> findByUserAndSku(Long userId, Long skuId) throws SQLException {
        List<Map<String, Object>> rows = JdbcUtils.query(
            "SELECT * FROM cart WHERE user_id=? AND sku_id=? LIMIT 1", userId, skuId);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public int insert(Long userId, Long goodsId, Long skuId, int quantity) throws SQLException {
        return JdbcUtils.update(
            "INSERT INTO cart (user_id, goods_id, sku_id, quantity, selected) VALUES (?,?,?,?,1)",
            userId, goodsId, skuId, quantity);
    }

    public int addQuantity(Long userId, Long skuId, int quantity) throws SQLException {
        return JdbcUtils.update(
            "UPDATE cart SET quantity=quantity+? WHERE user_id=? AND sku_id=?",
            quantity, userId, skuId);
    }

    public int updateQuantity(Long id, int quantity) throws SQLException {
        return JdbcUtils.update("UPDATE cart SET quantity=? WHERE id=?", quantity, id);
    }

    public int updateSelected(Long id, int selected) throws SQLException {
        return JdbcUtils.update("UPDATE cart SET selected=? WHERE id=?", selected, id);
    }

    public int updateAllSelected(Long userId, int selected) throws SQLException {
        return JdbcUtils.update("UPDATE cart SET selected=? WHERE user_id=?", selected, userId);
    }

    public int deleteById(Connection conn, Long id) throws SQLException {
        return JdbcUtils.update(conn, "DELETE FROM cart WHERE id=?", id);
    }

    public int deleteByIds(Connection conn, Long userId, List<Long> ids) throws SQLException {
        if (ids == null || ids.isEmpty()) return 0;
        StringBuilder sb = new StringBuilder("DELETE FROM cart WHERE user_id=? AND id IN (");
        for (int i = 0; i < ids.size(); i++) {
            sb.append(i == 0 ? "?" : ",?");
        }
        sb.append(")");
        Object[] params = new Object[ids.size() + 1];
        params[0] = userId;
        for (int i = 0; i < ids.size(); i++) params[i + 1] = ids.get(i);
        return JdbcUtils.update(conn, sb.toString(), params);
    }

    public int deleteSelected(Connection conn, Long userId) throws SQLException {
        return JdbcUtils.update(conn, "DELETE FROM cart WHERE user_id=? AND selected=1", userId);
    }
}
