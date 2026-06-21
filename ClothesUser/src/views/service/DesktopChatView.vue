<script setup lang="ts">
import { ref, nextTick, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showFailToast } from 'vant'
import { aiApi, type AiMessage } from '@/api/ai'

const router = useRouter()
const messages = ref<Array<AiMessage & { time: string }>>([])
const input = ref('')
const loading = ref(false)
const chatScroll = ref<HTMLElement | null>(null)
const productPanelOpen = ref(false)

const products = [
  { id: 1, brand: 'MAISON', name: '纯棉白色基础 T 恤', price: 129, image: '/assets/products/goods-3-chun-mian-bai-t.jpg' },
  { id: 2, brand: 'MAISON', name: '条纹休闲 Polo 衫', price: 249, image: '/assets/products/goods-2-tiao-wen-polo.jpg' },
  { id: 3, brand: 'MAISON', name: '法式碎花连衣裙', price: 459, image: '/assets/products/goods-22-fa-shi-sui-hua-qun.jpg' },
  { id: 4, brand: 'MAISON', name: '黑色修身半身裙', price: 329, image: '/assets/products/goods-23-hei-se-xiu-shen-qun.jpg' },
  { id: 5, brand: 'Nike', name: '复古运动休闲鞋', price: 599, image: '/assets/products/goods-42-fu-gu-yun-dong-xie.jpg' },
  { id: 6, brand: 'MAISON', name: '简约黑色手拿包', price: 289, image: '/assets/products/goods-58-jian-yue-hei-se-shou-na-bao.jpg' },
]

const quickQuestions = [
  '给我推荐几件夏季上衣',
  '怎么退换货？',
  '现在有什么优惠？',
  '这条裙子适合什么场合？',
]

const inspoTips = [
  '帮我搭一套通勤穿搭',
  '男生夏天怎么穿才好看？',
  '最近流行什么颜色？',
  '白色T恤怎么搭配不单调？',
]

function formatTime(): string {
  const now = new Date()
  return `${String(now.getHours()).padStart(2,'0')}:${String(now.getMinutes()).padStart(2,'0')}`
}

function addMessage(role: 'user' | 'assistant', content: string) {
  messages.value.push({ role, content, time: formatTime() })
}

async function send() {
  const text = input.value.trim()
  if (!text || loading.value) return
  input.value = ''
  loading.value = true
  addMessage('user', text)
  scrollToBottom()
  try {
    const list: AiMessage[] = messages.value.map(m => ({ role: m.role, content: m.content }))
    const data = await aiApi.chat(list)
    addMessage('assistant', data.reply)
  } catch (e: any) {
    addMessage('assistant', '抱歉，我现在有点忙不过来，请稍后再试～')
    showFailToast(e?.message || '请求失败')
  } finally {
    loading.value = false
    scrollToBottom()
  }
}

function sendQuick(text: string) {
  input.value = text
  // 让 textarea 自动调整高度
  nextTick(() => {
    const el = document.querySelector('.chat-input') as HTMLTextAreaElement
    if (el) { el.style.height = 'auto'; el.style.height = Math.min(el.scrollHeight, 120) + 'px' }
  })
  send()
}

function sendInspiration() {
  const tip = inspoTips[Math.floor(Math.random() * inspoTips.length)]
  input.value = tip
  nextTick(() => {
    const el = document.querySelector('.chat-input') as HTMLTextAreaElement
    if (el) { el.style.height = 'auto'; el.style.height = Math.min(el.scrollHeight, 120) + 'px' }
  })
}

function askAboutProduct(product: typeof products[0]) {
  input.value = `帮我介绍一下这款「${product.name}」，适合什么场合穿？`
  productPanelOpen.value = false
  nextTick(() => {
    const el = document.querySelector('.chat-input') as HTMLTextAreaElement
    if (el) { el.style.height = 'auto'; el.style.height = Math.min(el.scrollHeight, 120) + 'px' }
  })
  send()
}

function scrollToBottom() {
  nextTick(() => { chatScroll.value?.scrollTo({ top: chatScroll.value.scrollHeight, behavior: 'smooth' }) })
}

function handleKey(e: KeyboardEvent) {
  if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); send() }
}

function goBack() { router.back() }
function goHome() { router.push('/') }

onMounted(() => {
  // 初始消息
  addMessage('assistant', '欢迎来到 MAISON！我是你的专属时尚顾问，告诉我你喜欢什么风格，我来帮你挑～')
})
</script>

