package org.example.clothesback.dto;

public record CategoryDTO(Long parentId, String name, String icon, Integer sort, Integer status) {}
