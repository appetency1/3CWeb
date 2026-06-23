<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { showToast, showConfirmDialog, showFailToast } from 'vant'
import { getBannerList, saveBanner, deleteBanner } from '@/api/banner'
import { uploadFile, imgUrl } from '@/utils/request'

const banners = ref<any[]>([])
const imageUploading = ref(false)
const loading = ref(false)
const showForm = ref(false)
const editing = ref<any>(null)

async function fetchList() {
  loading.value = true
  try {
    const data = await getBannerList()
    banners.value = data || []
  } catch { /* silent */ }
  loading.value = false
}

function onAdd() {
  editing.value = { title: '', image: '', link: '', sort: 0, status: 1 }
  showForm.value = true
}

function onBannerUpload(e: Event) {
  const input = e.target as HTMLInputElement
  const file = input.files?.[0]
  if (!file) return
  if (!file.type.startsWith('image/')) { showFailToast('请选择图片文件'); return }
  if (file.size > 5 * 1024 * 1024) { showFailToast('图片不能超过 5MB'); return }
  imageUploading.value = true
  uploadFile(file).then(url => {
    editing.value.image = url
    imageUploading.value = false
  }).catch(e => {
    showFailToast(e?.message || '上传失败')
    imageUploading.value = false
  })
  input.value = ''
}

function onEdit(b: any) {
  editing.value = { ...b }
  showForm.value = true
}

async function onDelete(id: number) {
  try {
    await showConfirmDialog({ title: '确认删除', message: '确定删除该轮播图？' })
    await deleteBanner(id)
    showToast('已删除')
    fetchList()
  } catch { /* 取消或失败 */ }
}

async function onSave() {
  if (!editing.value?.image?.trim()) {
    showFailToast('请填写图片地址')
    return
  }
  try {
    await saveBanner(editing.value)
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
      <h1 class="page-title">轮播图管理</h1>
      <p class="page-subtitle">共 {{ banners.length }} 个轮播图</p>
    </div>

    <div style="margin-bottom: 20px">
      <button class="admin-btn" @click="onAdd">+ 新增轮播图</button>
    </div>

    <div class="panel">
      <div class="panel-body" style="padding:0">
        <table class="data-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>标题</th>
              <th>图片</th>
              <th>链接</th>
              <th>排序</th>
              <th>状态</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="loading">
              <td colspan="7" style="text-align:center;color:#999;padding:60px 0">加载中...</td>
            </tr>
            <tr v-else-if="banners.length === 0">
              <td colspan="7" style="text-align:center;color:#999;padding:60px 0">暂无轮播图</td>
            </tr>
            <tr v-for="b in banners" :key="b.id">
              <td><span style="font-family:'JetBrains Mono',monospace;color:#666;font-size:12px">{{ b.id }}</span></td>
              <td>{{ b.title || '-' }}</td>
              <td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ b.image }}</td>
              <td style="max-width:150px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:#666">{{ b.link || '-' }}</td>
              <td>{{ b.sort ?? '-' }}</td>
              <td>
                <span :class="['tag', b.status === 1 ? 'tag-success' : 'tag-muted']">
                  {{ b.status === 1 ? '显示' : '隐藏' }}
                </span>
              </td>
              <td>
                <button class="action-btn" @click="onEdit(b)">编辑</button>
                <button class="action-btn action-danger" @click="onDelete(b.id)">删除</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- 弹窗 -->
    <van-dialog
      v-model:show="showForm"
      :title="editing?.id ? '编辑轮播图' : '新增轮播图'"
      show-cancel-button
      @confirm="onSave"
      @closed="showForm = false"
    >
      <div style="padding: 20px 24px">
        <div class="dialog-field">
          <label>标题</label>
          <input v-model="editing.title" class="dialog-input" placeholder="选填" />
        </div>
        <div class="dialog-field">
          <label>图片 <span style="color:#c45c4a">*</span></label>
          <div v-if="editing.image" class="banner-preview">
            <img :src="imgUrl(editing.image)" class="banner-preview-img" />
            <button class="banner-preview-del" @click="editing.image = ''">✕</button>
          </div>
          <div v-else class="upload-zone-sm" @click="$refs.bannerFileInput?.click()">
            <input ref="bannerFileInput" type="file" accept="image/*" style="display:none" @change="onBannerUpload" />
            <span v-if="imageUploading">上传中...</span>
            <span v-else>点击选择图片</span>
          </div>
        </div>
        <div class="dialog-field">
          <label>跳转链接</label>
          <input v-model="editing.link" class="dialog-input" placeholder="选填" />
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
.banner-preview {
  position: relative; display: inline-block;
  border: 1px solid var(--border); border-radius: 4px; overflow: hidden;
}
.banner-preview-img { display: block; max-width: 100%; max-height: 120px; object-fit: contain; background: var(--bg-raised); }
.banner-preview-del {
  position: absolute; top: 4px; right: 4px; width: 20px; height: 20px;
  border: none; border-radius: 50%;
  background: rgba(0,0,0,0.6); color: #fff; font-size: 11px;
  cursor: pointer; display: flex; align-items: center; justify-content: center;
}
.banner-preview-del:hover { background: rgba(255,42,138,0.8); }
.upload-zone-sm {
  border: 1.5px dashed var(--border); border-radius: 6px;
  padding: 16px; text-align: center;
  cursor: pointer; transition: all 0.2s;
  color: var(--text3); font-size: 13px;
  background: var(--bg-surface);
}
.upload-zone-sm:hover { border-color: var(--neon-blue); color: var(--neon-blue); background: rgba(0,240,255,0.03); }
</style>
