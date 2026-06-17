<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { showFailToast, showToast } from 'vant'
import { addressApi } from '@/api/address'
import type { Address } from '@/types/model'

const addresses = ref<Address[]>([])
const loading = ref(false)

async function load() {
  loading.value = true
  try {
    const data: any = await addressApi.list()
    addresses.value = data || []
  } catch (e: any) { showFailToast('加载失败') }
  finally { loading.value = false }
}

async function setDefault(addr: Address) {
  try { await addressApi.setDefault(addr.id); await load(); showToast('设置成功') }
  catch (e: any) { showFailToast(e?.message || '设置失败') }
}

async function deleteAddr(addr: Address) {
  try {
    await addressApi.remove(addr.id)
    addresses.value = addresses.value.filter(a => a.id !== addr.id)
    showToast('已删除')
  } catch (e: any) { showFailToast(e?.message || '删除失败') }
}

onMounted(load)
</script>

<template>
  <DesktopLayout>
    <div class="desktop-page-title">收货地址</div>

    <div v-if="!addresses.length && !loading" class="desktop-empty">
      <div class="empty-icon">
        <svg width="80" height="80" viewBox="0 0 80 80" fill="none" xmlns="http://www.w3.org/2000/svg">
          <circle cx="40" cy="40" r="38" fill="#F5F7FA"/>
          <path d="M40 20 C28 20 18 30 18 42 C18 60 40 70 40 70 C40 70 62 60 62 42 C62 30 52 20 40 20Z" stroke="#D1D5DB" stroke-width="3" fill="none"/>
          <circle cx="40" cy="42" r="8" stroke="#D1D5DB" stroke-width="2.5" fill="none"/>
          <line x1="30" y1="35" x2="30" y2="50" stroke="#E5E7EB" stroke-width="2" stroke-linecap="round" stroke-dasharray="3 3"/>
          <line x1="35" y1="38" x2="35" y2="46" stroke="#E5E7EB" stroke-width="2" stroke-linecap="round" stroke-dasharray="3 3"/>
        </svg>
      </div><p>还没有收货地址</p>
    </div>

    <div class="desktop-address-grid">
      <div
        v-for="addr in addresses"
        :key="addr.id"
        class="desktop-address-card"
        :class="{ active: addr.isDefault === 1 }"
      >
        <div class="addr-top">
          <span class="addr-name">{{ addr.receiver }}</span>
          <span class="addr-phone">{{ addr.phone }}</span>
          <span v-if="addr.isDefault === 1" style="margin-left:auto;background:#fdf6ec;color:#c9a96e;font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px">默认</span>
        </div>
        <div class="addr-text">{{ addr.province }}{{ addr.city }}{{ addr.district }}{{ addr.detail }}</div>
        <div class="addr-actions">
          <span @click="setDefault(addr)">设为默认</span>
          <span @click="deleteAddr(addr)">删除</span>
        </div>
      </div>

      <div class="desktop-add-address-btn">
        <div class="add-icon">+</div>
        <div>添加新地址</div>
      </div>
    </div>
  </DesktopLayout>
</template>
