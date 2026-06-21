package org.example.clothesback.dto;

public record AddressDTO(String receiver, String phone, String province, String city, String district, String detail, int isDefault, String tag) {
    /** 兼容旧调用：无 isDefault/tag 时默认为 0/空 */
    public AddressDTO(String receiver, String phone, String province, String city, String district, String detail) {
        this(receiver, phone, province, city, district, detail, 0, null);
    }

    public AddressDTO(String receiver, String phone, String province, String city, String district, String detail, int isDefault) {
        this(receiver, phone, province, city, district, detail, isDefault, null);
    }
}
