package org.example.clothesback.util;

import java.io.InputStream;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.logging.Logger;

/**
 * JDBC 工具:加载 db.properties,提供 query/update/transaction 三个核心方法。
 *
 * 重要约束:
 * 1. 业务方法必须 {@code PreparedStatement} 绑定参数,禁止字符串拼接 SQL。
 * 2. 事务由 {@link #transaction(SqlAction)} 提供,回调内复用同一个 {@link Connection}。
 * 3. DAO 内方法签名分两类:
 *    - 无 {@code Connection} 参数:内部自行开关连接(读多写少)
 *    - 有 {@code Connection} 参数:必须在 {@link #transaction(SqlAction)} 回调中使用
 */
public final class JdbcUtils {
    private static final Logger log = Logger.getLogger(JdbcUtils.class.getName());

    private static String url;
    private static String user;
    private static String password;

    static {
        try (InputStream in = JdbcUtils.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in == null) {
                throw new RuntimeException("找不到 db.properties");
            }
            Properties p = new Properties();
            p.load(in);
            url = p.getProperty("jdbc.url");
            user = p.getProperty("jdbc.user");
            password = p.getProperty("jdbc.password");
            String driver = p.getProperty("jdbc.driver", "com.mysql.cj.jdbc.Driver");
            Class.forName(driver);
        } catch (Exception e) {
            throw new RuntimeException("加载数据库配置失败", e);
        }
    }

    private JdbcUtils() {}

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, user, password);
    }

    public static void close(Connection conn, Statement stmt, ResultSet rs) {
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (stmt != null) try { stmt.close(); } catch (SQLException ignored) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
    }

    /** 绑定 PreparedStatement 的 ? 参数(支持 null) */
    public static void setParams(PreparedStatement ps, Object... params) throws SQLException {
        if (params == null) return;
        for (int i = 0; i < params.length; i++) {
            Object v = params[i];
            if (v == null) {
                ps.setObject(i + 1, null);
            } else if (v instanceof java.time.LocalDate) {
                ps.setDate(i + 1, java.sql.Date.valueOf((java.time.LocalDate) v));
            } else if (v instanceof java.time.LocalDateTime) {
                ps.setTimestamp(i + 1, java.sql.Timestamp.valueOf((java.time.LocalDateTime) v));
            } else if (v instanceof java.util.Date) {
                ps.setTimestamp(i + 1, new java.sql.Timestamp(((java.util.Date) v).getTime()));
            } else if (v instanceof Boolean) {
                ps.setInt(i + 1, ((Boolean) v) ? 1 : 0);
            } else if (v instanceof BigDecimal) {
                ps.setBigDecimal(i + 1, (BigDecimal) v);
            } else if (v instanceof Enum) {
                ps.setString(i + 1, ((Enum<?>) v).name());
            } else {
                ps.setObject(i + 1, v);
            }
        }
    }

    /** INSERT / UPDATE / DELETE,返回受影响行数。 */
    public static int update(String sql, Object... params) throws SQLException {
        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            setParams(ps, params);
            return ps.executeUpdate();
        }
    }

    /** 事务内的 update,共用同一个 Connection。 */
    public static int update(Connection conn, String sql, Object... params) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            setParams(ps, params);
            return ps.executeUpdate();
        }
    }

    /** 查询,返回 List<Map>。列名用 LinkedHashMap 保留顺序,空结果返回空列表。 */
    public static List<Map<String, Object>> query(String sql, Object... params) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            setParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                ResultSetMetaData md = rs.getMetaData();
                int cols = md.getColumnCount();
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    for (int i = 1; i <= cols; i++) {
                        row.put(md.getColumnLabel(i), rs.getObject(i));
                    }
                    list.add(row);
                }
            }
        }
        return list;
    }

    /** 事务内查询,共用同一个 Connection。 */
    public static List<Map<String, Object>> query(Connection conn, String sql, Object... params) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            setParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                ResultSetMetaData md = rs.getMetaData();
                int cols = md.getColumnCount();
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    for (int i = 1; i <= cols; i++) {
                        row.put(md.getColumnLabel(i), rs.getObject(i));
                    }
                    list.add(row);
                }
            }
        }
        return list;
    }

    /** 查询单行单列(如 COUNT)。 */
    public static Long queryLong(String sql, Object... params) throws SQLException {
        List<Map<String, Object>> rows = query(sql, params);
        if (rows.isEmpty() || rows.get(0).isEmpty()) return 0L;
        Object v = rows.get(0).values().iterator().next();
        if (v == null) return 0L;
        if (v instanceof Number n) return n.longValue();
        return Long.parseLong(v.toString());
    }

    /** 事务内查询单行单列。 */
    public static Long queryLong(Connection conn, String sql, Object... params) throws SQLException {
        List<Map<String, Object>> rows = query(conn, sql, params);
        if (rows.isEmpty() || rows.get(0).isEmpty()) return 0L;
        Object v = rows.get(0).values().iterator().next();
        if (v == null) return 0L;
        if (v instanceof Number n) return n.longValue();
        return Long.parseLong(v.toString());
    }

    /** 事务:回调内复用同一个 Connection,任一异常都回滚。 */
    public static void transaction(SqlAction action) throws SQLException {
        try (Connection c = getConnection()) {
            c.setAutoCommit(false);
            try {
                action.execute(c);
                c.commit();
            } catch (Exception e) {
                c.rollback();
                if (e instanceof SQLException sqlE) throw sqlE;
                if (e instanceof RuntimeException re) throw re;
                throw new SQLException(e);
            }
        }
    }

    /** 事务:返回结果。 */
    public static <T> T transactionResult(SqlFunction<T> action) throws SQLException {
        try (Connection c = getConnection()) {
            c.setAutoCommit(false);
            try {
                T r = action.apply(c);
                c.commit();
                return r;
            } catch (Exception e) {
                c.rollback();
                if (e instanceof SQLException sqlE) throw sqlE;
                if (e instanceof RuntimeException re) throw re;
                throw new SQLException(e);
            }
        }
    }

    @FunctionalInterface
    public interface SqlAction {
        void execute(Connection conn) throws SQLException;
    }

    @FunctionalInterface
    public interface SqlFunction<T> {
        T apply(Connection conn) throws SQLException;
    }
}
