<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showFailToast, showToast } from 'vant'
import { userApi } from '@/api/user'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()
const form = ref({ nickname: '', phone: '', email: '', gender: 0 })
const loading = ref(true)
const saving = ref(false)

async function loadInfo() {
  loading.value = true
  try {
    if (userStore.userInfo) {
      Object.assign(form.value, {
        nickname: userStore.userInfo.nickname || '',
        phone: userStore.userInfo.phone || '',
        email: userStore.userInfo.email || '',
        gender: userStore.userInfo.gender || 0,
      })
    } else {
      const info: any = await userApi.info()
      userStore.setUserInfo(info)
      Object.assign(form.value, {
        nickname: info.nickname || '', phone: info.phone || '',
        email: info.email || '', gender: info.gender || 0,
      })
    }
  } catch { /* silent */ }
  finally { loading.value = false }
}

async function save() {
  if (!form.value.nickname.trim()) { showToast('请输入昵称'); return }
  saving.value = true
  try {
    await userApi.updateInfo(form.value as any)
    userStore.setUserInfo({ ...userStore.userInfo, ...form.value } as any)
    showToast('保存成功')
    router.push('/user')
  } catch (e: any) { showFailToast(e?.message || '保存失败') }
  finally { saving.value = false }
}

onMounted(loadInfo)
</script>

<template>
  <DesktopLayout>
    <div class="desktop-page-title">个人资料</div>

    <div style="max-width:640px">
      <div style="background:#fff;border-radius:12px;padding:24px;box-shadow:0 1px 4px rgba(0,0,0,0.06)">
        <!-- Avatar -->
        <div style="text-align:center;margin-bottom:24px">
          <div style="width:80px;height:80px;border-radius:50%;background:#1a1a1a;display:flex;align-items:center;justify-content:center;margin:0 auto 10px;overflow:hidden">
            <img src="/assets/avatars/avatar-default.svg" style="width:80px;height:80px" alt="" />
          </div>
          <div style="font-size:12px;color:#bbb">点击头像更换（开发中）</div>
        </div>

        <!-- Fields -->
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px">
          <div>
            <div style="font-size:12px;color:#888;margin-bottom:6px">昵称</div>
            <input v-model="form.nickname" style="width:100%;height:42px;border:1.5px solid #e0e0e0;border-radius:8px;padding:0 14px;font-size:14px;outline:none;box-sizing:border-box" />
          </div>
          <div>
            <div style="font-size:12px;color:#888;margin-bottom:6px">性别</div>
            <div style="display:flex;gap:8px">
              <div
                v-for="opt in [{label:'保密',val:0},{label:'男',val:1},{label:'女',val:2}]"
                :key="opt.val"
                style="flex:1;height:42px;border:1.5px solid #ddd;border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:13px;cursor:pointer;transition:all 0.15s"
                :style="form.gender === opt.val ? {borderColor:'#c9a96e',background:'#fdf6ec',color:'#c9a96e',fontWeight:700} : {}"
                @click="form.gender = opt.val"
              >{{ opt.label }}</div>
            </div>
          </div>
          <div style="grid-column:1/-1">
            <div style="font-size:12px;color:#888;margin-bottom:6px">手机号</div>
            <input v-model="form.phone" style="width:100%;height:42px;border:1.5px solid #e0e0e0;border-radius:8px;padding:0 14px;font-size:14px;outline:none;box-sizing:border-box" placeholder="选填" />
          </div>
          <div style="grid-column:1/-1">
            <div style="font-size:12px;color:#888;margin-bottom:6px">邮箱</div>
            <input v-model="form.email" style="width:100%;height:42px;border:1.5px solid #e0e0e0;border-radius:8px;padding:0 14px;font-size:14px;outline:none;box-sizing:border-box" placeholder="选填" />
          </div>
        </div>

        <button
          style="width:100%;height:46px;background:#1a1a1a;color:#fff;border:none;border-radius:8px;font-size:15px;font-weight:700;cursor:pointer;margin-top:24px;transition:background 0.15s"
          :disabled="saving"
          @click="save"
        >{{ saving ? '保存中...' : '保存修改' }}</button>
      </div>
    </div>
  </DesktopLayout>
</template>
