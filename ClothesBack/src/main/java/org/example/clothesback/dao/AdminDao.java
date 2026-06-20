package org.example.clothesback.dao;

import org.example.clothesback.util.JdbcUtils;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public class AdminDao {

    // ── 内部用（含 password） ──
    public Map<String, Object> findByUsernameWithPwd(String username) throws SQLException {
        List<Map<String, Object>> rows = JdbcUtils.query(
            "SELECT * FROM admin WHERE username = ? LIMIT 1", username);
        return rows.isEmpty() ? null : rows.get(0);
    }

    // ── 对外用（不含 password） ──
    public Map<String, Object> findByUsername(String username) throws SQLException {
        List<Map<String, Object>> rows = JdbcUtils.query(
            "SELECT id, username, nickname, avatar, status, create_time, last_login FROM admin WHERE username = ? LIMIT 1", username);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public Map<String, Object> findById(Long id) throws SQLException {
        List<Map<String, Object>> rows = JdbcUtils.query(
            "SELECT id, username, nickname, avatar, status, create_time, last_login FROM admin WHERE id = ? LIMIT 1", id);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public int updateLastLogin(Long id, LocalDateTime time) throws SQLException {
        return JdbcUtils.update("UPDATE admin SET last_login=? WHERE id=?", time, id);
    }

    public int updatePassword(Long id, String password) throws SQLException {
        return JdbcUtils.update("UPDATE admin SET password=? WHERE id=?", password, id);
    }
}
