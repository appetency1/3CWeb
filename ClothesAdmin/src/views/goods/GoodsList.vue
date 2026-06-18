<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showFailToast, showConfirmDialog } from 'vant'
import { getGoodsList, deleteGoods, updateGoodsStatus } from '@/api/goods'

const router = useRouter()
const goodsList = ref<any[]>([])
const loading = ref(false)
const page = ref(1)
const size = 20
const finished = ref(false)
const keyword = ref('')

async function fetchList(append = false) {
  if (loading.value) return
  loading.value = true
  try {
    // unwrap 后直接是 { list, total, pageNum, pageSize } | { code, message, data }
    const res = await getGoodsList({ page: page.value, size, keyword: keyword.value || undefined })
    // res 可能是解包后的 data 或原始响应，兼容处理
    const list = res?.list || res?.data?.list || res || []
    if (Array.isArray(list)) {
      if (append) goodsList.value.push(...list)
      else goodsList.value = list
    }
    finished.value = (list?.length || 0) < size
    page.value++
  } catch (e: any) {
    showFailToast(e?.message || '加载失败')
  } finally {
    loading.value = false
  }
}

async function onDelete(id: number) {
  try {
    await showConfirmDialog({ message: '确定删除该商品？' })
    await deleteGoods(id)
    goodsList.value = goodsList.value.filter(g => g.id !== id)
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

function onAdd() {
  router.push({ name: 'goodsAdd' })
}

function onEdit(id: number) {
  router.push({ name: 'goodsEdit', params: { id } })
}

function onSearch() {
  page.value = 1
  goodsList.value = []
  finished.value = false
  fetchList()
}

onMounted(() => fetchList())
</script>

<template>
  <div class="goods-list">
    <van-nav-bar title="商品管理">
      <template #right>
        <van-button size="small" type="primary" @click="onAdd">新增</van-button>
      </template>
    </van-nav-bar>

    <van-search
      v-model="keyword"
      placeholder="搜索商品名称"
      @search="onSearch"
      @clear="onSearch"
    />

    <van-cell-group>
      <van-cell
        v-for="item in goodsList"
        :key="item.id"
      >
        <template #title>
          <span>{{ item.name }}</span>
          <van-tag
            :type="item.status === 1 ? 'success' : 'warning'"
            size="mini"
            style="margin-left: 8px"
          >{{ item.status === 1 ? '上架' : '下架' }}</van-tag>
        </template>
        <template #label>
          ¥{{ item.price }} | 库存:{{ item.stock }} | 销量:{{ item.sales }}
        </template>
        <template #extra>
          <van-button size="mini" plain type="primary" @click.stop="onEdit(item.id)">编辑</van-button>
          <van-button
            size="mini" plain
            :type="item.status === 1 ? 'warning' : 'success'"
            style="margin-left: 6px"
            @click.stop="onToggleStatus(item.id, item.status)"
          >{{ item.status === 1 ? '下架' : '上架' }}</van-button>
          <van-button size="mini" plain type="danger" style="margin-left: 6px" @click.stop="onDelete(item.id)">删除</van-button>
        </template>
      </van-cell>
    </van-cell-group>

    <van-empty v-if="!loading && goodsList.length === 0" description="暂无商品" />

    <van-loading v-if="loading" size="20" style="padding: 20px; text-align: center">加载中...</van-loading>
  </div>
</template>
