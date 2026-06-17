package org.example.clothesback.dto;

import java.time.LocalDate;

public record UpdateUserDTO(String nickname, String avatar, String phone, String email, Integer gender, LocalDate birthday) {}
