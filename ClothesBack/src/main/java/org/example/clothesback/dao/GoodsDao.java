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
            List<Long> catIds = expandCategoryIds(categoryId);
            sql.append(" AND").append(buildCategoryClause(catIds, params));
        }
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (").append(buildKeywordClause(keyword, params)).append(")");
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
        if (categoryId != null) {
            List<Long> catIds = expandCategoryIds(categoryId);
            sql.append(" AND").append(buildCategoryClause(catIds, params));
        }
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (").append(buildKeywordClause(keyword, params)).append(")");
        }
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

    /**
     * 展开分类ID：如果是父分类，返回其所有子分类ID + 自身ID；
     * 如果是叶子分类，返回仅包含自身的列表。
     */
    private List<Long> expandCategoryIds(Long categoryId) throws SQLException {
        List<Long> ids = new ArrayList<>();
        ids.add(categoryId);
        List<Map<String, Object>> children = JdbcUtils.query(
            "SELECT id FROM category WHERE parent_id=?", categoryId);
        for (Map<String, Object> row : children) {
            ids.add(((Number) row.get("id")).longValue());
        }
        return ids;
    }

    /** 构建 "category_id IN (?,?,?)" 片段，返回SQL片段并收集参数 */
    private String buildCategoryClause(List<Long> catIds, List<Object> params) {
        StringBuilder clause = new StringBuilder(" category_id IN (");
        for (int i = 0; i < catIds.size(); i++) {
            if (i > 0) clause.append(",");
            clause.append("?");
            params.add(catIds.get(i));
        }
        clause.append(")");
        return clause.toString();
    }

    /**
     * 关键词搜索：FULLTEXT（ngram 中文分词）+ LIKE 单字兜底。
     *
     * 先走 MATCH AGAINST（快、有相关性排序）：
     *   "手机" → 命中 ngram 分词 "手机"
     *   "笔记本"   → 命中全文索引
     * 再 OR 上单字 LIKE 拆分做兜底：
     *   "电脑"  → LIKE '%电%' OR LIKE '%脑%' → 找到"笔记本电脑""台式电脑"等
     */
    private String buildKeywordClause(String keyword, List<Object> params) {
        // 1) FULLTEXT MATCH（ngram 分词，按相关性排序）
        StringBuilder clause = new StringBuilder();
        clause.append("MATCH(name, brand, description) AGAINST(? IN BOOLEAN MODE)");
        // BOOLEAN MODE 下 + 表示必须包含，* 是通配符
        // 中文 ngram(2) 会自动按双字分词
        params.add("+" + keyword + "*");

        // 2) LIKE 单字兜底（解决 ngram 无论如何也匹配不到的情况）
        String[] chars = keyword.codePoints()
            .filter(c -> c >= 0x4E00 && c <= 0x9FFF)
            .mapToObj(c -> new String(new int[]{c}, 0, 1))
            .toArray(String[]::new);
        for (String ch : chars) {
            clause.append(" OR name LIKE ? OR brand LIKE ? OR description LIKE ?");
            String like = "%" + ch + "%";
            params.add(like); params.add(like); params.add(like);
        }
        return clause.toString();
    }

    private String buildOrderBy(String sort) {
        String dflt = "create_time DESC, id DESC";
        if (sort == null || sort.isBlank()) return dflt;
        String[] parts = sort.split("_");
        if (parts.length < 2) return dflt;
        String field = parts[0];
        String dir = parts[parts.length - 1].equalsIgnoreCase("asc") ? "ASC" : "DESC";
        if (!ALLOWED_SORT.contains(field)) return dflt;
        return field + " " + dir + ", id DESC";
    }
}
