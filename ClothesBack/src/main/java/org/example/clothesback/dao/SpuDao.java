package org.example.clothesback.dao;

import org.example.clothesback.util.JdbcUtils;

import java.sql.Connection;
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

    /** 展开分类ID：若是一级分类则递归查出所有子分类ID */
    private List<Long> expandCategoryIds(Long categoryId) throws SQLException {
        List<Long> ids = new ArrayList<>();
        ids.add(categoryId);
        // 查是否有子分类
        List<Map<String, Object>> children = JdbcUtils.query(
            "SELECT id FROM category WHERE parent_id=? AND status=1", categoryId);
        for (Map<String, Object> child : children) {
            Long childId = ((Number) child.get("id")).longValue();
            ids.add(childId);
            // 递归查孙分类
            List<Map<String, Object>> grandChildren = JdbcUtils.query(
                "SELECT id FROM category WHERE parent_id=? AND status=1", childId);
            for (Map<String, Object> gc : grandChildren) {
                ids.add(((Number) gc.get("id")).longValue());
            }
        }
        return ids;
    }

    /** SPU 分页列表（公开），含最低价/最高价/SKU数量 */
    public List<Map<String, Object>> listPublic(Long categoryId, String keyword, String sort,
                                                 int offset, int size) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT s.*, MIN(g.price) AS min_price, MAX(g.price) AS max_price, " +
            "COALESCE(SUM(g.sales),0) AS total_sales, COUNT(g.id) AS sku_count " +
            "FROM spu s LEFT JOIN goods g ON g.spu_id = s.id AND g.status = 1 WHERE s.status = 1");
        List<Object> params = new ArrayList<>();
        if (categoryId != null) {
            List<Long> catIds = expandCategoryIds(categoryId);
            if (catIds.size() == 1) {
                sql.append(" AND s.category_id=?");
                params.add(categoryId);
            } else {
                sql.append(" AND s.category_id IN (");
                for (int i = 0; i < catIds.size(); i++) {
                    sql.append(i > 0 ? ",?" : "?");
                    params.add(catIds.get(i));
                }
                sql.append(")");
            }
        }
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (s.name LIKE ? OR s.brand LIKE ? OR s.description LIKE ?)");
            String like = "%" + keyword + "%";
            params.add(like); params.add(like); params.add(like);
        }
        sql.append(" GROUP BY s.id HAVING COUNT(g.id) > 0 ORDER BY ").append(buildOrderBy(sort));
        sql.append(" LIMIT ? OFFSET ?");
        params.add(size);
        params.add(offset);
        return JdbcUtils.query(sql.toString(), params.toArray());
    }

    public long countPublic(Long categoryId, String keyword) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM spu WHERE status=1");
        List<Object> params = new ArrayList<>();
        if (categoryId != null) {
            List<Long> catIds = expandCategoryIds(categoryId);
            if (catIds.size() == 1) {
                sql.append(" AND category_id=?");
                params.add(categoryId);
            } else {
                sql.append(" AND category_id IN (");
                for (int i = 0; i < catIds.size(); i++) {
                    sql.append(i > 0 ? ",?" : "?");
                    params.add(catIds.get(i));
                }
                sql.append(")");
            }
        }
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
            "GROUP BY s.id HAVING COUNT(g.id) > 0 ORDER BY total_sales DESC LIMIT ?", limit);
    }

    /** 新品 SPU */
    public List<Map<String, Object>> listNew(int limit) throws SQLException {
        return JdbcUtils.query(
            "SELECT s.*, MIN(g.price) AS min_price, MAX(g.price) AS max_price, " +
            "COALESCE(SUM(g.sales),0) AS total_sales, COUNT(g.id) AS sku_count " +
            "FROM spu s LEFT JOIN goods g ON g.spu_id = s.id AND g.status = 1 " +
            "WHERE s.status = 1 AND s.is_new = 1 " +
            "GROUP BY s.id HAVING COUNT(g.id) > 0 ORDER BY s.create_time DESC LIMIT ?", limit);
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
            "SELECT s.id, g.name, g.cover, s.price, g.original_price, " +
            "s.stock, s.sales, s.spec AS specs, g.brand " +
            "FROM sku s JOIN goods g ON g.id = s.goods_id " +
            "WHERE g.spu_id = ? AND g.status = 1 ORDER BY s.price ASC", spuId);
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
        // 映射字段名
        String orderField = switch (field) {
            case "price" -> "min_price";
            case "sales" -> "total_sales";
            case "create_time" -> "s.create_time";
            case "view_count" -> "s.view_count";
            default -> "s.create_time";
        };
        return orderField + " " + dir + ", s.id DESC";
    }

    public int insert(Connection conn, String name, String brand, String cover, String description,
                      Long categoryId, int isHot, int isNew) throws SQLException {
        return JdbcUtils.update(conn,
            "INSERT INTO spu (name,brand,cover,description,category_id,status,is_hot,is_new,create_time,update_time) " +
            "VALUES (?,?,?,?,?,1,?,?,NOW(),NOW())",
            name, brand, cover, description, categoryId, isHot, isNew);
    }
}
