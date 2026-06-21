-- 修复 address 表缺少 tag 列的问题
-- 执行: mysql -u root -p clothes_demo < fix_tag_col.sql
ALTER TABLE address ADD COLUMN tag VARCHAR(20) DEFAULT NULL COMMENT '地址标签: 家/公司/学校等' AFTER is_default;
