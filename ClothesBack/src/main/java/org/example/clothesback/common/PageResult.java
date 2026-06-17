package org.example.clothesback.common;

import java.util.Collections;
import java.util.List;

/**
 * 分页结果。前端按 {@code total, page, size, totalPages, list} 渲染。
 */
public class PageResult<T> {
    private List<T> list;
    private long total;
    private int page;
    private int size;
    private int totalPages;

    public PageResult() {
        this.list = Collections.emptyList();
    }

    public PageResult(List<T> list, long total, int page, int size) {
        this.list = list == null ? Collections.emptyList() : list;
        this.total = total;
        this.page = page;
        this.size = size;
        this.totalPages = size <= 0 ? 0 : (int) Math.ceil(total * 1.0 / size);
    }

    public static <T> PageResult<T> empty(int page, int size) {
        return new PageResult<>(Collections.emptyList(), 0, page, size);
    }

    public List<T> getList() { return list; }
    public void setList(List<T> list) { this.list = list; }
    public long getTotal() { return total; }
    public void setTotal(long total) { this.total = total; }
    public int getPage() { return page; }
    public void setPage(int page) { this.page = page; }
    public int getSize() { return size; }
    public void setSize(int size) { this.size = size; }
    public int getTotalPages() { return totalPages; }
    public void setTotalPages(int totalPages) { this.totalPages = totalPages; }
}
