package org.example.clothesback.dao;

import org.example.clothesback.util.JdbcUtils;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public class AdminDao {

    public Map<String, Object> findByUsername(String username) throws SQLException {
        List<Map<String, Object>> rows = JdbcUtils.query(
            "SELECT * FROM admin WHERE username = ? LIMIT 1", username);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public Map<String, Object> findById(Long id) throws SQLException {
        List<Map<String, Object>> rows = JdbcUtils.query(
            "SELECT * FROM admin WHERE id = ? LIMIT 1", id);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public int updateLastLogin(Long id, LocalDateTime time) throws SQLException {
        return JdbcUtils.update("UPDATE admin SET last_login=? WHERE id=?", time, id);
    }
}
