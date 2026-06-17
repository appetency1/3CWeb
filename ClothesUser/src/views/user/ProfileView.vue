<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showFailToast, showToast } from 'vant'
import { userApi } from '@/api/user'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()

const form = ref({
  nickname: '',
  phone: '',
  email: '',
  gender: 0,
})
const loading = ref(false)
const saving = ref(false)

const genderOptions = [
  { label: '保密', value: 0 },
  { label: '男', value: 1 },
  { label: '女', value: 2 },
]

async function loadInfo() {
  loading.value = true
  try {
    if (userStore.userInfo) {
      form.value.nickname = userStore.userInfo.nickname || ''
      form.value.phone = userStore.userInfo.phone || ''
      form.value.email = userStore.userInfo.email || ''
      form.value.gender = userStore.userInfo.gender || 0
    } else {
      const info: any = await userApi.info()
      userStore.setUserInfo(info)
      form.value.nickname = info.nickname || ''
      form.value.phone = info.phone || ''
      form.value.email = info.email || ''
      form.value.gender = info.gender || 0
    }
  } catch (e: any) {
    showFailToast('加载失败')
  } finally {
    loading.value = false
  }
}

async function onSave() {
  if (!form.value.nickname.trim()) {
    showToast('请输入昵称')
    return
  }
  saving.value = true
  try {
    await userApi.updateInfo({
      nickname: form.value.nickname,
      phone: form.value.phone,
      email: form.value.email,
      gender: form.value.gender,
    } as any)
    userStore.setUserInfo({ ...userStore.userInfo, ...form.value } as any)
    showToast('保存成功')
    router.back()
  } catch (e: any) {
    showFailToast(e?.message || '保存失败')
  } finally {
    saving.value = false
  }
}

onMounted(loadInfo)
</script>

<template>
  <div class="profile-page">
    <van-nav-bar title="个人资料" left-arrow @click-left="router.back()" />

    <van-loading v-if="loading" class="loading-center" />

    <van-form v-else @submit="onSave" class="profile-form">
      <!-- Avatar -->
      <div class="avatar-section">
        <div class="avatar-ring">
          <div class="avatar-circle">
            {{ (form.nickname || userStore.userInfo?.username || 'U')[0].toUpperCase() }}
          </div>
        </div>
        <p class="avatar-tip">点击头像更换（开发中）</p>
      </div>

      <!-- Fields -->
      <div class="fields-card">
        <div class="field-row">
          <span class="field-label">昵称</span>
          <van-field
            v-model="form.nickname"
            placeholder="请输入昵称"
            :border="false"
            input-align="right"
            class="profile-field"
          />
        </div>
        <div class="field-divider" />
        <div class="field-row">
          <span class="field-label">手机号</span>
          <van-field
            v-model="form.phone"
            type="tel"
            placeholder="请输入手机号"
            :border="false"
            input-align="right"
            class="profile-field"
          />
        </div>
        <div class="field-divider" />
        <div class="field-row">
          <span class="field-label">邮箱</span>
          <van-field
            v-model="form.email"
            type="email"
            placeholder="选填"
            :border="false"
            input-align="right"
            class="profile-field"
          />
        </div>
        <div class="field-divider" />
        <div class="field-row">
          <span class="field-label">性别</span>
          <div class="gender-picker">
            <span
              v-for="opt in genderOptions"
              :key="opt.value"
              class="gender-option"
              :class="{ active: form.gender === opt.value }"
              @click="form.gender = opt.value"
            >
              {{ opt.label }}
            </span>
          </div>
        </div>
      </div>

      <!-- Info Note -->
      <div class="info-note">
        <van-icon name="info-o" size="14" />
        <span>个人信息仅用于为您提供更好的服务，我们严格保护您的隐私。</span>
      </div>

      <!-- Submit -->
      <div class="form-submit">
        <van-button
          type="primary"
          round
          block
          native-type="submit"
          :loading="saving"
          loading-text="保存中..."
          class="save-btn"
        >
          保存修改
        </van-button>
      </div>
    </van-form>
  </div>
</template>

<style scoped>
.profile-page {
  min-height: 100vh;
  background: var(--cl-bg);
  padding-bottom: env(safe-area-inset-bottom);
}

.loading-center {
  display: flex;
  justify-content: center;
  padding: 60px;
}

/* Avatar */
.avatar-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 32px 0 24px;
  background: var(--cl-bg-card);
  margin-bottom: 12px;
}
.avatar-ring {
  width: 88px;
  height: 88px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--cl-accent), var(--cl-accent-dark));
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 10px;
  box-shadow: 0 4px 16px rgba(201,169,110,0.3);
}
.avatar-circle {
  width: 78px;
  height: 78px;
  border-radius: 50%;
  background: var(--cl-bg-card);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  font-weight: 700;
  font-family: var(--font-display);
  color: var(--cl-primary);
}
.avatar-tip {
  font-size: 12px;
  color: var(--cl-text-muted);
}

/* Form */
.profile-form {
  padding: 0 12px;
}
.fields-card {
  background: var(--cl-bg-card);
  border-radius: var(--radius-lg);
  overflow: hidden;
  box-shadow: var(--shadow-xs);
  margin-bottom: 16px;
}
.field-row {
  display: flex;
  align-items: center;
  padding: 0 16px;
  min-height: 52px;
}
.field-label {
  font-size: 14px;
  color: var(--cl-text-primary);
  font-weight: 500;
  width: 70px;
  flex-shrink: 0;
}
.field-divider {
  height: 1px;
  background: var(--cl-border-light);
  margin: 0 16px;
}
.profile-field {
  flex: 1;
  padding: 8px 0;
  background: transparent;
}
.profile-field :deep(.van-field__control) {
  text-align: right;
  font-size: 14px;
  color: var(--cl-text-primary);
}
.profile-field :deep(.van-field__control::placeholder) {
  color: var(--cl-text-muted);
}

/* Gender */
.gender-picker {
  display: flex;
  gap: 8px;
  margin-left: auto;
}
.gender-option {
  padding: 4px 12px;
  border-radius: var(--radius-full);
  font-size: 12px;
  color: var(--cl-text-secondary);
  background: var(--cl-bg-muted);
  cursor: pointer;
  transition: all var(--transition-fast);
  border: 1px solid transparent;
}
.gender-option.active {
  background: rgba(201,169,110,0.15);
  color: var(--cl-accent-dark);
  border-color: var(--cl-accent);
  font-weight: 600;
}

/* Info Note */
.info-note {
  display: flex;
  align-items: flex-start;
  gap: 6px;
  padding: 12px 16px;
  font-size: 12px;
  color: var(--cl-text-muted);
  line-height: 1.5;
  margin-bottom: 16px;
}
.info-note span { flex: 1; }

/* Submit */
.form-submit { padding: 0 0 24px; }
.save-btn {
  height: 48px;
  font-size: 16px;
  font-weight: 600;
  letter-spacing: 1px;
  background: var(--cl-primary) !important;
  border-color: var(--cl-primary) !important;
}
</style>
