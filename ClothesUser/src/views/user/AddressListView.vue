<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showFailToast, showToast, showConfirmDialog } from 'vant'
import { addressApi } from '@/api/address'
import type { Address } from '@/types/model'

const router = useRouter()
const addresses = ref<Address[]>([])
const loading = ref(false)
const deleting = ref<number | null>(null)
const showAddForm = ref(false)
const editingAddress = ref<Partial<Address> | null>(null)
const saving = ref(false)

const form = ref({
  receiver: '',
  phone: '',
  province: '',
  city: '',
  district: '',
  detail: '',
  isDefault: 0,
})

async function loadAddresses() {
  loading.value = true
  try {
    const data: any = await addressApi.list()
    addresses.value = data || []
  } catch (e: any) {
    showFailToast('加载失败')
  } finally {
    loading.value = false
  }
}

function openAdd() {
  editingAddress.value = null
  form.value = { receiver: '', phone: '', province: '', city: '', district: '', detail: '', isDefault: 0 }
  showAddForm.value = true
}

function openEdit(addr: Address) {
  editingAddress.value = addr
  form.value = {
    receiver: addr.receiver,
    phone: addr.phone,
    province: addr.province,
    city: addr.city,
    district: addr.district,
    detail: addr.detail,
    isDefault: addr.isDefault,
  }
  showAddForm.value = true
}

async function saveAddress() {
  if (!form.value.receiver || !form.value.phone || !form.value.detail) {
    showToast('请填写完整信息')
    return
  }
  saving.value = true
  try {
    if (editingAddress.value?.id) {
      await addressApi.update(editingAddress.value.id, form.value as any)
      showToast('修改成功')
    } else {
      const data: any = await addressApi.add(form.value as any)
      if (data?.id) addresses.value.push(data as Address)
      else await loadAddresses()
      showToast('添加成功')
    }
    showAddForm.value = false
    await loadAddresses()
  } catch (e: any) {
    showFailToast(e?.message || '保存失败')
  } finally {
    saving.value = false
  }
}

async function setDefault(addr: Address) {
  try {
    await addressApi.setDefault(addr.id)
    await loadAddresses()
    showToast('设置成功')
  } catch (e: any) {
    showFailToast(e?.message || '设置失败')
  }
}

async function deleteAddress(addr: Address) {
  try {
    await showConfirmDialog({ title: '确认删除', message: `删除收货地址"${addr.receiver}"？` })
  } catch { return }
  deleting.value = addr.id
  try {
    await addressApi.remove(addr.id)
    addresses.value = addresses.value.filter(a => a.id !== addr.id)
    showToast('已删除')
  } catch (e: any) {
    showFailToast(e?.message || '删除失败')
  } finally {
    deleting.value = null
  }
}

function selectAddress(addr: Address) {
  router.replace({ path: '/order/confirm', query: { addressId: String(addr.id) } })
}

onMounted(loadAddresses)
</script>

