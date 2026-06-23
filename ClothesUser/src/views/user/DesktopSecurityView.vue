<script setup lang="ts">
import { ref, onMounted, nextTick, computed } from 'vue'
import { showToast, showFailToast } from 'vant'
import { userApi } from '@/api/user'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()

const showPwdModal = ref(false)
const showPhoneModal = ref(false)
const showEmailModal = ref(false)
const pwdForm = ref({ oldPassword: '', newPassword: '', confirmPassword: '' })
const phoneForm = ref('')
const emailForm = ref('')
const pwdLoading = ref(false)
const phoneLoading = ref(false)
const emailLoading = ref(false)

const securityScore = ref(0)
const gaugeOffset = ref(502)

const user = ref(userStore.userInfo || {})

// 安全项状态
const securityItems = ref([
  { id: 'pwd', icon: '🔑', name: '登录密码', value: '已设置', status: 'ok' as const, editable: true },
  { id: 'phone', icon: '📱', name: '手机绑定', value: '未绑定', status: 'warn' as const, editable: true },
  { id: 'email', icon: '✉️', name: '邮箱绑定', value: '未绑定', status: 'warn' as const, editable: true },
])



function calcScore() {
  let score = 30 // 登录密码基础分
  if (user.value?.phone) score += 35
  if (user.value?.email) score += 35
  return score
}

const pwdPercent = computed(() => 30)
const phonePercent = computed(() => user.value?.phone ? 35 : 0)
const emailPercent = computed(() => user.value?.email ? 35 : 0)

onMounted(async () => {
  // 如果 store 已有数据直接用，否则调 API
  if (!user.value.phone && !user.value.email) {
    try {
      const info: any = await userApi.info()
      user.value = info
      userStore.setUserInfo(info)
    } catch { /* silent */ }
  }
  // 更新安全项状态
  if (user.value?.phone) {
    const item = securityItems.value.find(i => i.id === 'phone')
    if (item) { item.value = user.value.phone; item.status = 'ok' }
  }
  if (user.value?.email) {
    const item = securityItems.value.find(i => i.id === 'email')
    if (item) { item.value = user.value.email; item.status = 'ok' }
  }
  securityScore.value = calcScore()

  await nextTick()
  // 动画：分数环
  setTimeout(() => {
    gaugeOffset.value = 502 * (1 - securityScore.value / 100)
  }, 400)
})

// 修改密码
async function onChangePwd() {
  const f = pwdForm.value
  if (!f.oldPassword || !f.newPassword) { showToast('请填写完整'); return }
  if (f.newPassword.length < 6) { showToast('新密码至少6位'); return }
  if (f.newPassword !== f.confirmPassword) { showToast('两次密码不一致'); return }
  pwdLoading.value = true
  try {
    await userApi.changePassword({ oldPassword: f.oldPassword, newPassword: f.newPassword })
    showToast('密码修改成功')
    showPwdModal.value = false
    pwdForm.value = { oldPassword: '', newPassword: '', confirmPassword: '' }
  } catch (e: any) {
    showFailToast(e?.message || '修改失败')
  } finally {
    pwdLoading.value = false
  }
}

// 修改手机
const PHONE_REGEX = /^1[3-9]\d{9}$/
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

async function onChangePhone() {
  if (!phoneForm.value) { showToast('请输入手机号'); return }
  if (!PHONE_REGEX.test(phoneForm.value)) { showToast('手机号格式不正确'); return }
  phoneLoading.value = true
  try {
    await userApi.updateInfo({ phone: phoneForm.value })
    const item = securityItems.value.find(i => i.id === 'phone')
    if (item) { item.value = phoneForm.value; item.status = 'ok' }
    user.value.phone = phoneForm.value
    securityScore.value = calcScore()
    showToast('手机绑定成功')
    showPhoneModal.value = false
  } catch (e: any) {
    showFailToast(e?.message || '绑定失败')
  } finally {
    phoneLoading.value = false
  }
}

// 修改邮箱
async function onChangeEmail() {
  if (!emailForm.value) { showToast('请输入邮箱'); return }
  if (!EMAIL_REGEX.test(emailForm.value)) { showToast('邮箱格式不正确'); return }
  emailLoading.value = true
  try {
    await userApi.updateInfo({ email: emailForm.value })
    const item = securityItems.value.find(i => i.id === 'email')
    if (item) { item.value = emailForm.value; item.status = 'ok' }
    user.value.email = emailForm.value
    securityScore.value = calcScore()
    showToast('邮箱绑定成功')
    showEmailModal.value = false
  } catch (e: any) {
    showFailToast(e?.message || '绑定失败')
  } finally {
    emailLoading.value = false
  }
}

