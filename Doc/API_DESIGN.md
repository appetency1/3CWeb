# 接口设计文档 (API Design)

> 前后端分离的接口契约,前端按此文档联调,后端按此文档实现

---

## 一、基础约定

### 1.1 服务地址
| 环境 | 地址 |
|---|---|
| 本地开发 | `http://localhost:8080/clothes` |
| 用户端前缀 | `/api/user` |
| 管理端前缀 | `/api/admin` |
| 公共接口 | `/api/public` |

> 部署到 Tomcat 时,应用上下文为 `/clothes`,所有接口需带此前缀

### 1.2 数据格式
- **请求/响应**: 全部 `application/json; charset=UTF-8`
- **字符集**: UTF-8
- **时间格式**: `yyyy-MM-dd HH:mm:ss`
- **金额单位**: 元(decimal,保留 2 位)
- **图片字段**: 相对路径 `/banners/banner1.jpg`,前端需拼接 `BASE_URL`

### 1.3 请求方式
| 操作 | HTTP 方法 |
|---|---|
| 查询列表 | `GET` (参数放 query) |
| 查询详情 | `GET` (参数放 path) |
| 新增 | `POST` (body JSON) |
| 修改 | `PUT` (body JSON) |
| 删除 | `DELETE` (参数放 path) |

---

## 二、统一响应结构

所有接口**必须**返回如下结构,**禁止**直接返回业务数据。

```json
{
  "code": 200,
  "message": "操作成功",
  "data": { ... }
}
```

### 2.1 字段说明
| 字段 | 类型 | 说明 |
|---|---|---|
| `code` | int | 状态码,见下方枚举 |
| `message` | string | 提示信息 |
| `data` | object/array | 业务数据,失败时为 null |

### 2.2 统一状态码
| code | 含义 | 触发场景 |
|---|---|---|
| 200 | 成功 | 业务正常 |
| 400 | 参数错误 | 入参校验失败 |
| 401 | 未登录 | Token 缺失/过期 |
| 403 | 无权限 | 用户角色不足 |
| 404 | 资源不存在 | - |
| 409 | 业务冲突 | 库存不足/重复提交 |
| 500 | 服务器异常 | 未捕获异常 |

### 2.3 分页响应 (data 内)
```json
{
  "list": [ ... ],
  "total": 100,
  "page": 1,
  "size": 10,
  "totalPages": 10
}
```

---

## 三、Token 鉴权

### 3.1 实现方式
- 后端登录成功后生成 **Token**(UUID 或 JWT),存入内存 Map(教学够用)
- 后续请求在 **请求头** 携带:
  ```
  Authorization: Bearer {token}
  ```

### 3.2 角色区分
- 用户端 Token: 鉴权拦截器只放行 `user` 角色
- 管理端 Token: 鉴权拦截器只放行 `admin` 角色
- 公共接口: 任何角色或未登录都可访问

### 3.3 Token 失效
- 返回 `code=401`,前端**必须**清空本地用户信息并跳转登录页

---

## 四、跨域 (CORS)

后端通过**全局 Filter**统一放行,前端开发期无需代理:

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET,POST,PUT,DELETE,OPTIONS
Access-Control-Allow-Headers: Content-Type,Authorization
```

---

## 五、错误处理规范

### 5.1 业务异常
后端封装 `BizException`,在 Filter 或 Servlet 中统一捕获,返回业务错误码。

### 5.2 参数校验
- 必填项缺失 → `code=400, message="xxx不能为空"`
- 格式错误 → `code=400, message="xxx格式不正确"`

### 5.3 友好错误信息
- 库存不足 → `code=409, message="库存不足,仅剩X件"`
- 订单状态非法 → `code=409, message="订单当前状态不支持此操作"`

---

## 六、用户端接口清单 (`/api/user`)

> ✅ 需 Token 鉴权

### 6.1 用户模块
| 方法 | 路径 | 说明 |
|---|---|---|
| POST | `/api/user/register` | 注册(公开) |
| POST | `/api/user/login` | 登录(公开) |
| GET | `/api/user/info` | 获取当前用户信息 |
| PUT | `/api/user/info` | 修改个人信息 |
| PUT | `/api/user/password` | 修改密码 |

### 6.2 收货地址
| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/api/user/address` | 列表 |
| POST | `/api/user/address` | 新增 |
| PUT | `/api/user/address/{id}` | 修改 |
| DELETE | `/api/user/address/{id}` | 删除 |
| PUT | `/api/user/address/{id}/default` | 设为默认 |

