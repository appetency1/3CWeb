<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { showFailToast, showToast, showConfirmDialog } from 'vant'
import { addressApi } from '@/api/address'
import type { Address } from '@/types/model'

const addresses = ref<Address[]>([])
const loading = ref(false)
const showModal = ref(false)
const editingId = ref<number | null>(null)
const showAreaPicker = ref(false)

const selectedProvince = ref<any>(null)
const selectedCity = ref<any>(null)
const areaValues = ref<any[]>([])
const areaColumns = [
  { text: '北京市', children: [{ text: '北京市', children: [{ text: '东城区' }, { text: '西城区' }, { text: '朝阳区' }, { text: '海淀区' }, { text: '丰台区' }, { text: '石景山区' }, { text: '通州区' }, { text: '大兴区' }, { text: '昌平区' }, { text: '顺义区' }, { text: '房山区' }, { text: '门头沟区' }, { text: '怀柔区' }, { text: '平谷区' }, { text: '密云区' }, { text: '延庆区' }] }] },
  { text: '上海市', children: [{ text: '上海市', children: [{ text: '黄浦区' }, { text: '徐汇区' }, { text: '长宁区' }, { text: '静安区' }, { text: '普陀区' }, { text: '虹口区' }, { text: '杨浦区' }, { text: '浦东新区' }, { text: '闵行区' }, { text: '宝山区' }, { text: '嘉定区' }, { text: '金山区' }, { text: '松江区' }, { text: '青浦区' }, { text: '奉贤区' }, { text: '崇明区' }] }] },
  { text: '广州市', children: [{ text: '广州市', children: [{ text: '荔湾区' }, { text: '越秀区' }, { text: '海珠区' }, { text: '天河区' }, { text: '白云区' }, { text: '黄埔区' }, { text: '番禺区' }, { text: '花都区' }, { text: '南沙区' }, { text: '从化区' }, { text: '增城区' }] }] },
  { text: '深圳市', children: [{ text: '深圳市', children: [{ text: '罗湖区' }, { text: '福田区' }, { text: '南山区' }, { text: '宝安区' }, { text: '龙岗区' }, { text: '盐田区' }, { text: '龙华区' }, { text: '坪山区' }, { text: '光明区' }] }] },
  { text: '浙江省', children: [
    { text: '杭州市', children: [{ text: '上城区' }, { text: '拱墅区' }, { text: '西湖区' }, { text: '滨江区' }, { text: '萧山区' }, { text: '余杭区' }, { text: '富阳区' }, { text: '临安区' }] },
    { text: '宁波市', children: [{ text: '海曙区' }, { text: '江北区' }, { text: '北仑区' }, { text: '鄞州区' }] },
    { text: '温州市', children: [{ text: '鹿城区' }, { text: '龙湾区' }, { text: '瓯海区' }] },
  ] },
  { text: '江苏省', children: [
    { text: '南京市', children: [{ text: '玄武区' }, { text: '秦淮区' }, { text: '建邺区' }, { text: '鼓楼区' }, { text: '浦口区' }, { text: '栖霞区' }, { text: '雨花台区' }, { text: '江宁区' }] },
    { text: '苏州市', children: [{ text: '姑苏区' }, { text: '吴中区' }, { text: '相城区' }, { text: '吴江区' }, { text: '虎丘区' }] },
    { text: '无锡市', children: [{ text: '梁溪区' }, { text: '锡山区' }, { text: '惠山区' }, { text: '滨湖区' }, { text: '新吴区' }] },
  ] },
  { text: '四川省', children: [
    { text: '成都市', children: [{ text: '锦江区' }, { text: '青羊区' }, { text: '金牛区' }, { text: '武侯区' }, { text: '成华区' }, { text: '高新区' }, { text: '天府新区' }, { text: '龙泉驿区' }, { text: '双流区' }] },
  ] },
  { text: '湖北省', children: [
    { text: '武汉市', children: [{ text: '江岸区' }, { text: '江汉区' }, { text: '硚口区' }, { text: '武昌区' }, { text: '洪山区' }, { text: '汉阳区' }, { text: '青山区' }] },
  ] },
  { text: '湖南省', children: [
    { text: '长沙市', children: [{ text: '芙蓉区' }, { text: '天心区' }, { text: '岳麓区' }, { text: '开福区' }, { text: '雨花区' }, { text: '望城区' }] },
  ] },
  { text: '福建省', children: [
    { text: '厦门市', children: [{ text: '思明区' }, { text: '海沧区' }, { text: '湖里区' }, { text: '集美区' }, { text: '同安区' }, { text: '翔安区' }] },
    { text: '福州市', children: [{ text: '鼓楼区' }, { text: '台江区' }, { text: '仓山区' }, { text: '晋安区' }, { text: '马尾区' }] },
  ] },
  { text: '山东省', children: [
    { text: '青岛市', children: [{ text: '市南区' }, { text: '市北区' }, { text: '黄岛区' }, { text: '崂山区' }, { text: '城阳区' }, { text: '即墨区' }] },
    { text: '济南市', children: [{ text: '历下区' }, { text: '市中区' }, { text: '槐荫区' }, { text: '天桥区' }, { text: '历城区' }] },
  ] },
  { text: '重庆市', children: [{ text: '重庆市', children: [{ text: '渝中区' }, { text: '江北区' }, { text: '沙坪坝区' }, { text: '九龙坡区' }, { text: '南岸区' }, { text: '渝北区' }, { text: '巴南区' }, { text: '北碚区' }] }] },
]

