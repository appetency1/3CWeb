<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { showFailToast, showToast } from 'vant'
import { userApi } from '@/api/user'
import { publicApi } from '@/api/public'
import { useUserStore } from '@/stores/user'
import DesktopLayout from '@/components/desktop/DesktopLayout.vue'

const router = useRouter()
const userStore = useUserStore()

const form = ref({ nickname: '', phone: '', email: '', gender: 0 })
const loading = ref(true)
const saving = ref(false)
const avatarUploading = ref(false)
const showAvatarPicker = ref(false)

const defaultAvatars = [
  { id: 1, url: '/assets/avatars/avatar-1.svg', label: '陶土红' },
  { id: 2, url: '/assets/avatars/avatar-2.svg', label: '石板蓝' },
  { id: 3, url: '/assets/avatars/avatar-3.svg', label: '鼠尾草' },
  { id: 4, url: '/assets/avatars/avatar-4.svg', label: '暖金色' },
  { id: 5, url: '/assets/avatars/avatar-5.svg', label: '深紫色' },
  { id: 6, url: '/assets/avatars/avatar-6.svg', label: '珊瑚红' },
  { id: 7, url: '/assets/avatars/avatar-7.svg', label: '海洋蓝' },
  { id: 8, url: '/assets/avatars/avatar-8.svg', label: '炭黑色' },
]

const userAvatar = computed(() => {
  const str = userStore.userInfo?.nickname || userStore.userInfo?.username || '?'
  return str[0].toUpperCase()
})

const avatarUrl = computed(() => {
  const a = userStore.userInfo?.avatar
  if (!a) return ''
  if (a.startsWith('http')) return a
  // 默认头像从前端 public 提供
  if (a.startsWith('/assets/avatars/')) return a
  const base = 'http://localhost:8080/ClothesBack_war'
  return base + a
})

async function loadInfo() {
  loading.value = true
  try {
    if (userStore.userInfo) {
      Object.assign(form.value, {
        nickname: userStore.userInfo.nickname || '',
        phone: userStore.userInfo.phone || '',
        email: userStore.userInfo.email || '',
        gender: userStore.userInfo.gender ?? 0,
      })
    } else {
      const info: any = await userApi.info()
      userStore.setUserInfo(info)
      Object.assign(form.value, {
        nickname: info.nickname || '', phone: info.phone || '',
        email: info.email || '', gender: info.gender ?? 0,
      })
    }
  } catch { /* silent */ }
  finally { loading.value = false }
}

function openAvatarPicker() {
  showAvatarPicker.value = true
}

async function selectDefaultAvatar(url: string) {
  try {
    await userApi.updateInfo({ avatar: url } as any)
    userStore.setUserInfo({ ...userStore.userInfo, avatar: url })
    showToast('头像已更新')
    showAvatarPicker.value = false
  } catch (e: any) {
    showFailToast(e?.message || '设置失败')
  }
}

async function onAvatarUpload(e: Event) {
  const input = e.target as HTMLInputElement
  const file = input.files?.[0]
  if (!file) return
  if (!file.type.startsWith('image/')) { showFailToast('请选择图片文件'); return }
  if (file.size > 5 * 1024 * 1024) { showFailToast('图片不能超过 5MB'); return }
  avatarUploading.value = true
  try {
    const formData = new FormData()
    formData.append('file', file)
    const data = await publicApi.upload(formData)
    const url = data.url
    // 更新头像
    await userApi.updateInfo({ avatar: url } as any)
    userStore.setUserInfo({ ...userStore.userInfo, avatar: url })
    showToast('头像已更新')
  } catch (e: any) {
    showFailToast(e?.message || '上传失败')
  } finally {
    avatarUploading.value = false
    input.value = ''
  }
}

async function save() {
  if (!form.value.nickname.trim()) { showToast('请输入昵称'); return }
  if (form.value.phone && !/^1[3-9]\d{9}$/.test(form.value.phone)) { showToast('手机号格式不正确'); return }
  saving.value = true
  try {
    await userApi.updateInfo(form.value as any)
    userStore.setUserInfo({ ...userStore.userInfo, ...form.value } as any)
    showToast('资料已保存')
  } catch (e: any) { showFailToast(e?.message || '保存失败') }
  finally { saving.value = false }
}

