package org.example.clothesback.util;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.concurrent.ThreadLocalRandom;

/**
 * 订单号生成:yyyyMMddHHmmss + 4 位随机数。教学项目对唯一性不做强保证(实际唯一键在表上)。
 */
public final class IdGenerator {
    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    private IdGenerator() {}

    public static String orderNo() {
        return LocalDateTime.now().format(FMT) + (1000 + ThreadLocalRandom.current().nextInt(9000));
    }
}
