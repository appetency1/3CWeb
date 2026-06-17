package org.example.clothesback.dto;

import java.util.List;

public record CreateOrderDTO(Long addressId, List<Long> cartIds, String remark) {}
