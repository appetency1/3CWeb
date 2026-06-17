package org.example.clothesback.dao;

import org.example.clothesback.util.JdbcUtils;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class CategoryDao {

    public List<Map<String, Object>> listAll() throws SQLException {
        return JdbcUtils.query("SELECT * FROM category ORDER BY parent_id ASC, sort ASC, id ASC");
    }

    public List<Map<String, Object>> listEnabled() throws SQLException {
        return JdbcUtils.query("SELECT * FROM category WHERE status=1 ORDER BY parent_id ASC, sort ASC, id ASC");
    }

    public Map<String, Object> findById(Long id) throws SQLException {
        List<Map<String, Object>> rows = JdbcUtils.query(
            "SELECT * FROM category WHERE id = ? LIMIT 1", id);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public List<Map<String, Object>> listByParent(Long parentId) throws SQLException {
        return JdbcUtils.query(
            "SELECT * FROM category WHERE parent_id=? AND status=1 ORDER BY sort ASC, id ASC", parentId);
    }

    public int countChildren(Long parentId) throws SQLException {
        return JdbcUtils.queryLong("SELECT COUNT(*) FROM category WHERE parent_id=?", parentId).intValue();
    }

    public int countGoods(Long categoryId) throws SQLException {
        return JdbcUtils.queryLong("SELECT COUNT(*) FROM goods WHERE category_id=?", categoryId).intValue();
    }

    public int insert(Connection conn, Long parentId, String name, String icon, Integer sort, Integer status) throws SQLException {
        return JdbcUtils.update(conn,
            "INSERT INTO category (parent_id, name, icon, sort, status) VALUES (?, ?, ?, ?, ?)",
            parentId, name, icon, sort == null ? 0 : sort, status == null ? 1 : status);
    }

    public int update(Connection conn, Long id, Long parentId, String name, String icon, Integer sort, Integer status) throws SQLException {
        return JdbcUtils.update(conn,
            "UPDATE category SET parent_id=?, name=?, icon=?, sort=?, status=? WHERE id=?",
            parentId, name, icon, sort, status, id);
    }

    public int delete(Connection conn, Long id) throws SQLException {
        return JdbcUtils.update(conn, "DELETE FROM category WHERE id=?", id);
    }
}
