-- 为 goods 表添加全文索引（ngram 中文分词）
-- 执行: mysql -u root -p000000 clothes_demo < Doc/migrations/add_ft_search.sql
ALTER TABLE goods ADD FULLTEXT INDEX ft_search (name, brand, description) WITH PARSER ngram;
