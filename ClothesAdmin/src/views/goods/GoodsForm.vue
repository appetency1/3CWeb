<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { showToast, showFailToast } from 'vant'
import { saveGoods, getGoodsDetail } from '@/api/goods'
import { uploadFile, imgUrl } from '@/utils/request'

const router = useRouter()
const route = useRoute()
const isEdit = ref(false)
const saving = ref(false)
const coverUploading = ref(false)

const form = ref({
  id: 0,
  name: '',
  price: 0,
  originalPrice: 0,
  stock: 0,
  sales: 0,
  categoryId: 0,
  brand: '',
  cover: '',
  description: '',
  status: 1,
  isHot: false,
  isNew: false,
})

const dropActive = ref(false)

function onCoverDrop(e: DragEvent) {
  dropActive.value = false
  const file = e.dataTransfer?.files?.[0]
  if (file) doUploadCover(file)
}

function onCoverSelect(e: Event) {
  const input = e.target as HTMLInputElement
  const file = input.files?.[0]
  if (file) doUploadCover(file)
  input.value = ''
}

async function doUploadCover(file: File) {
  if (!file.type.startsWith('image/')) { showFailToast('请选择图片文件'); return }
  if (file.size > 5 * 1024 * 1024) { showFailToast('图片不能超过 5MB'); return }
  coverUploading.value = true
  try {
    const url = await uploadFile(file)
    form.value.cover = url
  } catch (e: any) {
    showFailToast(e?.message || '上传失败')
  } finally {
    coverUploading.value = false
  }
}

function removeCover() {
  form.value.cover = ''
}

async function onSave() {
  if (!form.value.name?.trim()) { showFailToast('请输入商品名称'); return }
  if (!form.value.price) { showFailToast('请输入价格'); return }
  saving.value = true
  try {
    await saveGoods(form.value)
    showToast(form.value.id ? '修改成功' : '新增成功')
    router.push({ name: 'goods' })
  } catch (e: any) {
    showFailToast(e?.message || '保存失败')
  } finally {
    saving.value = false
  }
}

onMounted(async () => {
  const id = route.params.id as string
  if (id) {
    isEdit.value = true
    try {
      const data = await getGoodsDetail(Number(id))
      if (data) {
        // getGoodsDetail 返回 { goods: {...}, skus: [...] }
        const g = data.goods || data
        form.value = { ...form.value, ...g }
      }
    } catch { /* silent */ }
  }
})
</script>

<template>
  <div class="page-content">
    <div class="page-header" style="display:flex;align-items:center;justify-content:space-between">
      <div>
        <h1 class="page-title">{{ isEdit ? '编辑商品' : '新增商品' }}</h1>
        <p class="page-subtitle">{{ isEdit ? '修改商品信息' : '添加新商品到商城' }}</p>
      </div>
      <div>
        <button class="admin-btn admin-btn-outline" style="margin-right:12px" @click="router.push({name:'goods'})">取消</button>
        <button class="admin-btn" :disabled="saving" @click="onSave">
          {{ saving ? '保存中...' : '保存' }}
        </button>
      </div>
    </div>

    <div class="form-panel">
      <div class="form-section">
        <h3 class="form-section-title">基本信息</h3>
        <div class="form-grid">
          <div class="form-field">
            <label>商品名称 <span style="color:#c45c4a">*</span></label>
            <input v-model="form.name" class="form-input" placeholder="请输入商品名称" />
          </div>
          <div class="form-field">
            <label>品牌</label>
            <input v-model="form.brand" class="form-input" placeholder="如 Apple、HUAWEI" />
          </div>
          <div class="form-field">
            <label>价格 <span style="color:#c45c4a">*</span></label>
            <input v-model.number="form.price" class="form-input" type="number" step="0.01" placeholder="0.00" />
          </div>
          <div class="form-field">
            <label>原价</label>
            <input v-model.number="form.originalPrice" class="form-input" type="number" step="0.01" placeholder="划线价" />
          </div>
          <div class="form-field">
            <label>库存</label>
            <input v-model.number="form.stock" class="form-input" type="number" placeholder="0" />
          </div>
          <div class="form-field">
            <label>分类 ID</label>
            <input v-model.number="form.categoryId" class="form-input" type="number" placeholder="0" />
          </div>
        </div>
      </div>

      <div class="form-section">
        <h3 class="form-section-title">封面图片</h3>
        <!-- 有图时显示预览 -->
        <div v-if="form.cover" class="cover-preview-wrap">
          <div class="cover-preview">
            <img :src="imgUrl(form.cover)" alt="商品封面" class="cover-img" />
            <button class="cover-remove" @click="removeCover">✕</button>
          </div>
          <div class="cover-path">{{ form.cover }}</div>
        </div>
        <!-- 无图时显示上传区域 -->
        <div
          v-else
          class="upload-zone"
          :class="{ 'drop-active': dropActive }"
          @dragenter.prevent="dropActive = true"
          @dragover.prevent="dropActive = true"
          @dragleave.prevent="dropActive = false"
          @drop.prevent="onCoverDrop"
          @click="$refs.coverInput?.click()"
        >
          <input ref="coverInput" type="file" accept="image/*" style="display:none" @change="onCoverSelect" />
          <div class="upload-icon">
            <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
              <polyline points="17 8 12 3 7 8"/>
              <line x1="12" y1="3" x2="12" y2="15"/>
            </svg>
          </div>
          <div class="upload-text">
            <span v-if="coverUploading">上传中...</span>
            <span v-else>点击或拖拽上传封面图片</span>
          </div>
          <div class="upload-hint">支持 jpg/png/webp，最大 5MB</div>
        </div>
      </div>

      <div class="form-section">
        <h3 class="form-section-title">其他设置</h3>
        <div class="form-grid">
          <div class="form-field">
            <label>状态</label>
            <select v-model.number="form.status" class="form-input">
              <option :value="1">上架</option>
              <option :value="0">下架</option>
            </select>
          </div>
          <div class="form-field">
            <label class="checkbox-label">
              <input type="checkbox" v-model="form.isHot" />
              热门推荐
            </label>
          </div>
          <div class="form-field">
            <label class="checkbox-label">
              <input type="checkbox" v-model="form.isNew" />
              新品
            </label>
          </div>
        </div>
      </div>

      <div class="form-section">
        <h3 class="form-section-title">描述</h3>
        <textarea v-model="form.description" class="form-textarea" rows="4" placeholder="商品描述..."></textarea>
      </div>
    </div>
  </div>
