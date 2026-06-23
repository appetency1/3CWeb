<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showFailToast, showConfirmDialog, showToast } from 'vant'
import { getGoodsList, deleteGoods, updateGoodsStatus } from '@/api/goods'
import { imgUrl } from '@/utils/request'

const router = useRouter()
const goodsList = ref<any[]>([])
const loading = ref(false)
const page = ref(1)
const size = 20
const total = ref(0)
const keyword = ref('')
const filterStatus = ref<number | undefined>(undefined)

const totalPages = computed(() => Math.ceil(total.value / size) || 0)

const statusPills = [
  { label: '全部', value: undefined },
  { label: '上架', value: 1 },
  { label: '下架', value: 0 },
]

async function fetchList() {
  if (loading.value) return
  loading.value = true
  try {
    const res = await getGoodsList({ page: page.value, size, keyword: keyword.value || undefined, status: filterStatus.value })
    const list = res?.list || res?.data?.list || res || []
    if (Array.isArray(list)) goodsList.value = list
    total.value = res?.total ?? 0
  } catch (e: any) {
    showFailToast(e?.message || '加载失败')
  } finally {
    loading.value = false
  }
}

function goPage(p: number) {
  if (p < 1 || p > totalPages.value || p === page.value) return
  page.value = p
  fetchList()
}

async function onDelete(id: number) {
  try {
    await showConfirmDialog({ message: '确定删除该商品？' })
    await deleteGoods(id)
    goodsList.value = goodsList.value.filter(g => g.id !== id)
    showToast('已删除')
  } catch { /* 取消 */ }
}

async function onToggleStatus(id: number, current: number) {
  const newStatus = current === 1 ? 0 : 1
  try {
    await updateGoodsStatus(id, newStatus)
    const g = goodsList.value.find(item => item.id === id)
    if (g) g.status = newStatus
  } catch (e: any) {
    showFailToast(e?.message || '操作失败')
  }
}

function onAdd() { router.push({ name: 'goodsAdd' }) }
function onEdit(id: number) { router.push({ name: 'goodsEdit', params: { id } }) }

function onSearch() {
  page.value = 1
  total.value = 0
  goodsList.value = []
  fetchList()
}

function onFilterChange(val: number | undefined) {
  filterStatus.value = val
  page.value = 1
  total.value = 0
  goodsList.value = []
  fetchList()
}

onMounted(() => fetchList())
</script>

<template>
  <div class="page-content">
    <div class="page-header">
      <h1 class="page-title">商品管理</h1>
      <p class="page-subtitle">管理商品库存与上架状态</p>
    </div>

    <div class="toolbar">
      <div class="toolbar-left">
        <div class="search-box">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
          <input v-model="keyword" placeholder="搜索商品名称..." @keyup.enter="onSearch" />
        </div>
        <div class="filter-pills">
          <button
            v-for="p in statusPills"
            :key="String(p.value)"
            :class="['pill', { active: filterStatus === p.value }]"
            @click="onFilterChange(p.value)"
          >{{ p.label }}</button>
        </div>
      </div>
      <button class="admin-btn" @click="onAdd">+ 新增商品</button>
    </div>

    <div class="panel">
      <div class="panel-body" style="padding:0">
        <table class="data-table">
          <thead>
            <tr>
              <th>商品</th>
              <th>价格</th>
              <th>库存</th>
              <th>销量</th>
              <th>状态</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="loading">
              <td colspan="6" style="text-align:center;color:#999;padding:60px 0">加载中...</td>
            </tr>
            <tr v-else-if="goodsList.length === 0">
              <td colspan="6" style="text-align:center;color:#999;padding:60px 0">暂无商品</td>
            </tr>
            <tr v-for="g in goodsList" :key="g.id">
              <td>
                <div class="goods-cell">
                  <div class="goods-thumb">
                    <img v-if="g.cover" :src="imgUrl(g.cover)" />
                    <span v-else style="color:#ccc;font-size:11px">无图</span>
                  </div>
                  <div>
                    <div class="goods-name">{{ g.name }}</div>
                    <div v-if="g.brand" class="goods-brand">{{ g.brand }}</div>
                  </div>
                </div>
              </td>
              <td class="cell-mono">¥{{ Number(g.price).toFixed(2) }}</td>
              <td>{{ g.stock ?? '-' }}</td>
              <td>{{ g.sales ?? '-' }}</td>
              <td>
                <span :class="['tag', g.status === 1 ? 'tag-success' : 'tag-muted']">
                  {{ g.status === 1 ? '上架' : '下架' }}
                </span>
              </td>
              <td>
                <button class="action-btn" @click="onEdit(g.id)">编辑</button>
                <button
                  class="action-btn"
                  :class="g.status === 1 ? 'action-warn' : 'action-ok'"
                  @click="onToggleStatus(g.id, g.status)"
                >{{ g.status === 1 ? '下架' : '上架' }}</button>
                <button class="action-btn action-danger" @click="onDelete(g.id)">删除</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <div v-if="total > size" class="pagination-bar">
      <span class="pagination-info">共 {{ total }} 件商品，{{ totalPages }} 页</span>
      <div class="pagination-controls">
        <button class="page-btn" :disabled="page <= 1" @click="goPage(page - 1)">上一页</button>
        <template v-for="p in totalPages" :key="p">
          <button
            v-if="p === 1 || p === totalPages || Math.abs(p - page) <= 2"
            :class="['page-btn', { active: p === page }]"
            @click="goPage(p)"
          >{{ p }}</button>
          <span v-else-if="p === page - 3 || p === page + 3" class="page-dots">…</span>
        </template>
        <button class="page-btn" :disabled="page >= totalPages" @click="goPage(page + 1)">下一页</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.page-content { animation: fadeIn 0.4s ease; }