function goOrders() { router.push('/order') }
function goFavorites() { router.push('/favorites') }
function goProfile() { router.push('/profile') }

onMounted(loadInfo)
</script>

<template>
  <DesktopLayout>
    <div class="profile-page">
      <!-- Breadcrumbs -->
      <div class="breadcrumbs">
        <a href="/">首页</a>
        <span>/</span>
        <a href="/user">我的账户</a>
        <span>/</span>
        <span>个人资料</span>
      </div>

      <h1 class="page-title">个人资料</h1>
      <p class="page-subtitle">管理你的账户信息，让购物体验更个性化。</p>

      <div class="main-layout">
        <!-- Left Sidebar -->
        <aside class="profile-sidebar">
          <div class="avatar-upload-wrap" @click="openAvatarPicker">
            <div class="avatar-preview" style="cursor:pointer">
              <img v-if="avatarUrl" :src="avatarUrl" class="avatar-img" alt="用户头像" />
              <div v-else class="avatar-placeholder">{{ userAvatar }}</div>
              <div class="avatar-overlay">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
                  <polyline points="17 8 12 3 7 8"/>
                  <line x1="12" y1="3" x2="12" y2="15"/>
                </svg>
                <span>{{ avatarUploading ? '上传中...' : '更换头像' }}</span>
              </div>
            </div>
          </div>

          <div class="profile-name">{{ userStore.userInfo?.nickname || userStore.userInfo?.username }}</div>
          <div v-if="userStore.userInfo?.id" class="profile-id">会员 ID: {{ userStore.userInfo.id }}</div>

          <div class="profile-stats">
            <div class="profile-stat" @click="goOrders">
              <strong>{{ userStore.userInfo?.orderCount ?? '0' }}</strong>
              <span>订单</span>
            </div>
            <div class="profile-stat" @click="goFavorites">
              <strong>{{ userStore.userInfo?.favCount ?? '0' }}</strong>
              <span>收藏</span>
            </div>
            <div class="profile-stat">
              <strong>{{ userStore.userInfo?.couponCount ?? '0' }}</strong>
              <span>优惠券</span>
            </div>
          </div>

          <div class="sidebar-menu">
            <div class="menu-item active" @click="goProfile">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                <circle cx="12" cy="7" r="4"/>
              </svg>
              个人资料
            </div>
            <div class="menu-item" @click="goOrders">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4Z"/><path d="M3 6h18"/><path d="M16 10a4 4 0 0 1-8 0"/>
              </svg>
              我的订单
            </div>
            <div class="menu-item" @click="goFavorites">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z"/>
              </svg>
              收藏夹
            </div>
            <div class="menu-item">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="3"/>
                <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1Z"/>
              </svg>
              账户设置
            </div>
          </div>
        </aside>

        <!-- Right Form -->
        <section class="form-card">
          <div class="form-section">
            <div class="section-label">基本信息</div>
            <div class="form-grid">
              <div class="form-group">
                <label class="form-label">昵称</label>
                <input v-model="form.nickname" class="form-input" placeholder="请输入昵称" />
              </div>
              <div class="form-group">
                <label class="form-label">性别</label>
                <div class="gender-group">
                  <label :class="['gender-option', { active: form.gender === 0 }]">
                    <input type="radio" name="gender" :value="0" v-model="form.gender" class="gender-radio" />
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="12" cy="12" r="10"/><path d="M12 8v8"/><path d="M8 12h8"/></svg>
                    保密
                  </label>
                  <label :class="['gender-option', { active: form.gender === 1 }]">
                    <input type="radio" name="gender" :value="1" v-model="form.gender" class="gender-radio" />
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="10" cy="14" r="6"/><path d="M19 5l-3.5 3.5"/><path d="M19 5h-4"/><path d="M19 5v4"/></svg>
                    男
                  </label>
                  <label :class="['gender-option', { active: form.gender === 2 }]">
                    <input type="radio" name="gender" :value="2" v-model="form.gender" class="gender-radio" />
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="12" cy="9" r="6"/><path d="M12 15v7"/><path d="M9 20h6"/></svg>
                    女
                  </label>
                </div>
              </div>
              <div class="form-group">
                <label class="form-label">手机号</label>
                <input v-model="form.phone" class="form-input" placeholder="选填" type="tel" />
              </div>
              <div class="form-group">
                <label class="form-label">邮箱</label>
                <input v-model="form.email" class="form-input" placeholder="选填" />
              </div>
            </div>
          </div>

          <div class="form-actions">
            <button class="btn btn-secondary" type="button" @click="router.push('/user')">取消</button>
            <button class="btn btn-primary" :disabled="saving" @click="save">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" style="width:18px;height:18px;stroke-width:2">
                <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2Z"/>
                <polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/>
              </svg>
              {{ saving ? '保存中...' : '保存修改' }}
            </button>
          </div>
        </section>
      </div>
    </div>

    <!-- Avatar Picker Modal -->
    <teleport to="body">
      <div v-if="showAvatarPicker" class="picker-overlay" @click.self="showAvatarPicker = false">
        <div class="picker-modal">
          <div class="picker-header">
            <h3>更换头像</h3>
            <button class="picker-close" @click="showAvatarPicker = false">✕</button>
          </div>
          <div class="picker-body">
            <div class="picker-section">
              <div class="picker-section-title">默认头像</div>
              <div class="avatar-grid">
                <div
                  v-for="av in defaultAvatars"
                  :key="av.id"
                  class="avatar-option"
                  :class="{ selected: userStore.userInfo?.avatar === av.url }"
                  @click="selectDefaultAvatar(av.url)"
                >
                  <img :src="av.url" :alt="av.label" class="avatar-option-img" />
                  <span class="avatar-option-label">{{ av.label }}</span>
                </div>
              </div>
            </div>
            <div class="picker-divider">
              <span>或</span>
            </div>
            <div class="picker-section">
              <div class="picker-section-title">自定义上传</div>
              <label class="upload-btn-label">
                <input type="file" accept="image/*" style="display:none" @change="onAvatarUpload" />
                <div class="upload-btn-content">
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
                    <polyline points="17 8 12 3 7 8"/>
                    <line x1="12" y1="3" x2="12" y2="15"/>
                  </svg>
                  <span>{{ avatarUploading ? '上传中...' : '从本地上传图片' }}</span>
                </div>
              </label>
              <p class="upload-hint">支持 jpg/png/webp，最大 5MB</p>
            </div>
          </div>
        </div>
      </div>
    </teleport>
  </DesktopLayout>