<template>
  <div class="address-page">
    <van-nav-bar title="收货地址" left-arrow @click-left="router.back()" />

    <!-- Empty -->
    <div v-if="!addresses.length && !loading" class="empty-state">
      <div class="empty-icon">📍</div>
      <p class="empty-title">还没有收货地址</p>
      <p class="empty-sub">添加一个吧</p>
    </div>

    <!-- Address List -->
    <div v-else class="address-list">
      <div
        v-for="addr in addresses"
        :key="addr.id"
        class="address-card"
        :class="{ 'is-default': addr.isDefault === 1 }"
        @click="selectAddress(addr)"
      >
        <div class="addr-content">
          <div class="addr-top">
            <span class="addr-receiver">{{ addr.receiver }}</span>
            <span class="addr-phone">{{ addr.phone }}</span>
            <span v-if="addr.isDefault === 1" class="tag tag-accent addr-default">默认</span>
          </div>
          <p class="addr-detail">{{ addr.province }}{{ addr.city }}{{ addr.district }}{{ addr.detail }}</p>
        </div>
        <div class="addr-actions" @click.stop>
          <span class="addr-action" @click="setDefault(addr)">设为默认</span>
          <span class="addr-action" @click="openEdit(addr)">编辑</span>
          <span class="addr-action danger" @click="deleteAddress(addr)">删除</span>
        </div>
      </div>
    </div>

    <!-- Add / Edit Button -->
    <div class="add-btn-wrap">
      <van-button
        type="primary"
        round
        block
        class="add-btn"
        @click="openAdd"
      >
        + 添加新地址
      </van-button>
    </div>

    <!-- Add/Edit Popup -->
    <van-popup v-model:show="showAddForm" position="bottom" round :style="{ maxHeight: '85vh' }">
      <div class="addr-form-popup">
        <div class="popup-header">
          <span class="popup-title">{{ editingAddress?.id ? '编辑地址' : '新增地址' }}</span>
          <van-icon name="cross" @click="showAddForm = false" />
        </div>

        <div class="popup-body">
          <van-form>
            <van-cell-group inset>
              <van-field v-model="form.receiver" label="收货人" placeholder="请输入姓名" />
              <van-field v-model="form.phone" label="手机号" type="tel" placeholder="请输入手机号" />
              <van-field v-model="form.province" label="省份" placeholder="省" />
              <van-field v-model="form.city" label="城市" placeholder="市" />
              <van-field v-model="form.district" label="区县" placeholder="区/县" />
              <van-field v-model="form.detail" label="详细地址" type="textarea" rows="2" placeholder="街道、门牌号等" />
            </van-cell-group>
          </van-form>
        </div>

        <div class="popup-footer">
          <van-button
            type="primary"
            round
            block
            :loading="saving"
            @click="saveAddress"
          >
            保存地址
          </van-button>
        </div>
      </div>
    </van-popup>
  </div>
</template>

<style scoped>
.address-page {
  min-height: 100vh;
  background: var(--cl-bg);
  padding-bottom: 80px;
}

/* Empty */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 80px 24px;
}
.empty-icon { font-size: 64px; opacity: 0.4; margin-bottom: 16px; }
.empty-title { font-size: 16px; font-weight: 600; color: var(--cl-text-primary); margin-bottom: 6px; }
.empty-sub { font-size: 13px; color: var(--cl-text-muted); }

/* List */
.address-list {
  padding: 12px;
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.address-card {
  background: var(--cl-bg-card);
  border-radius: var(--radius-lg);
  padding: 14px 16px;
  box-shadow: var(--shadow-xs);
  cursor: pointer;
  transition: transform var(--transition-fast);
  border-left: 3px solid transparent;
}
.address-card:active { transform: scale(0.99); }
.address-card.is-default {
  border-left-color: var(--cl-accent);
}
.addr-content { margin-bottom: 10px; }
.addr-top {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 6px;
}
.addr-receiver {
  font-size: 15px;
  font-weight: 600;
  color: var(--cl-text-primary);
}
.addr-phone {
  font-size: 13px;
  color: var(--cl-text-secondary);
}
.addr-default { margin-left: auto; }
.addr-detail {
  font-size: 13px;
  color: var(--cl-text-secondary);
  line-height: 1.5;
}
.addr-actions {
  display: flex;
  gap: 16px;
  border-top: 1px solid var(--cl-border-light);
  padding-top: 10px;
}
.addr-action {
  font-size: 12px;
  color: var(--cl-text-secondary);
  cursor: pointer;
}
.addr-action:active { color: var(--cl-primary); }
.addr-action.danger:active { color: var(--cl-red); }

/* Add Button */
.add-btn-wrap {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 12px 16px;
  background: var(--cl-bg-card);
  border-top: 1px solid var(--cl-border-light);
  padding-bottom: calc(12px + env(safe-area-inset-bottom));
}
.add-btn {
  background: var(--cl-primary) !important;
  border-color: var(--cl-primary) !important;
  height: 46px;
}

/* Popup */
.addr-form-popup {
  display: flex;
  flex-direction: column;
  max-height: 85vh;
}
.popup-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px;
  border-bottom: 1px solid var(--cl-border-light);
}
.popup-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--cl-text-primary);
}
.popup-body {
  flex: 1;
  overflow-y: auto;
  padding: 12px 0;
}
.popup-footer {
  padding: 12px 16px;
  border-top: 1px solid var(--cl-border-light);
}
</style>