const form = ref({
  receiver: '',
  phone: '',
  province: '',
  city: '',
  district: '',
  detail: '',
  isDefault: 0 as number,
  tag: '' as string,
})

const tagOptions = ['家', '公司', '学校']

async function load() {
  loading.value = true
  try {
    const data: any = await addressApi.list()
    addresses.value = data || []
  } catch { showFailToast('加载失败') }
  finally { loading.value = false }
}

function openAdd() {
  editingId.value = null
  form.value = { receiver: '', phone: '', province: '', city: '', district: '', detail: '', isDefault: 0, tag: '' }
  showModal.value = true
}

function openEdit(addr: Address) {
  editingId.value = addr.id
  form.value = {
    receiver: addr.receiver,
    phone: addr.phone,
    province: addr.province,
    city: addr.city,
    district: addr.district,
    detail: addr.detail,
    isDefault: addr.isDefault || 0,
    tag: addr.tag || '',
  }
  showModal.value = true
}

function openAreaPicker() {
  selectedProvince.value = areaColumns.find(p => p.text === form.value.province) || null
  selectedCity.value = null
  if (selectedProvince.value) {
    selectedCity.value = (selectedProvince.value.children || []).find((c: any) => c.text === form.value.city) || null
  }
  showAreaPicker.value = true
}

function selectProvince(p: any) {
  selectedProvince.value = p
  selectedCity.value = null
  form.value.province = p.text
  form.value.city = ''
  form.value.district = ''
}

function selectCity(c: any) {
  selectedCity.value = c
  form.value.city = c.text
  form.value.district = ''
}

function selectDistrict(d: any) {
  form.value.district = d.text
}

function confirmArea() {
  if (!form.value.province) { showFailToast('请选择省份'); return }
  if (!form.value.city) { showFailToast('请选择城市'); return }
  if (!form.value.district) { showFailToast('请选择区/县'); return }
  showAreaPicker.value = false
}

