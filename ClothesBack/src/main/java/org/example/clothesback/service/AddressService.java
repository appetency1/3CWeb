package org.example.clothesback.service;

import org.example.clothesback.common.BizException;
import org.example.clothesback.common.ResultCode;
import org.example.clothesback.dao.AddressDao;
import org.example.clothesback.dto.AddressDTO;
import org.example.clothesback.util.JdbcUtils;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class AddressService {
    private final AddressDao dao = new AddressDao();

    public List<Map<String, Object>> listByUser(Long userId) {
        try { return dao.listByUser(userId); }
        catch (SQLException e) { throw new BizException(ResultCode.SERVER_ERROR, "查询失败"); }
    }

    public Map<String, Object> create(Long userId, AddressDTO dto) {
        validate(dto);
        try {
            Long id = JdbcUtils.transactionResult(conn -> {
                int isDefault = (dao.countByUser(userId) == 0) ? 1 : 0;
                dao.insert(conn, userId, dto.receiver().trim(), dto.phone().trim(),
                    dto.province(), dto.city(), dto.district(), dto.detail(), isDefault);
                return JdbcUtils.queryLong(conn, "SELECT LAST_INSERT_ID()");
            });
            return dao.findById(id);
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "新增失败");
        }
    }

    public void update(Long userId, Long id, AddressDTO dto) {
        validate(dto);
        try {
            Map<String, Object> own = dao.findById(id);
            if (own == null || ((Number) own.get("user_id")).longValue() != userId) {
                throw new BizException(ResultCode.NOT_FOUND, "地址不存在");
            }
            JdbcUtils.transaction(conn ->
                dao.update(conn, id, dto.receiver().trim(), dto.phone().trim(),
                    dto.province(), dto.city(), dto.district(), dto.detail())
            );
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "更新失败");
        }
    }

    public void delete(Long userId, Long id) {
        try {
            Map<String, Object> own = dao.findById(id);
            if (own == null || ((Number) own.get("user_id")).longValue() != userId) {
                throw new BizException(ResultCode.NOT_FOUND, "地址不存在");
            }
            JdbcUtils.transaction(conn -> dao.delete(conn, id));
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "删除失败");
        }
    }

    public void setDefault(Long userId, Long id) {
        try {
            Map<String, Object> own = dao.findById(id);
            if (own == null || ((Number) own.get("user_id")).longValue() != userId) {
                throw new BizException(ResultCode.NOT_FOUND, "地址不存在");
            }
            JdbcUtils.transaction(conn -> {
                dao.clearDefault(conn, userId);
                dao.setDefault(conn, id);
            });
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "操作失败");
        }
    }

    private void validate(AddressDTO dto) {
        if (dto.receiver() == null || dto.receiver().isBlank()) throw new BizException(400, "收货人不能为空");
        if (dto.phone() == null || dto.phone().isBlank()) throw new BizException(400, "手机号不能为空");
        if (dto.province() == null || dto.province().isBlank()) throw new BizException(400, "省份不能为空");
        if (dto.city() == null || dto.city().isBlank()) throw new BizException(400, "城市不能为空");
        if (dto.district() == null || dto.district().isBlank()) throw new BizException(400, "区县不能为空");
        if (dto.detail() == null || dto.detail().isBlank()) throw new BizException(400, "详细地址不能为空");
    }
}
