<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import { showFailToast, showConfirmDialog, showToast } from 'vant'
import { getOrderList, shipOrder, refundOrder } from '@/api/order'

const orders = ref<any[]>([])
const loading = ref(false)
const activePill = ref('all')
const page = ref(1)
const size = 20
const finished = ref(false)

const pills = [
  { key: 'all', label: '全部' },
  { key: '0', label: '待付款' },
  { key: '1', label: '待发货' },
  { key: '2', label: '待收货' },
  { key: '3', label: '已完成' },
]

const statusMap: Record<string, { text: string; cls: string }> = {
  '0': { text: '待付款', cls: 'tag-warning' },
  '1': { text: '待发货', cls: 'tag-primary' },
  '2': { text: '待收货', cls: 'tag-info' },
  '3': { text: '已完成', cls: 'tag-success' },
  '4': { text: '已取消', cls: 'tag-muted' },
  '5': { text: '已退款', cls: 'tag-muted' },
}

function getStatusTag(status: number | string) {
  return statusMap[String(status)] || { text: '未知', cls: 'tag-muted' }
}

async function fetchOrders() {
  if (loading.value) return
  loading.value = true
  try {
    const status = activePill.value === 'all' ? undefined : Number(activePill.value)
    const res = await getOrderList({ page: page.value, size, status })
    const list = res?.list || res || []
    if (Array.isArray(list)) orders.value = list
  } catch (e: any) {
    showFailToast(e?.message || '加载失败')
  } finally {
    loading.value = false
  }
}

async function onShip(id: number) {
  try {
    await showConfirmDialog({ message: '确定发货？' })
    await shipOrder(id)
    showToast('已发货')
    fetchOrders()
  } catch { /* */ }
}

async function onRefund(id: number) {
  try {
    await showConfirmDialog({ message: '确定退款？' })
    await refundOrder(id)
    showToast('已退款')
    fetchOrders()
  } catch { /* */ }
}

watch(activePill, () => {
  page.value = 1; orders.value = []; fetchOrders()
})

onMounted(() => fetchOrders())
</script>

<template>
  <div class="page-content">
    <div class="page-header">
      <h1 class="page-title">订单管理</h1>
      <p class="page-subtitle">查看和处理所有订单</p>
    </div>

    <div class="filter-pills" style="margin-bottom:24px">
      <button
        v-for="p in pills"
        :key="p.key"
        :class="['pill', { active: activePill === p.key }]"
        @click="activePill = p.key"
      >{{ p.label }}</button>
    </div>

    <div class="panel">
      <div class="panel-body" style="padding:0">
        <table class="data-table">
          <thead>
            <tr>
              <th>订单号</th>
              <th>商品</th>
              <th>金额</th>
              <th>状态</th>
              <th>时间</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="loading">
              <td colspan="6" style="text-align:center;color:#999;padding:60px 0">加载中...</td>
            </tr>
            <tr v-else-if="orders.length === 0">
              <td colspan="6" style="text-align:center;color:#999;padding:60px 0">暂无订单</td>
            </tr>
            <tr v-for="o in orders" :key="o.id">
              <td class="cell-mono">{{ o.orderNo }}</td>
              <td>{{ o.goods }}</td>
              <td class="cell-mono">¥{{ Number(o.totalAmount || o.payAmount || 0).toFixed(2) }}</td>
              <td>
                <span :class="['tag', getStatusTag(o.status).cls]">{{ getStatusTag(o.status).text }}</span>
              </td>
              <td style="color:#706a64;font-size:12px">{{ o.createTime }}</td>
              <td>
                <button
                  v-if="Number(o.status) === 1"
                  class="action-btn action-ok"
                  @click="onShip(o.id)"
                >发货</button>
                <button
                  v-if="Number(o.status) === 1 || Number(o.status) === 2"
                  class="action-btn action-danger"
                  @click="onRefund(o.id)"
                >退款</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<style scoped>
.page-content { animation: fadeIn 0.4s ease; }
@keyframes fadeIn { from { opacity:0;transform:translateY(8px) } to { opacity:1;transform:translateY(0) } }
.page-header { margin-bottom: 28px; }
.page-title {
  font-family: var(--font-display);
  font-size: 28px; font-weight: 700; margin-bottom: 8px;
  letter-spacing: 2px; line-height: 1.1; color: var(--text);
}
.page-subtitle { font-size: 14px; color: var(--text2); font-weight: 300; }
.filter-pills { display: flex; gap: 8px; flex-wrap:wrap; }
.pill {
  padding: 8px 20px; border-radius: 999px; border: 1px solid var(--border);
  background: transparent; color: var(--text2); font-size: 12px; font-weight: 500;
  cursor: pointer; transition: all 0.2s;
}
.pill:hover { border-color: var(--neon-blue); color: var(--neon-blue); }
.pill.active {
  background: var(--neon-blue); color: #000;
  border-color: var(--neon-blue); box-shadow: 0 0 12px var(--neon-blue-glow);
}
.panel {
  background: var(--bg-surface);
  border: 1px solid var(--border);
  border-radius: 16px;
}
.panel-body { padding: 0; }
.data-table { width: 100%; border-collapse: collapse; font-size: 13px; }
.data-table th {
  text-align: left; padding: 16px 24px;
  font-family: var(--font-display);
  font-size: 10px; text-transform: uppercase; letter-spacing: 1.5px;
  color: var(--text3); font-weight: 500;
  border-bottom: 1px solid var(--border);
  background: var(--bg-raised);
}
.data-table td { padding: 16px 24px; border-bottom: 1px solid var(--border); color: var(--text); }
.data-table tr:last-child td { border-bottom: none; }
.data-table tr:hover td { background: var(--bg-hover); }
.cell-mono { font-family: var(--font-mono); color: var(--text2); font-size: 12px; }
.tag { display: inline-block; padding: 4px 12px; font-size: 11px; font-weight: 500; letter-spacing: 0.5px; border-radius:4px; }
.tag-success { background: rgba(0,255,163,0.1); color: var(--neon-green); }
.tag-primary { background: rgba(0,240,255,0.1); color: var(--neon-blue); }
.tag-warning { background: rgba(255,42,138,0.1); color: var(--neon-pink); }
.tag-info { background: rgba(184,41,247,0.1); color: var(--neon-violet); }
.tag-muted { background: rgba(90,90,120,0.15); color: var(--text3); }
.action-btn {
  padding: 6px 14px; background: transparent; border: 1px solid var(--border);
  font-size: 12px; cursor: pointer; transition: all 0.2s; margin-right: 6px;
  color: var(--text2); border-radius: 6px; font-family: inherit;
}
.action-btn:hover { border-color: var(--neon-blue); color: var(--neon-blue); }
.action-danger:hover { border-color: var(--neon-pink); color: var(--neon-pink); }
.action-ok:hover { border-color: var(--neon-green); color: var(--neon-green); }
</style>