@keyframes fadeIn { from { opacity:0;transform:translateY(8px) } to { opacity:1;transform:translateY(0) } }

.page-header { margin-bottom: 28px; }
.page-title {
  font-family: 'Cormorant Garamond', 'Noto Serif SC', Georgia, serif;
  font-size: 38px; font-weight: 600; margin-bottom: 8px;
  letter-spacing: -0.5px; line-height: 1.1; color: #1a1a1a;
}
.page-subtitle { font-size: 14px; color: #666; font-weight: 300; }

.toolbar {
  display: flex; align-items: center; justify-content: space-between;
  margin-bottom: 24px; gap: 16px;
}
.toolbar-left { display: flex; align-items: center; gap: 16px; flex: 1; }

.search-box {
  display: flex; align-items: center; gap: 10px;
  padding: 0 16px; height: 42px;
  background: #fff; border: 1px solid #e6e1dc; border-radius: 100px;
  color: #999; flex: 1; max-width: 320px;
}
.search-box input {
  flex: 1; border: none; outline: none; font-size: 13px;
  font-family: inherit; color: #1a1a1a; background: transparent;
}
.search-box input::placeholder { color: #bbb; }
.search-box:focus-within { border-color: #b05c4f; }

.filter-pills { display: flex; gap: 8px; }
.pill {
  padding: 8px 18px; border-radius: 999px; border: 1px solid #e6e1dc;
  background: #fff; color: #706a64; font-size: 12px; font-weight: 500;
  cursor: pointer; transition: all 0.2s;
}
.pill:hover { border-color: #b05c4f; color: #b05c4f; }
.pill.active { background: #1a1a1a; color: #fff; border-color: #1a1a1a; }

.admin-btn {
  padding: 10px 24px; background: #1a1a1a; color: #f5f3f0;
  border: none; font-size: 12px; font-weight: 600; letter-spacing: 1px;
  cursor: pointer; transition: background 0.3s; border-radius: 8px; white-space: nowrap;
}
.admin-btn:hover { background: #b05c4f; }

.panel { background:#fff; border:1px solid #e6e1dc; border-radius:16px; box-shadow:0 4px 24px rgba(26,24,22,0.04); }
.panel-body { padding:0; }

.data-table { width:100%; border-collapse:collapse; font-size:13px; }
.data-table th {
  text-align:left; padding:16px 24px; font-size:11px;
  text-transform:uppercase; letter-spacing:1.5px; color:#706a64; font-weight:500;
  border-bottom:1px solid #e6e1dc; background:#faf8f6;
}
.data-table td { padding:16px 24px; border-bottom:1px solid #f0ede8; color:#1a1a1a; }
.data-table tr:last-child td { border-bottom:none; }
.data-table tr:hover td { background:#faf8f6; }

.goods-cell { display:flex; align-items:center; gap:14px; }
.goods-thumb {
  width: 44px; height: 44px; border-radius: 8px; overflow:hidden;
  background: #f5f3f0; display:flex; align-items:center; justify-content:center; flex-shrink:0;
}
.goods-thumb img { width:100%; height:100%; object-fit:cover; }
.goods-name { font-weight:500; margin-bottom:2px; }
.goods-brand { font-size:11px; color:#706a64; }

.cell-mono { font-family:'JetBrains Mono',monospace; color:#706a64; font-size:12px; }

.tag { display:inline-block; padding:4px 12px; font-size:11px; font-weight:500; letter-spacing:0.5px; border-radius:4px; }
.tag-success { background:rgba(74,124,89,0.1); color:#4a7c59; }
.tag-muted { background:#f0eeeb; color:#706a64; }

.action-btn {
  padding:6px 14px; background:transparent; border:1px solid #e6e1dc;
  font-size:12px; cursor:pointer; transition:all 0.2s; margin-right:6px;
  color:#706a64; border-radius:6px;
}
.action-btn:hover { border-color:#999; color:#1a1a1a; }
.action-danger:hover { border-color:#b05c4f; color:#b05c4f; }
.action-warn:hover { border-color:#c9a227; color:#c9a227; }
.action-ok:hover { border-color:#4a7c59; color:#4a7c59; }

.pagination-bar {
  display: flex; align-items: center; justify-content: space-between;
  padding: 20px 24px 8px; flex-wrap: wrap; gap: 12px;
}
.pagination-info { font-size: 13px; color: #706a64; }
.pagination-controls { display: flex; align-items: center; gap: 6px; }
.page-btn {
  padding: 6px 14px; border: 1px solid #e6e1dc; background: #fff;
  font-size: 12px; color: #1a1a1a; cursor: pointer; border-radius: 6px;
  transition: all 0.2s; font-family: inherit;
}
.page-btn:hover:not(:disabled) { border-color: #b05c4f; color: #b05c4f; }
.page-btn.active { background: #1a1a1a; color: #fff; border-color: #1a1a1a; }
.page-btn:disabled { opacity: 0.4; cursor: default; }
.page-dots { color: #999; font-size: 13px; letter-spacing: 2px; user-select: none; }
</style>