function openPwdModal() { showPwdModal.value = true }
function openPhoneModal() { phoneForm.value = user.value?.phone || ''; showPhoneModal.value = true }
function openEmailModal() { emailForm.value = user.value?.email || ''; showEmailModal.value = true }

function onSecurityAction(id: string) {
  if (id === 'pwd') openPwdModal()
  else if (id === 'phone') openPhoneModal()
  else if (id === 'email') openEmailModal()
}




</script>

<template>
  <div class="security-page">
    <!-- Header -->
    <div class="page-header">
      <h1 class="page-title">账号安全</h1>
      <p class="page-desc">管理你的密码、绑定信息与账户安全设置</p>
    </div>

    <!-- Score + Status -->
    <div class="hero-section">
      <div class="glass-card score-card">
        <div class="score-gauge-wrap" id="gaugeWrap">
          <svg class="score-gauge" viewBox="0 0 170 170">
            <defs>
              <linearGradient id="gaugeGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stop-color="#c45c4a" />
                <stop offset="100%" stop-color="#2d8a5e" />
              </linearGradient>
            </defs>
            <circle class="track" cx="85" cy="85" r="80" />
            <circle class="fill" id="gaugeFill" cx="85" cy="85" r="80"
              :style="{ strokeDashoffset: gaugeOffset }" />
          </svg>
          <div class="score-center">
            <div class="score-num">{{ securityScore }}</div>
            <div class="score-label">安全评分</div>
          </div>
        </div>
        <div class="score-info">
          <h2>{{ securityScore >= 80 ? '安全性良好' : securityScore >= 50 ? '安全性一般' : '安全性较低' }}</h2>
          <p>{{ securityScore >= 80 ? '你的账户安全设置较为完善，建议定期更换密码。'
            : securityScore >= 50 ? '建议完成所有安全设置，提升账户安全性。'
            : '存在安全风险，请尽快绑定手机和邮箱。' }}</p>
          <div class="score-actions">
            <button class="btn btn-primary" @click="openPwdModal">修改密码</button>
            <button class="btn btn-outline" @click="openPhoneModal">绑定手机</button>
          </div>
        </div>
      </div>

      <div class="glass-card status-summary-card">
        <div>
          <div class="status-summary-title">安全状态概览</div>
          <div class="status-bars">
            <div class="status-bar-item">
              <div class="status-bar-head"><span>密码强度</span><span>{{ pwdPercent }}%</span></div>
              <div class="status-bar-track"><div class="status-bar-fill" :style="{ width: pwdPercent + '%', background: 'var(--accent)' }"></div></div>
            </div>
            <div class="status-bar-item">
              <div class="status-bar-head"><span>手机绑定</span><span>{{ phonePercent }}%</span></div>
              <div class="status-bar-track"><div class="status-bar-fill" :style="{ width: phonePercent + '%', background: 'var(--success)' }"></div></div>
            </div>
            <div class="status-bar-item">
              <div class="status-bar-head"><span>邮箱绑定</span><span>{{ emailPercent }}%</span></div>
              <div class="status-bar-track"><div class="status-bar-fill" :style="{ width: emailPercent + '%', background: 'var(--info)' }"></div></div>
            </div>

          </div>
        </div>
        <div style="font-size:12px;color:var(--text-muted);margin-top:16px">
          完成所有设置后安全评分将提升至 100 分
        </div>
      </div>
    </div>

    <!-- Security Items -->
    <div class="bento-grid">
      <div class="glass-card bento-item wide">
        <div class="bento-header">
          <div class="bento-title">安全设置</div>
        </div>
        <div class="security-rows">
          <div v-for="item in securityItems" :key="item.id" class="security-row">
            <div class="security-main">
              <div :class="['security-icon', item.status === 'ok' ? 'green' : 'orange']">{{ item.icon }}</div>
              <div class="security-text">
                <div class="security-name">{{ item.name }}</div>
                <div class="security-value">{{ item.value }}</div>
              </div>
            </div>
            <div class="security-right">
              <div :class="['security-status', item.status]">
                <span :class="['status-dot', { pulse: item.status === 'warn' }]"></span>
                {{ item.status === 'ok' ? '已设置' : '未设置' }}
              </div>
              <button v-if="item.editable" class="btn btn-link" @click="onSecurityAction(item.id)">
                {{ item.status === 'ok' ? '修改' : '设置' }}
              </button>
            </div>
          </div>
        </div>
      </div>



    </div>

    <!-- Danger Zone -->
    <div class="glass-card bento-item" style="min-height:auto">
      <div class="bento-header">
        <div class="bento-title" style="color:var(--danger)">危险区域</div>
      </div>
      <div class="danger-content">
        <div class="danger-left">
          <div class="danger-icon">⚠️</div>
          <div>
            <div class="danger-title">注销账号</div>
            <div class="danger-desc">一旦注销，所有数据将被永久删除且无法恢复</div>
          </div>
        </div>
        <button class="btn btn-danger" disabled style="opacity:0.4;cursor:not-allowed" title="功能开发中">注销账号（即将上线）</button>
      </div>
    </div>

    <!-- Modals -->
    <Teleport to="body">
      <!-- 修改密码 -->
      <div :class="['modal-overlay', { active: showPwdModal }]" @click.self="showPwdModal = false">
        <div class="modal">
          <div class="modal-header">
            <h4>修改密码</h4>
            <div class="modal-close" @click="showPwdModal = false">&times;</div>
          </div>
          <div class="modal-body">
            <div class="form-grid">
              <div class="form-item full">
                <label class="form-label">当前密码</label>
                <input class="form-input" type="password" v-model="pwdForm.oldPassword" placeholder="输入当前密码" />
              </div>
              <div class="form-item full">
                <label class="form-label">新密码</label>
                <input class="form-input" type="password" v-model="pwdForm.newPassword" placeholder="至少6位" />
              </div>
              <div class="form-item full">
                <label class="form-label">确认新密码</label>
                <input class="form-input" type="password" v-model="pwdForm.confirmPassword" placeholder="再次输入新密码" />
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button class="btn btn-outline" @click="showPwdModal = false">取消</button>
            <button class="btn btn-primary" :disabled="pwdLoading" @click="onChangePwd">
              {{ pwdLoading ? '提交中...' : '确认修改' }}
            </button>
          </div>
        </div>
      </div>

      <!-- 绑定手机 -->
      <div :class="['modal-overlay', { active: showPhoneModal }]" @click.self="showPhoneModal = false">
        <div class="modal">
          <div class="modal-header">
            <h4>{{ user?.phone ? '修改手机号' : '绑定手机号' }}</h4>
            <div class="modal-close" @click="showPhoneModal = false">&times;</div>
          </div>
          <div class="modal-body">
            <div class="form-grid">
              <div class="form-item full">
                <label class="form-label">手机号</label>
                <input class="form-input" v-model="phoneForm" placeholder="输入手机号" />
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button class="btn btn-outline" @click="showPhoneModal = false">取消</button>
            <button class="btn btn-primary" :disabled="phoneLoading" @click="onChangePhone">
              {{ phoneLoading ? '提交中...' : '确认' }}
            </button>
          </div>
        </div>
      </div>

      <!-- 绑定邮箱 -->
      <div :class="['modal-overlay', { active: showEmailModal }]" @click.self="showEmailModal = false">
        <div class="modal">
          <div class="modal-header">
            <h4>{{ user?.email ? '修改邮箱' : '绑定邮箱' }}</h4>
            <div class="modal-close" @click="showEmailModal = false">&times;</div>
          </div>
          <div class="modal-body">
            <div class="form-grid">
              <div class="form-item full">
                <label class="form-label">邮箱地址</label>
                <input class="form-input" v-model="emailForm" placeholder="输入邮箱地址" />
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button class="btn btn-outline" @click="showEmailModal = false">取消</button>
            <button class="btn btn-primary" :disabled="emailLoading" @click="onChangeEmail">
              {{ emailLoading ? '提交中...' : '确认' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<style scoped>
.security-page {
  max-width: 1080px;
  margin: 0 auto;
  padding: 40px 32px 80px;
}

.page-header { margin-bottom: 36px; }
.page-title {
  font-family: 'Cormorant Garamond', 'Noto Serif SC', serif;
  font-size: 38px;
  font-weight: 600;
  color: var(--text-primary, #1a1a1a);
  margin-bottom: 8px;
}
.page-desc { font-size: 14px; color: var(--text-muted, #999); }

/* Glass Card */
.glass-card {
  background: rgba(6,6,10,0.88);
  border: 1px solid var(--border);
  border-radius: 20px;
  box-shadow: 0 4px 20px rgba(0,0,0,0.04);
  backdrop-filter: blur(16px);
  overflow: hidden;
  position: relative;
}

/* Hero */
.hero-section {
  display: grid;
  grid-template-columns: 1.1fr 1fr;
  gap: 24px;
  margin-bottom: 28px;
}

.score-card {
  padding: 32px;
  display: flex;
  align-items: center;
  gap: 32px;
  min-height: 260px;
}
.score-gauge-wrap {
  position: relative;
  width: 160px; height: 160px;
  flex-shrink: 0;
}
.score-gauge { width: 100%; height: 100%; transform: rotate(-90deg); }
.score-gauge circle { fill: none; stroke-width: 10; stroke-linecap: round; }
.score-gauge .track { stroke: var(--border); }
.score-gauge .fill {
  stroke: var(--accent, #c45c4a);
  stroke-dasharray: 502;
  stroke-dashoffset: 502;
  transition: stroke-dashoffset 1.6s cubic-bezier(0.16,1,0.3,1);
}
.score-center {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}
.score-num {
  font-family: 'Cormorant Garamond', serif;
  font-size: 48px;
  font-weight: 700;
  color: var(--accent, #c45c4a);
  line-height: 1;
}
.score-label { font-size: 12px; color: var(--text-muted, #999); margin-top: 4px; }
.score-info h2 { font-size: 22px; font-weight: 600; margin-bottom: 10px; }
.score-info p { font-size: 13px; color: var(--text-secondary); line-height: 1.7; margin-bottom: 20px; }
.score-actions { display: flex; gap: 10px; }

.status-summary-card {
  padding: 28px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}
.status-summary-title {
  font-size: 14px; font-weight: 700; color: var(--text-secondary);
  margin-bottom: 20px;
}
.status-bars { display: flex; flex-direction: column; gap: 16px; }
.status-bar-item { display: flex; flex-direction: column; gap: 6px; }
.status-bar-head { display: flex; justify-content: space-between; font-size: 13px; font-weight: 500; }
.status-bar-track { height: 6px; background: var(--border); border-radius: 3px; overflow: hidden; }
.status-bar-fill { height: 100%; width: 0; border-radius: 3px; transition: width 1.2s cubic-bezier(0.16,1,0.3,1); }

/* Buttons */
.btn {
  height: 42px;
  padding: 0 20px;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.25s;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  border: none;
  font-family: inherit;
}
.btn-primary { background: var(--bg-dark); color: white; }
.btn-primary:hover { background: #333; transform: translateY(-1px); }
.btn-primary:disabled { opacity: 0.5; cursor: not-allowed; transform: none; }
.btn-outline { background: var(--bg-card); border: 1px solid var(--border); color: var(--text-secondary); }
.btn-outline:hover { border-color: var(--accent, #c45c4a); color: var(--accent, #c45c4a); }
.btn-danger { background: var(--bg-card); border: 1px solid rgba(201,58,58,0.3); color: var(--danger); }
.btn-danger:hover { background: var(--bg-elevated); border-color: var(--danger); }
.btn-link { background: transparent; border: none; color: var(--accent, #c45c4a); padding: 0; height: auto; font-weight: 600; font-size: 12px; }
.btn-link:hover { text-decoration: underline; }

/* Bento Grid */
.bento-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 24px;
  margin-bottom: 28px;
}
.bento-item {
  padding: 28px;
}
.bento-item.wide { grid-column: 1 / -1; }
.bento-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20px;
}
.bento-title {
  font-size: 16px;
  font-weight: 700;
  display: flex;
  align-items: center;
  gap: 8px;
}
.bento-title::before {
  content: '';
  width: 4px; height: 18px;
  background: var(--accent, #c45c4a);
  border-radius: 2px;
}

/* Security Rows */
.security-rows { display: flex; flex-direction: column; gap: 12px; }
.security-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 16px;
  border-radius: 12px;
  background: var(--bg-secondary);
  border: 1px solid transparent;
  transition: all 0.25s;
}
.security-row:hover { background: var(--bg-elevated); border-color: var(--border); }
.security-main { display: flex; align-items: center; gap: 12px; }
.security-icon {
  width: 40px; height: 40px;
  border-radius: 10px;
  background: var(--bg-elevated);
  display: flex; align-items: center; justify-content: center;
  font-size: 16px; flex-shrink: 0;
}
.security-icon.green { background: rgba(0,232,160,0.1); }
.security-icon.orange { background: var(--bg-card)8e6; }
.security-name { font-size: 14px; font-weight: 600; margin-bottom: 2px; }
.security-value { font-size: 12px; color: var(--text-muted, #999); }
.security-right { display: flex; align-items: center; gap: 12px; }
.security-status {
  font-size: 12px; font-weight: 600;
  display: flex; align-items: center; gap: 4px;
}
.security-status.ok { color: var(--success, #2d8a5e); }
.security-status.warn { color: var(--warning, #c77d0a); }
.status-dot { width: 6px; height: 6px; border-radius: 50%; background: currentColor; }
.status-dot.pulse { animation: pulse 1.8s ease-out infinite; }
@keyframes pulse {
  0% { box-shadow: 0 0 0 0 currentColor; }
  100% { box-shadow: 0 0 0 8px transparent; }
}

/* OAuth */
.oauth-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 12px; }
.oauth-card {
  padding: 16px;
  border-radius: 12px;
  background: var(--bg-secondary);
  border: 1px solid transparent;
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  transition: all 0.25s;
}
.oauth-card:hover { background: var(--bg-elevated); border-color: var(--border); }
.oauth-icon { width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 20px; background: var(--bg-secondary); flex-shrink: 0; }
.oauth-name { font-size: 14px; font-weight: 600; }
.oauth-status { font-size: 12px; color: var(--text-muted, #999); margin-top: 2px; }
.oauth-action { color: var(--accent, #c45c4a); font-size: 12px; font-weight: 600; margin-left: auto; }

/* Device Timeline */
.device-timeline { display: flex; flex-direction: column; gap: 8px; }
.device-item {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 12px 0;
  border-bottom: 1px solid var(--border);
}
.device-item:last-child { border-bottom: none; }
.device-icon { width: 40px; height: 40px; border-radius: 10px; background: var(--bg-secondary); display: flex; align-items: center; justify-content: center; font-size: 16px; flex-shrink: 0; }
.device-name { font-size: 14px; font-weight: 600; display: flex; align-items: center; gap: 8px; }
.device-current { font-size: 10px; color: var(--success, #2d8a5e); background: rgba(0,232,160,0.1); padding: 2px 8px; border-radius: 20px; font-weight: 700; }
.device-meta { font-size: 12px; color: var(--text-muted, #999); margin-top: 2px; }

/* Danger */
.danger-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
  flex-wrap: wrap;
}
.danger-icon { width: 48px; height: 48px; border-radius: 12px; background: var(--bg-elevated); color: var(--danger); display: flex; align-items: center; justify-content: center; font-size: 22px; flex-shrink: 0; }
.danger-title { font-size: 15px; font-weight: 700; }
.danger-desc { font-size: 12px; color: var(--text-muted, #999); margin-top: 2px; }

/* Modal */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(26,26,26,0.32);
  display: none;
  align-items: center;
  justify-content: center;
  z-index: 100;
  backdrop-filter: blur(6px);
  padding: 20px;
}
.modal-overlay.active { display: flex; }
.modal {
  background: rgba(6,6,10,0.96);
  border-radius: 20px;
  width: 420px;
  max-width: 100%;
  box-shadow: 0 20px 60px rgba(0,0,0,0.12);
  border: 1px solid var(--border);
}
.modal-header { padding: 22px 26px; border-bottom: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; }
.modal-header h4 { font-size: 17px; font-weight: 700; }
.modal-close { font-size: 22px; color: var(--text-muted, #999); cursor: pointer; width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; border-radius: 50%; transition: all 0.2s; }
.modal-close:hover { background: var(--bg-secondary); color: var(--text-primary); }
.modal-body { padding: 24px 26px; }
.form-grid { display: grid; gap: 16px; }
.form-item { display: flex; flex-direction: column; gap: 6px; }
.form-item.full { grid-column: 1 / -1; }
.form-label { font-size: 12px; font-weight: 600; color: var(--text-secondary); }
.form-input {
  height: 44px; border: 1px solid var(--border);
  border-radius: 8px; padding: 0 14px; font-size: 14px;
  outline: none; transition: all 0.2s;
  background: var(--bg-card);
  color: var(--text-primary, #1a1a1a);
}
.form-input:focus { border-color: var(--accent, #c45c4a); box-shadow: 0 0 0 3px rgba(196,92,74,0.08); }
.modal-footer { padding: 16px 26px 26px; display: flex; gap: 10px; }
.modal-footer .btn { flex: 1; }
</style>
