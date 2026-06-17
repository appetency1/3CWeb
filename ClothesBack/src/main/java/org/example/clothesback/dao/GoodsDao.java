package org.example.clothesback.dao;

import org.example.clothesback.util.JdbcUtils;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class GoodsDao {

    private static final Set<String> ALLOWED_SORT = Set.of(
        "create_time", "price", "sales", "view_count");

    public Map<String, Object> findById(Long id) throws SQLException {
        List<Map<String, Object>> rows = JdbcUtils.query(
            "SELECT * FROM goods WHERE id=? LIMIT 1", id);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public int incrementView(Long id) throws SQLException {
        return JdbcUtils.update("UPDATE goods SET view_count=view_count+1 WHERE id=?", id);
    }

    /** 公共商品分页。{@code sort} 形如 {@code sales_desc} / {@code price_asc} / {@code create_time_desc} */
    public List<Map<String, Object>> listPublic(Long categoryId, String keyword, String sort,
                                                int offset, int size) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT * FROM goods WHERE status=1");
        List<Object> params = new ArrayList<>();
        if (categoryId != null) {
            sql.append(" AND category_id=?");
            params.add(categoryId);
        }
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND name LIKE ?");
            params.add("%" + keyword + "%");
        }
        sql.append(" ORDER BY ").append(buildOrderBy(sort));
        sql.append(" LIMIT ? OFFSET ?");
        params.add(size);
        params.add(offset);
        return JdbcUtils.query(sql.toString(), params.toArray());
    }

    public long countPublic(Long categoryId, String keyword) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM goods WHERE status=1");
        List<Object> params = new ArrayList<>();
        if (categoryId != null) { sql.append(" AND category_id=?"); params.add(categoryId); }
        if (keyword != null && !keyword.isBlank()) { sql.append(" AND name LIKE ?"); params.add("%" + keyword + "%"); }
        return JdbcUtils.queryLong(sql.toString(), params.toArray());
    }

    public List<Map<String, Object>> listHot(int limit) throws SQLException {
        return JdbcUtils.query("SELECT * FROM goods WHERE status=1 AND is_hot=1 ORDER BY sales DESC LIMIT ?", limit);
    }

    public List<Map<String, Object>> listNew(int limit) throws SQLException {
        return JdbcUtils.query("SELECT * FROM goods WHERE status=1 AND is_new=1 ORDER BY create_time DESC LIMIT ?", limit);
    }

    public List<Map<String, Object>> listAdmin(Long categoryId, String keyword, Integer status,
                                               int offset, int size) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT * FROM goods WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (categoryId != null) { sql.append(" AND category_id=?"); params.add(categoryId); }
        if (keyword != null && !keyword.isBlank()) { sql.append(" AND name LIKE ?"); params.add("%" + keyword + "%"); }
        if (status != null) { sql.append(" AND status=?"); params.add(status); }
        sql.append(" ORDER BY id DESC LIMIT ? OFFSET ?");
        params.add(size); params.add(offset);
        return JdbcUtils.query(sql.toString(), params.toArray());
    }

    public long countAdmin(Long categoryId, String keyword, Integer status) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM goods WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (categoryId != null) { sql.append(" AND category_id=?"); params.add(categoryId); }
        if (keyword != null && !keyword.isBlank()) { sql.append(" AND name LIKE ?"); params.add("%" + keyword + "%"); }
        if (status != null) { sql.append(" AND status=?"); params.add(status); }
        return JdbcUtils.queryLong(sql.toString(), params.toArray());
    }

    public int countPendingOrders(Long goodsId) throws SQLException {
        return JdbcUtils.queryLong(
            "SELECT COUNT(*) FROM order_item oi INNER JOIN orders o ON oi.order_id=o.id " +
            "WHERE oi.goods_id=? AND o.status IN (0,1,2)", goodsId).intValue();
    }

    public int insert(Connection conn, Long categoryId, String name, String brand, String cover,
                      String images, String description, String detail, BigDecimal price,
                      BigDecimal originalPrice, Integer stock, Integer isHot, Integer isNew) throws SQLException {
        return JdbcUtils.update(conn,
            "INSERT INTO goods (category_id,name,brand,cover,images,description,detail,price,original_price,stock,is_hot,is_new,status) " +
            "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,1)",
            categoryId, name, brand, cover, images, description, detail, price, originalPrice,
            stock == null ? 0 : stock, isHot, isNew);
    }

    public int update(Connection conn, Long id, Long categoryId, String name, String brand, String cover,
                      String images, String description, String detail, BigDecimal price,
                      BigDecimal originalPrice, Integer isHot, Integer isNew) throws SQLException {
        return JdbcUtils.update(conn,
            "UPDATE goods SET category_id=?,name=?,brand=?,cover=?,images=?,description=?,detail=?,price=?,original_price=?,is_hot=?,is_new=? WHERE id=?",
            categoryId, name, brand, cover, images, description, detail, price, originalPrice, isHot, isNew, id);
    }

    public int updateStatus(Long id, int status) throws SQLException {
        return JdbcUtils.update("UPDATE goods SET status=? WHERE id=?", status, id);
    }

    public int delete(Connection conn, Long id) throws SQLException {
        return JdbcUtils.update(conn, "DELETE FROM goods WHERE id=?", id);
    }

    public int recomputeStockAndSales(Connection conn, Long id) throws SQLException {
        return JdbcUtils.update(conn,
            "UPDATE goods g SET g.stock=(SELECT COALESCE(SUM(stock),0) FROM sku WHERE goods_id=g.id), " +
            "g.sales=(SELECT COALESCE(SUM(sales),0) FROM sku WHERE goods_id=g.id) WHERE g.id=?", id);
    }

    private String buildOrderBy(String sort) {
        if (sort == null || sort.isBlank()) return "create_time DESC, id DESC";
        String[] parts = sort.split("_");
        if (parts.length < 2) return "create_time DESC, id DESC";
        String field = parts[0];
        String dir = parts[parts.length - 1].equalsIgnoreCase("asc") ? "ASC" : "DESC";
        if (!ALLOWED_SORT.contains(field)) return "create_time DESC, id DESC";
        return field + " " + dir + ", id DESC";
    }
}
