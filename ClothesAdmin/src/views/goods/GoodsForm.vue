<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { showToast } from 'vant'

const router = useRouter()
const route = useRoute()
const isEdit = ref(false)
const form = ref({
  name: '',
  price: 0,
  stock: 0,
  categoryId: 0,
  description: '',
  details: ''
})

function onSave() {
  // TODO: 调用保存接口
  showToast('保存成功')
  router.push({ name: 'goods' })
}
</script>

<template>
  <div class="goods-form">
    <van-nav-bar :title="isEdit ? '编辑商品' : '新增商品'" left-arrow @click-left="router.back()">
      <template #right>
        <van-button size="small" type="primary" @click="onSave">保存</van-button>
      </template>
    </van-nav-bar>

    <van-form @submit="onSave">
      <van-field v-model="form.name" label="商品名称" placeholder="请输入名称" :rules="[{ required: true }]" />
      <van-field v-model="form.price" label="价格" type="number" placeholder="请输入价格" :rules="[{ required: true }]" />
      <van-field v-model="form.stock" label="库存" type="number" placeholder="请输入库存" />
      <van-field v-model="form.description" label="描述" type="textarea" rows="3" placeholder="请输入商品描述" />
    </van-form>
  </div>
</template>