</template>

<style scoped>
.page-content { animation: fadeIn 0.4s ease; }
@keyframes fadeIn { from { opacity:0;transform:translateY(8px) } to { opacity:1;transform:translateY(0) } }
.page-header { margin-bottom: 36px; }
.page-title {
  font-family: var(--font-display);
  font-size: 28px; font-weight: 700; margin-bottom: 8px;
  letter-spacing: 2px; line-height: 1.1; color: var(--text);
}
.page-subtitle { font-size: 14px; color: var(--text2); font-weight: 300; }
.form-actions { display: flex; gap: 12px; justify-content: flex-end; }
.admin-btn {
  padding: 10px 24px;
  background: linear-gradient(135deg, rgba(0,240,255,0.15), rgba(184,41,247,0.1));
  color: var(--neon-blue); border: 1px solid var(--border);
  font-family: var(--font-display);
  font-size: 12px; font-weight: 600; letter-spacing: 1px;
  cursor: pointer; transition: all 0.3s; border-radius: 8px;
}
.admin-btn:hover:not(:disabled) {
  border-color: var(--neon-blue);
  box-shadow: 0 0 16px rgba(0,240,255,0.1);
}
.admin-btn:disabled { opacity: 0.5; cursor: not-allowed; }
.admin-btn-outline { background: transparent; border: 1px solid var(--border); color: var(--text2); }
.admin-btn-outline:hover { border-color: var(--neon-blue); color: var(--neon-blue); box-shadow: none; }
.form-panel {
  background: var(--bg-surface);
  border: 1px solid var(--border);
  border-radius: 16px;
  padding: 40px;
}
.form-section { margin-bottom: 36px; }
.form-section:last-child { margin-bottom: 0; }
.form-section-title {
  font-family: var(--font-display);
  font-size: 14px; font-weight: 600; margin-bottom: 20px; padding-bottom: 12px;
  border-bottom: 1px solid var(--border); color: var(--text2);
  letter-spacing: 1px;
}
.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
.form-field label { display:block; font-size:12px; color:var(--text3); margin-bottom:6px; font-weight:500; }
.form-input {
  width:100%; padding:10px 12px; border:1px solid var(--border); font-size:14px;
  outline:none; transition:border-color 0.25s; box-sizing:border-box; font-family:inherit;
  background: var(--bg-surface); color: var(--text);
}
.form-input:focus { border-color: var(--neon-blue); box-shadow: 0 0 0 3px rgba(0,240,255,0.08); }
.form-textarea {
  width:100%; padding:12px; border:1px solid var(--border); font-size:14px;
  outline:none; transition:border-color 0.25s; box-sizing:border-box; font-family:inherit; resize:vertical;
  line-height:1.6; background: var(--bg-surface); color: var(--text);
}
.form-textarea:focus { border-color: var(--neon-blue); box-shadow: 0 0 0 3px rgba(0,240,255,0.08); }
.checkbox-label { display:flex; align-items:center; gap:8px; cursor:pointer; font-size:14px; color:var(--text); }
select.form-input { appearance: auto; }

/* ── 封面图片上传 ── */
.cover-preview-wrap { margin-bottom: 8px; }
.cover-preview {
  position: relative;
  display: inline-block;
  border: 1px solid var(--border);
  border-radius: 4px;
  overflow: hidden;
}
.cover-img {
  display: block;
  max-width: 280px;
  max-height: 200px;
  object-fit: contain;
  background: var(--bg-raised);
}
.cover-remove {
  position: absolute;
  top: 6px; right: 6px;
  width: 24px; height: 24px;
  border: none; border-radius: 50%;
  background: rgba(0,0,0,0.6); color: #fff;
  font-size: 12px; cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  transition: background 0.2s;
}
.cover-remove:hover { background: rgba(255,42,138,0.8); }
.cover-path {
  margin-top: 6px;
  font-size: 11px; color: var(--text3); font-family: var(--font-mono);
}
.upload-zone {
  border: 2px dashed var(--border);
  border-radius: 8px;
  padding: 40px 20px;
  text-align: center;
  cursor: pointer;
  transition: all 0.25s;
  background: var(--bg-surface);
}
.upload-zone:hover { border-color: var(--neon-blue); background: rgba(0,240,255,0.03); }
.upload-zone.drop-active { border-color: var(--neon-blue); background: rgba(0,240,255,0.03); }
.upload-icon { color: var(--text3); margin-bottom: 12px; }
.upload-text { font-size: 14px; color: var(--text2); margin-bottom: 6px; }
.upload-hint { font-size: 12px; color: var(--text3); }
</style>
