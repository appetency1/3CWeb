package org.example.clothesback.dto;

public record AddressDTO(String receiver, String phone, String province, String city, String district, String detail, int isDefault) {
    /** 兼容旧调用：无 isDefault 时默认为 0 */
    public AddressDTO(String receiver, String phone, String province, String city, String district, String detail) {
        this(receiver, phone, province, city, district, detail, 0);
    }
}
