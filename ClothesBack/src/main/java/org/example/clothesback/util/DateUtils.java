package org.example.clothesback.util;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Date;

/**
 * 日期工具。统一返回 {@code yyyy-MM-dd HH:mm:ss} 字符串(对应 API 规范 §1.2)。
 */
public final class DateUtils {
    public static final String PATTERN_DATETIME = "yyyy-MM-dd HH:mm:ss";
    public static final String PATTERN_DATE = "yyyy-MM-dd";

    private static final DateTimeFormatter FMT_DT = DateTimeFormatter.ofPattern(PATTERN_DATETIME);
    private static final DateTimeFormatter FMT_D = DateTimeFormatter.ofPattern(PATTERN_DATE);

    private DateUtils() {}

    public static String format(LocalDateTime dt) {
        return dt == null ? null : dt.format(FMT_DT);
    }

    public static String format(LocalDate d) {
        return d == null ? null : d.format(FMT_D);
    }

    public static String format(Date d) {
        return d == null ? null : new java.sql.Timestamp(d.getTime()).toLocalDateTime().format(FMT_DT);
    }
}
