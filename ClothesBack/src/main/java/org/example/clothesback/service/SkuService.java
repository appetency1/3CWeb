package org.example.clothesback.service;

import org.example.clothesback.common.BizException;
import org.example.clothesback.common.ResultCode;
import org.example.clothesback.dao.SkuDao;
import org.example.clothesback.dto.SkuDTO;
import org.example.clothesback.util.JdbcUtils;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class SkuService {
    private final SkuDao skuDao = new SkuDao();

    public List<Map<String, Object>> listByGoods(Long goodsId) {
        try { return skuDao.listByGoods(goodsId); }
        catch (SQLException e) { throw new BizException(ResultCode.SERVER_ERROR, "查询失败"); }
    }

    public void create(Long goodsId, SkuDTO dto) {
        if (dto.spec() == null || dto.spec().isBlank()) throw new BizException(400, "规格不能为空");
        if (dto.price() == null) throw new BizException(400, "价格不能为空");
        try {
            JdbcUtils.transactionResult(conn -> {
                int n = skuDao.insert(conn, goodsId, dto.spec(), dto.price(),
                    dto.stock() == null ? 0 : dto.stock(), dto.image(),
                    dto.sort() == null ? 0 : dto.sort());
                if (n == 0) throw new BizException(500, "新增失败");
                return null;
            });
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "新增失败");
        }
    }

    public void update(Long id, SkuDTO dto) {
        try {
            JdbcUtils.transaction(conn ->
                skuDao.update(conn, id, dto.spec(), dto.price(), dto.stock(), dto.image(), dto.sort())
            );
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "更新失败");
        }
    }

    public void delete(Long id) {
        try { skuDao.delete(JdbcUtils.getConnection(), id); }
        catch (SQLException e) { throw new BizException(ResultCode.SERVER_ERROR, "删除失败"); }
    }
}
