package org.example.clothesback.service;

import org.example.clothesback.common.BizException;
import org.example.clothesback.common.PageResult;
import org.example.clothesback.common.ResultCode;
import org.example.clothesback.dao.GoodsDao;
import org.example.clothesback.dao.SkuDao;
import org.example.clothesback.dto.GoodsSaveDTO;
import org.example.clothesback.util.JdbcUtils;
import org.example.clothesback.vo.V.GoodsDetailVO;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class GoodsService {
    private final GoodsDao goodsDao = new GoodsDao();
    private final SkuDao skuDao = new SkuDao();

    public PageResult<Map<String, Object>> listPublic(Long categoryId, String keyword, String sort, int page, int size) {
        try {
            int offset = (page - 1) * size;
            List<Map<String, Object>> rows = goodsDao.listPublic(categoryId, keyword, sort, offset, size);
            long total = goodsDao.countPublic(categoryId, keyword);
            return new PageResult<>(rows, total, page, size);
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "查询失败");
        }
    }

    public List<Map<String, Object>> listHot() {
        try { return goodsDao.listHot(10); } catch (SQLException e) { throw new BizException(ResultCode.SERVER_ERROR, "查询失败"); }
    }

    public List<Map<String, Object>> listNew() {
        try { return goodsDao.listNew(10); } catch (SQLException e) { throw new BizException(ResultCode.SERVER_ERROR, "查询失败"); }
    }

    public GoodsDetailVO detail(Long id) {
        try {
            Map<String, Object> g = goodsDao.findById(id);
            if (g == null || ((Number) g.get("status")).intValue() != 1) {
                throw new BizException(ResultCode.NOT_FOUND, "商品不存在");
            }
            // 浏览量 +1
            try { goodsDao.incrementView(id); } catch (Exception ignored) {}
            List<Map<String, Object>> skus = skuDao.listByGoods(id);
            return new GoodsDetailVO(g, skus);
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "查询失败");
        }
    }

    public PageResult<Map<String, Object>> listAdmin(Long categoryId, String keyword, Integer status, int page, int size) {
        try {
            int offset = (page - 1) * size;
            List<Map<String, Object>> rows = goodsDao.listAdmin(categoryId, keyword, status, offset, size);
            long total = goodsDao.countAdmin(categoryId, keyword, status);
            return new PageResult<>(rows, total, page, size);
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "查询失败");
        }
    }

    public Map<String, Object> detailAdmin(Long id) {
        try {
            Map<String, Object> g = goodsDao.findById(id);
            if (g == null) throw new BizException(ResultCode.NOT_FOUND, "商品不存在");
            return g;
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "查询失败");
        }
    }

    public Long create(GoodsSaveDTO dto) {
        validateSaveDto(dto);
        try {
            return JdbcUtils.transactionResult(conn -> {
                int n = goodsDao.insert(conn, dto.categoryId(), dto.name().trim(), dto.brand(), dto.cover(),
                    dto.images(), dto.description(), dto.detail(), dto.price(),
                    dto.originalPrice(), dto.stock(), dto.isHot(), dto.isNew());
                if (n == 0) throw new BizException(500, "新增商品失败");
                Long newId = JdbcUtils.queryLong(conn, "SELECT LAST_INSERT_ID()");
                if (dto.skus() != null) {
                    for (var s : dto.skus()) {
                        skuDao.insert(conn, newId, s.spec(), s.price(), s.stock(), s.image(), s.sort());
                    }
                }
                goodsDao.recomputeStockAndSales(conn, newId);
                return newId;
            });
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "新增失败");
        }
    }

    public void update(Long id, GoodsSaveDTO dto) {
        validateSaveDto(dto);
        try {
            JdbcUtils.transaction(conn -> {
                goodsDao.update(conn, id, dto.categoryId(), dto.name().trim(), dto.brand(), dto.cover(),
                    dto.images(), dto.description(), dto.detail(), dto.price(),
                    dto.originalPrice(), dto.isHot(), dto.isNew());
                goodsDao.recomputeStockAndSales(conn, id);
            });
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "更新失败");
        }
    }

    public void changeStatus(Long id, int status) {
        if (status != 0 && status != 1) throw new BizException(400, "状态值非法");
        try {
            int n = goodsDao.updateStatus(id, status);
            if (n == 0) throw new BizException(ResultCode.NOT_FOUND, "商品不存在");
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "操作失败");
        }
    }

    public void delete(Long id) {
        try {
            if (goodsDao.countPendingOrders(id) > 0) {
                throw new BizException(409, "存在未完成订单,不能删除");
            }
            JdbcUtils.transaction(conn -> {
                skuDao.deleteByGoods(conn, id);
                goodsDao.delete(conn, id);
            });
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "删除失败");
        }
    }

    private void validateSaveDto(GoodsSaveDTO dto) {
        if (dto.name() == null || dto.name().isBlank()) throw new BizException(400, "商品名称不能为空");
        if (dto.categoryId() == null) throw new BizException(400, "分类不能为空");
        if (dto.price() == null) throw new BizException(400, "价格不能为空");
        if (dto.cover() == null || dto.cover().isBlank()) throw new BizException(400, "封面图不能为空");
    }
}
