package org.example.clothesback.dao;

import org.example.clothesback.util.JdbcUtils;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class SkuDao {

    public List<Map<String, Object>> listByGoods(Long goodsId) throws SQLException {
        return JdbcUtils.query("SELECT * FROM sku WHERE goods_id=? ORDER BY sort ASC, id ASC", goodsId);
    }

    public Map<String, Object> findById(Long id) throws SQLException {
        List<Map<String, Object>> rows = JdbcUtils.query(
            "SELECT * FROM sku WHERE id=? LIMIT 1", id);
        return rows.isEmpty() ? null : rows.get(0);
    }

    /** 锁行读,用于事务内下单。 */
    public Map<String, Object> lockById(Connection conn, Long id) throws SQLException {
        List<Map<String, Object>> rows = JdbcUtils.query(conn,
            "SELECT * FROM sku WHERE id=? FOR UPDATE", id);
        return rows.isEmpty() ? null : rows.get(0);
    }

    /** 乐观扣减:影响行数为 0 表示库存不足。 */
    public int decrementStock(Connection conn, Long id, int qty) throws SQLException {
        return JdbcUtils.update(conn,
            "UPDATE sku SET stock=stock-?, sales=sales+? WHERE id=? AND stock>=?",
            qty, qty, id, qty);
    }

    public int incrementStock(Connection conn, Long id, int qty) throws SQLException {
        return JdbcUtils.update(conn,
            "UPDATE sku SET stock=stock+?, sales=GREATEST(sales-?,0) WHERE id=?",
            qty, qty, id);
    }

    public int insert(Connection conn, Long goodsId, String spec, BigDecimal price,
                      Integer stock, String image, Integer sort) throws SQLException {
        return JdbcUtils.update(conn,
            "INSERT INTO sku (goods_id, spec, price, stock, sales, image, sort) VALUES (?,?,?,?,0,?,?)",
            goodsId, spec, price, stock == null ? 0 : stock, image, sort == null ? 0 : sort);
    }

    public int update(Connection conn, Long id, String spec, BigDecimal price, Integer stock,
                      String image, Integer sort) throws SQLException {
        return JdbcUtils.update(conn,
            "UPDATE sku SET spec=?, price=?, stock=?, image=?, sort=? WHERE id=?",
            spec, price, stock, image, sort, id);
    }

    public int delete(Connection conn, Long id) throws SQLException {
        return JdbcUtils.update(conn, "DELETE FROM sku WHERE id=?", id);
    }

    public int deleteByGoods(Connection conn, Long goodsId) throws SQLException {
        return JdbcUtils.update(conn, "DELETE FROM sku WHERE goods_id=?", goodsId);
    }
}
