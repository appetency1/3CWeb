package org.example.clothesback.dao;

import org.example.clothesback.util.JdbcUtils;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class FavoriteDao {

    public List<Map<String, Object>> listByUser(Long userId, int offset, int size) throws SQLException {
        return JdbcUtils.query(
            "SELECT f.id, f.goods_id, f.create_time, g.name, g.cover, g.price, g.brand, g.original_price" +
            " FROM favorite f" +
            " LEFT JOIN goods g ON f.goods_id = g.id" +
            " WHERE f.user_id=? ORDER BY f.id DESC LIMIT ? OFFSET ?",
            userId, size, offset);
    }

    public long countByUser(Long userId) throws SQLException {
        return JdbcUtils.queryLong("SELECT COUNT(*) FROM favorite WHERE user_id=?", userId);
    }

    public Map<String, Object> findByUserAndGoods(Long userId, Long goodsId) throws SQLException {
        List<Map<String, Object>> rows = JdbcUtils.query(
            "SELECT * FROM favorite WHERE user_id=? AND goods_id=? LIMIT 1", userId, goodsId);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public int insert(Long userId, Long goodsId) throws SQLException {
        return JdbcUtils.update("INSERT INTO favorite (user_id, goods_id) VALUES (?, ?)", userId, goodsId);
    }

    public int delete(Long userId, Long goodsId) throws SQLException {
        return JdbcUtils.update("DELETE FROM favorite WHERE user_id=? AND goods_id=?", userId, goodsId);
    }

    public List<Long> goodsIdsByUser(Long userId) throws SQLException {
        List<Map<String, Object>> rows = JdbcUtils.query(
            "SELECT goods_id FROM favorite WHERE user_id=?", userId);
        List<Long> ids = new ArrayList<>(rows.size());
        for (Map<String, Object> r : rows) {
            Object v = r.get("goods_id");
            if (v != null) ids.add(((Number) v).longValue());
        }
        return ids;
    }
}
