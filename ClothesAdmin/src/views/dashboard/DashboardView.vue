<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getDashboardStats } from '@/api/dashboard'
import { getOrderList } from '@/api/order'

const router = useRouter()

const stats = ref({ totalSales: 0, orderCount: 0, userCount: 0, goodsCount: 0 })
const orderList = ref<any[]>([])
const today = ref('')

// 动画数字
const animatedRevenue = ref(0)
const animatedOrders = ref(0)
const animatedUsers = ref(0)
const animatedGoods = ref(0)

// 销售数据（7天）
const salesData = ref<{ day: string; value: number; pct: number }[]>([])
const maxSale = ref(0)

function animateTo(target: number, setter: (v: number) => void) {
  let cur = 0
  const step = Math.max(1, Math.floor(target / 60))
  const timer = setInterval(() => {
    cur += step
    if (cur >= target) { cur = target; clearInterval(timer) }
    setter(cur)
  }, 16)
}

function goOrders() { router.push({ name: 'orders' }) }

onMounted(async () => {
  const d = new Date()
  today.value = `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`

  try {
    const s = await getDashboardStats()
    if (s) stats.value = s
  } catch { /* silent */ }

  animateTo(stats.value.totalSales || stats.value.revenue || 0, (v: number) => animatedRevenue.value = v)
  animateTo(stats.value.orderCount, (v: number) => animatedOrders.value = v)
  animateTo(stats.value.userCount, (v: number) => animatedUsers.value = v)
  animateTo(stats.value.goodsCount, (v: number) => animatedGoods.value = v)

  // 模拟7天销售数据
  const days = ['周一','周二','周三','周四','周五','周六','周日']
  const vals = [4200, 5800, 3900, 7200, 8800, 10500, 9300]
  maxSale.value = Math.max(...vals)
  salesData.value = days.map((day, i) => ({
    day,
    value: vals[i],
    pct: (vals[i] / maxSale.value) * 100
  }))

  try {
    const res = await getOrderList({ page: 1, size: 5 })
    orderList.value = res?.list || res || []
  } catch { /* silent */ }
})
</script>

<template>
  <div class="page-content">
    <div class="page-header">
      <h1 class="page-title">数据概览</h1>
      <p class="page-subtitle">{{ today }}，欢迎回来</p>
    </div>

    <div class="stats-row">
      <div class="stat-block">
        <div class="stat-label">今日营收</div>
        <div class="stat-value">¥{{ animatedRevenue.toLocaleString() }}</div>
        <div class="stat-change up">+12.5% 较昨日</div>
      </div>
      <div class="stat-block">
        <div class="stat-label">订单数量</div>
        <div class="stat-value">{{ animatedOrders.toLocaleString() }}</div>
        <div class="stat-change up">+8.2% 较昨日</div>
      </div>
      <div class="stat-block">
        <div class="stat-label">新增用户</div>
        <div class="stat-value">{{ animatedUsers.toLocaleString() }}</div>
        <div class="stat-change down">-2.1% 较昨日</div>
      </div>
      <div class="stat-block">
        <div class="stat-label">商品总数</div>
        <div class="stat-value">{{ animatedGoods.toLocaleString() }}</div>
        <div class="stat-change up">+3 件上新</div>
      </div>
    </div>

    <div class="dashboard-grid">
      <div class="panel">
        <div class="panel-header">
          <span class="panel-title">销售趋势</span>
          <span class="panel-meta">最近 7 天</span>
        </div>
        <div class="panel-body">
          <div class="chart-bars">
            <div
              v-for="(bar, i) in salesData"
              :key="i"
              class="chart-bar"
              :style="{ height: bar.pct + '%' }"
              :data-label="bar.day"
            >
              <div class="chart-tooltip">¥{{ bar.value.toLocaleString() }}</div>
            </div>
          </div>
        </div>
      </div>
      <div class="panel">
        <div class="panel-header">
          <span class="panel-title">分类占比</span>
        </div>
        <div class="panel-body">
          <div class="pie-chart"></div>
          <div class="pie-legend">
            <div class="pie-legend-item">
              <div class="pie-legend-left">
                <span class="pie-legend-dot" style="background: #c45c4a"></span>
                <span>上装</span>
              </div>
              <span class="pie-legend-pct">35%</span>
            </div>
            <div class="pie-legend-item">
              <div class="pie-legend-left">
                <span class="pie-legend-dot" style="background: #b8963f"></span>
                <span>裙装</span>
              </div>
              <span class="pie-legend-pct">25%</span>
            </div>
            <div class="pie-legend-item">
              <div class="pie-legend-left">
                <span class="pie-legend-dot" style="background: #2d8a5e"></span>
                <span>裤装</span>
              </div>
              <span class="pie-legend-pct">20%</span>
            </div>
            <div class="pie-legend-item">
              <div class="pie-legend-left">
                <span class="pie-legend-dot" style="background: #f0eeeb"></span>
                <span>其他</span>
              </div>
              <span class="pie-legend-pct">20%</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="panel">
      <div class="panel-header">
        <span class="panel-title">最近订单</span>
        <span class="panel-more" @click="goOrders">查看全部 &rarr;</span>
      </div>
      <div class="panel-body" style="padding:0">
        <table class="data-table">
          <thead>
            <tr>
              <th>订单号</th>
              <th>商品</th>
              <th>客户</th>
              <th>金额</th>
              <th>状态</th>
              <th>时间</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="o in orderList" :key="o.id">
              <td class="cell-mono">{{ o.orderNo || o.no }}</td>
              <td>{{ o.goods }}</td>
              <td>{{ o.customer }}</td>
              <td class="cell-mono">¥{{ o.amount }}</td>
              <td>
                <span :class="['tag', o.statusClass || 'tag-muted']">{{ o.statusText || o.status }}</span>
              </td>
              <td class="cell-subtle">{{ o.createTime || o.time }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<style scoped>
.page-content {
  animation: fadeIn 0.4s ease;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(8px); }
  to { opacity: 1; transform: translateY(0); }
}