</template>

<style scoped>
.profile-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 32px 40px 80px;
}

/* ── Breadcrumbs ── */
.breadcrumbs {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 13px;
  color: var(--text-muted);
  margin-bottom: 16px;
}
.breadcrumbs a {
  color: var(--text-secondary);
  text-decoration: none;
  transition: color 0.2s;
  cursor: pointer;
}
.breadcrumbs a:hover { color: #00f0ff; }

/* ── Page Title ── */
.page-title {
  font-family: 'Cormorant Garamond', 'Noto Serif SC', Georgia, serif;
  font-size: 38px;
  font-weight: 700;
  letter-spacing: -0.5px;
  margin-bottom: 8px;
  color: var(--text-primary);
}
.page-subtitle {
  font-size: 15px;
  color: var(--text-secondary);
  margin-bottom: 36px;
}

/* ── Main Layout ── */
.main-layout {
  display: grid;
  grid-template-columns: 300px 1fr;
  gap: 32px;
  align-items: start;
}

/* ── Sidebar ── */
.profile-sidebar {
  background: var(--bg-card);
  border: 1px solid var(--border);
  border-radius: 16px;
  padding: 32px 24px;
  text-align: center;
  box-shadow: 0 1px 3px rgba(0,0,0,0.04);
  position: sticky;
  top: 90px;
}

.avatar-upload-wrap {
  position: relative;
  width: 120px;
  height: 120px;
  margin: 0 auto 20px;
}

.avatar-preview {
  display: block;
  width: 120px;
  height: 120px;
  border-radius: 50%;
  overflow: hidden;
  cursor: pointer;
  border: 4px solid var(--bg-primary, #0a0a0f);
  box-shadow: 0 4px 16px rgba(0,0,0,0.1);
  position: relative;
  transition: transform 0.3s ease;
}

.avatar-preview:hover { transform: scale(1.03); }

.avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-placeholder {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #f8e8e4, #f5d6ce);
  display: grid;
  place-items: center;
  font-family: 'Cormorant Garamond', serif;
  font-size: 42px;
  font-weight: 600;
  color: #00f0ff;
}

.avatar-overlay {
  position: absolute;
  inset: 0;
  border-radius: 50%;
  background: rgba(26,26,26,0.55);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
  color: var(--text-primary);
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.3s ease;
}
.avatar-preview:hover .avatar-overlay { opacity: 1; }
.avatar-overlay span { font-size: 11px; font-weight: 500; }

.profile-name {
  font-size: 20px;
  font-weight: 700;
  margin-bottom: 4px;
  color: var(--text-primary);
}

.profile-id {
  font-size: 13px;
  color: var(--text-muted);
  margin-bottom: 24px;
}

.profile-stats {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
  padding-top: 24px;
  border-top: 1px solid var(--border);
}

.profile-stat {
  cursor: pointer;
  transition: opacity 0.2s;
}
.profile-stat:hover { opacity: 0.7; }
.profile-stat strong {
  display: block;
  font-size: 20px;
  font-weight: 700;
  color: var(--text-primary);
}
.profile-stat span {
  font-size: 12px;
  color: var(--text-muted);
}

.sidebar-menu {
  margin-top: 24px;
  text-align: left;
}

.menu-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 14px;
  border-radius: 10px;
  font-size: 14px;
  font-weight: 500;
  color: var(--text-secondary);
  cursor: pointer;
  transition: all 0.2s ease;
  margin-bottom: 4px;
}

.menu-item:hover {
  background: var(--bg-secondary);
  color: var(--text-primary);
}

.menu-item.active {
  background: rgba(0,240,255,0.08);
  color: #00f0ff;
}

.menu-item svg {
  width: 18px;
  height: 18px;
  flex-shrink: 0;
}

/* ── Form Card ── */
.form-card {
  background: var(--bg-card);
  border: 1px solid var(--border);
  border-radius: 16px;
  padding: 40px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.04);
}

