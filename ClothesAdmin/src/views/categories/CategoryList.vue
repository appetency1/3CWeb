<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { showToast, showConfirmDialog, showFailToast } from 'vant'
import { getCategoryList, saveCategory, deleteCategory } from '@/api/category'

const categories = ref<any[]>([])
const loading = ref(false)
const showForm = ref(false)
const editing = ref<any>(null)

async function fetchList() {
  loading.value = true
  try {
    const data = await getCategoryList()
    categories.value = data || []
  } catch { /* silent */ }
  loading.value = false
}

function onAdd() {
  editing.value = { name: '', parentId: 0, sort: 0, status: 1 }
  showForm.value = true
}

function onEdit(cat: any) {
  editing.value = { ...cat }
  showForm.value = true
}

async function onDelete(id: number) {
  try {
    await showConfirmDialog({ title: '确认删除', message: '确定删除该分类？若有子分类或商品则会拒绝' })
    await deleteCategory(id)
    showToast('已删除')
    fetchList()
  } catch { /* 取消或失败 */ }
}

async function onSave() {
  if (!editing.value?.name?.trim()) {
    showFailToast('请输入分类名称')
    return
  }
  try {
    await saveCategory(editing.value)
    showToast(editing.value.id ? '修改成功' : '新增成功')
    showForm.value = false
    fetchList()
  } catch (e: any) {
    showFailToast(e?.message || '保存失败')
  }
}

onMounted(() => fetchList())
</script>

<template>
  <div class="page-content">
    <div class="page-header">
      <h1 class="page-title">分类管理</h1>
      <p class="page-subtitle">共 {{ categories.length }} 个分类</p>
    </div>

    <div style="margin-bottom: 20px">
      <button class="admin-btn" @click="onAdd">+ 新增分类</button>
    </div>

    <div class="panel">
      <div class="panel-body" style="padding:0">
        <table class="data-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>名称</th>
              <th>父分类</th>
              <th>排序</th>
              <th>状态</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="loading">
              <td colspan="6" style="text-align:center;color:#999;padding:60px 0">加载中...</td>
            </tr>
            <tr v-else-if="categories.length === 0">
              <td colspan="6" style="text-align:center;color:#999;padding:60px 0">暂无分类</td>
            </tr>
            <tr v-for="cat in categories" :key="cat.id">
              <td><span style="font-family:'JetBrains Mono',monospace;color:#666;font-size:12px">{{ cat.id }}</span></td>
              <td>{{ cat.name }}</td>
              <td style="color:#666">{{ cat.parentName || cat.parentId || '-' }}</td>
              <td>{{ cat.sort ?? '-' }}</td>
              <td>
                <span :class="['tag', cat.status === 1 ? 'tag-success' : 'tag-muted']">
                  {{ cat.status === 1 ? '显示' : '隐藏' }}
                </span>
              </td>
              <td>
                <button class="action-btn" @click="onEdit(cat)">编辑</button>
                <button class="action-btn action-danger" @click="onDelete(cat.id)">删除</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- 弹窗 -->
    <van-dialog
      v-model:show="showForm"
      :title="editing?.id ? '编辑分类' : '新增分类'"
      show-cancel-button
      @confirm="onSave"
      @closed="showForm = false"
    >
      <div style="padding: 20px 24px">
        <div class="dialog-field">
          <label>分类名称</label>
          <input v-model="editing.name" class="dialog-input" placeholder="请输入" />
        </div>
        <div class="dialog-field">
          <label>父分类 ID</label>
          <input v-model.number="editing.parentId" class="dialog-input" type="number" placeholder="0=顶级" />
        </div>
        <div class="dialog-field">
          <label>排序</label>
          <input v-model.number="editing.sort" class="dialog-input" type="number" placeholder="数字越小越靠前" />
        </div>
        <div class="dialog-field">
          <label>状态</label>
          <select v-model.number="editing.status" class="dialog-select">
            <option :value="1">显示</option>
            <option :value="0">隐藏</option>
          </select>
        </div>
      </div>
    </van-dialog>
  </div>
</template>

<style scoped>
.page-content { animation: fadeIn 0.4s ease; }
@keyframes fadeIn { from { opacity:0;transform:translateY(8px) } to { opacity:1;transform:translateY(0) } }
.page-header { margin-bottom: 32px; }
.page-title {
  font-family: var(--font-display);
  font-size: 28px; font-weight: 700; margin-bottom: 8px;
  letter-spacing: 2px; line-height: 1.1; color: var(--text);
}
.page-subtitle { font-size: 14px; color: var(--text2); font-weight: 300; }
.admin-btn {
  padding: 10px 24px;
  background: linear-gradient(135deg, rgba(0,240,255,0.15), rgba(184,41,247,0.1));
  color: var(--neon-blue); border: 1px solid var(--border);
  font-family: var(--font-display);
  font-size: 12px; font-weight: 600; letter-spacing: 1px;
  cursor: pointer; transition: all 0.3s; border-radius: 8px;
}
.admin-btn:hover {
  border-color: var(--neon-blue);
  box-shadow: 0 0 16px rgba(0,240,255,0.1);
}
.panel {
  background: var(--bg-surface);
  border: 1px solid var(--border);
  border-radius: 16px;
}
.panel-body { padding: 28px; }
.data-table { width: 100%; border-collapse: collapse; font-size: 13px; }
.data-table th {
  text-align: left; padding: 16px 24px;
  font-family: var(--font-display);
  font-size: 10px; text-transform: uppercase; letter-spacing: 1.5px;
  color: var(--text3); font-weight: 500;
  border-bottom: 1px solid var(--border);
}
.data-table td { padding: 20px 24px; border-bottom: 1px solid var(--border); color: var(--text); }
.data-table tr { transition: background 0.2s; }
.data-table tr:hover td { background: var(--bg-hover); }
.data-table tr:last-child td { border-bottom: none; }
.tag { display: inline-block; padding: 4px 12px; font-size: 11px; font-weight: 500; letter-spacing: 0.5px; border-radius:4px; }
.tag-success { background: rgba(0,255,163,0.1); color: var(--neon-green); }
.tag-muted { background: rgba(90,90,120,0.15); color: var(--text3); }
.action-btn {
  padding: 6px 14px; background: transparent; border: 1px solid var(--border);
  font-size: 12px; cursor: pointer; transition: all 0.2s; margin-right: 6px;
  color: var(--text2); border-radius: 6px; font-family: inherit;
}
.action-btn:hover { border-color: var(--neon-blue); color: var(--neon-blue); }
.action-danger:hover { border-color: var(--neon-pink); color: var(--neon-pink); }
.dialog-field { margin-bottom: 16px; }
.dialog-field label { display: block; font-size: 12px; color: var(--text3); margin-bottom: 6px; font-weight: 500; }
.dialog-input {
  width: 100%; padding: 10px 12px; border: 1px solid var(--border); font-size: 14px;
  outline: none; transition: border-color 0.25s; box-sizing: border-box; font-family: inherit;
  background: var(--bg-surface); color: var(--text);
}
.dialog-input:focus { border-color: var(--neon-blue); box-shadow: 0 0 0 3px rgba(0,240,255,0.08); }
.dialog-select {
  width: 100%; padding: 10px 12px; border: 1px solid var(--border); font-size: 14px;
  outline: none; box-sizing: border-box; font-family: inherit;
  background: var(--bg-surface); color: var(--text);
}
</style>
