<script setup lang="ts">
import { ref } from 'vue'
import { showToast } from 'vant'

const banners = ref<any[]>([])
const showForm = ref(false)
const editing = ref<any>(null)

function onAdd() {
  editing.value = { image: '', link: '' }
  showForm.value = true
}

function onEdit(banner: any) {
  editing.value = { ...banner }
  showForm.value = true
}

function onSave() {
  // TODO: 调用保存接口
  showToast('保存成功')
  showForm.value = false
}
</script>

<template>
  <div class="banner-list">
    <van-nav-bar title="轮播图管理">
      <template #right>
        <van-button size="small" type="primary" @click="onAdd">新增</van-button>
      </template>
    </van-nav-bar>

    <van-cell
      v-for="banner in banners"
      :key="banner.id"
      :title="banner.image"
      is-link
      @click="onEdit(banner)"
    />

    <van-empty v-if="banners.length === 0" description="暂无轮播图" />

    <van-dialog v-model:show="showForm" :title="editing?.id ? '编辑轮播图' : '新增轮播图'" show-cancel-button @confirm="onSave">
      <van-field v-model="editing.image" label="图片地址" placeholder="请输入" />
      <van-field v-model="editing.link" label="跳转链接" placeholder="请输入（可选）" />
    </van-dialog>
  </div>
</template>
