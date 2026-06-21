<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { showConfirmDialog, showToast } from 'vant'
import { getUserList, updateUserStatus } from '@/api/user'

const users = ref<any[]>([])
const loading = ref(false)

async function toggleStatus(u: any) {
  const action = u.status === 1 ? '禁用' : '启用'
  try {
    await showConfirmDialog({ title: '确认' + action, message: `确定要${action}用户「${u.username}」吗？` })
  } catch { return }
  try {
    await updateUserStatus(u.id, u.status === 1 ? 0 : 1)
    u.status = u.status === 1 ? 0 : 1
    showToast(action + '成功')
  } catch (e: any) {
    showToast(e?.message || '操作失败')
  }
}

onMounted(async () => {
  loading.value = true
  try {
    const data: any = await getUserList({ page: 1, size: 100 })
    users.value = data?.list || []
  } catch { /* silent */ }
  loading.value = false
})
</script>

<template>
  <div class="page-content">
    <div class="page-header">
      <h1 class="page-title">用户管理</h1>
      <p class="page-subtitle">共 {{ users.length }} 个注册用户</p>
    </div>

    <div class="panel">
      <div class="panel-body" style="padding:0">
        <table class="data-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>用户名</th>
              <th>昵称</th>
              <th>手机号</th>
              <th>状态</th>
              <th>注册时间</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="loading">
              <td colspan="7" style="text-align:center;color:#999;padding:60px 0">加载中...</td>
            </tr>
            <tr v-else-if="users.length === 0">
              <td colspan="7" style="text-align:center;color:#999;padding:60px 0">暂无用户数据</td>
            </tr>
            <tr v-for="u in users" :key="u.id">
              <td><span style="font-family:'JetBrains Mono',monospace;color:#666;font-size:12px">{{ u.id }}</span></td>
              <td>{{ u.username }}</td>
              <td>{{ u.nickname || '-' }}</td>
              <td>{{ u.phone || '-' }}</td>
              <td>
                <span :class="['tag', u.status === 1 ? 'tag-success' : 'tag-muted']">
                  {{ u.status === 1 ? '正常' : '禁用' }}
                </span>
              </td>
              <td style="color:#666;font-size:12px">{{ u.createTime || '-' }}</td>
              <td>
                <button :class="['btn', u.status === 1 ? 'btn-warning' : 'btn-success']"
                  @click="toggleStatus(u)">
                  {{ u.status === 1 ? '禁用' : '启用' }}
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<style scoped>
.page-content {
  animation: fadeIn 0.4s ease;
}
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(8px); }
  to { opacity: 1; transform: translateY(0); }
}
.page-header {
  margin-bottom: 40px;
}
.page-title {
  font-family: 'Cormorant Garamond', 'Noto Serif SC', Georgia, serif;
  font-size: 38px;
  font-weight: 600;
  margin-bottom: 8px;
  letter-spacing: -0.5px;
  line-height: 1.1;
  color: #1a1a1a;
}
.page-subtitle {
  font-size: 14px;
  color: #666;
  font-weight: 300;
}
.panel {
  background: #ffffff;
  border: 1px solid #e8e5e0;
  box-shadow: 0 1px 3px rgba(0,0,0,0.04);
}
.panel-body { padding: 28px; }

.data-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}
.data-table th {
  text-align: left;
  padding: 16px 24px;
  font-size: 10px;
  text-transform: uppercase;
  letter-spacing: 1.5px;
  color: #666;
  font-weight: 500;
  border-bottom: 1px solid #e8e5e0;
}
.data-table td {
  padding: 20px 24px;
  border-bottom: 1px solid #e8e5e0;
  color: #1a1a1a;
}
.data-table tr { transition: background 0.2s; }
.data-table tr:hover td { background: #faf9f7; }
.data-table tr:last-child td { border-bottom: none; }

.tag {
  display: inline-block;
  padding: 4px 12px;
  font-size: 11px;
  font-weight: 500;
  letter-spacing: 0.5px;
}
.tag-success { background: rgba(90,143,123,0.1); color: #2d8a5e; }
.tag-muted { background: #f0eeeb; color: #666; }
</style>
