<script setup lang="ts">
import { ref } from 'vue'

const users = ref<any[]>([])
</script>

<template>
  <div class="user-list">
    <van-nav-bar title="用户管理" />

    <van-cell-group>
      <van-cell
        v-for="user in users"
        :key="user.id"
        :title="user.username"
        :label="`电话: ${user.phone || '未填'}`"
      />
    </van-cell-group>

    <van-empty v-if="users.length === 0" description="暂无用户" />
  </div>
</template>
