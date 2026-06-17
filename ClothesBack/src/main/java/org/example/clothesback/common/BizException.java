package org.example.clothesback.common;

/**
 * 业务异常:Service/DAO 在校验/查不到/冲突时抛出,由 Servlet/BaseServlet 统一捕获并转 JSON。
 */
public class BizException extends RuntimeException {
    private final int code;

    public BizException(int code, String message) {
        super(message);
        this.code = code;
    }

    public BizException(ResultCode rc) {
        super(rc.getMessage());
        this.code = rc.getCode();
    }

    public BizException(ResultCode rc, String message) {
        super(message);
        this.code = rc.getCode();
    }

    public int getCode() { return code; }
}
