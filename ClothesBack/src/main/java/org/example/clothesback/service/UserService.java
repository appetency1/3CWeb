package org.example.clothesback.service;

import org.example.clothesback.common.BizException;
import org.example.clothesback.common.ResultCode;
import org.example.clothesback.dao.UserDao;
import org.example.clothesback.dto.LoginDTO;
import org.example.clothesback.dto.RegisterDTO;
import org.example.clothesback.dto.UpdatePasswordDTO;
import org.example.clothesback.dto.UpdateUserDTO;
import org.example.clothesback.entity.User;
import org.example.clothesback.util.BeanUtils;
import org.example.clothesback.util.MD5Utils;
import org.example.clothesback.util.TokenManager;
import org.example.clothesback.vo.V.LoginVO;

import java.sql.SQLException;
import java.util.Map;

public class UserService {
    private final UserDao userDao = new UserDao();

    public LoginVO login(LoginDTO dto) {
        try {
            if (dto.username() == null || dto.username().isBlank()
                || dto.password() == null || dto.password().isBlank()) {
                throw new BizException(ResultCode.BAD_REQUEST, "用户名和密码不能为空");
            }
            Map<String, Object> row = userDao.findByUsernameWithPwd(dto.username().trim());
            if (row == null) throw new BizException(ResultCode.BAD_REQUEST, "用户名或密码错误");
            String storedPwd = String.valueOf(row.get("password"));
            if (!MD5Utils.verify(dto.password(), storedPwd)) {
                throw new BizException(ResultCode.BAD_REQUEST, "用户名或密码错误");
            }
            // 旧 MD5 密码登录成功时自动升级为 BCrypt
            if (MD5Utils.needsUpgrade(storedPwd)) {
                userDao.updatePassword(((Number) row.get("id")).longValue(), MD5Utils.hash(dto.password()));
            }
            Integer status = ((Number) row.get("status")).intValue();
            if (status != 1) throw new BizException(ResultCode.FORBIDDEN, "账号已禁用");

            User user = BeanUtils.mapToBean(row, User.class);
            String token = TokenManager.generate();
            TokenManager.put(token, user);
            Map<String, Object> userInfo = Map.of(
                "id", user.getId(),
                "username", user.getUsername(),
                "nickname", user.getNickname() == null ? "" : user.getNickname(),
                "avatar", user.getAvatar() == null ? "" : user.getAvatar(),
                "phone", user.getPhone() == null ? "" : user.getPhone(),
                "email", user.getEmail() == null ? "" : user.getEmail()
            );
            return new LoginVO(token, userInfo);
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "登录失败");
        }
    }

    public LoginVO register(RegisterDTO dto) {
        try {
            if (dto.username() == null || dto.username().isBlank()) throw new BizException(400, "用户名不能为空");
            if (dto.username().length() < 3 || dto.username().length() > 50) throw new BizException(400, "用户名长度3-50");
            if (!dto.username().matches("^[a-zA-Z0-9_\\u4e00-\\u9fa5]+$")) throw new BizException(400, "用户名只能包含字母、数字、下划线和中文");
            if (dto.password() == null || dto.password().length() < 6 || dto.password().length() > 50) throw new BizException(400, "密码长度6-50位");
            if (dto.password().matches("^\\d+$")) throw new BizException(400, "密码不能纯数字");
            if (userDao.findByUsername(dto.username().trim()) != null) throw new BizException(409, "用户名已存在");

            String phone = dto.phone();
            if (phone != null && !phone.isBlank() && userDao.findByPhone(phone) != null) {
                throw new BizException(409, "手机号已注册");
            }
            userDao.insert(dto.username().trim(), MD5Utils.hash(dto.password()),
                dto.nickname(), phone, dto.email());
            return login(new LoginDTO(dto.username(), dto.password()));
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "注册失败");
        }
    }

    public User current(Long userId) {
        try {
            Map<String, Object> row = userDao.findById(userId);
            if (row == null) throw new BizException(ResultCode.NOT_FOUND, "用户不存在");
            User user = BeanUtils.mapToBean(row, User.class);
            user.setPassword(null); // 不返回密码
            return user;
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "查询失败");
        }
    }

    public void updateProfile(Long userId, UpdateUserDTO dto) {
        try {
            int n = userDao.updateProfile(userId, dto.nickname(), dto.avatar(), dto.phone(),
                dto.email(), dto.gender(), dto.birthday());
            if (n == 0) throw new BizException(ResultCode.NOT_FOUND, "用户不存在");
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "更新失败");
        }
    }

    public void updatePassword(Long userId, UpdatePasswordDTO dto) {
        if (dto.oldPassword() == null || dto.newPassword() == null) {
            throw new BizException(400, "参数不能为空");
        }
        if (dto.newPassword().length() < 6) throw new BizException(400, "新密码至少6位");
        try {
            Map<String, Object> row = userDao.findByIdWithPwd(userId);
            if (row == null) throw new BizException(ResultCode.NOT_FOUND, "用户不存在");
            if (!MD5Utils.verify(dto.oldPassword(), String.valueOf(row.get("password")))) {
                throw new BizException(400, "原密码错误");
            }
            userDao.updatePassword(userId, MD5Utils.hash(dto.newPassword()));
        } catch (SQLException e) {
            throw new BizException(ResultCode.SERVER_ERROR, "修改失败");
        }
    }

    public void logout(String token) {
        TokenManager.remove(token);
    }
}
