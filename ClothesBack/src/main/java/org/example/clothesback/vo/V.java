package org.example.clothesback.vo;

import java.util.List;
import java.util.Map;

/**
 * 业务 VO 全部用 {@code Map<String,Object>} 承载,简单可读。
 * 类放在这里仅作 VO 命名索引和 javadoc 锚点。
 */
public final class V {
    private V() {}

    public record LoginVO(String token, Map<String, Object> userInfo, boolean needChangePassword) {
        public LoginVO(String token, Map<String, Object> userInfo) {
            this(token, userInfo, false);
        }
    }

    /** 购物车行,带商品/快照信息。 */
    public record CartItemVO(
            Long cartId, Long goodsId, Long skuId, String goodsName, String goodsCover,
            String spec, java.math.BigDecimal price, Integer quantity, Integer selected,
            Integer stock) {}

    /** 订单详情:订单主体 + 订单项列表。 */
    public record OrderDetailVO(
            Map<String, Object> order, List<Map<String, Object>> items) {}

    /** 商品详情:商品 + SKU 列表。 */
    public record GoodsDetailVO(
            Map<String, Object> goods, List<Map<String, Object>> skus) {}
}
