package org.example.clothesback.service;

import org.example.clothesback.common.BizException;
import org.example.clothesback.common.PageResult;
import org.example.clothesback.common.ResultCode;
import org.example.clothesback.dao.CategoryDao;
import org.example.clothesback.dto.CategoryDTO;
import org.example.clothesback.util.BeanUtils;
import org.example.clothesback.util.JdbcUtils;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class CategoryService {
    private final CategoryDao dao = new CategoryDao();

    public List<Map<String, Object>> listEnabledTree() {
        try {
            List<Map<String, Object>> all = dao.listEnabled();
            return buildTree(all, 0L);
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "查询分类失败: " + e.getMessage());
        }
    }

    public List<Map<String, Object>> listAllFlat() {
        try { return dao.listAll(); } catch (SQLException e) { throw new BizException(ResultCode.SERVER_ERROR, "查询失败"); }
    }

    @SuppressWarnings("unchecked")
    private List<Map<String, Object>> buildTree(List<Map<String, Object>> all, Long parentId) {
        List<Map<String, Object>> roots = new ArrayList<>();
        for (Map<String, Object> c : all) {
            Number pid = (Number) c.get("parent_id");
            if ((pid == null && parentId == 0L) || (pid != null && pid.longValue() == parentId)) {
                List<Map<String, Object>> children = buildTree(all, ((Number) c.get("id")).longValue());
                Map<String, Object> node = new LinkedHashMap<>(c);
                if (!children.isEmpty()) node.put("children", children);
                roots.add(node);
            }
        }
        return roots;
    }

    public PageResult<Map<String, Object>> listAdmin(int page, int size) {
        try {
            int offset = (page - 1) * size;
            List<Map<String, Object>> rows = dao.listAll();
            long total = rows.size();
            int from = Math.min(offset, rows.size());
            int to = Math.min(offset + size, rows.size());
            return new PageResult<>(rows.subList(from, to), total, page, size);
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "查询失败");
        }
    }

    public Long create(CategoryDTO dto) {
        if (dto.name() == null || dto.name().isBlank()) throw new BizException(400, "名称不能为空");
        Long parent = dto.parentId() == null ? 0L : dto.parentId();
        try {
            if (parent != 0L && dao.findById(parent) == null) {
                throw new BizException(400, "父分类不存在");
            }
            JdbcUtils.transaction(conn ->
                dao.insert(conn, parent, dto.name().trim(), dto.icon(),
                    dto.sort() == null ? 0 : dto.sort(),
                    dto.status() == null ? 1 : dto.status())
            );
            // 返回新 ID 较复杂,这里直接返回 null 让前端重查列表
            return null;
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "新增失败");
        }
    }

    public void update(Long id, CategoryDTO dto) {
        if (dto.name() == null || dto.name().isBlank()) throw new BizException(400, "名称不能为空");
        try {
            JdbcUtils.transaction(conn ->
                dao.update(conn, id, dto.parentId() == null ? 0L : dto.parentId(), dto.name().trim(),
                    dto.icon(), dto.sort() == null ? 0 : dto.sort(),
                    dto.status() == null ? 1 : dto.status())
            );
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "修改失败");
        }
    }

    public void delete(Long id) {
        try {
            if (dao.countChildren(id) > 0) throw new BizException(409, "存在子分类,不能删除");
            if (dao.countGoods(id) > 0) throw new BizException(409, "存在商品,不能删除");
            JdbcUtils.transaction(conn -> dao.delete(conn, id));
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "删除失败");
        }
    }
}
