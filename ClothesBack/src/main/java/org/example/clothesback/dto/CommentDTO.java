package org.example.clothesback.dto;

import java.util.List;

public record CommentDTO(Long orderId, Long goodsId, String content, Integer rating, List<String> images) {}
