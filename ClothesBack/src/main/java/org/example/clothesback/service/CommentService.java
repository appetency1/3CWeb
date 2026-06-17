package org.example.clothesback.service;

import com.alibaba.fastjson2.JSON;
import org.example.clothesback.common.BizException;
import org.example.clothesback.common.PageResult;
import org.example.clothesback.common.ResultCode;
import org.example.clothesback.dao.CommentDao;
import org.example.clothesback.dto.CommentDTO;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class CommentService {
    private final CommentDao dao = new CommentDao();

    public PageResult<Map<String, Object>> listByGoods(Long goodsId, int page, int size) {
        try {
            int offset = (page - 1) * size;
            List<Map<String, Object>> rows = dao.listByGoods(goodsId, offset, size);
            long total = dao.countByGoods(goodsId);
            return new PageResult<>(rows, total, page, size);
        } catch (SQLException e) { throw new BizException(ResultCode.SERVER_ERROR, "查询失败"); }
    }

    public PageResult<Map<String, Object>> listByUser(Long userId, int page, int size) {
        try {
            int offset = (page - 1) * size;
            List<Map<String, Object>> rows = dao.listByUser(userId, offset, size);
            long total = dao.countByUser(userId);
            return new PageResult<>(rows, total, page, size);
        } catch (SQLException e) { throw new BizException(ResultCode.SERVER_ERROR, "查询失败"); }
    }

    public void add(Long userId, CommentDTO dto) {
        if (dto.goodsId() == null || dto.orderId() == null) throw new BizException(400, "参数不能为空");
        if (dto.content() == null || dto.content().isBlank()) throw new BizException(400, "评价内容不能为空");
        if (dto.rating() == null || dto.rating() < 1 || dto.rating() > 5) throw new BizException(400, "评分1-5");
        try {
            if (dao.existsByOrderAndGoods(userId, dto.orderId(), dto.goodsId())) {
                throw new BizException(409, "已评价过该商品");
            }
            String images = dto.images() == null || dto.images().isEmpty() ? null : JSON.toJSONString(dto.images());
            dao.insert(userId, dto.goodsId(), dto.orderId(), dto.content().trim(), dto.rating(), images);
        } catch (SQLException e) { throw new BizException(ResultCode.SERVER_ERROR, "评价失败"); }
    }
}
