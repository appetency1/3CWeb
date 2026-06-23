<script setup lang="ts">
import { ref, onMounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { getDashboardStats } from '@/api/dashboard'
import { getOrderList } from '@/api/order'

const router = useRouter()

const stats = ref({ totalSales: 0, orderCount: 0, userCount: 0, goodsCount: 0, todaySales: 0, todayOrders: 0, todayUsers: 0 })
const orderList = ref<any[]>([])
const today = ref('')

const barData = [
  { label: '周一', value: 0 },
  { label: '周二', value: 0 },
  { label: '周三', value: 0 },
  { label: '周四', value: 0 },
  { label: '周五', value: 0 },
  { label: '周六', value: 0 },
  { label: '周日', value: 0 },
]

const statusMap: Record<string, { text: string; cls: string }> = {
  '0': { text: '待付款', cls: 'tag-warning' },
  '1': { text: '待发货', cls: 'tag-primary' },
  '2': { text: '待收货', cls: 'tag-info' },
  '3': { text: '已完成', cls: 'tag-success' },
  '4': { text: '已取消', cls: 'tag-muted' },
  '5': { text: '已退款', cls: 'tag-muted' },
}

function statusTag(s: number | string) {
  return statusMap[String(s)] || { text: '未知', cls: 'tag-muted' }
}

function goOrders() { router.push({ name: 'orders' }) }

onMounted(async () => {
  const d = new Date()
  const days = ['周日','周一','周二','周三','周四','周五','周六']
  const todayIdx = d.getDay()
  // 生成最近7天标签
  for (let i = 6; i >= 0; i--) {
    const idx = (todayIdx - i + 7) % 7
    barData[6 - i].label = days[idx]
  }

  let maxSale = 0
  try {
    const s = await getDashboardStats()
    if (s) {
      stats.value = s
      // 用真实销售额生成模拟趋势
      const base = s.totalSales || s.todaySales || 5000
      const vals = barData.map((_, i) => Math.round(base * (0.6 + Math.random() * 0.8)))
      maxSale = Math.max(...vals)
      vals.forEach((v, i) => { barData[i].value = v })
    }
  } catch { /* silent */ }

  // 模拟数据兜底
  if (!maxSale) {
    const fallback = [4200, 5800, 3900, 7200, 8800, 10500, 9300]
    maxSale = Math.max(...fallback)
    fallback.forEach((v, i) => { barData[i].value = v })
  }

  try {
    const res = await getOrderList({ page: 1, size: 5 })
    orderList.value = res?.list || res || []
  } catch { /* silent */ }

  const fmt = `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`
  today.value = fmt

  // 等 DOM 挂载后再初始化动画
  await nextTick()
  initAnimations(barData, maxSale)
})

function initAnimations(data: typeof barData, maxVal: number) {
  // 柱状图
  const bars = document.querySelectorAll('.bar')
  bars.forEach((bar, i) => {
    const v = data[i]?.value || 0
    const pct = maxVal > 0 ? (v / maxVal) * 100 : 0
    setTimeout(() => {
      (bar as HTMLElement).style.height = pct + '%'
    }, 300 + i * 80)
  })

  // 环形图
  const donutSegments = document.querySelectorAll('.donut-segment') as NodeListOf<SVGCircleElement>
  const radius = 70
  const circumference = 2 * Math.PI * radius
  donutSegments.forEach((seg, i) => {
    const percent = parseFloat(seg.dataset.percent || '0')
    const startPercent = parseFloat(seg.dataset.start || '0')
    const length = (percent / 100) * circumference
    const rotation = (startPercent / 100) * 360
    seg.style.strokeDasharray = `${length} ${circumference - length}`
    seg.style.strokeDashoffset = String(length)
    seg.style.transform = `rotate(${rotation}deg)`
    if (typeof gsap !== 'undefined') {
      gsap.to(seg, {
        strokeDashoffset: 0,
        duration: 1.1,
        delay: 0.7 + i * 0.18,
        ease: 'power3.out'
      })
    }
  })

  // 中心文字
  if (typeof gsap !== 'undefined') {
    gsap.from('.donut-center', {
      scale: 0.8,
      opacity: 0,
      duration: 0.6,
      delay: 1.3,
      ease: 'back.out(1.7)'
    })
  }

  // Card 入场
  if (typeof gsap !== 'undefined') {
    gsap.from('[data-bento]', {
      y: 30,
      opacity: 0,
      duration: 0.7,
      stagger: 0.06,
      ease: 'power3.out',
      delay: 0.1
    })
  }

  // MagicBento 效果
  initCardEffects()
}

function initCardEffects() {
  const cards = document.querySelectorAll<HTMLElement>('[data-bento]')
  const grid = document.getElementById('bentoGrid')
  if (!grid) return

  cards.forEach(card => {
    let isHovered = false
    let particles: HTMLElement[] = []

    function clearParticles() {
      particles.forEach(p => {
        if (typeof gsap !== 'undefined') {
          gsap.to(p, {
            scale: 0, opacity: 0, duration: 0.3,
            ease: 'back.in(1.7)',
            onComplete: () => { p.remove(); particles = particles.filter(x => x !== p) }
          })
        } else p.remove()
      })
    }

    function spawnParticles() {
      clearParticles()
      const rect = card.getBoundingClientRect()
      for (let i = 0; i < 6; i++) {
        const x = Math.random() * rect.width
        const y = Math.random() * rect.height
        const p = document.createElement('div')
        p.className = 'particle'
        p.style.left = x + 'px'
        p.style.top = y + 'px'
        card.appendChild(p)
        particles.push(p)
        if (typeof gsap !== 'undefined') {
          gsap.fromTo(p, { scale: 0, opacity: 0 }, { scale: 1, opacity: 1, duration: 0.35, delay: i * 0.04, ease: 'back.out(1.7)' })
          gsap.to(p, {
            x: (Math.random() - 0.5) * 60, y: (Math.random() - 0.5) * 60,
            rotation: Math.random() * 360, duration: 2 + Math.random() * 2,
            ease: 'none', repeat: -1, yoyo: true
          })
          gsap.to(p, { opacity: 0.35, duration: 1.2, ease: 'power2.inOut', repeat: -1, yoyo: true })
        }
      }
    }

    function updateGlow(mouseX: number, mouseY: number, intensity: number) {
      const rect = card.getBoundingClientRect()
      const x = ((mouseX - rect.left) / rect.width) * 100
      const y = ((mouseY - rect.top) / rect.height) * 100
      card.style.setProperty('--glow-x', x + '%')
      card.style.setProperty('--glow-y', y + '%')
      card.style.setProperty('--glow-intensity', intensity.toString())
    }

    card.addEventListener('mouseenter', () => {
      isHovered = true
      spawnParticles()
      if (typeof gsap !== 'undefined') {
        gsap.to(card, { scale: 1.015, duration: 0.4, ease: 'power2.out' })
      }
    })

    card.addEventListener('mouseleave', () => {
      isHovered = false
      clearParticles()
      if (typeof gsap !== 'undefined') {
        gsap.to(card, { rotateX: 0, rotateY: 0, x: 0, y: 0, scale: 1, duration: 0.5, ease: 'power2.out' })
      }
      card.style.setProperty('--glow-intensity', '0')
    })

    card.addEventListener('mousemove', (e) => {
      if (!isHovered) return
      const rect = card.getBoundingClientRect()
      const x = e.clientX - rect.left
      const y = e.clientY - rect.top
      const cx = rect.width / 2
      const cy = rect.height / 2
      const rotateX = ((y - cy) / cy) * -8
      const rotateY = ((x - cx) / cx) * 8
      const magnetX = (x - cx) * 0.04
      const magnetY = (y - cy) * 0.04
      if (typeof gsap !== 'undefined') {
        gsap.to(card, { rotateX, rotateY, x: magnetX, y: magnetY, duration: 0.1, ease: 'power2.out', transformPerspective: 1200 })
      }
      updateGlow(e.clientX, e.clientY, 1)
    })

    card.addEventListener('click', (e) => {
      const rect = card.getBoundingClientRect()
      const x = e.clientX - rect.left
      const y = e.clientY - rect.top
      const maxDist = Math.max(Math.hypot(x, y), Math.hypot(x - rect.width, y), Math.hypot(x, y - rect.height), Math.hypot(x - rect.width, y - rect.height))
      const ripple = document.createElement('div')
      ripple.className = 'ripple'
      ripple.style.cssText = `width:${maxDist*2}px;height:${maxDist*2}px;left:${x - maxDist}px;top:${y - maxDist}px;`
      card.appendChild(ripple)
      if (typeof gsap !== 'undefined') {
        gsap.fromTo(ripple, { scale: 0, opacity: 1 }, { scale: 1, opacity: 0, duration: 0.8, ease: 'power2.out', onComplete: () => ripple.remove() })
      }
    })
  })

  // 全局聚光灯
  const spotlight = document.getElementById('spotlight')
  if (spotlight) {
    document.addEventListener('mousemove', (e) => {
      const gridRect = grid.getBoundingClientRect()
      const inside = e.clientX >= gridRect.left && e.clientX <= gridRect.right && e.clientY >= gridRect.top && e.clientY <= gridRect.bottom
      if (!inside) {
        if (typeof gsap !== 'undefined') gsap.to(spotlight, { opacity: 0, duration: 0.4 })
        cards.forEach(c => c.style.setProperty('--glow-intensity', '0'))
        return
      }
      if (typeof gsap !== 'undefined') gsap.to(spotlight, { left: e.clientX, top: e.clientY, opacity: 0.9, duration: 0.1 })
    })
    document.addEventListener('mouseleave', () => {
      if (typeof gsap !== 'undefined') gsap.to(spotlight, { opacity: 0, duration: 0.4 })
      cards.forEach(c => c.style.setProperty('--glow-intensity', '0'))
    })
  }
}
</script>

<template>
  <div class="dashboard">
    <div class="ambient"><div class="ambient__grain"></div></div>
    <div class="global-spotlight" id="spotlight"></div>

    <header class="header">
      <div>
        <h1 class="header__title">数据概览</h1>
        <div class="header__subtitle">{{ today }}，欢迎回来</div>
      </div>
      <div class="header__date">今日实时</div>
    </header>

    <main class="bento-grid" id="bentoGrid">
      <!-- 统计卡片 -->
      <div class="bento-card" data-bento>
        <div class="card__content">
          <div class="card__label">今日营收</div>
          <div class="card__value">¥{{ stats.todaySales?.toLocaleString() || '0' }}</div>
          <div class="card__trend up">+12.5% 较昨日</div>
        </div>
      </div>

      <div class="bento-card" data-bento>
        <div class="card__content">
          <div class="card__label">今日订单</div>
          <div class="card__value">{{ stats.todayOrders || 0 }}</div>
          <div class="card__trend up">+8.2% 较昨日</div>
        </div>
      </div>

      <div class="bento-card" data-bento>
        <div class="card__content">
          <div class="card__label">新增用户</div>
          <div class="card__value">{{ stats.todayUsers || 0 }}</div>
          <div class="card__trend down">-2.1% 较昨日</div>
        </div>
      </div>

      <div class="bento-card" data-bento>
        <div class="card__content">
          <div class="card__label">商品总数</div>
          <div class="card__value">{{ stats.goodsCount || 0 }}</div>
          <div class="card__trend neutral">+3 件上新</div>
        </div>
      </div>

      <!-- 销售趋势 -->
      <div class="bento-card bento-card--wide" data-bento>
        <div class="card__content">
          <div class="chart-header">
            <div class="chart-title">销售趋势</div>
            <div class="chart-period">最近 7 天</div>
          </div>
          <div class="bar-chart">
            <div v-for="(item, i) in barData" :key="i" class="bar-group">
              <div class="bar" :style="{ height: '0' }"></div>
              <div class="bar-label">{{ item.label }}</div>
            </div>
          </div>
        </div>
      </div>

      <!-- 分类占比 -->
      <div class="bento-card bento-card--wide" data-bento>
        <div class="card__content">
          <div class="chart-header">
            <div class="chart-title">分类占比</div>
            <div class="chart-period">本周</div>
          </div>
          <div class="donut-wrap">
            <div class="donut-chart">
              <svg viewBox="0 0 160 160">
                <circle class="donut-track" cx="80" cy="80" r="70"></circle>
                <circle class="donut-segment" cx="80" cy="80" r="70" stroke="var(--neon-blue)" data-start="0" data-percent="35"></circle>
                <circle class="donut-segment" cx="80" cy="80" r="70" stroke="var(--neon-violet)" data-start="35" data-percent="25"></circle>
                <circle class="donut-segment" cx="80" cy="80" r="70" stroke="var(--neon-pink)" data-start="60" data-percent="20"></circle>
                <circle class="donut-segment" cx="80" cy="80" r="70" stroke="var(--neon-green)" data-start="80" data-percent="20"></circle>
              </svg>
              <div class="donut-center">
                <div class="donut-center__label">Total</div>
                <div class="donut-center__value">100%</div>
              </div>
            </div>
            <div class="legend">
              <div class="legend-item"><span class="legend-dot" style="background:var(--neon-blue)"></span><span>手机</span><span class="legend-pct">35%</span></div>
              <div class="legend-item"><span class="legend-dot" style="background:var(--neon-violet)"></span><span>笔记本</span><span class="legend-pct">25%</span></div>
              <div class="legend-item"><span class="legend-dot" style="background:var(--neon-pink)"></span><span>平板</span><span class="legend-pct">20%</span></div>
              <div class="legend-item"><span class="legend-dot" style="background:var(--neon-green)"></span><span>配件</span><span class="legend-pct">20%</span></div>
            </div>
          </div>
        </div>
      </div>
    </main>

    <!-- 最近订单 -->
    <div class="orders-section">
      <div class="orders-header">
        <h3>最近订单</h3>
        <span class="orders-more" @click="goOrders">查看全部 &rarr;</span>
      </div>
      <table class="orders-table">
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
            <td class="cell-mono">¥{{ Number(o.payAmount || o.amount || 0).toFixed(2) }}</td>
            <td><span :class="['tag', statusTag(o.status).cls]">{{ statusTag(o.status).text }}</span></td>
            <td class="cell-subtle">{{ o.createTime || o.time }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<style scoped>
.dashboard {
  position: relative;
  z-index: 2;
  max-width: 1280px;
  margin: 0 auto;
  min-height: 200px;
}

/* ── Ambient ── */
.ambient {
  position: fixed;
  inset: 0;
  pointer-events: none;
  z-index: 0;
  overflow: hidden;
}
.ambient__grain {
  position: absolute;
  inset: 0;
  opacity: 0.02;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.85' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E");
  mix-blend-mode: screen;
}

.global-spotlight {
  position: fixed;
  width: 1000px; height: 1000px;
  border-radius: 50%;
  pointer-events: none;
  background: radial-gradient(circle, rgba(0,240,255,0.15) 0%, rgba(0,240,255,0.08) 14%, rgba(0,240,255,0.03) 26%, transparent 50%);
  z-index: 1;
  opacity: 0;
  transform: translate(-50%, -50%);
}

/* ── Header ── */
.header {
  margin-bottom: 36px;
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  position: relative;
  z-index: 2;
}
.header__title {
  font-family: var(--font-display);
  font-size: 28px;
  font-weight: 700;
  letter-spacing: 2px;
  margin-bottom: 6px;
  color: var(--text);
}
.header__subtitle {
  font-size: 14px;
  color: var(--text2);
}
.header__date {
  font-size: 12px;
  color: var(--neon-green);
  padding: 8px 14px;
  background: rgba(0,255,163,0.08);
  border: 1px solid rgba(0,255,163,0.2);
  border-radius: 100px;
  font-family: var(--font-display);
  letter-spacing: 1px;
  display: flex;
  align-items: center;
  gap: 6px;
}
.header__date::before {
  content: '';
  width: 6px; height: 6px;
  border-radius: 50%;
  background: var(--neon-green);
  box-shadow: 0 0 8px var(--neon-green-glow);
  animation: pulse-dot 2s infinite;
}
@keyframes pulse-dot {
  0%, 100% { opacity: 1; transform: scale(1); }
  50% { opacity: 0.5; transform: scale(0.8); }
}

/* ── Bento Grid ── */
.bento-grid {
  position: relative;
  z-index: 2;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  grid-auto-rows: minmax(160px, auto);
  gap: 20px;
}

.bento-card {
  position: relative;
  background: var(--bg-surface);
  border: 1px solid var(--border);
  border-radius: 20px;
  padding: 24px;
  overflow: hidden;
  transform-style: preserve-3d;
  transition: box-shadow 0.4s cubic-bezier(0.22,1,0.36,1), border-color 0.3s;
  --glow-x: 50%;
  --glow-y: 50%;
  --glow-intensity: 0;
  --glow-radius: 280px;
}

.bento-card::before {
  content: '';
  position: absolute;
  top: 0; left: 24px; right: 24px;
  height: 1px;
  background: linear-gradient(90deg, transparent, var(--neon-blue), transparent);
  opacity: 0.5;
}

.bento-card:hover {
  border-color: var(--border-hover);
  box-shadow: 0 12px 40px rgba(0,0,0,0.4), 0 0 30px rgba(0,240,255,0.05);
  transform: translateY(-2px);
}

.bento-card::after {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: 20px;
  background: radial-gradient(var(--glow-radius) circle at var(--glow-x) var(--glow-y),
    rgba(0,240,255, calc(0.1 * var(--glow-intensity))),
    rgba(0,240,255, calc(0.04 * var(--glow-intensity))) 45%,
    transparent 65%);
  pointer-events: none;
  z-index: 1;
  opacity: var(--glow-intensity);
  transition: opacity 0.2s;
}

.bento-card--wide { grid-column: span 2; }

.card__content {
  position: relative;
  z-index: 2;
  height: 100%;
  display: flex;
  flex-direction: column;
  transition: opacity 0.35s, transform 0.35s;
}
.bento-card:hover .card__content {
  opacity: 0.92;
  transform: translateY(-2px);
}

.card__label {
  font-family: var(--font-display);
  font-size: 11px;
  color: var(--text3);
  letter-spacing: 1px;
  text-transform: uppercase;
  margin-bottom: 12px;
}

.card__value {
  font-family: var(--font-mono);
  font-size: 32px;
  font-weight: 500;
  color: var(--text);
  margin-bottom: 14px;
  letter-spacing: 1px;
}

.card__trend {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  width: fit-content;
  padding: 6px 10px;
  border-radius: 8px;
  font-family: var(--font-display);
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 1px;
}
.card__trend.up { color: var(--neon-green); background: rgba(0,255,163,0.08); border: 1px solid rgba(0,255,163,0.15); }
.card__trend.down { color: var(--neon-pink); background: rgba(255,42,138,0.08); border: 1px solid rgba(255,42,138,0.15); }
.card__trend.neutral { color: var(--neon-blue); background: rgba(0,240,255,0.08); border: 1px solid rgba(0,240,255,0.15); }

/* ── Chart ── */
.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}
.chart-title {
  font-family: var(--font-display);
  font-size: 14px;
  font-weight: 600;
  letter-spacing: 1px;
  color: var(--text2);
}
.chart-period {
  font-family: var(--font-display);
  font-size: 11px;
  letter-spacing: 1px;
  color: var(--text3);
  padding: 4px 10px;
  border-radius: 6px;
  background: var(--bg-raised);
  border: 1px solid var(--border);
}

.bar-chart {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 16px;
  height: 160px;
  padding-top: 20px;
  position: relative;
}
.bar-chart::before {
  content: '';
  position: absolute;
  inset: 0;
  bottom: 24px;
  pointer-events: none;
  background-image:
    linear-gradient(0deg, transparent calc(100% - 1px), rgba(138,138,168,0.05) calc(100% - 1px)),
    linear-gradient(0deg, transparent calc(50% - 1px), rgba(138,138,168,0.05) calc(50% - 1px));
  background-size: 100% 100%;
}

.bar-group {
  flex: 1;
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-end;
  gap: 10px;
}

.bar {
  width: 100%;
  max-width: 36px;
  background: linear-gradient(180deg, rgba(0,240,255,0.5), rgba(0,240,255,0.08));
  border-radius: 6px 6px 0 0;
  transition: height 0.4s cubic-bezier(0.22,1,0.36,1);
  position: relative;
}
.bar::before {
  content: '';
  position: absolute;
  top: 0; left: 0; right: 0;
  height: 3px;
  background: var(--neon-blue);
  border-radius: 6px 6px 0 0;
}
.bar:hover {
  background: linear-gradient(180deg, rgba(0,240,255,0.7), rgba(0,240,255,0.15));
  box-shadow: 0 0 20px rgba(0,240,255,0.15);
}

.bar-label {
  font-family: var(--font-display);
  font-size: 10px;
  color: var(--text3);
  letter-spacing: 1px;
}

/* ── Donut ── */
.donut-wrap {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 40px;
  flex: 1;
}

.donut-chart {
  width: 180px;
  height: 180px;
  position: relative;
  transform: rotate(-90deg);
}
.donut-chart svg { width: 100%; height: 100%; overflow: visible; }

.donut-track { fill: none; stroke: rgba(255,255,255,0.04); stroke-width: 22; }

.donut-segment {
  fill: none;
  stroke-width: 22;
  stroke-linecap: round;
  cursor: pointer;
  transition: filter 0.3s, transform 0.3s;
  transform-origin: 80px 80px;
}
.donut-segment:hover { filter: brightness(1.1) drop-shadow(0 0 8px currentColor); transform: scale(1.04); }

.donut-center {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  transform: rotate(90deg);
  pointer-events: none;
}
.donut-center__label {
  font-family: var(--font-display);
  font-size: 10px;
  color: var(--text3);
  text-transform: uppercase;
  letter-spacing: 1px;
}
.donut-center__value {
  font-family: var(--font-mono);
  font-size: 28px;
  font-weight: 500;
  color: var(--text);
  margin-top: 2px;
}

.legend {
  display: flex;
  flex-direction: column;
  gap: 14px;
}
.legend-item {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 13px;
  color: var(--text2);
}
.legend-dot { width: 8px; height: 8px; border-radius: 50%; }
.legend-pct {
  margin-left: auto;
  font-family: var(--font-mono);
  color: var(--text);
}

/* ── Orders ── */
.orders-section {
  position: relative;
  z-index: 2;
  background: var(--bg-surface);
  border: 1px solid var(--border);
  border-radius: 20px;
  margin-top: 24px;
  overflow: hidden;
}

.orders-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 24px;
  border-bottom: 1px solid var(--border);
}
.orders-header h3 {
  font-family: var(--font-display);
  font-size: 14px;
  font-weight: 600;
  letter-spacing: 1px;
  color: var(--text2);
}
.orders-more {
  font-family: var(--font-display);
  font-size: 11px;
  color: var(--neon-blue);
  cursor: pointer;
  font-weight: 600;
  letter-spacing: 1px;
  transition: opacity 0.2s;
  padding: 4px 10px;
  border-radius: 6px;
  background: var(--bg-raised);
  border: 1px solid var(--border);
}
.orders-more:hover { opacity: 0.7; }

