package org.example.clothesback.dao;

import org.example.clothesback.util.JdbcUtils;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class AddressDao {

    public List<Map<String, Object>> listByUser(Long userId) throws SQLException {
        return JdbcUtils.query(
            "SELECT * FROM address WHERE user_id=? ORDER BY is_default DESC, id DESC", userId);
    }

    public Map<String, Object> findById(Long id) throws SQLException {
        List<Map<String, Object>> rows = JdbcUtils.query(
            "SELECT * FROM address WHERE id=? LIMIT 1", id);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public int countByUser(Long userId) throws SQLException {
        return JdbcUtils.queryLong("SELECT COUNT(*) FROM address WHERE user_id=?", userId).intValue();
    }

    public int insert(Connection conn, Long userId, String receiver, String phone,
                      String province, String city, String district, String detail, int isDefault) throws SQLException {
        return JdbcUtils.update(conn,
            "INSERT INTO address (user_id, receiver, phone, province, city, district, detail, is_default) " +
            "VALUES (?,?,?,?,?,?,?,?)",
            userId, receiver, phone, province, city, district, detail, isDefault);
    }

    public int update(Connection conn, Long id, String receiver, String phone,
                      String province, String city, String district, String detail) throws SQLException {
        return JdbcUtils.update(conn,
            "UPDATE address SET receiver=?, phone=?, province=?, city=?, district=?, detail=? WHERE id=?",
            receiver, phone, province, city, district, detail, id);
    }

    public int clearDefault(Connection conn, Long userId) throws SQLException {
        return JdbcUtils.update(conn, "UPDATE address SET is_default=0 WHERE user_id=?", userId);
    }

    public int setDefault(Connection conn, Long id) throws SQLException {
        return JdbcUtils.update(conn, "UPDATE address SET is_default=1 WHERE id=?", id);
    }

    public int delete(Connection conn, Long id) throws SQLException {
        return JdbcUtils.update(conn, "DELETE FROM address WHERE id=?", id);
    }
}