<template>
  <div class="chat-page">
    <!-- Header -->
    <header class="chat-header">
      <div class="chat-header-inner">
        <div class="chat-header-left">
          <button class="chat-back" @click="goBack" aria-label="返回">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M19 12H5M12 19l-7-7 7-7"/>
            </svg>
          </button>
          <div class="chat-brand">
            <div class="chat-brand-name" @click="goHome" style="cursor:pointer">MAISON</div>
            <div class="chat-brand-divider"></div>
            <div class="chat-brand-tagline">AI 时尚顾问</div>
          </div>
        </div>
        <div class="chat-header-right">
          <div class="chat-status">
            <span class="chat-status-dot"></span>
            在线中
          </div>
          <button class="chat-clear" @click="messages.splice(1)">清空对话</button>
        </div>
      </div>
    </header>

    <!-- Main -->
    <div class="chat-main">
      <!-- Product Sidebar -->
      <aside :class="['product-panel', { open: productPanelOpen }]">
        <div class="product-panel-header">
          <div class="product-panel-title">相关商品</div>
          <div class="product-panel-subtitle">点击商品可快速向 AI 顾问询问搭配、尺码或库存</div>
        </div>
        <div class="product-list">
          <div
            v-for="p in products"
            :key="p.id"
            class="product-card"
            @click="askAboutProduct(p)"
          >
            <img class="product-img" :src="p.image" :alt="p.name" loading="lazy"
              @error="($event.target as HTMLImageElement).src='/assets/placeholders/product-placeholder.svg'">
            <div class="product-info">
              <div class="product-brand">{{ p.brand }}</div>
              <div class="product-name">{{ p.name }}</div>
              <div class="product-bottom">
                <div class="product-price"><span class="unit">¥</span>{{ p.price }}</div>
                <span class="product-ask">问问 AI</span>
              </div>
            </div>
          </div>
        </div>
      </aside>
      <div :class="['panel-overlay', { open: productPanelOpen }]" @click="productPanelOpen = false"></div>

      <!-- Chat Area -->
      <div class="chat-area">
        <div class="chat-body" ref="chatScroll">
          <!-- Welcome Hero -->
          <div class="welcome-hero" v-if="messages.length <= 1">
            <div class="welcome-title">你好，我是你的 AI 时尚顾问 ✨</div>
            <div class="welcome-text">我可以帮你推荐搭配、查询商品、解答退换货问题。左侧挑选商品，或直接在这里输入你想咨询的问题。</div>
          </div>

          <!-- Quick Questions -->
          <div class="quick-section" v-if="messages.length <= 1">
            <div class="quick-label">你可以这样问我</div>
            <div class="quick-chips">
              <button v-for="q in quickQuestions" :key="q" class="quick-chip" @click="sendQuick(q)">{{ q }}</button>
            </div>
          </div>

          <!-- Messages -->
          <div class="messages" v-if="messages.length > 1 || loading">
            <div
              v-for="(msg, i) in messages.slice(1)"
              :key="i"
              :class="['message', msg.role === 'user' ? 'message-user' : 'message-ai']"
            >
              <div class="avatar" v-if="msg.role === 'assistant'">AI</div>
              <div class="bubble-wrap">
                <div class="bubble">{{ msg.content }}</div>
                <div class="message-time">{{ msg.time }}</div>
              </div>
              <div class="avatar avatar-user" v-if="msg.role === 'user'">U</div>
            </div>

            <!-- Typing -->
            <div class="message message-ai" v-if="loading">
              <div class="avatar">AI</div>
              <div class="bubble-wrap">
                <div class="bubble typing">
                  <span></span><span></span><span></span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Input -->
        <div class="input-area">
          <div class="input-inner">
            <button class="inspire-btn" @click="sendInspiration" aria-label="获取灵感">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M12 2l2.4 7.2h7.6l-6 4.8 2.4 7.2-6-4.8-6 4.8 2.4-7.2-6-4.8h7.6z"/>
              </svg>
            </button>
            <textarea
              v-model="input"
              class="chat-input"
              rows="1"
              placeholder="输入你想咨询的问题，或点击星星获取灵感..."
              @keydown="handleKey"
              :disabled="loading"
            ></textarea>
            <button class="send-btn" :disabled="!input.trim() || loading" @click="send" aria-label="发送">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/>
              </svg>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Mobile toggle -->
    <button class="mobile-toggle" @click="productPanelOpen = !productPanelOpen" aria-label="查看商品">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/>
      </svg>
    </button>
  </div>
</template>

<style scoped>
/* ── Layout ── */
.chat-page {
  display: flex;
  flex-direction: column;
  height: calc(100vh - 73px);
  background: #faf9f7;
  overflow: hidden;
}

