package org.example.clothesback.dao;

import org.example.clothesback.util.JdbcUtils;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class BannerDao {

    public List<Map<String, Object>> listEnabled() throws SQLException {
        return JdbcUtils.query("SELECT * FROM banner WHERE status=1 ORDER BY sort ASC, id ASC");
    }

    public List<Map<String, Object>> listAll() throws SQLException {
        return JdbcUtils.query("SELECT * FROM banner ORDER BY sort ASC, id ASC");
    }

    public Map<String, Object> findById(Long id) throws SQLException {
        List<Map<String, Object>> rows = JdbcUtils.query("SELECT * FROM banner WHERE id=? LIMIT 1", id);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public int insert(String title, String image, String link, Integer sort, Integer status) throws SQLException {
        return JdbcUtils.update(
            "INSERT INTO banner (title, image, link, sort, status) VALUES (?,?,?,?,?)",
            title, image, link, sort == null ? 0 : sort, status == null ? 1 : status);
    }

    public int update(Long id, String title, String image, String link, Integer sort, Integer status) throws SQLException {
        return JdbcUtils.update(
            "UPDATE banner SET title=?, image=?, link=?, sort=?, status=? WHERE id=?",
            title, image, link, sort, status, id);
    }

    public int delete(Long id) throws SQLException {
        return JdbcUtils.update("DELETE FROM banner WHERE id=?", id);
    }
}
