<script setup lang="ts">
import { ref } from 'vue'

const orders = ref<any[]>([])
const active = ref(0)

const tabs = ['全部', '待付款', '待发货', '待收货', '已完成']
</script>

<template>
  <div class="order-list">
    <van-nav-bar title="订单管理" />

    <van-tabs v-model:active="active">
      <van-tab v-for="(tab, idx) in tabs" :key="idx" :title="tab">
        <van-cell
          v-for="order in orders"
          :key="order.id"
          :title="order.orderNo"
          :label="`¥${order.totalAmount} | ${order.createTime}`"
          :value="order.statusText"
        />
        <van-empty v-if="orders.length === 0" :description="`暂无${tab}订单`" />
      </van-tab>
    </van-tabs>
  </div>
</template>
