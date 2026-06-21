package org.example.clothesback.service;

import org.example.clothesback.common.BizException;
import org.example.clothesback.common.PageResult;
import org.example.clothesback.common.ResultCode;
import org.example.clothesback.dao.*;
import org.example.clothesback.dto.CreateOrderDTO;
import org.example.clothesback.util.IdGenerator;
import org.example.clothesback.util.JdbcUtils;
import org.example.clothesback.vo.V.OrderDetailVO;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * 订单服务。核心:创建订单(事务扣库存 + 写订单 + 删购物车)。
 */
public class OrderService {
    private final OrderDao orderDao = new OrderDao();
    private final OrderItemDao orderItemDao = new OrderItemDao();
    private final CartDao cartDao = new CartDao();
    private final SkuDao skuDao = new SkuDao();
    private final GoodsDao goodsDao = new GoodsDao();
    private final AddressDao addressDao = new AddressDao();

    public Map<String, Object> create(Long userId, CreateOrderDTO dto) {
        if (dto.addressId() == null) throw new BizException(400, "请选择收货地址");
        if (dto.cartIds() == null || dto.cartIds().isEmpty()) throw new BizException(400, "请选择要结算的商品");
        try {
            return JdbcUtils.transactionResult(conn -> doCreate(conn, userId, dto));
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "创建订单失败");
        }
    }

    private Map<String, Object> doCreate(Connection conn, Long userId, CreateOrderDTO dto) throws SQLException {
        // 1. 验证地址
        Map<String, Object> addr = addressDao.findById(dto.addressId());
        if (addr == null || ((Number) addr.get("user_id")).longValue() != userId) {
            throw new BizException(400, "收货地址无效");
        }

        // 2. 收集 cart 行
        List<Map<String, Object>> items = new ArrayList<>();
        for (Long cartId : dto.cartIds()) {
            Map<String, Object> c = cartDao.findById(cartId);
            if (c == null || ((Number) c.get("user_id")).longValue() != userId) {
                throw new BizException(400, "购物车项无效");
            }
            items.add(c);
        }

        // 3. 锁库存 + 计算价格
        BigDecimal total = BigDecimal.ZERO;
        List<Map<String, Object>> snapshotList = new ArrayList<>(items.size());
        for (Map<String, Object> c : items) {
            Long skuId = ((Number) c.get("sku_id")).longValue();
            int qty = ((Number) c.get("quantity")).intValue();
            Map<String, Object> sku = skuDao.lockById(conn, skuId);
            if (sku == null) throw new BizException(400, "SKU不存在");
            int stock = ((Number) sku.get("stock")).intValue();
            if (stock < qty) {
                throw new BizException(409, "库存不足,仅剩" + stock + "件");
            }
            int n = skuDao.decrementStock(conn, skuId, qty);
            if (n == 0) throw new BizException(409, "库存不足");

            Map<String, Object> g = goodsDao.findById(((Number) sku.get("goods_id")).longValue());
            if (g == null) throw new BizException(500, "商品不存在");

            BigDecimal price = (BigDecimal) sku.get("price");
            BigDecimal subtotal = price.multiply(BigDecimal.valueOf(qty));
            total = total.add(subtotal);

            Map<String, Object> snap = new java.util.LinkedHashMap<>();
            snap.put("goods_id", ((Number) sku.get("goods_id")).longValue());
            snap.put("sku_id", skuId);
            snap.put("goods_name", g.get("name"));
            snap.put("goods_cover", g.get("cover"));
            snap.put("spec", sku.get("spec"));
            snap.put("price", price);
            snap.put("quantity", qty);
            snap.put("subtotal", subtotal);
            snap.put("cart_id", ((Number) c.get("id")).longValue());
            snapshotList.add(snap);
        }

        // 4. 计算优惠 + 实付
        BigDecimal discountAmount = BigDecimal.ZERO;
        if (total.compareTo(new BigDecimal("500")) >= 0) {
            discountAmount = new BigDecimal("200");
        } else if (total.compareTo(new BigDecimal("299")) >= 0) {
            discountAmount = new BigDecimal("50");
        }
        BigDecimal payAmount = total.subtract(discountAmount);

        // 5. 写订单
        String orderNo = IdGenerator.orderNo();
        orderDao.insert(conn, orderNo, userId, total, payAmount, BigDecimal.ZERO, discountAmount,
            String.valueOf(addr.get("receiver")),
            String.valueOf(addr.get("phone")),
            addr.get("province") + " " + addr.get("city") + " " + addr.get("district") + " " + addr.get("detail"),
            dto.remark());
        Long orderId = orderDao.lastInsertId(conn);

        // 6. 写订单项
        for (Map<String, Object> s : snapshotList) {
            orderItemDao.insert(conn, orderId,
                ((Number) s.get("goods_id")).longValue(),
                ((Number) s.get("sku_id")).longValue(),
                String.valueOf(s.get("goods_name")),
                String.valueOf(s.get("goods_cover")),
                String.valueOf(s.get("spec")),
                (BigDecimal) s.get("price"),
                ((Number) s.get("quantity")).intValue(),
                (BigDecimal) s.get("subtotal"));
        }

        // 7. 同步 SPU 冗余库存/销量
        for (Map<String, Object> s : snapshotList) {
            goodsDao.recomputeStockAndSales(conn, ((Number) s.get("goods_id")).longValue());
        }

        // 8. 删购物车项
        List<Long> cartIds = new ArrayList<>();
        for (Map<String, Object> s : snapshotList) {
            cartIds.add(((Number) s.get("cart_id")).longValue());
        }
        cartDao.deleteByIds(conn, userId, cartIds);

        return java.util.Map.of("orderNo", orderNo, "orderId", orderId);
    }

    public PageResult<Map<String, Object>> listByUser(Long userId, Integer status, int page, int size) {
        try {
            int offset = (page - 1) * size;
            List<Map<String, Object>> rows = orderDao.listByUser(userId, status, offset, size);
            long total = orderDao.countByUser(userId, status);
            return new PageResult<>(rows, total, page, size);
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "查询失败");
        }
    }

    public OrderDetailVO detail(Long userId, Long orderId, boolean isAdmin) {
        try {
            Map<String, Object> o = orderDao.findById(orderId);
            if (o == null) throw new BizException(ResultCode.NOT_FOUND, "订单不存在");
            if (!isAdmin && ((Number) o.get("user_id")).longValue() != userId) {
                throw new BizException(ResultCode.NOT_FOUND, "订单不存在");
            }
            List<Map<String, Object>> items = orderItemDao.listByOrder(orderId);
            return new OrderDetailVO(o, items);
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "查询失败");
        }
    }

    public void pay(Long userId, Long orderId) {
        try {
            // 幂等：数据库事务内先查再改，状态=0 时才能支付，避免了重复支付
            JdbcUtils.transaction(conn -> {
                Map<String, Object> o = orderDao.findById(orderId);
                if (o == null) throw new BizException(ResultCode.NOT_FOUND, "订单不存在");
                if (((Number) o.get("user_id")).longValue() != userId) throw new BizException(ResultCode.NOT_FOUND, "订单不存在");
                int st = ((Number) o.get("status")).intValue();
                if (st != 0) throw new BizException(409, "订单当前状态不支持支付");
                // 金额校验：实付金额必须 > 0
                BigDecimal payAmount = (BigDecimal) o.get("pay_amount");
                if (payAmount == null || payAmount.compareTo(BigDecimal.ZERO) <= 0) {
                    throw new BizException(400, "订单金额异常");
                }
                orderDao.updateStatusWithTime(conn, orderId, 1, "pay_time");
            });
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "支付失败");
        }
    }

    public void cancel(Long userId, Long orderId) {
        try {
            JdbcUtils.transaction(conn -> {
                Map<String, Object> o = orderDao.findById(orderId);
                if (o == null) throw new BizException(ResultCode.NOT_FOUND, "订单不存在");
                if (((Number) o.get("user_id")).longValue() != userId) throw new BizException(ResultCode.NOT_FOUND, "订单不存在");
                int st = ((Number) o.get("status")).intValue();
                if (st == 4) throw new BizException(409, "订单已取消");
                if (st == 3) throw new BizException(409, "订单已完成,不能取消");
                if (st == 2) throw new BizException(409, "订单已发货,不能取消");

                // 待付款(0)无需回滚库存;待发货(1)及以上需回滚
                if (st == 1) {
                    List<Map<String, Object>> items = orderItemDao.listByOrder(orderId);
                    for (Map<String, Object> it : items) {
                        Long skuId = ((Number) it.get("sku_id")).longValue();
                        int qty = ((Number) it.get("quantity")).intValue();
                        Long goodsId = ((Number) it.get("goods_id")).longValue();
                        skuDao.incrementStock(conn, skuId, qty);
                        goodsDao.recomputeStockAndSales(conn, goodsId);
                    }
                }
                orderDao.updateStatusWithTime(conn, orderId, 4, "cancel_time");
            });
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "取消失败");
        }
    }

    public void confirm(Long userId, Long orderId) {
        try {
            JdbcUtils.transaction(conn -> {
                Map<String, Object> o = orderDao.findById(orderId);
                if (o == null) throw new BizException(ResultCode.NOT_FOUND, "订单不存在");
                if (((Number) o.get("user_id")).longValue() != userId) throw new BizException(ResultCode.NOT_FOUND, "订单不存在");
                int st = ((Number) o.get("status")).intValue();
                if (st != 2) throw new BizException(409, "订单当前状态不支持确认收货");
                orderDao.updateStatusWithTime(conn, orderId, 3, "finish_time");
            });
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "操作失败");
        }
    }

    // -------- admin --------

    public PageResult<Map<String, Object>> listAdmin(Integer status, String keyword, int page, int size) {
        try {
            int offset = (page - 1) * size;
            List<Map<String, Object>> rows = orderDao.listAdmin(status, keyword, offset, size);
            long total = orderDao.countAdmin(status, keyword);
            return new PageResult<>(rows, total, page, size);
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "查询失败");
        }
    }

    public void ship(Long orderId) {
        try {
            JdbcUtils.transaction(conn -> {
                Map<String, Object> o = orderDao.findById(orderId);
                if (o == null) throw new BizException(ResultCode.NOT_FOUND, "订单不存在");
                int st = ((Number) o.get("status")).intValue();
                if (st != 1) throw new BizException(409, "订单当前状态不支持发货");
                orderDao.updateStatusWithTime(conn, orderId, 2, "ship_time");
            });
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "操作失败");
        }
    }

    public void refund(Long orderId) {
        try {
            JdbcUtils.transaction(conn -> {
                Map<String, Object> o = orderDao.findById(orderId);
                if (o == null) throw new BizException(ResultCode.NOT_FOUND, "订单不存在");
                int st = ((Number) o.get("status")).intValue();
                if (st == 4) throw new BizException(409, "订单已取消");
                if (st == 3) throw new BizException(409, "订单已完成");
                if (st == 0) throw new BizException(409, "待付款订单直接取消即可");
                List<Map<String, Object>> items = orderItemDao.listByOrder(orderId);
                for (Map<String, Object> it : items) {
                    Long skuId = ((Number) it.get("sku_id")).longValue();
                    int qty = ((Number) it.get("quantity")).intValue();
                    Long goodsId = ((Number) it.get("goods_id")).longValue();
                    skuDao.incrementStock(conn, skuId, qty);
                    goodsDao.recomputeStockAndSales(conn, goodsId);
                }
                orderDao.updateStatusWithTime(conn, orderId, 5, "cancel_time");
            });
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "退款失败");
        }
    }
}
