package org.example.clothesback.dto;

import java.math.BigDecimal;
import java.util.List;

public record GoodsSaveDTO(
        Long categoryId,
        String name,
        String brand,
        String cover,
        String images,
        String description,
        String detail,
        BigDecimal price,
        BigDecimal originalPrice,
        Integer stock,
        Integer isHot,
        Integer isNew,
        List<SkuDTO> skus
) {
    public record SkuDTO(String spec, BigDecimal price, Integer stock, String image, Integer sort) {}
}