/* ── Header ── */
.chat-header {
  flex-shrink: 0;
  height: 64px;
  background: rgba(250,249,247,0.94);
  backdrop-filter: blur(16px);
  border-bottom: 1px solid #e8e5e0;
  z-index: 20;
}
.chat-header-inner {
  max-width: 1440px;
  margin: 0 auto;
  padding: 0 28px;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.chat-header-left {
  display: flex;
  align-items: center;
  gap: 18px;
}
.chat-back {
  width: 38px; height: 38px;
  border-radius: 50%;
  border: 1px solid #e8e5e0;
  background: #fff;
  color: #666;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.25s;
}
.chat-back:hover { border-color: #c45c4a; color: #c45c4a; background: #fdf5f3; }
.chat-brand { display: flex; align-items: baseline; gap: 10px; }
.chat-brand-name {
  font-family: 'Cormorant Garamond', 'Noto Serif SC', serif;
  font-size: 26px; font-weight: 700; letter-spacing: 2px;
  color: #1a1a1a;
}
.chat-brand-divider { width: 1px; height: 18px; background: #d0cbc4; }
.chat-brand-tagline { font-size: 13px; color: #999; font-weight: 500; }
.chat-header-right { display: flex; align-items: center; gap: 16px; }
.chat-status {
  display: flex; align-items: center; gap: 7px;
  font-size: 12px; color: #2d8a5e; font-weight: 600;
  padding: 6px 12px; background: rgba(45,138,94,0.08);
  border-radius: 20px;
}
.chat-status-dot {
  width: 7px; height: 7px; border-radius: 50%;
  background: #2d8a5e;
  box-shadow: 0 0 0 3px rgba(45,138,94,0.12);
  animation: pulse 2s infinite;
}
@keyframes pulse { 0%,100%{opacity:1} 50%{opacity:0.55} }
.chat-clear {
  font-size: 12px; color: #999;
  background: transparent; border: 1px solid #e8e5e0;
  padding: 8px 14px; border-radius: 10px;
  cursor: pointer; transition: all 0.25s; font-weight: 500;
}
.chat-clear:hover { color: #c45c4a; border-color: #c45c4a; background: #fdf5f3; }

/* ── Main ── */
.chat-main {
  flex: 1; display: flex; overflow: hidden;
  max-width: 1440px; margin: 0 auto; width: 100%;
}

/* ── Product Panel ── */
.product-panel {
  width: 360px; flex-shrink: 0;
  background: #fff; border-right: 1px solid #e8e5e0;
  display: flex; flex-direction: column; overflow: hidden;
}
.product-panel-header {
  padding: 22px 24px 16px;
  border-bottom: 1px solid #e8e5e0;
}
.product-panel-title {
  font-family: 'Cormorant Garamond', 'Noto Serif SC', serif;
  font-size: 22px; font-weight: 600; color: #1a1a1a;
  margin-bottom: 6px;
}
.product-panel-subtitle {
  font-size: 12px; color: #999; line-height: 1.5;
}
.product-list {
  flex: 1; overflow-y: auto;
  padding: 16px 20px 24px;
  display: flex; flex-direction: column; gap: 14px;
}
.product-list::-webkit-scrollbar { width: 5px; }
.product-list::-webkit-scrollbar-thumb { background: #d0cbc4; border-radius: 3px; }
.product-card {
  display: flex; gap: 14px; padding: 12px;
  background: #faf9f7; border: 1px solid #e8e5e0;
  border-radius: 14px; cursor: pointer;
  transition: all 0.25s;
}
.product-card:hover {
  border-color: #e8a090; background: #fdf5f3;
  transform: translateY(-2px); box-shadow: 0 1px 3px rgba(0,0,0,0.04);
}
.product-card:active { transform: scale(0.98); }
.product-img {
  width: 72px; height: 72px; border-radius: 10px;
  object-fit: cover; background: #f5f3f0; flex-shrink: 0;
}
.product-info { flex: 1; min-width: 0; display: flex; flex-direction: column; justify-content: center; }
.product-brand { font-size: 11px; font-weight: 600; color: #c45c4a; letter-spacing: 0.5px; margin-bottom: 4px; }
.product-name {
  font-size: 13px; color: #1a1a1a; line-height: 1.4;
  margin-bottom: 8px; display: -webkit-box; -webkit-line-clamp: 2;
  -webkit-box-orient: vertical; overflow: hidden;
}
.product-bottom { display: flex; align-items: center; justify-content: space-between; }
.product-price { font-size: 15px; font-weight: 700; color: #c45c4a; }
.product-price .unit { font-size: 11px; font-weight: 600; margin-right: 1px; }
.product-ask {
  font-size: 11px; font-weight: 600; color: #666;
  padding: 5px 10px; border: 1px solid #e8e5e0;
  border-radius: 20px; background: #fff; transition: all 0.25s;
}
.product-card:hover .product-ask { border-color: #c45c4a; color: #c45c4a; background: #fff; }

.panel-overlay { display: none; }

/* ── Chat Area ── */
.chat-area {
  flex: 1; display: flex; flex-direction: column;
  overflow: hidden; background: #faf9f7;
}
.chat-body {
  flex: 1; overflow-y: auto;
  padding: 28px 32px 24px;
}
.chat-body::-webkit-scrollbar { width: 5px; }
.chat-body::-webkit-scrollbar-thumb { background: #d0cbc4; border-radius: 3px; }

/* Welcome Hero */
.welcome-hero {
  background: linear-gradient(135deg, #c45c4a 0%, #8b3a2a 100%);
  border-radius: 20px; padding: 28px 32px; color: white;
  margin-bottom: 24px; position: relative; overflow: hidden;
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
}
.welcome-hero::before {
  content: ''; position: absolute; right: -60px; top: -60px;
  width: 240px; height: 240px; border-radius: 50%;
  background: rgba(255,255,255,0.08); pointer-events: none;
}
.welcome-hero::after {
  content: ''; position: absolute; left: -30px; bottom: -30px;
  width: 150px; height: 150px; border-radius: 50%;
  background: rgba(255,255,255,0.05); pointer-events: none;
}
.welcome-title {
  font-family: 'Cormorant Garamond', 'Noto Serif SC', serif;
  font-size: 28px; font-weight: 700; margin-bottom: 10px;
  position: relative; z-index: 1;
}
.welcome-text {
  font-size: 13px; line-height: 1.7; opacity: 0.92;
  max-width: 520px; position: relative; z-index: 1;
}

/* Quick Questions */
.quick-section { margin-bottom: 26px; }
.quick-label {
  font-size: 11px; color: #999; font-weight: 600;
  letter-spacing: 0.8px; text-transform: uppercase; margin-bottom: 12px;
}
.quick-chips { display: flex; flex-wrap: wrap; gap: 10px; }
.quick-chip {
  padding: 9px 16px; border-radius: 24px;
  border: 1px solid #e8e5e0; background: #fff;
  color: #666; font-size: 13px; cursor: pointer;
  transition: all 0.25s; font-weight: 500;
}
.quick-chip:hover { border-color: #c45c4a; color: #c45c4a; background: #fdf5f3; transform: translateY(-1px); }
.quick-chip:active { transform: scale(0.96); }

/* Messages */
.messages { display: flex; flex-direction: column; gap: 18px; }
.message {
  display: flex; gap: 12px; max-width: 82%;
  animation: msgIn 0.4s cubic-bezier(0.22,1,0.36,1) both;
}
@keyframes msgIn {
  from { opacity: 0; transform: translateY(12px); }
  to { opacity: 1; transform: translateY(0); }
}
.message-user { align-self: flex-end; flex-direction: row-reverse; }
.message-ai { align-self: flex-start; }
.avatar {
  width: 38px; height: 38px; border-radius: 50%; flex-shrink: 0;
  display: flex; align-items: center; justify-content: center;
  font-size: 13px; font-weight: 700;
  font-family: 'Montserrat', 'Noto Sans SC', sans-serif;
}
.message-user .avatar { background: #f5f3f0; color: #666; }
.message-ai .avatar {
  background: linear-gradient(135deg, #c45c4a, #8b3a2a); color: white;
  box-shadow: 0 4px 12px rgba(196,92,74,0.25);
}
.bubble-wrap { display: flex; flex-direction: column; }
.bubble {
  padding: 13px 17px; border-radius: 14px;
  font-size: 14px; line-height: 1.7; word-break: break-word;
  white-space: pre-wrap;
}
.message-user .bubble {
  background: linear-gradient(135deg, #c45c4a 0%, #8b3a2a 100%);
  color: white; border-bottom-right-radius: 5px;
  box-shadow: 0 4px 14px rgba(196,92,74,0.22);
}
.message-ai .bubble {
  background: #fff; color: #1a1a1a;
  border: 1px solid #e8e5e0; border-bottom-left-radius: 5px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.04);
}
.message-time {
  font-size: 11px; color: #999; margin-top: 6px; padding: 0 5px;
}
.message-user .message-time { text-align: right; }

/* Typing */
.typing { display: flex; align-items: center; gap: 5px; padding: 4px 0; }
.typing span {
  width: 7px; height: 7px; border-radius: 50%;
  background: #999; animation: typing 1.4s infinite both;
}
.typing span:nth-child(1) { animation-delay: -0.32s; }
.typing span:nth-child(2) { animation-delay: -0.16s; }
@keyframes typing {
  0%,80%,100% { transform: scale(0.6); opacity: 0.3; }
  40% { transform: scale(1); opacity: 1; }
}

/* ── Input ── */
.input-area {
  flex-shrink: 0;
  background: rgba(250,249,247,0.96);
  backdrop-filter: blur(12px);
  border-top: 1px solid #e8e5e0;
  padding: 14px 32px 24px;
}
.input-inner {
  max-width: 720px; margin: 0 auto;
  display: flex; gap: 12px; align-items: flex-end;
}
.chat-input {
  flex: 1; min-height: 50px; max-height: 130px;
  border: 1.5px solid #e8e5e0; border-radius: 26px;
  background: #fff; padding: 12px 20px;
  font-family: inherit; font-size: 14px; line-height: 1.6;
  color: #1a1a1a; outline: none; resize: none;
  transition: all 0.25s; box-shadow: 0 1px 3px rgba(0,0,0,0.04);
}
.chat-input:focus { border-color: #c45c4a; box-shadow: 0 0 0 4px rgba(196,92,74,0.08); }
.chat-input::placeholder { color: #999; }
.chat-input:disabled { opacity: 0.6; }
.inspire-btn {
  width: 50px; height: 50px; border-radius: 50%; border: none;
  background: #fff; color: #999; cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  transition: all 0.25s; flex-shrink: 0;
  border: 1.5px solid #e8e5e0; box-shadow: 0 1px 3px rgba(0,0,0,0.04);
}
.inspire-btn:hover { border-color: #c45c4a; color: #c45c4a; background: #fdf5f3; transform: rotate(15deg); }
.inspire-btn:active { transform: scale(0.95); }
.send-btn {
  width: 50px; height: 50px; border-radius: 50%; border: none;
  background: #c45c4a; color: white; cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  transition: all 0.25s; flex-shrink: 0;
  box-shadow: 0 4px 14px rgba(196,92,74,0.28);
}
.send-btn:hover { background: #8b3a2a; transform: translateY(-2px); }
.send-btn:active { transform: scale(0.95); }
.send-btn:disabled { background: #e8e5e0; cursor: not-allowed; box-shadow: none; transform: none; }

/* Mobile Toggle */
.mobile-toggle {
  display: none; position: fixed; left: 16px; bottom: 90px;
  z-index: 30; width: 44px; height: 44px; border-radius: 50%;
  background: #c45c4a; color: white; border: none;
  box-shadow: 0 4px 12px rgba(0,0,0,0.12);
  cursor: pointer; align-items: center; justify-content: center;
}

/* ── Responsive ── */
@media (max-width: 1024px) {
  .product-panel { width: 300px; }
  .chat-body { padding: 22px 24px 24px; }
  .input-area { padding: 14px 24px 20px; }
}

@media (max-width: 768px) {
  .chat-header-inner { padding: 0 16px; }
  .chat-brand-divider, .chat-brand-tagline, .chat-status { display: none; }
  .chat-brand-name { font-size: 22px; }
  .chat-clear { padding: 6px 10px; }

  .product-panel {
    position: fixed; left: 0; top: 64px; bottom: 0;
    width: 85%; max-width: 320px; z-index: 25;
    transform: translateX(-100%);
    transition: transform 0.35s cubic-bezier(0.22,1,0.36,1);
    box-shadow: 0 12px 32px rgba(0,0,0,0.10);
  }
  .product-panel.open { transform: translateX(0); }
  .panel-overlay {
    display: block; position: fixed; inset: 64px 0 0 0;
    background: rgba(0,0,0,0.25); z-index: 24; opacity: 0;
    pointer-events: none; transition: opacity 0.35s;
  }
  .panel-overlay.open { opacity: 1; pointer-events: auto; }
  .mobile-toggle { display: flex; }

  .chat-body { padding: 18px 16px 20px; }
  .input-area { padding: 12px 16px 20px; }
  .message { max-width: 92%; }
  .welcome-hero { padding: 22px 22px; }
  .welcome-title { font-size: 24px; }
}
</style>