async function saveAddress() {
  const f = form.value
  if (!f.receiver.trim()) { showFailToast('请填写收货人'); return }
  if (!f.phone.trim()) { showFailToast('请填写手机号'); return }
  if (!f.province.trim() || !f.city.trim()) { showFailToast('请选择地区'); return }
  try {
    if (editingId.value) {
      await addressApi.update(editingId.value, {
        receiver: f.receiver.trim(), phone: f.phone.trim(),
        province: f.province, city: f.city, district: f.district, detail: f.detail,
        isDefault: f.isDefault,
        tag: f.tag,
      })
      showModal.value = false
      await load()
    } else {
      await addressApi.add({
        receiver: f.receiver.trim(), phone: f.phone.trim(),
        province: f.province, city: f.city, district: f.district, detail: f.detail,
        isDefault: f.isDefault,
        tag: f.tag,
      })
      showModal.value = false
      await load()
    }
  } catch (e: any) {
    // 401/403 由 axios 全局拦截器处理（自动弹 toast + 跳登录），不重复处理
    const status = e?.response?.status
    if (status !== 401 && status !== 403) {
      showFailToast(e?.message || '操作失败')
    }
  }
}

async function setDefault(addr: Address) {
  try { await addressApi.setDefault(addr.id); await load(); showToast('已设为默认') }
  catch { showFailToast('设置失败') }
}

async function deleteAddr(addr: Address) {
  try {
    await showConfirmDialog({ title: '确认删除', message: `确定删除"${addr.receiver}"的地址吗？` })
  } catch { return }
  try {
    await addressApi.remove(addr.id)
    addresses.value = addresses.value.filter(a => a.id !== addr.id)
    showToast('已删除')
  } catch { showFailToast('删除失败') }
}

onMounted(load)
</script>