### 6.3 购物车
| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/api/user/cart` | 购物车列表(含商品详情) |
| POST | `/api/user/cart` | 加入购物车 `{skuId, quantity}` |
| PUT | `/api/user/cart/{id}` | 修改数量 |
| PUT | `/api/user/cart/{id}/select` | 切换选中 |
| PUT | `/api/user/cart/select-all` | 全选/反选 |
| DELETE | `/api/user/cart/{id}` | 删除单项 |
| DELETE | `/api/user/cart/selected` | 删除选中项 |

### 6.4 订单
| 方法 | 路径 | 说明 |
|---|---|---|
| POST | `/api/user/order` | 创建订单(从购物车) `{addressId, cartIds, remark}` |
| GET | `/api/user/order` | 订单列表 `?status=0&page=1&size=10` |
| GET | `/api/user/order/{id}` | 订单详情 |
| POST | `/api/user/order/{id}/pay` | 模拟支付 |
| POST | `/api/user/order/{id}/cancel` | 取消订单 |
| POST | `/api/user/order/{id}/confirm` | 确认收货 |

### 6.5 收藏
| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/api/user/favorite` | 收藏列表 |
| POST | `/api/user/favorite` | 收藏 `{goodsId}` |
| DELETE | `/api/user/favorite/{goodsId}` | 取消收藏 |

### 6.6 评价
| 方法 | 路径 | 说明 |
|---|---|---|
| POST | `/api/user/comment` | 发表评价 `{orderId, goodsId, content, rating, images}` |
| GET | `/api/user/comment` | 我的评价 |

---

## 七、公共接口 (`/api/public`)

> 🌐 无需登录

### 7.1 商品
| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/api/public/category` | 全部分类(含二级) |
| GET | `/api/public/goods` | 商品列表(分页) `?categoryId=&keyword=&sort=sales_desc&page=1&size=10` |
| GET | `/api/public/goods/{id}` | 商品详情(含 SKU) |
| GET | `/api/public/goods/hot` | 热门商品(取 10 条) |
| GET | `/api/public/goods/new` | 新品(取 10 条) |

### 7.2 商品评价
| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/api/public/comment` | 某商品评价 `?goodsId=&page=1&size=10` |

### 7.3 轮播图
| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/api/public/banner` | 启用的轮播图列表 |

### 7.4 文件上传
| 方法 | 路径 | 说明 |
|---|---|---|
| POST | `/api/public/upload` | 上传图片(multipart),返回 `{url}` |

---

## 八、管理端接口 (`/api/admin`)

> 🔒 需管理员 Token 鉴权

### 8.1 管理员
| 方法 | 路径 | 说明 |
|---|---|---|
| POST | `/api/admin/login` | 登录(公开) |
| GET | `/api/admin/info` | 当前管理员信息 |
| POST | `/api/admin/logout` | 退出登录 |

### 8.2 仪表盘
| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/api/admin/dashboard` | 统计数据 `{userCount, orderCount, goodsCount, totalSales, todayOrders, todaySales}` |

### 8.3 分类管理
| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/api/admin/category` | 全部分类(树形) |
| POST | `/api/admin/category` | 新增 |
| PUT | `/api/admin/category/{id}` | 修改 |
| DELETE | `/api/admin/category/{id}` | 删除(有子分类/商品则拒绝) |

### 8.4 商品管理
| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/api/admin/goods` | 商品列表(分页+筛选) |
| GET | `/api/admin/goods/{id}` | 商品详情(含 SKU) |
| POST | `/api/admin/goods` | 新增商品(SPU + SKU 一起) |
| PUT | `/api/admin/goods/{id}` | 修改商品 |
| DELETE | `/api/admin/goods/{id}` | 删除(有未完成订单则拒绝) |
| PUT | `/api/admin/goods/{id}/status` | 上下架 `{status: 0\|1}` |