.page-header {
  margin-bottom: 40px;
}

.page-title {
  font-family: 'Cormorant Garamond', 'Noto Serif SC', Georgia, serif;
  font-size: 38px;
  font-weight: 600;
  margin-bottom: 8px;
  letter-spacing: -0.5px;
  line-height: 1.1;
  color: #1a1a1a;
}

.page-subtitle {
  font-size: 14px;
  color: #666;
  font-weight: 300;
}

/* ── Stats ── */
.stats-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 36px;
}

.stat-block {
  background: #ffffff;
  border: 1px solid #e8e5e0;
  padding: 32px;
  transition: border-color 0.3s, box-shadow 0.3s;
  position: relative;
  overflow: hidden;
  box-shadow: 0 1px 3px rgba(0,0,0,0.04);
  cursor: default;
}

.stat-block:hover {
  box-shadow: 0 4px 12px rgba(0,0,0,0.06);
}

.stat-block::after {
  content: '';
  position: absolute;
  top: 0; left: 0; right: 0;
  height: 1px;
  background: linear-gradient(to right, transparent, #b8963f, transparent);
  opacity: 0;
  transition: opacity 0.3s;
}

.stat-block:hover { border-color: #999; }
.stat-block:hover::after { opacity: 0.3; }

.stat-label {
  font-size: 10px;
  text-transform: uppercase;
  letter-spacing: 2px;
  color: #666;
  margin-bottom: 18px;
  font-weight: 500;
}

.stat-value {
  font-family: 'JetBrains Mono', 'SF Mono', monospace;
  font-size: 34px;
  font-weight: 500;
  color: #1a1a1a;
  letter-spacing: -1.5px;
  margin-bottom: 14px;
}

.stat-change {
  font-size: 12px;
  font-weight: 500;
}

.stat-change.up { color: #2d8a5e; }
.stat-change.down { color: #c45c4a; }

/* ── Dashboard Grid ── */
.dashboard-grid {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 20px;
  margin-bottom: 36px;
}

.panel {
  background: #ffffff;
  border: 1px solid #e8e5e0;
  box-shadow: 0 1px 3px rgba(0,0,0,0.04);
}

.panel-header {
  padding: 22px 28px;
  border-bottom: 1px solid #e8e5e0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.panel-title {
  font-family: 'Cormorant Garamond', 'Noto Serif SC', Georgia, serif;
  font-size: 20px;
  font-weight: 600;
  color: #1a1a1a;
}

.panel-meta { font-size: 12px; color: #999; }

.panel-more {
  font-size:12px;
  color:#c45c4a;
  cursor:pointer;
  font-weight:500;
  letter-spacing:0.5px;
  transition: opacity 0.2s;
}

.panel-more:hover { opacity: 0.7; }

.panel-body { padding: 28px; }

/* ── Chart Bars ── */
.chart-bars {
  display: flex;
  align-items: flex-end;
  gap: 10px;
  height: 200px;
  padding-bottom: 36px;
  border-bottom: 1px solid #e8e5e0;
  position: relative;
}

.chart-bar {
  flex: 1;
  background: #f0eeeb;
  border-top: 2px solid #b8963f;
  transition: all 0.4s;
  position: relative;
  cursor: pointer;
}

.chart-bar:hover {
  background: rgba(184,150,63,0.15);
  border-top-color: #c45c4a;
}

.chart-bar::after {
  content: attr(data-label);
  position: absolute;
  bottom: -30px;
  left: 50%;
  transform: translateX(-50%);
  font-size: 11px;
  color: #999;
  white-space: nowrap;
}

.chart-tooltip {
  position: absolute;
  top: -40px;
  left: 50%;
  transform: translateX(-50%);
  background: #faf9f7;
  border: 1px solid #e8e5e0;
  padding: 6px 12px;
  font-size: 12px;
  font-family: 'JetBrains Mono', monospace;
  white-space: nowrap;
  opacity: 0;
  transition: opacity 0.2s;
  pointer-events: none;
}

.chart-bar:hover .chart-tooltip { opacity: 1; }

/* ── Pie Chart ── */
.pie-chart {
  width: 150px;
  height: 150px;
  border-radius: 50%;
  margin: 0 auto 28px;
  background: conic-gradient(
    #c45c4a 0% 35%,
    #b8963f 35% 60%,
    #2d8a5e 60% 80%,
    #f0eeeb 80% 100%
  );
  position: relative;
}

.pie-chart::after {
  content: '';
  position: absolute;
  inset: 38px;
  border-radius: 50%;
  background: #ffffff;
}

.pie-legend {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.pie-legend-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 13px;
  color: #1a1a1a;
}

.pie-legend-left {
  display: flex;
  align-items: center;
  gap: 10px;
}

.pie-legend-dot {
  width: 8px;
  height: 8px;
  display: inline-block;
  border-radius: 2px;
}

.pie-legend-pct {
  font-family: 'JetBrains Mono', monospace;
  color: #666;
}

/* ── Data Table ── */
.data-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}

.data-table th {
  text-align: left;
  padding: 16px 24px;
  font-size: 10px;
  text-transform: uppercase;
  letter-spacing: 1.5px;
  color: #666;
  font-weight: 500;
  border-bottom: 1px solid #e8e5e0;
}

.data-table td {
  padding: 20px 24px;
  border-bottom: 1px solid #e8e5e0;
  color: #1a1a1a;
}

.data-table tr { transition: background 0.2s; }
.data-table tr:hover td { background: #faf9f7; }
.data-table tr:last-child td { border-bottom: none; }

.cell-mono {
  font-family: 'JetBrains Mono', monospace;
  color: #666;
  font-size: 12px;
}

.cell-subtle {
  color: #666;
  font-size: 12px;
}

.tag {
  display: inline-block;
  padding: 4px 12px;
  font-size: 11px;
  font-weight: 500;
  letter-spacing: 0.5px;
}

.tag-primary { background: rgba(196,92,74,0.1); color: #d47a6a; }
.tag-success { background: rgba(90,143,123,0.1); color: #2d8a5e; }
.tag-warning { background: rgba(184,154,74,0.1); color: #b8963f; }
.tag-muted { background: #f0eeeb; color: #666; }

@media (max-width: 1100px) {
  .stats-row { grid-template-columns: repeat(2, 1fr); }
  .dashboard-grid { grid-template-columns: 1fr; }
}
</style>
