# 后端开发指南 (Backend Guide)

> 写给后端开发者的工程实现手册。技术栈已固定:**Servlet 6.1 + 原生 JDBC + MySQL 8 + Fastjson2 + Maven**。

---

## 一、技术栈一览

| 项 | 选型 | 版本 |
|---|---|---|
| Web 容器 | Jakarta Servlet | 6.1.0 |
| 打包 | WAR | 部署到 Tomcat 10+ |
| 数据库 | MySQL | 8.0+ |
| 数据库驱动 | mysql-connector-j | 8.3.0+ |
| 连接池 | 不使用 (教学项目,DriverManager 即可) | - |
| JSON | fastjson2 | 2.0.49+ |
| 工具 | Lombok (可选) | 1.18+ |
| 测试 | JUnit Jupiter | 5.10+ |
| Java | JDK | 17+ |
| 构建 | Maven | 3.8+ |

**⚠️ 严格禁止引入**:Spring / Spring Boot / MyBatis / Hibernate / Spring MVC 任何框架

---

## 二、目录结构

```
ClothesBack/
├── pom.xml
├── src/
│   ├── main/
│   │   ├── java/org/example/clothesback/
│   │   │   ├── common/             # 通用类
│   │   │   │   ├── Result.java           # 统一返回结构
│   │   │   │   ├── ResultCode.java       # 状态码枚举
│   │   │   │   ├── BizException.java     # 业务异常
│   │   │   │   └── PageResult.java       # 分页结果
│   │   │   ├── config/             # 配置类
│   │   │   │   └── AppConfig.java        # 应用配置(扫描/字符集等)
│   │   │   ├── filter/             # 过滤器
│   │   │   │   ├── CorsFilter.java       # 跨域
│   │   │   │   └── EncodingFilter.java   # 字符编码
│   │   │   ├── interceptor/        # 拦截器
│   │   │   │   ├── AuthInterceptor.java  # 鉴权
│   │   │   │   └── AdminInterceptor.java # 管理员鉴权
│   │   │   ├── util/               # 工具类
│   │   │   │   ├── JdbcUtils.java        # JDBC 工具
│   │   │   │   ├── JsonUtils.java        # JSON 工具
│   │   │   │   ├── TokenManager.java     # Token 管理
│   │   │   │   ├── MD5Utils.java         # MD5 加密
│   │   │   │   ├── BeanUtils.java        # 实体映射(ResultSet -> Bean)
│   │   │   │   ├── IdGenerator.java      # 订单号生成
│   │   │   │   └── DateUtils.java        # 日期
│   │   │   ├── entity/             # 实体类 (12 个)
│   │   │   │   ├── User.java
│   │   │   │   ├── Admin.java
│   │   │   │   ├── Category.java
│   │   │   │   ├── Goods.java
│   │   │   │   ├── Sku.java
│   │   │   │   ├── Address.java
│   │   │   │   ├── Cart.java
│   │   │   │   ├── Order.java
│   │   │   │   ├── OrderItem.java
│   │   │   │   ├── Banner.java
│   │   │   │   ├── Favorite.java
│   │   │   │   └── Comment.java
│   │   │   ├── dto/                # 入参 DTO
│   │   │   │   ├── LoginDTO.java
│   │   │   │   ├── RegisterDTO.java
│   │   │   │   ├── CreateOrderDTO.java
│   │   │   │   ├── CartAddDTO.java
│   │   │   │   ├── CommentDTO.java
│   │   │   │   └── ...
│   │   │   ├── vo/                 # 出参 VO
│   │   │   │   ├── LoginVO.java
│   │   │   │   ├── GoodsDetailVO.java
│   │   │   │   ├── CartVO.java
│   │   │   │   ├── OrderDetailVO.java
│   │   │   │   ├── DashboardVO.java
│   │   │   │   └── ...
│   │   │   ├── dao/                # 数据访问层 (Mapper)
│   │   │   │   ├── UserDao.java
│   │   │   │   ├── AdminDao.java
│   │   │   │   ├── GoodsDao.java
│   │   │   │   ├── SkuDao.java
│   │   │   │   ├── OrderDao.java
│   │   │   │   └── ...
│   │   │   ├── service/            # 业务层
│   │   │   │   ├── UserService.java
│   │   │   │   ├── GoodsService.java
│   │   │   │   ├── OrderService.java
│   │   │   │   ├── CartService.java
│   │   │   │   └── ...
│   │   │   ├── servlet/            # 控制器(每个接口一个 Servlet)
│   │   │   │   ├── BaseServlet.java       # 抽取公共逻辑
│   │   │   │   ├── user/
│   │   │   │   │   ├── UserServlet.java
│   │   │   │   │   ├── AddressServlet.java
│   │   │   │   │   ├── CartServlet.java
│   │   │   │   │   ├── OrderServlet.java
│   │   │   │   │   ├── FavoriteServlet.java
│   │   │   │   │   └── CommentServlet.java
│   │   │   │   ├── admin/
│   │   │   │   │   ├── AdminServlet.java
│   │   │   │   │   ├── DashboardServlet.java
│   │   │   │   │   ├── CategoryServlet.java
│   │   │   │   │   ├── GoodsManageServlet.java
│   │   │   │   │   ├── SkuServlet.java
│   │   │   │   │   ├── OrderManageServlet.java
│   │   │   │   │   ├── UserManageServlet.java
│   │   │   │   │   └── BannerServlet.java
│   │   │   │   └── public_/
│   │   │   │       ├── PublicGoodsServlet.java
│   │   │   │       ├── PublicCategoryServlet.java
│   │   │   │       ├── PublicCommentServlet.java
│   │   │   │       ├── PublicBannerServlet.java
│   │   │   │       └── UploadServlet.java
│   │   │   └── listener/           # 监听器
│   │   │       └── AppListener.java      # 启动初始化(加载配置等)
│   │   ├── resources/
│   │   │   ├── db.properties       # 数据库配置
│   │   │   ├── log4j2.xml         # 日志配置(可选)
│   │   │   ├── schema.sql          # 建库脚本 (教学参考)
│   │   │   ├── DB_DESIGN.md        # 表设计文档
│   │   │   ├── API_DESIGN.md       # 接口设计文档
│   │   │   └── BACKEND_GUIDE.md    # 本文档
│   │   └── webapp/
│   │       ├── index.jsp
│   │       └── WEB-INF/
│   │           └── web.xml         # Servlet/Filter/Listener 注册
│   └── test/
│       └── java/
│           └── org/example/clothesback/
│               ├── JdbcUtilsTest.java
│               ├── UserServiceTest.java
│               └── OrderServiceTest.java
```

