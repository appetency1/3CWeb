package org.example.clothesback.dto;

import java.math.BigDecimal;

public record SkuDTO(Long id, String spec, BigDecimal price, Integer stock, String image, Integer sort) {}
