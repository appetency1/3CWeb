package org.example.clothesback.service;

import org.example.clothesback.common.BizException;
import org.example.clothesback.common.PageResult;
import org.example.clothesback.common.ResultCode;
import org.example.clothesback.dao.BannerDao;
import org.example.clothesback.dto.BannerDTO;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class BannerService {
    private final BannerDao dao = new BannerDao();

    public List<Map<String, Object>> listEnabled() {
        try { return dao.listEnabled(); } catch (SQLException e) { throw new BizException(ResultCode.SERVER_ERROR, "查询失败: " + e.getMessage()); }
    }

    public List<Map<String, Object>> listAll() {
        try { return dao.listAll(); } catch (SQLException e) { throw new BizException(ResultCode.SERVER_ERROR, "查询失败: " + e.getMessage()); }
    }

    public Long create(BannerDTO dto) {
        if (dto.title() == null || dto.title().isBlank()) throw new BizException(400, "标题不能为空");
        if (dto.image() == null || dto.image().isBlank()) throw new BizException(400, "图片不能为空");
        try { return Long.valueOf(dao.insert(dto.title(), dto.image(), dto.link(),
                dto.sort() == null ? 0 : dto.sort(),
                dto.status() == null ? 1 : dto.status())); }
        catch (SQLException e) { throw new BizException(ResultCode.SERVER_ERROR, "新增失败"); }
    }

    public void update(Long id, BannerDTO dto) {
        try {
            int n = dao.update(id, dto.title(), dto.image(), dto.link(), dto.sort(), dto.status());
            if (n == 0) throw new BizException(ResultCode.NOT_FOUND, "轮播图不存在");
        } catch (SQLException e) { throw new BizException(ResultCode.SERVER_ERROR, "更新失败"); }
    }

    public void delete(Long id) {
        try {
            int n = dao.delete(id);
            if (n == 0) throw new BizException(ResultCode.NOT_FOUND, "轮播图不存在");
        } catch (SQLException e) { throw new BizException(ResultCode.SERVER_ERROR, "删除失败"); }
    }
}
