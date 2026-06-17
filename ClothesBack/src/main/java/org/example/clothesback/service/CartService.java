package org.example.clothesback.service;

import org.example.clothesback.common.BizException;
import org.example.clothesback.common.ResultCode;
import org.example.clothesback.dao.CartDao;
import org.example.clothesback.dao.SkuDao;
import org.example.clothesback.dto.CartAddDTO;
import org.example.clothesback.util.JdbcUtils;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class CartService {
    private final CartDao cartDao = new CartDao();
    private final SkuDao skuDao = new SkuDao();

    public List<Map<String, Object>> listByUser(Long userId) {
        try { return cartDao.listByUser(userId); }
        catch (SQLException e) { throw new BizException(ResultCode.SERVER_ERROR, "查询失败"); }
    }

    public void add(Long userId, CartAddDTO dto) {
        if (dto.skuId() == null) throw new BizException(400, "skuId不能为空");
        int qty = dto.quantity() == null ? 1 : dto.quantity();
        if (qty < 1 || qty > 999) throw new BizException(400, "数量必须在1-999之间");
        try {
            Map<String, Object> sku = skuDao.findById(dto.skuId());
            if (sku == null) throw new BizException(ResultCode.NOT_FOUND, "SKU不存在");
            Long goodsId = ((Number) sku.get("goods_id")).longValue();
            Map<String, Object> existing = cartDao.findByUserAndSku(userId, dto.skuId());
            if (existing != null) {
                cartDao.addQuantity(userId, dto.skuId(), qty);
            } else {
                cartDao.insert(userId, goodsId, dto.skuId(), qty);
            }
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "加入购物车失败");
        }
    }

    public void updateQuantity(Long userId, Long id, int quantity) {
        if (quantity < 1 || quantity > 999) throw new BizException(400, "数量必须在1-999之间");
        try {
            Map<String, Object> c = cartDao.findById(id);
            if (c == null || ((Number) c.get("user_id")).longValue() != userId) {
                throw new BizException(ResultCode.NOT_FOUND, "购物车项不存在");
            }
            cartDao.updateQuantity(id, quantity);
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "更新失败");
        }
    }

    public void toggleSelect(Long userId, Long id, int selected) {
        try {
            Map<String, Object> c = cartDao.findById(id);
            if (c == null || ((Number) c.get("user_id")).longValue() != userId) {
                throw new BizException(ResultCode.NOT_FOUND, "购物车项不存在");
            }
            cartDao.updateSelected(id, selected);
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "操作失败"); }
    }

    public void selectAll(Long userId, int selected) {
        try { cartDao.updateAllSelected(userId, selected); }
        catch (SQLException e) { throw new BizException(ResultCode.SERVER_ERROR, "操作失败"); }
    }

    public void delete(Long userId, Long id) {
        try (Connection conn = JdbcUtils.getConnection()) {
            Map<String, Object> c = cartDao.findById(id);
            if (c == null || ((Number) c.get("user_id")).longValue() != userId) {
                throw new BizException(ResultCode.NOT_FOUND, "购物车项不存在");
            }
            cartDao.deleteById(conn, id);
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "删除失败");
        }
    }

    public void deleteSelected(Long userId) {
        try (Connection conn = JdbcUtils.getConnection()) {
            cartDao.deleteSelected(conn, userId);
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "删除失败");
        }
    }
}