---

## 三、依赖管理 (pom.xml)

在现有基础上需新增的依赖:

```xml
<dependencies>
    <!-- Servlet API (已有) -->
    <dependency>
        <groupId>jakarta.servlet</groupId>
        <artifactId>jakarta.servlet-api</artifactId>
        <version>6.1.0</version>
        <scope>provided</scope>
    </dependency>

    <!-- MySQL 驱动 -->
    <dependency>
        <groupId>com.mysql</groupId>
        <artifactId>mysql-connector-j</artifactId>
        <version>8.3.0</version>
    </dependency>

    <!-- Fastjson2 -->
    <dependency>
        <groupId>com.alibaba.fastjson2</groupId>
        <artifactId>fastjson2</artifactId>
        <version>2.0.49</version>
    </dependency>

    <!-- Lombok (可选) -->
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <version>1.18.32</version>
        <scope>provided</scope>
    </dependency>

    <!-- JUnit 5 (已有) -->
</dependencies>
```

---

## 四、核心类模板

### 4.1 `Result.java` 统一返回
```java
public class Result<T> {
    private int code;
    private String message;
    private T data;

    public static <T> Result<T> success(T data) {
        Result<T> r = new Result<>();
        r.code = 200;
        r.message = "操作成功";
        r.data = data;
        return r;
    }

    public static <T> Result<T> error(int code, String message) {
        Result<T> r = new Result<>();
        r.code = code;
        r.message = message;
        return r;
    }

    // getter/setter
}
```

