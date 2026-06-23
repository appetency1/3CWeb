package org.example.clothesback.servlet.public_;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONArray;
import com.alibaba.fastjson2.JSONObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.clothesback.common.BizException;
import org.example.clothesback.servlet.BaseServlet;

import java.io.InputStream;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.Map;
import java.util.Properties;
import java.util.concurrent.ConcurrentHashMap;

/**
 * AI 客服聊天代理 — 前端消息经此转发至 DeepSeek API，API Key 不暴露给浏览器。
 * POST /api/public/ai/chat
 * Body: { "messages": [{"role": "user", "content": "..."}] }
 * Response: { "code": 0, "data": { "reply": "..." } }
 */
@WebServlet("/api/public/ai/chat")
public class AiChatServlet extends BaseServlet {

    private static final String DEEPSEEK_URL = "https://api.deepseek.com/chat/completions";
    private static final String MODEL = "deepseek-chat";
    private static final int TIMEOUT_SEC = 30;

    /** 系统提示词 — 定义 AI 角色和行为 */
    private static final String SYSTEM_PROMPT = """
你是一家名为 MAISON 的数码/3C 产品电商的 AI 智能顾问客服。你的语气友好、专业、热情。
你可以帮用户做以下几类事情：
1. 推荐搭配 — 根据用户喜好推荐数码产品，说明推荐理由
2. 介绍商品 — 描述产品参数、性能、适用场景
3. 解答问题 — 产品规格对比、售后政策、优惠活动
4. 选购建议 — 根据预算/需求/使用场景给出数码产品推荐

MAISON 的商品线包括：智能手机、笔记本电脑、平板电脑、耳机音箱、智能手表、相机、手机配件等各大品牌。

回答要求：
- 简洁清晰，中文回答，长度控制在 200 字以内
- 有推荐时给出具体理由而非笼统描述
- 如果用户问到不确定的信息，如实告知，不要编造
- 推荐商品时可以用 Markdown 列表格式
- 语气热情但专业，像一位懂数码产品的导购
""";

    /** 速率限制：每 IP 每分钟最多 10 次 */
    private static final int RATE_LIMIT = 10;
    private static final Duration RATE_WINDOW = Duration.ofMinutes(1);
    private static final Map<String, Deque<Instant>> rateMap = new ConcurrentHashMap<>();

    private static final String API_KEY;
    private static final HttpClient httpClient = HttpClient.newBuilder()
        .connectTimeout(Duration.ofSeconds(10))
        .build();

    static {
        // 优先从环境变量读取（生产安全），其次 app.properties（本地开发）
        String key = System.getenv("DEEPSEEK_API_KEY");
        if (key == null || key.isBlank()) {
            try (InputStream in = AiChatServlet.class.getClassLoader().getResourceAsStream("app.properties")) {
                if (in != null) {
                    Properties p = new Properties();
                    p.load(in);
                    key = p.getProperty("deepseek.api.key", "");
                }
            } catch (Exception e) {
                // 保留空 key，请求时会返回错误
            }
        }
        API_KEY = key;
    }

    @Override
    protected void doDispatch(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        if (!"POST".equalsIgnoreCase(req.getMethod())) {
            writeJson(resp, 405, "仅支持 POST");
            return;
        }
        if (API_KEY == null || API_KEY.isBlank() || API_KEY.startsWith("sk-your")) {
            writeJson(resp, 500, "AI 服务未配置（缺少有效的 API Key）");
            return;
        }

        // 速率限制：每 IP 每分钟最多 RATE_LIMIT 次
        String ip = req.getRemoteAddr();
        if (ip == null) ip = "unknown";
        Instant now = Instant.now();
        Deque<Instant> timeline = rateMap.computeIfAbsent(ip, k -> new ArrayDeque<>());
        synchronized (timeline) {
            // 清理过期记录
            while (!timeline.isEmpty() && timeline.peekFirst().isBefore(now.minus(RATE_WINDOW))) {
                timeline.pollFirst();
            }
            if (timeline.size() >= RATE_LIMIT) {
                writeJson(resp, 429, "请求太频繁，请稍后再试");
                return;
            }
            timeline.addLast(now);
        }

        JSONObject body = readJson(req);
        JSONArray messages = body.getJSONArray("messages");
        if (messages == null || messages.isEmpty()) {
            writeJson(resp, 400, "messages 不能为空");
            return;
        }

        // 构造 DeepSeek 请求体
        JSONObject deepseekBody = new JSONObject();
        deepseekBody.put("model", MODEL);
        deepseekBody.put("stream", false);
        deepseekBody.put("max_tokens", 1024);

        // 在用户消息前插入系统提示词
        JSONArray fullMessages = new JSONArray();
        JSONObject sysMsg = new JSONObject();
        sysMsg.put("role", "system");
        sysMsg.put("content", SYSTEM_PROMPT);
        fullMessages.add(sysMsg);
        fullMessages.addAll(messages);
        deepseekBody.put("messages", fullMessages);

        // 发送请求
        HttpRequest dsReq = HttpRequest.newBuilder()
            .uri(URI.create(DEEPSEEK_URL))
            .header("Content-Type", "application/json")
            .header("Authorization", "Bearer " + API_KEY)
            .timeout(Duration.ofSeconds(TIMEOUT_SEC))
            .POST(HttpRequest.BodyPublishers.ofString(deepseekBody.toJSONString()))
            .build();

        HttpResponse<String> dsResp = httpClient.send(dsReq, HttpResponse.BodyHandlers.ofString());
        int statusCode = dsResp.statusCode();

        if (statusCode != 200) {
            log.warning("DeepSeek API 返回 " + statusCode + ": " + dsResp.body());
            writeJson(resp, 502, "AI 服务暂不可用，请稍后重试");
            return;
        }

        JSONObject dsJson = JSON.parseObject(dsResp.body());
        String reply = extractReply(dsJson);
        if (reply == null) {
            log.warning("DeepSeek 响应格式异常: " + dsResp.body());
            writeJson(resp, 502, "AI 响应解析失败");
            return;
        }

        JSONObject data = new JSONObject();
        data.put("reply", reply);
        writeOk(resp, data);
    }

    /** 从 DeepSeek 响应中提取 AI 回复文本 */
    private String extractReply(JSONObject dsJson) {
        JSONArray choices = dsJson.getJSONArray("choices");
        if (choices == null || choices.isEmpty()) return null;
        JSONObject first = choices.getJSONObject(0);
        JSONObject message = first.getJSONObject("message");
        if (message == null) return null;
        return message.getString("content");
    }
}
