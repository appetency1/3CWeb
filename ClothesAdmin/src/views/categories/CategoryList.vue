<script setup lang="ts">
import { ref } from 'vue'
import { showDialog, showToast } from 'vant'

const categories = ref<any[]>([])
const showForm = ref(false)
const editing = ref<any>(null)

function onAdd() {
  editing.value = null
  showForm.value = true
}

function onEdit(cat: any) {
  editing.value = { ...cat }
  showForm.value = true
}

function onDelete(id: number) {
  showDialog({ title: '确认删除', message: '确定删除该分类？' }).then(() => {
    // TODO: 调用删除接口
    showToast('已删除')
  })
}

function onSave() {
  // TODO: 调用保存接口
  showToast('保存成功')
  showForm.value = false
}
</script>

<template>
  <div class="category-list">
    <van-nav-bar title="分类管理">
      <template #right>
        <van-button size="small" type="primary" @click="onAdd">新增</van-button>
      </template>
    </van-nav-bar>

    <van-cell-group>
      <van-cell v-for="cat in categories" :key="cat.id" :title="cat.name" @click="onEdit(cat)">
        <template #right-icon>
          <van-icon name="delete" @click.stop="onDelete(cat.id)" />
        </template>
      </van-cell>
    </van-cell-group>

    <van-empty v-if="categories.length === 0" description="暂无分类" />

    <!-- 新增/编辑弹窗 -->
    <van-dialog v-model:show="showForm" :title="editing?.id ? '编辑分类' : '新增分类'" show-cancel-button @confirm="onSave">
      <van-field v-model="editing.name" label="分类名称" placeholder="请输入" />
    </van-dialog>
  </div>
</template>
