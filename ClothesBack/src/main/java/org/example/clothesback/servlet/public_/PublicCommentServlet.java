package org.example.clothesback.servlet.public_;

import jakarta.servlet.annotation.WebServlet;
import org.example.clothesback.common.PageResult;
import org.example.clothesback.service.CommentService;
import org.example.clothesback.servlet.BaseServlet;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.util.Map;

@WebServlet("/api/public/comment")
public class PublicCommentServlet extends BaseServlet {
    private final CommentService service = new CommentService();

    @Override
    protected void doDispatch(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String gid = req.getParameter("goodsId");
        if (gid == null) { writeJson(resp, 400, "goodsId不能为空"); return; }
        Long goodsId = Long.parseLong(gid);
        int page = parseInt(req.getParameter("page"), 1);
        int size = Math.min(parseInt(req.getParameter("size"), 10), 100);
        PageResult<Map<String, Object>> data = service.listByGoods(goodsId, page, size);
        writeOk(resp, data);
    }
}