.orders-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}
.orders-table th {
  text-align: left;
  padding: 14px 24px;
  font-family: var(--font-display);
  font-size: 10px;
  text-transform: uppercase;
  letter-spacing: 1.5px;
  color: var(--text3);
  font-weight: 500;
  border-bottom: 1px solid var(--border);
}
.orders-table td {
  padding: 18px 24px;
  border-bottom: 1px solid var(--border);
  color: var(--text);
}
.orders-table tr { transition: background 0.2s; }
.orders-table tr:hover td { background: var(--bg-hover); }
.orders-table tr:last-child td { border-bottom: none; }

.cell-mono { font-family: var(--font-mono); color: var(--text2); font-size: 12px; }
.cell-subtle { color: var(--text3); font-size: 12px; }

.tag {
  display: inline-block;
  padding: 4px 12px;
  font-size: 11px;
  font-weight: 500;
  letter-spacing: 0.5px;
  border-radius: 4px;
}
.tag-primary { background: rgba(0,240,255,0.1); color: var(--neon-blue); }
.tag-success { background: rgba(0,255,163,0.1); color: var(--neon-green); }
.tag-warning { background: rgba(255,42,138,0.1); color: var(--neon-pink); }
.tag-info { background: rgba(184,41,247,0.1); color: var(--neon-violet); }
.tag-muted { background: rgba(90,90,120,0.15); color: var(--text3); }

/* ── Magic particles & ripple ── */
:deep(.particle) {
  position: absolute;
  width: 5px; height: 5px;
  border-radius: 50%;
  background: var(--neon-blue);
  box-shadow: 0 0 10px 2px var(--neon-blue-glow);
  pointer-events: none;
  z-index: 4;
}
:deep(.ripple) {
  position: absolute;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(0,240,255,0.35) 0%, rgba(0,240,255,0.15) 40%, transparent 70%);
  pointer-events: none;
  z-index: 5;
  transform: scale(0);
  opacity: 1;
}

@media (max-width: 1100px) {
  .bento-grid { grid-template-columns: repeat(2, 1fr); }
  .bento-card--wide { grid-column: span 2; }
}
@media (max-width: 680px) {
  .bento-grid { grid-template-columns: 1fr; }
  .bento-card--wide { grid-column: span 1; }
  .header { flex-direction: column; align-items: flex-start; gap: 16px; }
  .donut-wrap { flex-direction: column; }
}
</style>
