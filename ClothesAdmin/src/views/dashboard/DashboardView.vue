<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { getDashboardStats } from '@/api/dashboard'
import { getOrderList } from '@/api/order'

const stats = ref({
  orderCount: 0,
  goodsCount: 0,
  userCount: 0,
  revenue: 0
})

const orderList = ref<any[]>([])

onMounted(async () => {
  try {
    const s = await getDashboardStats()
    if (s) stats.value = s
  } catch { /* silent */ }
  try {
    const res = await getOrderList({ page: 1, size: 5 })
    orderList.value = res?.list || res || []
  } catch { /* silent */ }
})
</script>

<template>
  <div class="dashboard">
    <van-grid :column-num="4" :border="false">
      <van-grid-item>
        <div class="stat-card">
          <div class="stat-value">{{ stats.orderCount }}</div>
          <div class="stat-label">订单数</div>
        </div>
      </van-grid-item>
      <van-grid-item>
        <div class="stat-card">
          <div class="stat-value">{{ stats.goodsCount }}</div>
          <div class="stat-label">商品数</div>
        </div>
      </van-grid-item>
      <van-grid-item>
        <div class="stat-card">
          <div class="stat-value">{{ stats.userCount }}</div>
          <div class="stat-label">用户数</div>
        </div>
      </van-grid-item>
      <van-grid-item>
        <div class="stat-card">
          <div class="stat-value">¥{{ stats.revenue }}</div>
          <div class="stat-label">营收</div>
        </div>
      </van-grid-item>
    </van-grid>

    <van-cell-group title="最新订单" class="section">
      <van-cell v-for="order in orderList" :key="order.id" :title="order.orderNo" :label="order.createTime" />
      <van-empty v-if="orderList.length === 0" description="暂无订单数据" />
    </van-cell-group>
  </div>
</template>

<style scoped>
.stat-card {
  text-align: center;
  padding: 16px;
}
.stat-value {
  font-size: 28px;
  font-weight: bold;
  color: #323233;
}
.stat-label {
  font-size: 12px;
  color: #969799;
  margin-top: 4px;
}
.section {
  margin-top: 16px;
}
</style>
