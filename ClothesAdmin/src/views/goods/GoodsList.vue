<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const goodsList = ref<any[]>([])
const loading = ref(false)
const finished = ref(false)

function onAdd() {
  router.push({ name: 'goodsAdd' })
}

function onEdit(id: number) {
  router.push({ name: 'goodsEdit', params: { id } })
}
</script>

<template>
  <div class="goods-list">
    <van-nav-bar title="商品管理">
      <template #right>
        <van-button size="small" type="primary" @click="onAdd">新增</van-button>
      </template>
    </van-nav-bar>

    <van-cell-group>
      <van-cell
        v-for="item in goodsList"
        :key="item.id"
        :title="item.name"
        :label="`¥${item.price} | 库存:${item.stock} | 销量:${item.sales}`"
        is-link
        @click="onEdit(item.id)"
      />
    </van-cell-group>

    <van-empty v-if="!loading && goodsList.length === 0" description="暂无商品" />
  </div>
</template>
