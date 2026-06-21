package org.example.clothesback.service;

import org.example.clothesback.common.BizException;
import org.example.clothesback.common.ResultCode;
import org.example.clothesback.dao.AdminDao;
import org.example.clothesback.dto.LoginDTO;
import org.example.clothesback.entity.Admin;
import org.example.clothesback.util.BeanUtils;
import org.example.clothesback.util.MD5Utils;
import org.example.clothesback.util.TokenManager;
import org.example.clothesback.vo.V.LoginVO;
import org.example.clothesback.vo.V.LoginResult;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.Map;

public class AdminService {
    private final AdminDao adminDao = new AdminDao();

    public LoginResult login(LoginDTO dto) {
        try {
            if (dto.username() == null || dto.password() == null) {
                throw new BizException(400, "用户名和密码不能为空");
            }
            Map<String, Object> row = adminDao.findByUsernameWithPwd(dto.username().trim());
            if (row == null) throw new BizException(401, "用户名或密码错误");
            String storedPwd = String.valueOf(row.get("password"));
            if (!MD5Utils.verify(dto.password(), storedPwd)) {
                throw new BizException(401, "用户名或密码错误");
            }
            // 检测是否为默认密码（MD5 of "888888" = 21218cca77804d2ba1922c33e0151105）
            boolean isDefaultPwd = "21218cca77804d2ba1922c33e0151105".equals(storedPwd);

            // 旧 MD5 密码登录成功时自动升级为 BCrypt
            if (MD5Utils.needsUpgrade(storedPwd)) {
                adminDao.updatePassword(((Number) row.get("id")).longValue(), MD5Utils.hash(dto.password()));
            }
            Admin admin = BeanUtils.mapToBean(row, Admin.class);
            if (admin.getStatus() == null || admin.getStatus() != 1) {
                throw new BizException(ResultCode.FORBIDDEN, "账号已禁用");
            }
            adminDao.updateLastLogin(admin.getId(), LocalDateTime.now());
            String token = TokenManager.generate();
            TokenManager.put(token, admin);
            Map<String, Object> userInfo = Map.of(
                "id", admin.getId(),
                "username", admin.getUsername(),
                "nickname", admin.getNickname() == null ? "" : admin.getNickname(),
                "avatar", admin.getAvatar() == null ? "" : admin.getAvatar()
            );
            return new LoginResult(new LoginVO(userInfo, isDefaultPwd), token);
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "登录失败");
        }
    }

    public Admin current(Long id) {
        try {
            Map<String, Object> row = adminDao.findById(id);
            if (row == null) throw new BizException(ResultCode.NOT_FOUND, "管理员不存在");
            return BeanUtils.mapToBean(row, Admin.class);
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "查询失败");
        }
    }

    public void logout(String token) {
        TokenManager.remove(token);
    }
}
