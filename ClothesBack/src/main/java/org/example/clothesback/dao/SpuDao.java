package org.example.clothesback.dao;

import org.example.clothesback.util.JdbcUtils;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * SPU（产品系列）数据访问。
 * SPU 是面向用户的商品单元，一个 SPU 下包含多个 SKU（goods）。
 */
public class SpuDao {

    private static final Set<String> ALLOWED_SORT = Set.of(
        "create_time", "price", "sales", "view_count");

    /** SPU 分页列表（公开），含最低价/最高价/SKU数量 */
    public List<Map<String, Object>> listPublic(Long categoryId, String keyword, String sort,
                                                 int offset, int size) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT s.*, MIN(g.price) AS min_price, MAX(g.price) AS max_price, " +
            "COALESCE(SUM(g.sales),0) AS total_sales, COUNT(g.id) AS sku_count " +
            "FROM spu s LEFT JOIN goods g ON g.spu_id = s.id AND g.status = 1 WHERE s.status = 1");
        List<Object> params = new ArrayList<>();
        if (categoryId != null) {
            sql.append(" AND s.category_id=?");
            params.add(categoryId);
        }
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (s.name LIKE ? OR s.brand LIKE ? OR s.description LIKE ?)");
            String like = "%" + keyword + "%";
            params.add(like); params.add(like); params.add(like);
        }
        sql.append(" GROUP BY s.id ORDER BY ").append(buildOrderBy(sort));
        sql.append(" LIMIT ? OFFSET ?");
        params.add(size);
        params.add(offset);
        return JdbcUtils.query(sql.toString(), params.toArray());
    }

    public long countPublic(Long categoryId, String keyword) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM spu WHERE status=1");
        List<Object> params = new ArrayList<>();
        if (categoryId != null) { sql.append(" AND category_id=?"); params.add(categoryId); }
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (name LIKE ? OR brand LIKE ? OR description LIKE ?)");
            String like = "%" + keyword + "%";
            params.add(like); params.add(like); params.add(like);
        }
        return JdbcUtils.queryLong(sql.toString(), params.toArray());
    }

    /** 热门 SPU（按销量取 top） */
    public List<Map<String, Object>> listHot(int limit) throws SQLException {
        return JdbcUtils.query(
            "SELECT s.*, MIN(g.price) AS min_price, MAX(g.price) AS max_price, " +
            "COALESCE(SUM(g.sales),0) AS total_sales, COUNT(g.id) AS sku_count " +
            "FROM spu s LEFT JOIN goods g ON g.spu_id = s.id AND g.status = 1 " +
            "WHERE s.status = 1 AND s.is_hot = 1 " +
            "GROUP BY s.id ORDER BY total_sales DESC LIMIT ?", limit);
    }

    /** 新品 SPU */
    public List<Map<String, Object>> listNew(int limit) throws SQLException {
        return JdbcUtils.query(
            "SELECT s.*, MIN(g.price) AS min_price, MAX(g.price) AS max_price, " +
            "COALESCE(SUM(g.sales),0) AS total_sales, COUNT(g.id) AS sku_count " +
            "FROM spu s LEFT JOIN goods g ON g.spu_id = s.id AND g.status = 1 " +
            "WHERE s.status = 1 AND s.is_new = 1 " +
            "GROUP BY s.id ORDER BY s.create_time DESC LIMIT ?", limit);
    }

    /** SPU 详情 */
    public Map<String, Object> findById(Long spuId) throws SQLException {
        List<Map<String, Object>> rows = JdbcUtils.query(
            "SELECT s.*, MIN(g.price) AS min_price, MAX(g.price) AS max_price, " +
            "COALESCE(SUM(g.sales),0) AS total_sales, COUNT(g.id) AS sku_count " +
            "FROM spu s LEFT JOIN goods g ON g.spu_id = s.id AND g.status = 1 " +
            "WHERE s.id = ? GROUP BY s.id", spuId);
        return rows.isEmpty() ? null : rows.get(0);
    }

    /** SPU 下的所有 SKU（goods） */
    public List<Map<String, Object>> listSkusBySpu(Long spuId) throws SQLException {
        return JdbcUtils.query(
            "SELECT id, name, cover, price, original_price, stock, sales, specs, brand " +
            "FROM goods WHERE spu_id = ? AND status = 1 ORDER BY price ASC", spuId);
    }

    /** 根据 goods id 查找所属 SPU */
    public Map<String, Object> findByGoodsId(Long goodsId) throws SQLException {
        List<Map<String, Object>> rows = JdbcUtils.query(
            "SELECT s.*, MIN(g.price) AS min_price, MAX(g.price) AS max_price, " +
            "COALESCE(SUM(g.sales),0) AS total_sales, COUNT(g.id) AS sku_count " +
            "FROM spu s JOIN goods g ON g.spu_id = s.id " +
            "WHERE g.id = ? GROUP BY s.id", goodsId);
        return rows.isEmpty() ? null : rows.get(0);
    }

    private String buildOrderBy(String sort) {
        String dflt = "s.create_time DESC, s.id DESC";
        if (sort == null || sort.isBlank()) return dflt;
        String[] parts = sort.split("_");
        if (parts.length < 2) return dflt;
        String field = parts[0];
        String dir = parts[parts.length - 1].equalsIgnoreCase("asc") ? "ASC" : "DESC";
        if (!ALLOWED_SORT.contains(field)) return dflt;
        return "total_sales " + dir + ", s.id DESC";
    }
}