### 4.2 `JdbcUtils.java` 核心模板
```java
public class JdbcUtils {
    private static String url;
    private static String user;
    private static String password;

    static {
        try (InputStream in = JdbcUtils.class.getClassLoader()
                .getResourceAsStream("db.properties")) {
            Properties p = new Properties();
            p.load(in);
            url = p.getProperty("jdbc.url");
            user = p.getProperty("jdbc.user");
            password = p.getProperty("jdbc.password");
            Class.forName(p.getProperty("jdbc.driver"));
        } catch (Exception e) {
            throw new RuntimeException("加载数据库配置失败", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, user, password);
    }

    public static void close(Connection conn, Statement stmt, ResultSet rs) {
        // 依次关闭
    }

    /** 通用 update:INSERT/UPDATE/DELETE */
    public static int update(String sql, Object... params) throws SQLException {
        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            setParams(ps, params);
            return ps.executeUpdate();
        }
    }

    /** 通用 query:返回 List<Map> */
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

    /** 事务:传入回调函数 */
    public static void transaction(SqlAction action) throws SQLException {
        try (Connection c = getConnection()) {
            c.setAutoCommit(false);
            try {
                action.execute(c);
                c.commit();
            } catch (Exception e) {
                c.rollback();
                throw e;
            }
        }
    }

    @FunctionalInterface
    public interface SqlAction {
        void execute(Connection conn) throws SQLException;
    }
}
```

### 4.3 `BaseServlet.java` 抽取公共
```java
public abstract class BaseServlet extends HttpServlet {

    /** 子类重写此方法处理所有请求 */
    protected void doHandle(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doGet(req, resp);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doHandle(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doHandle(req, resp);
    }

    /** 解析 JSON 请求体 */
    protected JSONObject readJson(HttpServletRequest req) throws IOException {
        BufferedReader reader = req.getReader();
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) sb.append(line);
        return JSONObject.parseObject(sb.toString());
    }

    /** 输出 JSON 响应 */
    protected void writeJson(HttpServletResponse resp, Object data) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().write(JSON.toJSONString(data));
    }

    protected void writeJson(HttpServletResponse resp, int code, String msg) throws IOException {
        writeJson(resp, Result.error(code, msg));
    }

    protected void writeJson(HttpServletResponse resp, int code, String msg, Object data) throws IOException {
        Result<Object> r = new Result<>();
        r.setCode(code);
        r.setMessage(msg);
        r.setData(data);
        writeJson(resp, r);
    }

    /** 获取当前登录用户 */
    protected User currentUser(HttpServletRequest req) {
        return (User) req.getAttribute("currentUser");
    }

    protected Admin currentAdmin(HttpServletRequest req) {
        return (Admin) req.getAttribute("currentAdmin");
    }
}
```

### 4.4 `UserServlet.java` 示例
```java
@WebServlet("/api/user/*")
public class UserServlet extends BaseServlet {
    private final UserService userService = new UserService();

    @Override
    protected void doHandle(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String path = req.getPathInfo(); // /login, /info, /register...
        switch (path) {
            case "/login":     doLogin(req, resp); break;
            case "/register":  doRegister(req, resp); break;
            case "/info":      doGetInfo(req, resp); break;
            default:           writeJson(resp, 404, "接口不存在");
        }
    }

    private void doLogin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        JSONObject body = readJson(req);
        String username = body.getString("username");
        String password = body.getString("password");
        if (username == null || password == null) {
            writeJson(resp, 400, "用户名和密码不能为空");
            return;
        }
        try {
            LoginVO vo = userService.login(username, password);
            writeJson(resp, 200, "登录成功", vo);
        } catch (BizException e) {
            writeJson(resp, e.getCode(), e.getMessage());
        }
    }
    // ...
}
```

---

