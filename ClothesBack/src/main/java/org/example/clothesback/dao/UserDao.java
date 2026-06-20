package org.example.clothesback.dao;

import org.example.clothesback.util.JdbcUtils;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class UserDao {

    // ── 内部用（含 password，仅限登录/校验场景） ──
    public Map<String, Object> findByUsernameWithPwd(String username) throws SQLException {
        List<Map<String, Object>> rows = JdbcUtils.query(
            "SELECT * FROM user WHERE username = ? LIMIT 1", username);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public Map<String, Object> findByIdWithPwd(Long id) throws SQLException {
        List<Map<String, Object>> rows = JdbcUtils.query(
            "SELECT * FROM user WHERE id = ? LIMIT 1", id);
        return rows.isEmpty() ? null : rows.get(0);
    }

    // ── 对外用（不含 password） ──
    public Map<String, Object> findByUsername(String username) throws SQLException {
        List<Map<String, Object>> rows = JdbcUtils.query(
            "SELECT id, username, nickname, avatar, phone, email, gender, birthday, status, create_time FROM user WHERE username = ? LIMIT 1", username);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public Map<String, Object> findById(Long id) throws SQLException {
        List<Map<String, Object>> rows = JdbcUtils.query(
            "SELECT id, username, nickname, avatar, phone, email, gender, birthday, status, create_time FROM user WHERE id = ? LIMIT 1", id);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public Map<String, Object> findByPhone(String phone) throws SQLException {
        List<Map<String, Object>> rows = JdbcUtils.query(
            "SELECT id, username, nickname, avatar, phone, email, gender, birthday, status, create_time FROM user WHERE phone = ? LIMIT 1", phone);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public int insert(String username, String password, String nickname, String phone, String email) throws SQLException {
        int n = JdbcUtils.update(
            "INSERT INTO user (username, password, nickname, phone, email, status) VALUES (?, ?, ?, ?, ?, 1)",
            username, password, nickname, phone, email);
        return n;
    }

    public int updateProfile(Long id, String nickname, String avatar, String phone, String email,
                             Integer gender, java.time.LocalDate birthday) throws SQLException {
        StringBuilder sql = new StringBuilder("UPDATE user SET ");
        java.util.List<Object> params = new java.util.ArrayList<>();
        if (nickname != null) { sql.append("nickname=?,"); params.add(nickname); }
        if (avatar != null) { sql.append("avatar=?,"); params.add(avatar); }
        if (phone != null) { sql.append("phone=?,"); params.add(phone); }
        if (email != null) { sql.append("email=?,"); params.add(email); }
        if (gender != null) { sql.append("gender=?,"); params.add(gender); }
        if (birthday != null) { sql.append("birthday=?,"); params.add(birthday); }
        if (params.isEmpty()) return 0;
        sql.setLength(sql.length() - 1);
        sql.append(" WHERE id=?");
        params.add(id);
        return JdbcUtils.update(sql.toString(), params.toArray());
    }

    public int updatePassword(Long id, String newPassword) throws SQLException {
        return JdbcUtils.update("UPDATE user SET password=? WHERE id=?", newPassword, id);
    }

    public int updateStatus(Long id, int status) throws SQLException {
        return JdbcUtils.update("UPDATE user SET status=? WHERE id=?", status, id);
    }

    public List<Map<String, Object>> listPage(String keyword, Integer status, int offset, int size) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT id, username, nickname, avatar, phone, email, gender, birthday, status, create_time FROM user WHERE 1=1");
        java.util.List<Object> params = new java.util.ArrayList<>();
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (username LIKE ? OR nickname LIKE ? OR phone LIKE ?)");
            String kw = "%" + keyword + "%";
            params.add(kw); params.add(kw); params.add(kw);
        }
        if (status != null) {
            sql.append(" AND status=?");
            params.add(status);
        }
        sql.append(" ORDER BY id DESC LIMIT ? OFFSET ?");
        params.add(size); params.add(offset);
        return JdbcUtils.query(sql.toString(), params.toArray());
    }

    public long countPage(String keyword, Integer status) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM user WHERE 1=1");
        java.util.List<Object> params = new java.util.ArrayList<>();
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (username LIKE ? OR nickname LIKE ? OR phone LIKE ?)");
            String kw = "%" + keyword + "%";
            params.add(kw); params.add(kw); params.add(kw);
        }
        if (status != null) {
            sql.append(" AND status=?");
            params.add(status);
        }
        return JdbcUtils.queryLong(sql.toString(), params.toArray());
    }
}
