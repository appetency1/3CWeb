# 衣服商城数据库设计说明

> 本文档配套 `schema.sql` 脚本使用,数据库名 `clothes_demo`

## 一、总体说明

| 项 | 值 |
|---|---|
| 数据库 | `clothes_demo` |
| 字符集 | `utf8mb4` |
| 排序规则 | `utf8mb4_general_ci` |
| MySQL版本 | 8.0+ |
| 表数量 | 12 张 |
| 命名规范 | 小写下划线,字段统一带注释 |

## 二、ER 关系概览

```
┌────────┐        ┌──────────┐        ┌─────────┐
│  user  │ 1───*  │  address │        │  admin  │  (管理员独立登录)
└───┬────┘        └──────────┘        └─────────┘
    │ 1
    │
    ├──*──┌─────────┐ 1───*──┌──────┐
    │     │  cart   │        │  sku │ N───1──┐
    │     └─────────┘        └──────┘        │
    │                                          │
    │     ┌─────────┐ 1───*  ┌──────────┐  *  │
    │     │ orders  │        │ order_   │  ────┤
    │     └────┬────┘        │  item    │      │
    │          │ 1           └──────────┘      │
    │          │                                │
    │     ┌────┴────┐        ┌────────┐         │
    ├──*──┤comment  │ *──1   │ goods  │ <───*───┘
    │     └─────────┘        │  (SPU) │
    │                        └───┬────┘
    │     ┌─────────┐            │ N
    │     │favorite │ *──1       │
    │     └─────────┘            │
    │                            │ N
    │                        ┌───┴──────┐
    │                        │ category │ (两级分类)
    │                        └──────────┘
    │
    │ 独立表:
    └── banner (轮播图, 无外键)
```

## 三、12 张表详细说明

### 3.1 管理员表 `admin`
- 字段: `id, username, password, nickname, avatar, email, status, last_login, create_time, update_time`
- 说明: 后台登录使用,与 `user` 表完全独立
- 默认账号: `admin` / `123456` (MD5已写入)

### 3.2 用户表 `user`
- 字段: `id, username, password, nickname, avatar, phone, email, gender, birthday, status, ...`
- 说明: C端用户登录,手机号/账号都可作为登录凭证

### 3.3 分类表 `category`
- 字段: `id, parent_id, name, icon, sort, status`
- 说明: **两级分类**,`parent_id=0` 为一级(如"男装"),`parent_id=1` 为"男装-上衣"
- 初始已写入 4 个一级 + 10 个二级

### 3.4 商品SPU表 `goods`
- 字段: `id, category_id, name, brand, cover, images, description, detail, price, original_price, stock, sales, view_count, status, is_hot, is_new, ...`
- 说明: SPU(Standard Product Unit)代表一个"商品款型",库存/价格字段为汇总值,实际下单以 SKU 为准

### 3.5 商品SKU表 `sku`
- 字段: `id, goods_id, spec, price, stock, sales, image, sort`
- 说明: SKU(Stock Keeping Unit)代表"具体规格",`spec` 用 JSON 存 `{"颜色":"红色","尺码":"XL"}`
- **重要**: SPU 的 `price/stock/sales` 在下单后应**事务性更新**

### 3.6 收货地址表 `address`
- 字段: `id, user_id, receiver, phone, province, city, district, detail, is_default`
- 说明: 一个用户可多个地址,`is_default=1` 为默认地址(每用户唯一)

### 3.7 购物车表 `cart`
- 字段: `id, user_id, goods_id, sku_id, quantity, selected`
- 唯一索引: `(user_id, sku_id)`,同一SKU重复加入会**更新数量**
- 字段 `selected` 用于结算时筛选

### 3.8 订单表 `orders`
- 字段: `id, order_no, user_id, total_amount, pay_amount, freight_amount, discount_amount, receiver, phone, address, remark, status, pay_time, ship_time, finish_time, cancel_time, ...`
- **订单号**: 时间戳 + 随机数,`uk_order_no` 唯一
- **状态机**:
  ```
  0 待付款 ──(支付)──> 1 待发货 ──(发货)──> 2 待收货 ──(收货)──> 3 已完成
     │
     └──(取消)──> 4 已取消
  ```
- **地址快照**: 收货人/电话/地址在订单创建时**冗余存储**,避免用户修改地址影响历史订单

### 3.9 订单详情表 `order_item`
- 字段: `id, order_id, goods_id, sku_id, goods_name, goods_cover, spec, price, quantity, subtotal`
- **商品快照**: `goods_name/cover/spec/price` 在下单时**冗余存储**,商品修改不影响历史订单

### 3.10 轮播图表 `banner`
- 字段: `id, title, image, link, sort, status`
- 用户端首页展示,后台可维护

### 3.11 收藏表 `favorite`
- 字段: `id, user_id, goods_id`
- 唯一索引: `(user_id, goods_id)`,重复收藏直接拒绝

### 3.12 评价表 `comment`
- 字段: `id, user_id, goods_id, order_id, content, rating, images`
- 一个订单可多次评价(每个商品一次),`rating` 1-5 星

## 四、设计原则

### 4.1 快照冗余
订单中的 `goods_name / goods_cover / spec / price` 以及 `receiver / phone / address` 都是**下单时快照**,即使商品/地址后续修改也不影响历史订单的可读性。

### 4.2 软删除 vs 物理删除
- 当前**未使用软删除**(无 `deleted` 字段),删除即物理删除
- 教学项目保持简洁,如需软删除可后续扩展

### 4.3 时间字段
所有表都包含 `create_time` 和 `update_time`,后者通过 `ON UPDATE CURRENT_TIMESTAMP` 自动维护。

### 4.4 金额字段
- 一律用 `DECIMAL(10,2)`,**不用** `FLOAT`/`DOUBLE`(浮点精度问题)
- 价格为元为单位,不存分

### 4.5 状态字段
- `TINYINT` 类型,配合注释说明枚举含义
- 订单状态等关键流转状态由后端业务层控制,前端只读

## 五、使用方法

### 5.1 初始化数据库
```bash
mysql -u root -p < schema.sql
```

### 5.2 默认账号

| 端 | 账号 | 密码 | 角色 |
|---|---|---|---|
| 管理后台 | `admin` | `123456` | 超级管理员 |
| 用户端 | (需注册) | - | 普通用户 |

## 六、待扩展 (后续可加)

- [ ] 优惠券表 `coupon` / 用户优惠券 `user_coupon`
- [ ] 支付流水表 `payment_log`
- [ ] 物流信息表 `shipping`
- [ ] 退款/售后表 `refund`
- [ ] 浏览足迹表 `browse_history`
- [ ] 消息通知表 `notification`