## 五、Filter/Listener/Interceptor 注册 (`web.xml`)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee 
         https://jakarta.ee/xml/ns/jakartaee/web-app_6_0.xsd"
         version="6.0">

    <display-name>ClothesBack</display-name>

    <!-- 字符编码 Filter -->
    <filter>
        <filter-name>EncodingFilter</filter-name>
        <filter-class>org.example.clothesback.filter.EncodingFilter</filter-class>
    </filter>
    <filter-mapping>
        <filter-name>EncodingFilter</filter-name>
        <url-pattern>/*</url-pattern>
    </filter-mapping>

    <!-- 跨域 Filter -->
    <filter>
        <filter-name>CorsFilter</filter-name>
        <filter-class>org.example.clothesback.filter.CorsFilter</filter-class>
    </filter>
    <filter-mapping>
        <filter-name>CorsFilter</filter-name>
        <url-pattern>/*</url-pattern>
    </filter-mapping>

    <!-- 启动监听 -->
    <listener>
        <listener-class>org.example.clothesback.listener.AppListener</listener-class>
    </listener>

    <!-- 欢迎页 -->
    <welcome-file-list>
        <welcome-file>index.jsp</welcome-file>
    </welcome-file-list>
</web-app>
```

> 注意:由于使用 `@WebServlet` 注解,**所有 Servlet 不用在 web.xml 中配置**
> Interceptor 在 Filter 中手动调用(教学项目简化处理)

---

## 六、`db.properties` 配置

```properties
jdbc.driver=com.mysql.cj.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/clothes_demo?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
jdbc.user=root
jdbc.password=你的密码
```

---

## 七、开发流程与规范

### 7.1 新增接口标准流程
1. 在 `entity/` 加实体(或复用)
2. 在 `dto/` 加入参封装,在 `vo/` 加出参封装
3. 在 `dao/` 加数据访问方法(可先用 `JdbcUtils.query/update`)
4. 在 `service/` 加业务方法,捕获 `BizException`
5. 在 `servlet/` 加 Servlet 处理请求路径
6. 自测:Postman / curl

### 7.2 命名规范
| 类型 | 命名 |
|---|---|
| 实体类 | 大驼峰,表名去掉下划线: `OrderItem` |
| 字段 | 小驼峰,与列名一致 |
| DAO 方法 | `findById / findByXxx / insert / update / delete / count` |
| Service 方法 | 业务动作: `login / register / createOrder / payOrder` |
| Servlet 路径 | 全小写,中划线分隔: `/api/user/order/{id}/cancel` |

### 7.3 必填校验
所有 Controller 入参**必须校验**:
- 字符串: 非空 + 长度
- 数字: 范围
- 枚举: 合法值

校验失败:`throw new BizException(400, "xxx不能为空")`

### 7.4 必走事务
- **创建订单**(扣库存 + 插订单 + 删购物车)
- **取消订单**(回滚库存 + 改状态)
- **退款**(回滚库存 + 改状态)
- **删除商品**前的合法性校验

### 7.5 必看 README
- 接口契约:`API_DESIGN.md`
- 表结构:`DB_DESIGN.md`
- 业务规则:见 `API_DESIGN.md` 第 9 节

---

## 八、部署

### 8.1 本地开发
```bash
# 1. 初始化数据库
mysql -u root -p < src/main/resources/schema.sql

# 2. 修改 db.properties 中的密码

# 3. Maven 构建
mvn clean package

# 4. 部署到 Tomcat 10+
#    将 target/ClothesBack-1.0-SNAPSHOT.war 复制到 tomcat/webapps/

# 5. 启动 Tomcat
#    访问 http://localhost:8080/clothes
```

### 8.2 配置文件外置(可选)
开发期 `db.properties` 放 `resources`,生产期可放外部目录,通过 JVM 参数覆盖:
```bash
-Ddb.config=/opt/clothes/db.properties
```

---

## 九、常见问题

### Q1:JSON 中文乱码?
✅ Servlet 中显式设置 `resp.setContentType("application/json;charset=UTF-8")`
✅ Tomcat `server.xml` 的 Connector 加 `URIEncoding="UTF-8"`

### Q2:请求参数中文乱码?
✅ `EncodingFilter` 中 `req.setCharacterEncoding("UTF-8")`
✅ 已 `getReader()` 的 JSON 请求**不需要**额外处理

### Q3:如何调试 SQL?
✅ `JdbcUtils.update` / `query` 中加 `System.out.println(sql)` + 参数
✅ 或用 IDE 调试,断点在 `PreparedStatement.executeXxx`

### Q4:事务不起作用?
✅ 必须在**同一个 Connection** 中操作
✅ 走 `JdbcUtils.transaction(conn -> {...})` 工具

### Q5:Token 怎么存?
✅ `TokenManager` 内部用 `ConcurrentHashMap<String, Object>`,key=token,value=User/Admin
✅ 退出登录时调用 `TokenManager.remove(token)`
✅ 重启服务会清空(教学项目可接受)

---

## 十、测试规范

### 10.1 单元测试范围
- Service 层核心业务(下单、支付、取消)
- JdbcUtils 工具方法
- 工具类(MD5、JsonUtils)

### 10.2 不测范围
- Servlet 转发(难以测试,靠 Postman 验证)
- 前端页面

### 10.3 测试原则
- 每个 Service 方法至少 1 个正常 + 1 个异常用例
- 测试 SQL 操作后**清理数据**(`@AfterEach`)
- 用 H2 内存库做集成测试也可(更彻底)

---

## 十一、参考资源

- [Servlet 6.1 规范](https://jakarta.ee/specifications/servlet/6.1/)
- [Fastjson2 文档](https://github.com/alibaba/fastjson2)
- [MySQL 8 文档](https://dev.mysql.com/doc/refman/8.0/en/)
- [JDBC 教程](https://docs.oracle.com/javase/tutorial/jdbc/)

---

## 十二、项目级 Agent Skills & Rules

本项目在仓库根目录的 `.cursor/skills/` 和 `.cursor/rules/` 下挂了 6 套项目级 skills/rules,**和本文档、DB_DESIGN、API_DESIGN、schema.sql 保持一致**,Agent 编辑对应文件时会自动触发。

### 随时可调用的 Skill

| Skill | 用途 |
|---|---|
| `java-coding-standards` | Java 编码规范(命名 / record / 异常 / 项目布局) |
| `backend-patterns` | 后端分层(DAO / Service / Servlet)+ 事务 + N+1 |
| `error-handling` | `BizException` 体系 + 入参校验 + JSON 响应映射 |
| `api-design` | REST 契约(URL / HTTP / 响应壳 / 分页 / 鉴权) |
| `api-connector-builder` | 新增 Servlet 端点的标准骨架 |
| `database-migrations` | MySQL 8 DDL 变更规范 + `schema.sql` / `DB_DESIGN.md` 维护 |

> 完整说明见 [`.cursor/SKILLS.md`](../../.cursor/SKILLS.md)。

### 调用方式

对话中直接说 "按 `xxx` skill 做 xxx",例如:

- *"按 `api-connector-builder` 加一个 `/api/user/address/list` 接口"*
- *"按 `database-migrations` 给 goods 表加一个 `is_featured` 字段"*
- *"按 `error-handling` 改 `BaseServlet` 的兜底逻辑"*

### 项目级硬规则(不受 skill 变更影响)

1. **不引入任何框架**:Spring / Spring Boot / MyBatis / Hibernate / 连接池一律不加
2. **统一响应壳**:`{ code, message, data }`,前端已绑定,不要改
3. **业务异常统一为 `BizException(code, message)`**:不扩散子类
4. **DDL 改动必须同步**:`Doc/schema.sql` + `Doc/DB_DESIGN.md` 同一个 commit
5. **以下场景必须走事务**:下单 / 取消 / 退款 / 级联删除

---

**最后更新:与 schema.sql / API_DESIGN.md 同步,后续添加新功能时务必同步更新本文档**
