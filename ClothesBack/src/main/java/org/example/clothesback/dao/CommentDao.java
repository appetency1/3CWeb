package org.example.clothesback.dao;

import org.example.clothesback.util.JdbcUtils;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class CommentDao {

    public List<Map<String, Object>> listByGoods(Long goodsId, int offset, int size) throws SQLException {
        return JdbcUtils.query(
            "SELECT * FROM comment WHERE goods_id=? ORDER BY id DESC LIMIT ? OFFSET ?",
            goodsId, size, offset);
    }

    public long countByGoods(Long goodsId) throws SQLException {
        return JdbcUtils.queryLong("SELECT COUNT(*) FROM comment WHERE goods_id=?", goodsId);
    }

    public List<Map<String, Object>> listByUser(Long userId, int offset, int size) throws SQLException {
        return JdbcUtils.query(
            "SELECT * FROM comment WHERE user_id=? ORDER BY id DESC LIMIT ? OFFSET ?",
            userId, size, offset);
    }

    public long countByUser(Long userId) throws SQLException {
        return JdbcUtils.queryLong("SELECT COUNT(*) FROM comment WHERE user_id=?", userId);
    }

    public int insert(Long userId, Long goodsId, Long orderId, String content, Integer rating, String images) throws SQLException {
        return JdbcUtils.update(
            "INSERT INTO comment (user_id, goods_id, order_id, content, rating, images) VALUES (?,?,?,?,?,?)",
            userId, goodsId, orderId, content, rating, images);
    }

    public boolean existsByOrderAndGoods(Long userId, Long orderId, Long goodsId) throws SQLException {
        return JdbcUtils.queryLong(
            "SELECT COUNT(*) FROM comment WHERE user_id=? AND order_id=? AND goods_id=?",
            userId, orderId, goodsId) > 0;
    }

    public List<Long> goodsIdsByIds(List<Long> ids) throws SQLException {
        if (ids == null || ids.isEmpty()) return new ArrayList<>();
        StringBuilder sb = new StringBuilder("SELECT goods_id FROM comment WHERE id IN (");
        for (int i = 0; i < ids.size(); i++) sb.append(i == 0 ? "?" : ",?");
        sb.append(")");
        List<Map<String, Object>> rows = JdbcUtils.query(sb.toString(), ids.toArray());
        List<Long> out = new ArrayList<>(rows.size());
        for (Map<String, Object> r : rows) {
            Object v = r.get("goods_id");
            if (v != null) out.add(((Number) v).longValue());
        }
        return out;
    }
}
