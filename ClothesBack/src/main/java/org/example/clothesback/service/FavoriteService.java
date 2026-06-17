package org.example.clothesback.service;

import org.example.clothesback.common.BizException;
import org.example.clothesback.common.PageResult;
import org.example.clothesback.common.ResultCode;
import org.example.clothesback.dao.FavoriteDao;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class FavoriteService {
    private final FavoriteDao dao = new FavoriteDao();

    public PageResult<Map<String, Object>> listByUser(Long userId, int page, int size) {
        try {
            int offset = (page - 1) * size;
            List<Map<String, Object>> rows = dao.listByUser(userId, offset, size);
            long total = dao.countByUser(userId);
            return new PageResult<>(rows, total, page, size);
        } catch (SQLException e) { throw new BizException(ResultCode.SERVER_ERROR, "查询失败"); }
    }

    public void add(Long userId, Long goodsId) {
        if (goodsId == null) throw new BizException(400, "goodsId不能为空");
        try {
            if (dao.findByUserAndGoods(userId, goodsId) != null) {
                throw new BizException(409, "已收藏");
            }
            dao.insert(userId, goodsId);
        } catch (SQLException e) { throw new BizException(ResultCode.SERVER_ERROR, "收藏失败"); }
    }

    public void remove(Long userId, Long goodsId) {
        try { dao.delete(userId, goodsId); }
        catch (SQLException e) { throw new BizException(ResultCode.SERVER_ERROR, "取消收藏失败"); }
    }
}