### 8.5 SKU 管理
| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/api/admin/sku/{goodsId}` | 某商品的全部 SKU |
| POST | `/api/admin/sku` | 新增 SKU |
| PUT | `/api/admin/sku/{id}` | 修改 SKU |
| DELETE | `/api/admin/sku/{id}` | 删除 SKU |

### 8.6 订单管理
| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/api/admin/order` | 订单列表(筛选+分页) |
| GET | `/api/admin/order/{id}` | 订单详情 |
| POST | `/api/admin/order/{id}/ship` | 发货 |
| POST | `/api/admin/order/{id}/refund` | 退款(模拟) |

### 8.7 用户管理
| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/api/admin/user` | 用户列表 |
| GET | `/api/admin/user/{id}` | 用户详情 |
| PUT | `/api/admin/user/{id}/status` | 启用/禁用 `{status}` |

### 8.8 轮播图管理
| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/api/admin/banner` | 全部轮播图 |
| POST | `/api/admin/banner` | 新增 |
| PUT | `/api/admin/banner/{id}` | 修改 |
| DELETE | `/api/admin/banner/{id}` | 删除 |

---

## 九、核心业务规则 (后端必读)

### 9.1 库存扣减
**下单时**事务性操作:
```
1. 校验 SKU 库存 >= 购买数量
2. UPDATE sku SET stock=stock-X, sales=sales+X WHERE id=? AND stock>=X
3. 若 affectedRows=0 → 库存不足,抛出异常,事务回滚
4. UPDATE goods SET stock=stock-X, sales=sales+X WHERE id=?
5. INSERT orders + order_item
6. DELETE cart 中已下单项
```

**取消订单**(待付款状态)无需回滚库存(未扣减)
**取消订单**(已付款状态)需回滚库存
**退货**回滚库存

### 9.2 SPU 库存同步
- SPU 的 `stock`/`sales` 是**冗余统计**,任何 SKU 变更都要同步更新
- 简化方案: **不维护 SPU 冗余**,查询时 SUM(sku.stock),统计时 SUM(sku.sales)
- 建议: 教学项目选简化方案,SQL 加 SUM 即可

### 9.3 订单号生成
```java
String orderNo = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
                  + (1000 + ThreadLocalRandom.current().nextInt(9000));
```

### 9.4 价格快照
- `order_item.price / goods_name / goods_cover / spec` 在创建订单时**直接读取并写入**
- 商品后续修改**不影响**历史订单显示

### 9.5 默认地址
- 用户新增第一个地址时,自动 `is_default=1`
- 设置新默认时,先将该用户其他地址 `is_default=0`,再设当前为 `1`

### 9.6 购物车 SKU
- 加入购物车时按 `(user_id, sku_id)` 唯一
- 重复加入: `UPDATE cart SET quantity=quantity+X`
- SKU 删除/下架: 该购物车项**保留**(前端展示"已失效")

### 9.7 浏览量
- `goods.view_count++` 在**商品详情接口**触发
- 不要求严格准确,无需加锁(教学可接受误差)

### 9.8 软删除策略
- 分类下有商品/子分类 → 拒绝删除
- 商品有未完成订单(status=0,1,2) → 拒绝删除
- 其他物理删除即可

---

## 十、接口示例 (登录)

### 请求
```http
POST /api/user/login
Content-Type: application/json

{
  "username": "test",
  "password": "123456"
}
```

### 响应
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "abc123def456",
    "userInfo": {
      "id": 1,
      "username": "test",
      "nickname": "测试用户",
      "avatar": "/avatar/1.jpg"
    }
  }
}
```

### 失败
```json
{
  "code": 400,
  "message": "用户名或密码错误",
  "data": null
}
```