<template>
  <DesktopLayout>
    <div class="address-page">
      <!-- 页面头部 -->
      <div class="page-header-addr">
        <div class="page-title-group">
          <h1 class="page-title">收货地址</h1>
          <p class="page-subtitle">管理您的配送地址，让包裹准确送达</p>
        </div>
        <button class="btn-add-address" @click="openAdd">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
            <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
          </svg>
          添加新地址
        </button>
      </div>

      <!-- 空状态 -->
      <div v-if="!addresses.length && !loading" class="empty-state">
        <div class="empty-icon-wrap">
          <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round">
            <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/>
          </svg>
        </div>
        <h3 class="empty-title">还没有收货地址</h3>
        <p class="empty-desc">添加一个地址，让包裹准确送达您手中</p>
        <button class="btn-add-address" @click="openAdd">＋ 添加新地址</button>
      </div>

      <!-- 地址列表 -->
      <div v-else class="address-list">
        <div
          v-for="addr in addresses" :key="addr.id"
          class="address-card"
          :class="{ default: addr.isDefault === 1 }"
        >
          <div class="address-card-header">
            <div class="address-user">
              <span class="address-name">{{ addr.receiver }}</span>
              <span class="address-phone">{{ addr.phone }}</span>
            </div>
            <div class="address-tags">
              <span v-if="addr.isDefault === 1" class="tag tag-default">默认</span>
              <span v-if="addr.tag" class="tag tag-default" style="background:var(--accent);color:#fff">{{ addr.tag }}</span>
            </div>
          </div>
          <div class="address-detail">
            <span class="province">{{ addr.province }}{{ addr.city }}{{ addr.district }}</span>
            {{ addr.detail }}
          </div>
          <div class="address-actions">
            <div class="address-action-btns">
              <button class="btn-text" @click="openEdit(addr)">✎ 编辑</button>
              <button class="btn-text btn-text-danger" @click="deleteAddr(addr)">🗑 删除</button>
            </div>
            <button v-if="addr.isDefault !== 1" class="btn-set-default" @click="setDefault(addr)">设为默认</button>
          </div>
        </div>

        <!-- 添加新地址卡片 -->
        <div class="add-address-card" @click="openAdd">
          <div class="add-address-icon">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
              <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
            </svg>
          </div>
          <div class="add-address-text">添加新地址</div>
          <div class="add-address-hint">最多可保存 10 个地址</div>
        </div>
      </div>
    </div>

    <!-- 模态框 -->
    <div class="modal-overlay" :class="{ active: showModal }" @click.self="showModal = false">
      <div class="modal">
        <div class="modal-header">
          <h2 class="modal-title">{{ editingId ? '编辑地址' : '新增地址' }}</h2>
          <button class="modal-close" @click="showModal = false">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
              <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
            </svg>
          </button>
        </div>

        <div class="form-group">
          <label class="form-label">收货人</label>
          <input v-model="form.receiver" class="form-input" placeholder="请输入收货人姓名" />
        </div>

        <div class="form-group">
          <label class="form-label">手机号</label>
          <input v-model="form.phone" class="form-input" placeholder="请输入手机号" type="tel" />
        </div>

        <div class="form-group">
          <label class="form-label">所在地区</label>
          <div class="area-selector" @click="openAreaPicker">
            <template v-if="form.province">
              <span class="area-text">{{ form.province }} {{ form.city }} {{ form.district }}</span>
            </template>
            <span v-else class="area-placeholder">请选择省/市/区</span>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><polyline points="9 18 15 12 9 6"/></svg>
          </div>
        </div>

        <div class="form-group">
            <label class="form-label">标签</label>
            <div class="tag-selector">
              <button v-for="t in tagOptions" :key="t"
                class="tag-option"
                :class="{ active: form.tag === t }"
                @click="form.tag = form.tag === t ? '' : t"
              >{{ t }}</button>
            </div>
          </div>

        <div class="form-group">
          <label class="form-label">详细地址</label>
          <textarea v-model="form.detail" class="form-textarea" placeholder="街道、楼栋、门牌号等" rows="2"></textarea>
        </div>

        <div class="checkbox-wrap">
          <input v-model="form.isDefault" type="checkbox" :true-value="1" :false-value="0" id="defaultAddr" />
          <label for="defaultAddr">设为默认地址</label>
        </div>

        <div class="modal-footer">
          <button class="btn btn-outline" @click="showModal = false">取消</button>
          <button class="btn btn-primary" @click="saveAddress">{{ editingId ? '保存修改' : '确认添加' }}</button>
        </div>
      </div>
    </div>

    <!-- 地区选择器 (网页版) -->
    <div v-if="showAreaPicker" class="area-modal-overlay" @click.self="showAreaPicker = false">
      <div class="area-modal">
        <div class="area-modal-header">
          <h3>选择地区</h3>
          <button class="area-modal-close" @click="showAreaPicker = false">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
              <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
            </svg>
          </button>
        </div>
        <div class="area-columns">
          <div class="area-col">
            <div class="area-col-title">省份</div>
            <div class="area-list">
              <button v-for="p in areaColumns" :key="p.text"
                :class="['area-item', { active: form.province === p.text }]"
                @click="selectProvince(p)"
              >{{ p.text }}</button>
            </div>
          </div>
          <div class="area-col" v-if="selectedProvince">
            <div class="area-col-title">城市</div>
            <div class="area-list">
              <button v-for="c in selectedProvince.children || []" :key="c.text"
                :class="['area-item', { active: form.city === c.text }]"
                @click="selectCity(c)"
              >{{ c.text }}</button>
            </div>
          </div>
          <div class="area-col" v-if="selectedCity">
            <div class="area-col-title">区/县</div>
            <div class="area-list">
              <button v-for="d in selectedCity.children || []" :key="d.text"
                :class="['area-item', { active: form.district === d.text }]"
                @click="selectDistrict(d)"
              >{{ d.text }}</button>
            </div>
          </div>
        </div>
        <div class="area-modal-footer">
          <button class="btn btn-primary" @click="confirmArea">确定</button>
        </div>
      </div>
    </div>
  </DesktopLayout>
</template>

<style scoped>
.address-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 24px 40px 60px;
}