.form-section { margin-bottom: 32px; }
.form-section:last-of-type { margin-bottom: 0; }

.section-label {
  font-size: 14px;
  font-weight: 700;
  color: var(--text-primary);
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  gap: 10px;
}

.section-label::before {
  content: '';
  width: 4px;
  height: 18px;
  background: #00f0ff;
  border-radius: 2px;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 24px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-label {
  font-size: 13px;
  font-weight: 600;
  color: var(--text-primary);
}

.form-input {
  height: 48px;
  border: 1.5px solid var(--border);
  border-radius: 10px;
  padding: 0 16px;
  font-family: inherit;
  font-size: 14px;
  color: var(--text-primary);
  background: var(--bg-card);
  transition: all 0.25s ease;
  outline: none;
  box-sizing: border-box;
}

.form-input::placeholder { color: var(--text-muted); }
.form-input:hover { border-color: var(--accent, #00f0ff); }
.form-input:focus {
  border-color: #00f0ff;
  box-shadow: 0 0 0 4px #fdf5f3;
}

/* ── Gender ── */
.gender-group {
  display: flex;
  gap: 12px;
}

.gender-option {
  flex: 1;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  border: 1.5px solid var(--border);
  border-radius: 10px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  color: var(--text-secondary);
  transition: all 0.25s ease;
  user-select: none;
}

.gender-option svg { width: 18px; height: 18px; flex-shrink: 0; }
.gender-option:hover { border-color: #d0cbc4; }
.gender-option.active {
  border-color: #00f0ff;
  background: rgba(0,240,255,0.08);
  color: #00f0ff;
  font-weight: 600;
}

.gender-radio { display: none; }

/* ── Buttons ── */
.form-actions {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 16px;
  padding-top: 32px;
  border-top: 1px solid var(--border);
  margin-top: 8px;
}

.btn {
  height: 48px;
  padding: 0 28px;
  border-radius: 10px;
  font-family: inherit;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.25s ease;
  border: none;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.btn-secondary {
  background: var(--bg-secondary, #0f0f18);
  color: var(--text-primary, #e8e8f0);
  border: 1.5px solid var(--border, rgba(255,255,255,0.1));
}

.btn-secondary:hover {
  background: var(--bg-card);
  border-color: var(--accent, #00f0ff);
}

.btn-primary {
  background: var(--bg-dark, #06060a);
  color: var(--text-primary, #e8e8f0);
  box-shadow: 0 8px 20px rgba(26,26,26,0.15);
}

.btn-primary:hover:not(:disabled) {
  background: #000;
  transform: translateY(-2px);
  box-shadow: 0 12px 28px rgba(26,26,26,0.2);
}

.btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* ── Animations ── */
.profile-sidebar, .form-card {
  opacity: 0;
  transform: translateY(20px);
  animation: slideUp 0.6s cubic-bezier(0.22, 1, 0.36, 1) forwards;
}

.form-card { animation-delay: 0.1s; }

@keyframes slideUp {
  to { opacity: 1; transform: translateY(0); }
}

/* ── Avatar Picker Modal ── */
.picker-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.45);
  backdrop-filter: blur(6px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10000;
  animation: fadeIn 0.2s ease;
}
@keyframes fadeIn { from { opacity:0 } to { opacity:1 } }

.picker-modal {
  background: var(--bg-card);
  border-radius: 20px;
  width: 520px;
  max-width: 90vw;
  max-height: 85vh;
  overflow-y: auto;
  box-shadow: 0 32px 80px rgba(0,0,0,0.25);
  animation: modalIn 0.35s cubic-bezier(0.22, 1, 0.36, 1);
}
@keyframes modalIn {
  from { opacity:0; transform:translateY(30px) scale(0.96) }
  to { opacity:1; transform:translateY(0) scale(1) }
}

.picker-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 24px 28px 0;
}
.picker-header h3 { font-size: 18px; font-weight: 700; color: var(--text-primary); }

.picker-close {
  width: 32px; height: 32px;
  border: none; border-radius: 50%;
  background: var(--bg-secondary); color: var(--text-muted);
  cursor: pointer; font-size: 14px;
  display: flex; align-items: center; justify-content: center;
  transition: all 0.2s;
}
.picker-close:hover { background: var(--border); color: var(--text-primary); }

.picker-body { padding: 20px 28px 28px; }

.picker-section { margin-bottom: 20px; }
.picker-section-title {
  font-size: 13px;
  font-weight: 600;
  color: var(--text-secondary);
  margin-bottom: 14px;
  letter-spacing: 0.3px;
}

.avatar-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
}

.avatar-option {
  border-radius: 12px;
  padding: 10px;
  cursor: pointer;
  border: 2px solid transparent;
  text-align: center;
  transition: all 0.2s ease;
}
.avatar-option:hover { background: var(--bg-secondary); }
.avatar-option.selected {
  border-color: #00f0ff;
  background: rgba(0,240,255,0.08);
}

.avatar-option-img {
  width: 56px;
  height: 56px;
  border-radius: 50%;
  display: block;
  margin: 0 auto 6px;
}

.avatar-option-label {
  font-size: 11px;
  color: var(--text-muted);
  display: block;
}

.picker-divider {
  display: flex;
  align-items: center;
  gap: 16px;
  margin: 24px 0;
  color: var(--text-muted);
  font-size: 12px;
}
.picker-divider::before,
.picker-divider::after {
  content: '';
  flex: 1;
  height: 1px;
  background: var(--border);
}

.upload-btn-label { display: block; cursor: pointer; }

.upload-btn-content {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  padding: 18px;
  border: 2px dashed var(--border);
  border-radius: 12px;
  color: var(--text-secondary);
  transition: all 0.25s;
}
.upload-btn-content:hover {
  border-color: #00f0ff;
  color: #00f0ff;
  background: rgba(0,240,255,0.08);
}

.upload-hint {
  font-size: 12px;
  color: var(--text-muted);
  margin-top: 8px;
  text-align: center;
}

/* ── Responsive ── */
@media (max-width: 900px) {
  .main-layout { grid-template-columns: 1fr; }
  .profile-sidebar { position: static; }
  .form-grid { grid-template-columns: 1fr; }
}

@media (max-width: 640px) {
  .profile-page { padding: 24px 16px 60px; }
  .form-card { padding: 28px 20px; }
  .page-title { font-size: 30px; }
  .form-actions { flex-direction: column-reverse; align-items: stretch; }
  .btn { width: 100%; }
}
</style>