.page-header-addr {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  margin-bottom: 32px;
  padding-bottom: 24px;
  border-bottom: 1px solid var(--border, #ece9e4);
}
.page-title-group { display: flex; flex-direction: column; gap: 6px; }
.page-title {
  font-size: 28px; font-weight: 700; color: var(--text-primary, #1a1a1a); letter-spacing: 0.5px;
}
.page-subtitle { font-size: 14px; color: var(--text-muted, #9a9a9a); }

.btn-add-address {
  display: inline-flex; align-items: center; gap: 8px;
  padding: 12px 28px; border-radius: 100px; border: none;
  background: var(--bg-dark, #1a1a1a); color: white;
  font-size: 14px; font-weight: 600; cursor: pointer;
}
.btn-add-address:hover { background: #333; transform: translateY(-2px); box-shadow: 0 6px 20px rgba(0,0,0,0.15); }
.btn-add-address svg { transition: transform 0.3s; }
.btn-add-address:hover svg { transform: rotate(90deg); }

/* 空状态 */
.empty-state { text-align: center; padding: 80px 20px; }
.empty-icon-wrap {
  width: 100px; height: 100px; margin: 0 auto 24px; border-radius: 50%;
  background: var(--bg-secondary, #f5f3f0); display: flex; align-items: center; justify-content: center;
  color: var(--accent, #c45c4a); position: relative;
}
.empty-icon-wrap::before {
  content: ''; position: absolute; width: 120px; height: 120px; border-radius: 50%;
  border: 1px dashed var(--border, #ece9e4);
}
.empty-title { font-size: 22px; font-weight: 600; margin-bottom: 8px; color: var(--text-primary, #1a1a1a); }
.empty-desc { color: var(--text-muted, #9a9a9a); font-size: 14px; margin-bottom: 24px; }

/* 地址卡片 */
.address-list { display: flex; flex-direction: column; gap: 16px; }
.address-card {
  background: var(--bg-card, #fff); border-radius: 16px;
  border: 1.5px solid var(--border, #ece9e4); padding: 28px;
  transition: all 0.3s ease;
}
.address-card:hover { box-shadow: 0 4px 20px rgba(0,0,0,0.06); border-color: #d0cbc4; transform: translateY(-2px); }
.address-card.default { border-color: rgba(196,92,74,0.3); background: linear-gradient(to right, #fff, #fdfbfb); }

.address-card-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
.address-user { display: flex; align-items: center; gap: 12px; }
.address-name { font-size: 17px; font-weight: 600; color: var(--text-primary, #1a1a1a); }
.address-phone { font-size: 14px; color: var(--text-secondary, #6b6b6b); }
.address-tags { display: flex; gap: 8px; align-items: center; }
.tag {
  padding: 4px 12px; border-radius: 100px; font-size: 11px; font-weight: 600; letter-spacing: 0.5px;
}
.tag-default { background: var(--bg-dark, #1a1a1a); color: white; }

.address-detail { font-size: 14px; color: var(--text-secondary, #6b6b6b); line-height: 1.7; margin-bottom: 20px; }
.address-detail .province { color: var(--text-primary, #1a1a1a); font-weight: 500; }

.address-actions {
  display: flex; align-items: center; justify-content: space-between;
  padding-top: 16px; border-top: 1px solid var(--border-light, #f3f1ed);
}
.address-action-btns { display: flex; gap: 8px; }
.btn-text {
  padding: 8px 16px; border-radius: 8px; border: none; background: transparent;
  color: var(--text-secondary, #6b6b6b); font-size: 13px; font-weight: 500; cursor: pointer;
}
.btn-text:hover { background: var(--bg-secondary, #f5f3f0); color: var(--text-primary, #1a1a1a); }
.btn-text-danger:hover { background: #fdf0ed; color: var(--accent, #c45c4a); }

.btn-set-default {
  padding: 8px 18px; border-radius: 100px; border: 1px solid var(--border, #ece9e4);
  background: transparent; color: var(--text-secondary, #6b6b6b);
  font-size: 12px; font-weight: 600; cursor: pointer;
}
.btn-set-default:hover { border-color: var(--accent, #c45c4a); color: var(--accent, #c45c4a); background: #fdf8f7; }

/* 添加地址卡片 */
.add-address-card {
  background: var(--bg-card, #fff); border-radius: 16px;
  border: 2px dashed var(--border, #ece9e4); padding: 36px;
  display: flex; flex-direction: column; align-items: center; gap: 12px;
  cursor: pointer; transition: all 0.3s; min-height: 160px;
}
.add-address-card:hover { border-color: var(--accent, #c45c4a); background: #fdf8f7; transform: translateY(-2px); }
.add-address-icon {
  width: 56px; height: 56px; border-radius: 50%; background: var(--bg-secondary, #f5f3f0);
  display: flex; align-items: center; justify-content: center; color: var(--accent, #c45c4a);
}
.add-address-card:hover .add-address-icon { background: var(--accent, #c45c4a); color: white; transform: scale(1.1); }
.add-address-text { font-size: 15px; font-weight: 600; color: var(--text-secondary, #6b6b6b); }
.add-address-card:hover .add-address-text { color: var(--accent, #c45c4a); }
.add-address-hint { font-size: 12px; color: var(--text-muted, #9a9a9a); }

/* 模态框 */
.modal-overlay {
  position: fixed; inset: 0; background: rgba(0,0,0,0.4); backdrop-filter: blur(4px);
  display: flex; align-items: center; justify-content: center; z-index: 1000;
  opacity: 0; visibility: hidden; transition: all 0.3s;
}
.modal-overlay.active { opacity: 1; visibility: visible; }
.modal {
  background: var(--bg-card, #fff); border-radius: 20px;
  width: 90%; max-width: 520px; max-height: 90vh; overflow-y: auto;
  padding: 36px;
  transform: translateY(20px) scale(0.96);
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
  box-shadow: 0 24px 80px rgba(0,0,0,0.15);
}
.modal-overlay.active .modal { transform: translateY(0) scale(1); }
.modal-header {
  display: flex; align-items: center; justify-content: space-between; margin-bottom: 28px;
}
.modal-title { font-size: 24px; font-weight: 600; color: var(--text-primary, #1a1a1a); }
.modal-close {
  width: 36px; height: 36px; border-radius: 50%; border: none;
  background: var(--bg-secondary, #f5f3f0); cursor: pointer; display: flex;
  align-items: center; justify-content: center; color: var(--text-secondary, #6b6b6b);
}
.modal-close:hover { background: var(--border, #ece9e4); transform: rotate(90deg); }

.form-group { margin-bottom: 20px; }
.form-label { display: block; font-size: 13px; font-weight: 600; color: var(--text-primary, #1a1a1a); margin-bottom: 8px; }
.form-input, .form-textarea {
  width: 100%; padding: 12px 16px; border-radius: 10px;
  border: 1.5px solid var(--border, #ece9e4); background: var(--bg-card, #fff);
  font-size: 14px; color: var(--text-primary, #1a1a1a); outline: none; box-sizing: border-box;
}
.form-input:focus, .form-textarea:focus { border-color: var(--accent, #c45c4a); box-shadow: 0 0 0 3px rgba(196,92,74,0.08); }

.area-selector {
  display: flex; align-items: center; justify-content: space-between;
  width: 100%; padding: 12px 16px; border-radius: 10px;
  border: 1.5px solid var(--border, #ece9e4); background: var(--bg-card, #fff);
  font-size: 14px; cursor: pointer; box-sizing: border-box;
}
.area-selector:hover { border-color: var(--accent, #c45c4a); }
.area-text { color: var(--text-primary, #1a1a1a); }
.area-placeholder { color: var(--text-muted, #9a9a9a); }
.area-selector svg { flex-shrink: 0; color: var(--text-muted, #9a9a9a); }
.form-textarea { resize: vertical; font-family: inherit; }
.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }

.tag-selector { display: flex; gap: 10px; }
.tag-option {
  padding: 8px 20px; border-radius: 100px; border: 1.5px solid var(--border, #ece9e4);
  background: transparent; font-size: 13px; font-weight: 500;
  color: var(--text-secondary, #6b6b6b); cursor: pointer;
}
.tag-option:hover { border-color: var(--accent, #c45c4a); color: var(--accent, #c45c4a); }
.tag-option.active { border-color: var(--accent, #c45c4a); background: rgba(196,92,74,0.06); color: var(--accent, #c45c4a); font-weight: 600; }

.checkbox-wrap { display: flex; align-items: center; gap: 10px; margin-top: 8px; }
.checkbox-wrap input[type="checkbox"] { width: 18px; height: 18px; accent-color: var(--accent, #c45c4a); cursor: pointer; }
.checkbox-wrap label { font-size: 13px; color: var(--text-secondary, #6b6b6b); cursor: pointer; }

.modal-footer {
  display: flex; justify-content: flex-end; gap: 12px;
  margin-top: 28px; padding-top: 24px; border-top: 1px solid var(--border, #ece9e4);
}
.btn {
  padding: 12px 28px; border-radius: 100px; font-size: 14px; font-weight: 600; cursor: pointer; border: none;
}
.btn-outline { background: transparent; border: 1px solid var(--border, #ece9e4); color: var(--text-secondary, #6b6b6b); }
.btn-outline:hover { border-color: var(--text-primary, #1a1a1a); color: var(--text-primary, #1a1a1a); }
.btn-primary { background: var(--bg-dark, #1a1a1a); color: white; }
.btn-primary:hover { background: #333; transform: translateY(-1px); box-shadow: 0 4px 16px rgba(0,0,0,0.15); }

/* ── 地区选择器(网页版) ── */
.area-modal-overlay {
  position: fixed; inset: 0; background: rgba(0,0,0,0.4); backdrop-filter: blur(4px);
  display: flex; align-items: center; justify-content: center; z-index: 1100;
}

.area-modal {
  background: var(--bg-card); border-radius: 16px; width: 680px; max-width: 92vw;
  max-height: 80vh; display: flex; flex-direction: column;
  box-shadow: 0 24px 80px rgba(0,0,0,0.15);
}

.area-modal-header {
  display: flex; align-items: center; justify-content: space-between;
  padding: 22px 28px 18px; border-bottom: 1px solid #f0eeeb;
}

.area-modal-header h3 { font-size: 17px; font-weight: 600; margin: 0; color: var(--text-primary); }

.area-modal-close {
  width: 32px; height: 32px; border-radius: 50%; border: none;
  background: var(--bg-secondary); cursor: pointer; display: flex;
  align-items: center; justify-content: center; color: var(--text-secondary);
}

.area-modal-close:hover { background: var(--border); }

.area-columns {
  display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 1px;
  background: #f0eeeb; flex: 1; min-height: 0; overflow: hidden;
}

.area-col {
  background: var(--bg-card); display: flex; flex-direction: column; min-height: 0;
}

.area-col-title {
  padding: 14px 20px 10px; font-size: 12px; font-weight: 600;
  color: var(--text-muted); text-transform: uppercase; letter-spacing: 1px;
  border-bottom: 1px solid #f5f3f0; flex-shrink: 0;
}

.area-list {
  overflow-y: auto; flex: 1; padding: 4px 0;
}

.area-item {
  display: block; width: 100%; text-align: left; padding: 10px 20px;
  border: none; background: transparent; font-size: 14px;
  color: #444; cursor: pointer; font-family: inherit;
  transition: all 0.15s;
}

.area-item:hover { background: #faf9f7; color: var(--text-primary); }
.area-item.active { background: #fdf1ef; color: #c45c4a; font-weight: 600; }

.area-modal-footer {
  padding: 16px 28px; border-top: 1px solid #f0eeeb;
  display: flex; justify-content: flex-end;
}

@media (max-width: 768px) {
  .address-page { padding: 16px 20px 40px; }
  .page-header-addr { flex-direction: column; align-items: flex-start; gap: 16px; }
  .form-row { grid-template-columns: 1fr; }
  .address-card { padding: 20px; }
  .address-actions { flex-direction: column; align-items: flex-start; gap: 12px; }
}
</style>
