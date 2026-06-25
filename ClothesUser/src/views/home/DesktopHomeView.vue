<script setup lang="ts">
import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { publicApi } from '@/api/public'
import { favoriteApi } from '@/api/favorite'
import { fullImgUrl, IMG_PLACEHOLDER } from '@/utils/img'
import { useUserStore } from '@/stores/user'
import * as THREE from 'three'
import DesktopLayout from '@/components/desktop/DesktopLayout.vue'

const router = useRouter()
const userStore = useUserStore()

let orbInstances: any[] = []

const banners = ref<any[]>([])
const bannersLoaded = ref(false)
const activeBanner = ref(0)
let bannerTimer: any = null

const categories = ref<any[]>([])
const hotGoods = ref<any[]>([])
const newGoods = ref<any[]>([])
const allGoods = ref<any[]>([])
const bentoLayouts = [
  { cls: 'large', badge: 'FLAGSHIP' },
  { cls: 'tall', badge: 'TOP' },
  { cls: '', badge: 'NEW' },
  { cls: '', badge: 'HOT' },
  { cls: 'wide', badge: 'PRO' },
  { cls: '', badge: 'TABLET' },
  { cls: '', badge: 'VR' },
  { cls: '', badge: 'GEAR' },
  { cls: '', badge: 'AUDIO' },
  { cls: 'tall', badge: 'SMART' },
  { cls: '', badge: 'WEAR' },
  { cls: 'wide', badge: 'ACCESS' },
]

// 收藏
const wishlistSet = ref(new Set<number>())
async function loadWishlist() {
  if (!userStore.isLoggedIn) return
  try {
    const data: any = await favoriteApi.list(1, 100)
    const ids = (data?.list || []).map((x: any) => Number(x.goodsId))
    wishlistSet.value = new Set(ids)
  } catch { /* silent */ }
}
async function toggleWishlist(g: any) {
  if (!userStore.isLoggedIn) { router.push({ name: 'login', query: { redirect: '/user/favorites' } }); return }
  const id = Number(g.id); const s = new Set(wishlistSet.value); const liked = s.has(id)
  try {
    if (liked) { await favoriteApi.remove(id); s.delete(id) }
    else { await favoriteApi.add(id); s.add(id) }
    wishlistSet.value = s
  } catch { showToast(liked ? '取消收藏失败' : '收藏失败') }
}

// 秒杀
const flashGoods = ref<any[]>([])
const countdown = ref({ h: '02', m: '15', s: '43' })
let countdownTimer: any = null

// 倒计时
function startCountdown() {
  let total = (2 * 60 + 15) * 60 + 43
  countdownTimer = setInterval(() => {
    if (total <= 0) total = (2 * 60 + 15) * 60 + 43
    total--
    const h = Math.floor(total / 3600), m = Math.floor((total % 3600) / 60), s = total % 60
    countdown.value = { h: String(h).padStart(2,'0'), m: String(m).padStart(2,'0'), s: String(s).padStart(2,'0') }
  }, 1000)
}

// 工具函数
function priceFmt(p: any) { return Number(p || 0).toFixed(2) }
function displayPrice(g: any) {
  if (g.minPrice && g.maxPrice && Number(g.minPrice) !== Number(g.maxPrice)) {
    return '¥' + priceFmt(g.minPrice) + ' - ¥' + priceFmt(g.maxPrice)
  }
  return '¥' + priceFmt(g.price || g.minPrice)
}
function pct(orig: any, cur: any) {
  const o = Number(orig), c = Number(cur)
  if (!o || o <= c) return 0
  return Math.round((1 - c / o) * 100)
}
function cover(g: any) { return fullImgUrl(g.cover) }
function goGoods(id: number) { router.push({ name: 'goodsDetail', params: { id } }) }

// ── Three.js 等离子球体 ──
const orbNoiseFns = `
  vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
  vec4 mod289(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
  vec4 permute(vec4 x) { return mod289(((x*34.0)+1.0)*x); }
  vec4 taylorInvSqrt(vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }
  float snoise(vec3 v) {
    const vec2 C = vec2(1.0/6.0, 1.0/3.0);
    const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);
    vec3 i = floor(v + dot(v, C.yyy));
    vec3 x0 = v - i + dot(i, C.xxx);
    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min(g.xyz, l.zxy);
    vec3 i2 = max(g.xyz, l.zxy);
    vec3 x1 = x0 - i1 + C.xxx;
    vec3 x2 = x0 - i2 + C.yyy;
    vec3 x3 = x0 - D.yyy;
    i = mod289(i);
    vec4 p = permute(permute(permute(i.z + vec4(0.0,i1.z,i2.z,1.0)) + i.y + vec4(0.0,i1.y,i2.y,1.0)) + i.x + vec4(0.0,i1.x,i2.x,1.0));
    float n_ = 0.142857142857;
    vec3 ns = n_ * D.wyz - D.xzx;
    vec4 j = p - 49.0 * floor(p * ns.z * ns.z);
    vec4 x_ = floor(j * ns.z);
    vec4 y_ = floor(j - 7.0 * x_);
    vec4 x = x_ * ns.x + ns.yyyy;
    vec4 y = y_ * ns.x + ns.yyyy;
    vec4 h = 1.0 - abs(x) - abs(y);
    vec4 b0 = vec4(x.xy, y.xy);
    vec4 b1 = vec4(x.zw, y.zw);
    vec4 s0 = floor(b0)*2.0 + 1.0;
    vec4 s1 = floor(b1)*2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));
    vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy;
    vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww;
    vec3 p0 = vec3(a0.xy, h.x);
    vec3 p1 = vec3(a0.zw, h.y);
    vec3 p2 = vec3(a1.xy, h.z);
    vec3 p3 = vec3(a1.zw, h.w);
    vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2,p2), dot(p3,p3)));
    p0 *= norm.x; p1 *= norm.y; p2 *= norm.z; p3 *= norm.w;
    vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
    m = m * m;
    return 42.0 * dot(m*m, vec4(dot(p0,x0), dot(p1,x1), dot(p2,x2), dot(p3,x3)));
  }
  float fbm(vec3 p) {
    float total = 0.0, amplitude = 0.5, frequency = 1.0;
    for (int i = 0; i < 3; i++) { total += snoise(p*frequency)*amplitude; amplitude *= 0.5; frequency *= 2.0; }
    return total;
  }
`

function createOrbScene(container: HTMLElement) {
  const width = container.clientWidth || 300
  const height = container.clientHeight || 300

  const scene = new THREE.Scene()
  const camera = new THREE.PerspectiveCamera(75, width / height, 0.1, 100)
  camera.position.z = 2.4

  const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true })
  renderer.setSize(width, height)
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
  renderer.toneMapping = THREE.ACESFilmicToneMapping
  renderer.toneMappingExposure = 0.9
  container.appendChild(renderer.domElement)

  const mainGroup = new THREE.Group()
  scene.add(mainGroup)

  const pointLight = new THREE.PointLight(0x0088ff, 2.0, 10)
  mainGroup.add(pointLight)

  // Shell shader
  const shellVert = `varying vec3 vNormal; varying vec3 vViewPosition; void main() { vNormal = normalize(normalMatrix * normal); vec4 mvPosition = modelViewMatrix * vec4(position, 1.0); vViewPosition = -mvPosition.xyz; gl_Position = projectionMatrix * mvPosition; }`
  const shellFrag = `varying vec3 vNormal; varying vec3 vViewPosition; uniform vec3 uColor; uniform float uOpacity; void main() { float fresnel = pow(1.0 - dot(normalize(vNormal), normalize(vViewPosition)), 2.5); gl_FragColor = vec4(uColor, fresnel * uOpacity); }`

  const shellGeo = new THREE.SphereGeometry(1.0, 64, 64)
  mainGroup.add(new THREE.Mesh(shellGeo, new THREE.ShaderMaterial({ vertexShader: shellVert, fragmentShader: shellFrag, uniforms: { uColor: { value: new THREE.Color(0x000055) }, uOpacity: { value: 0.3 } }, transparent: true, blending: THREE.AdditiveBlending, side: THREE.BackSide, depthWrite: false })))
  mainGroup.add(new THREE.Mesh(shellGeo, new THREE.ShaderMaterial({ vertexShader: shellVert, fragmentShader: shellFrag, uniforms: { uColor: { value: new THREE.Color(0x0066ff) }, uOpacity: { value: 0.41 } }, transparent: true, blending: THREE.AdditiveBlending, side: THREE.FrontSide, depthWrite: false })))

  // Plasma
  const plasmaGeo = new THREE.SphereGeometry(0.998, 128, 128)
  const plasmaMat = new THREE.ShaderMaterial({
    uniforms: {
      uTime: { value: 0 }, uScale: { value: 0.2 }, uBrightness: { value: 1.31 }, uThreshold: { value: 0.09 },
      uColorDeep: { value: new THREE.Color(0x001433) }, uColorMid: { value: new THREE.Color(0x0084ff) }, uColorBright: { value: new THREE.Color(0x00ffe1) },
      uMouse: { value: new THREE.Vector3(0, 0, 0) }, uMouseStrength: { value: 0 }
    },
    vertexShader: `varying vec3 vPosition; varying vec3 vNormal; varying vec3 vViewPosition; varying vec3 vWorldPos; void main() { vPosition = position; vNormal = normalize(normalMatrix * normal); vec4 mvPosition = modelViewMatrix * vec4(position, 1.0); vViewPosition = -mvPosition.xyz; vec4 worldPos = modelMatrix * vec4(position, 1.0); vWorldPos = worldPos.xyz; gl_Position = projectionMatrix * mvPosition; }`,
    fragmentShader: `uniform float uTime, uScale, uBrightness, uThreshold; uniform vec3 uColorDeep, uColorMid, uColorBright; uniform vec3 uMouse; uniform float uMouseStrength; varying vec3 vPosition, vNormal, vViewPosition, vWorldPos; ${orbNoiseFns} void main() { vec3 p = vPosition * uScale; vec3 q = vec3(fbm(p + vec3(0.0, uTime*0.05, 0.0)), fbm(p + vec3(5.2,1.3,2.8) + uTime*0.05), fbm(p + vec3(2.2,8.4,0.5) - uTime*0.02)); float density = fbm(p + 2.0*q); /* 水滴涟漪：鼠标位置产生波纹形变 */ float ripple = 0.0; if (uMouseStrength > 0.01) { float d = distance(vWorldPos, uMouse); ripple = sin(d * 20.0 - uTime * 4.0) * uMouseStrength * exp(-d * 3.0); density += ripple * 0.15; } float t = (density + 0.4)*0.8; float alpha = smoothstep(uThreshold, 0.7, t); vec3 color = mix(uColorDeep, uColorMid, smoothstep(uThreshold, 0.5, t)); color = mix(color, uColorBright, smoothstep(0.5, 0.8, t)); color = mix(color, vec3(1.0), smoothstep(0.8, 1.0, t)); float facing = dot(normalize(vNormal), normalize(vViewPosition)); gl_FragColor = vec4(color*uBrightness, alpha*(0.02+0.98*((facing+1.0)*0.5))); }`,
    transparent: true, blending: THREE.AdditiveBlending, side: THREE.DoubleSide, depthWrite: false
  })
  const plasmaMesh = new THREE.Mesh(plasmaGeo, plasmaMat)
  mainGroup.add(plasmaMesh)

  // Particles
  const pCount = 600
  const pPos = new Float32Array(pCount * 3), pSizes = new Float32Array(pCount)
  for (let i = 0; i < pCount; i++) {
    const r = 0.95 * Math.cbrt(Math.random()), theta = Math.random() * Math.PI * 2, phi = Math.acos(2 * Math.random() - 1)
    pPos[i*3] = r * Math.sin(phi) * Math.cos(theta); pPos[i*3+1] = r * Math.sin(phi) * Math.sin(theta); pPos[i*3+2] = r * Math.cos(phi)
    pSizes[i] = Math.random()
  }
  const pGeo = new THREE.BufferGeometry()
  pGeo.setAttribute('position', new THREE.BufferAttribute(pPos, 3))
  pGeo.setAttribute('aSize', new THREE.BufferAttribute(pSizes, 1))
  const pMat = new THREE.ShaderMaterial({
    uniforms: { uTime: { value: 0 }, uColor: { value: new THREE.Color(0xffffff) } },
    vertexShader: `uniform float uTime; attribute float aSize; varying float vAlpha; void main() { vec3 pos = position; pos.y += sin(uTime*0.2+pos.x)*0.02; pos.x += cos(uTime*0.15+pos.z)*0.02; vec4 mvPosition = modelViewMatrix * vec4(pos, 1.0); gl_PointSize = (8.0*aSize+4.0)*(1.0/-mvPosition.z); gl_Position = projectionMatrix*mvPosition; vAlpha = 0.8+0.2*sin(uTime+aSize*10.0); }`,
    fragmentShader: `uniform vec3 uColor; varying float vAlpha; void main() { vec2 uv = gl_PointCoord-vec2(0.5); float dist = length(uv); if(dist>0.5)discard; float glow = pow(1.0-dist*2.0, 1.8); gl_FragColor = vec4(uColor, glow*vAlpha); }`,
    transparent: true, blending: THREE.AdditiveBlending, depthWrite: false
  })
  mainGroup.add(new THREE.Points(pGeo, pMat))

  // Animation
  const clock = new THREE.Clock()
  let running = true, animId = 0
  let targetRotX = 0, targetRotY = 0
  let isDragging = false
  function animate() {
    if (!running) return
    animId = requestAnimationFrame(animate)
    const t = clock.getElapsedTime()
    plasmaMat.uniforms.uTime.value = t * 1.2
    pMat.uniforms.uTime.value = t
    plasmaMesh.rotation.y = t * 0.08

    if (isDragging) {
      mainGroup.rotation.x += (targetRotX - mainGroup.rotation.x) * 0.15
      mainGroup.rotation.y += (targetRotY - mainGroup.rotation.y) * 0.15
    } else {
      mainGroup.rotation.x += 0.002
      mainGroup.rotation.y += 0.005
      targetRotX = mainGroup.rotation.x
      targetRotY = mainGroup.rotation.y
    }

    renderer.render(scene, camera)
  }
  animate()

  const ro = new ResizeObserver(() => {
    const w = container.clientWidth, h = container.clientHeight
    if (w > 0 && h > 0) { camera.aspect = w / h; camera.updateProjectionMatrix(); renderer.setSize(w, h) }
  })
  ro.observe(container)

  // Mouse interaction — 拖拽交互
  const onDown = (e: MouseEvent) => {
    isDragging = true
    const rect = container.getBoundingClientRect()
    targetRotY = ((e.clientX - rect.left) / rect.width - 0.5) * 0.5
    targetRotX = ((e.clientY - rect.top) / rect.height - 0.5) * -0.3
  }
  const onMove = (e: MouseEvent) => {
    if (!isDragging) return
    const rect = container.getBoundingClientRect()
    targetRotY = ((e.clientX - rect.left) / rect.width - 0.5) * 0.5
    targetRotX = ((e.clientY - rect.top) / rect.height - 0.5) * -0.3
    // Ripple
    const x = (e.clientX - rect.left) / rect.width - 0.5
    const y = (e.clientY - rect.top) / rect.height - 0.5
    mouseStrength = Math.min(1, mouseStrength + 0.15)
    mouse.x = ((e.clientX - rect.left) / rect.width) * 2 - 1
    mouse.y = -((e.clientY - rect.top) / rect.height) * 2 + 1
    ray.setFromCamera(mouse, camera)
    const intersects = ray.intersectObject(plasmaMesh)
    if (intersects.length > 0) {
      plasmaMat.uniforms.uMouse.value.copy(intersects[0].point)
    }
  }
  const onUp = () => { isDragging = false; mouseStrength = 0 }
  container.addEventListener('mousedown', onDown)
  container.addEventListener('mousemove', onMove)
  container.addEventListener('mouseup', onUp)
  container.addEventListener('mouseleave', onUp)

  return { renderer, container, running, setRunning(v: boolean) { running = v }, stop() { running = false; container.removeEventListener('mousedown', onDown); container.removeEventListener('mousemove', onMove); container.removeEventListener('mouseup', onUp); container.removeEventListener('mouseleave', onUp) }, ro, animId }
}

function initHeroOrbs() {
  const containers = document.querySelectorAll('[data-three-orb]')
  containers.forEach(el => {
    const instance = createOrbScene(el as HTMLElement)
    // Pause when not visible
    const io = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) { instance.setRunning(true); if (!instance.running) { instance.setRunning(true); } }
        else { instance.setRunning(false) }
      })
    }, { threshold: 0.01 })
    io.observe(el)
    orbInstances.push({ ...instance, io })
  })
}
function goCategory(id?: number) {
  if (id) router.push({ name: 'categoryGoods', params: { id } })
  else router.push({ name: 'category' })
}

// 轮播自动切换
function nextBanner() {
  if (banners.value.length) activeBanner.value = (activeBanner.value + 1) % banners.value.length
}
function prevBanner() {
  if (banners.value.length) activeBanner.value = (activeBanner.value - 1 + banners.value.length) % banners.value.length
}
function startBannerAuto() {
  bannerTimer = setInterval(nextBanner, 4500)
}
function stopBannerAuto() { if (bannerTimer) clearInterval(bannerTimer) }

// 数据加载
async function loadBanners() {
  try { banners.value = (await publicApi.banners()) || [] } catch { /* silent */ }
  if (banners.value.length) bannersLoaded.value = true
}
async function loadCategories() {
  try {
    const data: any = await publicApi.categories()
    categories.value = (data || []).filter((c: any) => Number(c.parentId) === 0).slice(0, 6)
  } catch { /* silent */ }
}
async function loadHot() { try { hotGoods.value = (await publicApi.hotGoods()) || [] } catch { /* silent */ } }
async function loadNew() { try { newGoods.value = (await publicApi.newGoods()) || [] } catch { /* silent */ } }
async function loadAll() {
  try {
    const data: any = await publicApi.goodsList({ page: 1, size: 50, sort: 'create_time_desc' })
    allGoods.value = data?.list || data || []
  } catch { /* silent */ }
}

function buildFlash() {
  flashGoods.value = hotGoods.value.filter((g: any) => g.originalPrice && Number(g.originalPrice) > Number(g.minPrice || g.price)).slice(0, 5)
  if (flashGoods.value.length < 3) flashGoods.value = hotGoods.value.slice(0, 5)
}

onMounted(async () => {
  await Promise.all([loadBanners(), loadCategories(), loadHot(), loadNew(), loadAll()])
  buildFlash()
  startCountdown()
  loadWishlist()
  startBannerAuto()
  await nextTick()
  initHeroOrbs()
  // GSAP 滚动路径
  setTimeout(() => {
    const g = (window as any).gsap
    const st = (window as any).ScrollTrigger
    if (!g || !st) return
    g.registerPlugin(st)
    g.to('body', {
      scrollTrigger: {
        trigger: 'body', start: 'top top', end: 'bottom bottom', scrub: true,
        onUpdate: (self: any) => {
          const p = -(2400 * self.progress)
          g.set('body', { '--strokeDashoffset': p })
        }
      }
    })
  }, 600)
})
onUnmounted(() => {
  clearInterval(countdownTimer)
  stopBannerAuto()
  orbInstances.forEach((inst: any) => {
    inst.stop()
    inst.ro?.disconnect()
    inst.io?.disconnect()
    inst.renderer?.dispose()
  })
  orbInstances = []
})
</script>

<template>
  <DesktopLayout>
  <div class="home">
    <!-- SVG 路径定义 -->
    <svg width="0" height="0" role="none" style="position:absolute;">
      <defs>
        <path id="linePath02" d="m 33,85h 444c 96,0 190,107 190,201v 224c 0,116 -98,188 -190,187l -192,-2c -92,0 -166,75 -166,168v 278c 0,94 74,169 166,169h 194c 92,0 188,94 188,188v 228c 0,94 -104,191 -214,191H 105" />
        <path id="linePath03" d="m 155,127h 308c 94,0 162,86 162,177v 178c 0,109 -50,174 -166,173L 277,653C 158,653 77,762 77,849v 302c 0,118 107,196 180,197l 204,4c 92,0 164,67 164,160v 200c 0,91 -89,163 -188,163H 105" />
        <path id="linePath04" d="m 283,173c 2,0 165,0 165,0C 544,175 577,238 577,330v 156c 0,94 -48,126 -140,125L 269,609C 167,602 29,702 29,851v 312c 0,111 101,235 242,235h 162c 109,1 144,49 144,136v 162c 0,73 -53,130 -118,130l -353,1" />
        <linearGradient id="cl1" gradientUnits="objectBoundingBox" x1="0" y1="0" x2="1" y2="1">
          <stop offset="20%" stop-color="#b169db"/>
          <stop offset="45%" stop-color="#f7d152"/>
          <stop offset="65%" stop-color="#46cf71"/>
          <stop offset="85%" stop-color="#0fbffa"/>
          <stop offset="100%" stop-color="#0fbffa"/>
        </linearGradient>
      </defs>
    </svg>

    <!-- 丝滑滚动路径背景 -->
    <div class="scroll-lines-bg">
      <svg width="100%" height="100%" viewBox="0 0 740 2000" xmlns="http://www.w3.org/2000/svg">
        <use href="#linePath02" />
        <use href="#linePath03" />
        <use href="#linePath04" />
      </svg>
    </div>
    <div class="scroll-lines-blur"></div>

    <!-- 全屏 HERO 轮播 -->
    <section class="hero">
      <div class="hero-bg"></div>
      <div class="hero-grid-lines"></div>

      <div class="hero-slides">
        <div v-for="(b, i) in banners.slice(0, 8)" :key="b.id || i"
          class="hero-slide" :class="{ active: activeBanner === i }">
          <div class="hero-slide-bg" :style="{ backgroundImage: 'url(' + fullImgUrl(b.image) + ')' }"></div>
          <div class="hero-slide-content">
            <div>
              <div class="hero-tag"><span class="pulse"></span> {{ ['NEW COLLECTION 2026','WORKSTATION SERIES','SMART LIVING','AUDIO EXPERIENCE','GAMING PRO'][i % 5] }}</div>
              <h1 class="hero-title">{{ ['定义你的','释放无限','连接未来','沉浸声场','主宰战场'][i % 5] }}<br><span class="gradient">{{ ['数字生活方式','创作生产力','智能生活方式','听觉新维度','电竞新境界'][i % 5] }}</span></h1>
              <p class="hero-desc">{{ b.title || ['从旗舰手机到专业工作站，从智能穿戴到沉浸式影音。NEXUS 汇聚全球前沿科技。','专业级性能，为设计师、开发者、创作者打造终极工作站。','全屋智能 · 健康监测 · AI 助手。让科技融入生活的每个角落。','从高解析度音频到空间音频，重新定义你的听觉世界。','240Hz · 1ms · RTX 5090。为胜利而生的终极装备。'][i % 5] }}</p>
              <div class="hero-btns">
                <button class="btn-primary" @click="goCategory()">探索新品 <span class="btn-arrow">→</span></button>
                <button class="btn-secondary" @click="goCategory()">浏览分类</button>
              </div>
            </div>
            <div class="hero-slide-visual">
              <div class="three-orb-wrap" data-three-orb></div>
            </div>
          </div>
        </div>
      </div>

      <div class="hero-arrows">
        <button class="hero-arrow hero-prev" @click="prevBanner">‹</button>
        <button class="hero-arrow hero-next" @click="nextBanner">›</button>
      </div>
      <div class="hero-dots">
        <span v-for="i in banners.length" :key="i"
          :class="['hero-dot', { active: i-1 === activeBanner }]"
          @click="activeBanner = i-1" />
      </div>
      <div class="hero-scroll">
        <div class="mouse"><div class="mouse-wheel"></div></div>
        <span>SCROLL</span>
      </div>
    </section>

    <!-- 品牌信任条（在分类之前） -->
    <section class="brand-strip">
      <div class="brand-track">
        <span class="brand-item">APPLE</span><span class="brand-item">SAMSUNG</span><span class="brand-item">SONY</span>
        <span class="brand-item">XIAOMI</span><span class="brand-item">HUAWEI</span><span class="brand-item">BOSE</span>
        <span class="brand-item">META</span><span class="brand-item">GARMIN</span><span class="brand-item">DJI</span>
        <span class="brand-item">LG</span><span class="brand-item">ASUS</span><span class="brand-item">DELL</span>
        <span class="brand-item">APPLE</span><span class="brand-item">SAMSUNG</span><span class="brand-item">SONY</span>
        <span class="brand-item">XIAOMI</span><span class="brand-item">HUAWEI</span><span class="brand-item">BOSE</span>
        <span class="brand-item">META</span><span class="brand-item">GARMIN</span><span class="brand-item">DJI</span>
        <span class="brand-item">LG</span><span class="brand-item">ASUS</span><span class="brand-item">DELL</span>
      </div>
    </section>

    <!-- 快捷分类 -->
    <section class="cats" v-if="categories.length">
      <div class="cats-grid">
        <div v-for="c in categories" :key="c.id" class="cat-card reveal" @click="goCategory(c.id)">
          <div class="cat-icon-wrap"><span>{{ ['💻','📱','🎧','⌚','📷','🎮'][categories.indexOf(c) % 6] }}</span></div>
          <div class="cat-name">{{ c.name }}</div>
        </div>
      </div>
    </section>

    <!-- BENTO GRID 精选产品 -->
    <section class="bento-section reveal">
      <div class="sec-header">
        <div class="sec-title"><div class="bar"></div>BENTO <span>SELECTION</span></div>
        <div class="sec-more" @click="goCategory()">查看全部 &#8594;</div>
      </div>
      <div class="bento-grid">
        <div
          v-for="(item, idx) in allGoods.slice(0, bentoLayouts.length)"
          :key="item?.id || idx"
          class="bento-item"
          :class="[bentoLayouts[idx].cls, 'reveal']"
          @click="goGoods(item?.id)"
        >
          <div class="bento-img"><img :src="cover(item)" alt="" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" /></div>
          <div class="bento-overlay"></div>
          <div class="bento-content">
            <div class="bento-badge">{{ bentoLayouts[idx].badge }}</div>
            <div class="bento-brand">{{ item?.brand || '' }}</div>
            <div class="bento-name">{{ item?.name || '' }}</div>
            <div class="bento-price">{{ item ? displayPrice(item) : '' }}</div>
          </div>
        </div>
      </div>
    </section>

    <!-- 横向滚动推荐 -->
    <section class="scroll-section" v-if="newGoods.length">
      <div class="scroll-header">
        <div class="scroll-title">NEW ARRIVALS</div>
        <div class="sec-more" @click="goCategory()">查看全部 &#8594;</div>
      </div>
      <div class="scroll-track">
          <div v-for="g in newGoods" :key="g.id" class="sitem" @click="goGoods(g.id)">
            <div class="sitem-img"><img :src="cover(g)" alt="" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" /></div>
            <div class="sitem-body">
              <div class="sitem-name">{{ g.name }}</div>
              <div class="sitem-price">{{ displayPrice(g) }}</div>
            </div>
          </div>
          <!-- 重复一份实现无缝滚动 -->
          <div v-for="g in newGoods" :key="'s'+g.id" class="sitem" @click="goGoods(g.id)">
            <div class="sitem-img"><img :src="cover(g)" alt="" @error="($event.target as HTMLImageElement).src = IMG_PLACEHOLDER" /></div>
            <div class="sitem-body">
              <div class="sitem-name">{{ g.name }}</div>
              <div class="sitem-price">{{ displayPrice(g) }}</div>
            </div>
          </div>
        </div>
    </section>

    <!-- 促销横幅 -->
    <section class="promo">
      <div class="promo-card p1" @click="goCategory(1)">
        <div>
          <h3>数码配件狂欢</h3>
          <p>充电保护 · 一应俱全</p>
          <span class="promo-tag">限时 8 折</span>
        </div>
      </div>
      <div class="promo-card p2" @click="goCategory(4)">
        <div>
          <h3>智能穿戴新品</h3>
          <p>科技随行 · 健康生活</p>
          <span class="promo-tag">满 199 减 30</span>
        </div>
      </div>
    </section>

    <!-- 服务保障 -->
    <section class="service">
      <div class="svc-grid">
        <div class="svc"><div class="svc-icon">🚚</div><div><h4>全场包邮</h4><p>满 ¥299 免运费</p></div></div>
        <div class="svc"><div class="svc-icon">🔄</div><div><h4>7 天无理由</h4><p>不满意随时退换</p></div></div>
        <div class="svc"><div class="svc-icon">🛡️</div><div><h4>正品保障</h4><p>品牌授权 · 假一赔十</p></div></div>
        <div class="svc"><div class="svc-icon">💬</div><div><h4>专属客服</h4><p>24 小时在线服务</p></div></div>
      </div>
    </section>

  </div>
  </DesktopLayout>
</template>

<style scoped>
.home { position: relative; }

/* ── HERO ── 完全同步 demo_v4 ── */
.hero {
  position: relative; z-index: 2;
  height: calc(100vh - 112px); min-height: 600px;
  display: flex; align-items: center; justify-content: center;
  overflow: hidden;
}
.hero-bg {
  position: absolute; inset: 0;
  background: radial-gradient(ellipse at 30% 50%, rgba(0,240,255,0.06), transparent 55%),
              radial-gradient(ellipse at 70% 30%, rgba(184,41,247,0.05), transparent 50%),
              radial-gradient(ellipse at 50% 80%, rgba(255,42,138,0.03), transparent 45%);
}
.hero-grid-lines {
  position: absolute; inset: 0;
  background-image: 
    linear-gradient(90deg, rgba(0,240,255,0.03) 1px, transparent 1px),
    linear-gradient(0deg, rgba(0,240,255,0.03) 1px, transparent 1px);
  background-size: 80px 80px;
  mask-image: radial-gradient(ellipse at 50% 50%, black 30%, transparent 70%);
  -webkit-mask-image: radial-gradient(ellipse at 50% 50%, black 30%, transparent 70%);
}

/* Hero Slides */
.hero-slides { position: absolute; inset: 0; overflow: hidden; }
.hero-slide {
  position: absolute; inset: 0;
  opacity: 0; transition: opacity .8s ease;
  display: flex; align-items: center; justify-content: center;
}
.hero-slide.active { opacity: 1; }
.hero-slide-bg {
  position: absolute; inset: 0;
  background-size: cover; background-position: center;
}
.hero-slide-bg::after {
  content: ''; position: absolute; inset: 0;
  background: linear-gradient(90deg, rgba(5,5,8,0.88) 0%, rgba(5,5,8,0.3) 50%, rgba(5,5,8,0.15) 100%);
}
.hero-slide-bg-fallback {
  position: absolute; inset: 0;
  background: linear-gradient(135deg, #0a0a20, #1a0a2e);
}
.hero-slide-content {
  position: relative; z-index: 2;
  max-width: 1440px; width: 100%; padding: 0 40px;
  display: grid; grid-template-columns: 1.1fr 1fr; gap: 60px;
  align-items: center;
}

.hero-tag {
  display: inline-flex; align-items: center; gap: 10px; width: fit-content;
  padding: 8px 18px; border-radius: 100px;
  background: rgba(0,240,255,0.06); border: 1px solid rgba(0,240,255,0.15);
  color: var(--accent); font-size: 12px; font-weight: 600;
  font-family: var(--font-display); letter-spacing: 2px; margin-bottom: 28px;
}
.hero-tag .pulse {
  width: 6px; height: 6px; border-radius: 50%; background: var(--accent);
  box-shadow: 0 0 10px var(--accent-glow); animation: pulse-dot 2s infinite;
}
@keyframes pulse-dot {
  0%, 100% { opacity: 1; transform: scale(1); }
  50% { opacity: 0.5; transform: scale(0.8); }
}
.hero-title {
  font-size: 58px; font-weight: 700; line-height: 1.08; margin-bottom: 20px;
}
.hero-title .gradient {
  background: linear-gradient(135deg, var(--accent), var(--neon-violet), var(--neon-pink), var(--accent));
  background-size: 300% 300%;
  -webkit-background-clip: text; -webkit-text-fill-color: transparent;
  background-clip: text;
  animation: gradient-flow 6s ease infinite;
}
@keyframes gradient-flow {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}
.hero-desc {
  font-size: 16px; color: var(--text-secondary); line-height: 1.8;
  margin-bottom: 40px; max-width: 480px;
}
.hero-btns { display: flex; gap: 16px; }
.btn-primary {
  padding: 16px 36px; border-radius: 12px;
  background: linear-gradient(135deg, var(--accent), var(--accent-tertiary));
  color: #000; font-size: 15px; font-weight: 700; border: none;
  cursor: pointer; transition: all .3s; font-family: var(--font-body);
  box-shadow: 0 0 32px rgba(0,240,255,0.25);
  position: relative; overflow: hidden;
  display: flex; align-items: center; gap: 8px;
}
.btn-primary::before {
  content: ''; position: absolute; top: 0; left: -100%; width: 100%; height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
  transition: left .5s;
}
.btn-primary:hover::before { left: 100%; }
.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 48px rgba(0,240,255,0.4);
}
.btn-arrow { transition: transform .3s; display: inline-block; }
.btn-primary:hover .btn-arrow { transform: translateX(4px); }
.btn-secondary {
  padding: 16px 36px; border-radius: 12px;
  border: 1px solid var(--border); background: var(--bg-card);
  backdrop-filter: blur(10px);
  color: var(--text-primary); font-size: 15px; font-weight: 600;
  cursor: pointer; transition: all .3s; font-family: var(--font-body);
}
.btn-secondary:hover { border-color: var(--accent); color: var(--accent); }

.hero-slide-visual {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  perspective: 900px;
}
.three-orb-wrap {
  width: 300px;
  height: 300px;
  animation: orb-float 6s ease-in-out infinite;
}
.three-orb-wrap canvas {
  width: 100% !important;
  height: 100% !important;
  border-radius: 50%;
}
@keyframes orb-float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-18px); }
}

/* Hero 导航 */
.hero-dots {
  position: absolute; bottom: 40px; left: 40px; z-index: 10;
  display: flex; gap: 10px;
}
.hero-dot {
  width: 32px; height: 4px; border-radius: 2px;
  background: rgba(255,255,255,0.15); cursor: pointer;
  transition: all .3s;
}
.hero-dot.active {
  background: linear-gradient(90deg, var(--accent), var(--accent-tertiary));
  box-shadow: 0 0 8px var(--accent-glow);
}
.hero-arrows {
  position: absolute; top: 50%; transform: translateY(-50%);
  z-index: 10; display: flex; justify-content: space-between;
  width: 100%; padding: 0 20px; pointer-events: none;
}
.hero-arrow {
  width: 48px; height: 48px; border-radius: 50%;
  background: rgba(255,255,255,0.05); border: 1px solid var(--border);
  backdrop-filter: blur(10px);
  display: flex; align-items: center; justify-content: center;
  color: var(--text-secondary); font-size: 20px; cursor: pointer;
  transition: all .3s; pointer-events: auto; font-family: var(--font-body);
}
.hero-arrow:hover {
  border-color: var(--accent); color: var(--accent);
  background: rgba(0,240,255,0.08);
}

.hero-scroll {
  position: absolute; bottom: 30px; left: 50%; transform: translateX(-50%);
  display: flex; flex-direction: column; align-items: center; gap: 8px;
  color: var(--text-muted); font-size: 11px; letter-spacing: 2px;
  font-family: var(--font-display); z-index: 2;
}
.hero-scroll .mouse {
  width: 20px; height: 32px; border: 1px solid var(--text-muted); border-radius: 10px;
  position: relative;
}
.hero-scroll .mouse-wheel {
  position: absolute; top: 6px; left: 50%; transform: translateX(-50%);
  width: 4px; height: 6px; background: var(--accent); border-radius: 2px;
  animation: scroll-wheel 2s infinite;
}
@keyframes scroll-wheel {
  0%, 100% { top: 6px; opacity: 1; }
  50% { top: 14px; opacity: 0.3; }
}

/* ── 快捷分类 · 3D 悬浮 ── */
.cats {
  position: relative; z-index: 2;
  max-width: 1440px; margin: 60px auto 0; padding: 0 40px;
}
.cats-grid { display: grid; grid-template-columns: repeat(6, 1fr); gap: 20px; }
.cat-card {
  display: flex; flex-direction: column; align-items: center; gap: 14px;
  padding: 28px 16px; cursor: pointer; transition: all .4s;
  border-radius: 20px;
}
.cat-card:hover {
  background: var(--bg-card);
  transform: translateY(-6px);
}
.cat-icon-wrap {
  width: 80px; height: 80px; border-radius: 24px;
  background: linear-gradient(145deg, rgba(0,240,255,0.06), rgba(184,41,247,0.04));
  border: 1px solid rgba(0,240,255,0.1);
  display: flex; align-items: center; justify-content: center;
  font-size: 32px; transition: all .4s;
  position: relative; overflow: hidden;
  box-shadow: 0 4px 20px rgba(0,0,0,0.2);
}
.cat-icon-wrap::before {
  content: ''; position: absolute; inset: 0;
  background: linear-gradient(135deg, var(--accent), var(--accent-tertiary));
  opacity: 0; transition: opacity .3s;
}
.cat-card:hover .cat-icon-wrap {
  transform: translateY(-4px) scale(1.05);
  box-shadow: 0 12px 40px rgba(0,240,255,0.12);
  border-color: transparent;
}
.cat-card:hover .cat-icon-wrap::before { opacity: 1; }
.cat-icon-wrap span { position: relative; z-index: 2; transition: transform .3s; }
.cat-card:hover .cat-icon-wrap span { transform: scale(1.1); }
.cat-name { font-size: 14px; font-weight: 500; color: var(--text-primary); transition: color .3s; }
.cat-card:hover .cat-name { color: var(--accent); }

/* ── 品牌信任条 ── */
.brand-strip {
  position: relative; z-index: 2;
  border-top: 1px solid var(--border); border-bottom: 1px solid var(--border);
  padding: 32px 0; overflow: hidden;
  margin-top: 40px;
  background: linear-gradient(90deg, var(--bg-primary) 0%, rgba(10,10,18,0.6) 50%, var(--bg-primary) 100%);
}
.brand-track {
  display: flex; gap: 80px;
  animation: brand-scroll 30s linear infinite;
  width: max-content;
}
.brand-track:hover { animation-play-state: paused; }
@keyframes brand-scroll {
  0% { transform: translateX(0); }
  100% { transform: translateX(-50%); }
}
.brand-item {
  font-family: var(--font-display); font-size: 20px; font-weight: 600;
  color: var(--text-muted); letter-spacing: 3px;
  transition: color .3s; cursor: pointer; white-space: nowrap;
}
.brand-item:hover { color: var(--accent); }


/* ── BENTO GRID 产品区 · 同步 demo_v4 ── */
.bento-section {
  position: relative; z-index: 2;
  max-width: 1440px; margin: 80px auto 0; padding: 0 40px;
}
.sec-header {
  display: flex; align-items: center; justify-content: space-between;
  margin-bottom: 40px;
}
.sec-title {
  font-family: var(--font-display); font-size: 28px; font-weight: 700;
  letter-spacing: 2px; display: flex; align-items: center; gap: 14px;
}
.sec-title .bar {
  width: 4px; height: 28px; border-radius: 2px;
  background: linear-gradient(180deg, var(--accent), var(--neon-violet, var(--accent-tertiary)));
  box-shadow: 0 0 12px var(--accent-glow);
}
.sec-title span {
  background: linear-gradient(135deg, var(--text-primary), var(--text-secondary));
  -webkit-background-clip: text; -webkit-text-fill-color: transparent;
  background-clip: text;
}
.sec-more {
  font-size: 14px; color: var(--text-secondary); cursor: pointer;
  display: flex; align-items: center; gap: 6px; transition: all .2s;
  font-family: var(--font-display); letter-spacing: 1px;
}
.sec-more:hover { color: var(--accent); gap: 10px; }

.bento-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  grid-auto-rows: 220px;
  gap: 20px;
  grid-auto-flow: dense;
}
.bento-item {
  position: relative; border-radius: 24px; overflow: hidden;
  background: var(--bg-card);
  border: 1px solid var(--border);
  cursor: pointer; transition: all .5s cubic-bezier(0.4, 0, 0.2, 1);
}
.bento-item:hover {
  transform: translateY(-4px) scale(1.01);
  border-color: var(--border-hover);
  box-shadow: 0 24px 48px rgba(0,0,0,0.4), 0 0 40px rgba(0,240,255,0.06);
}
.bento-item.large { grid-column: span 2; grid-row: span 2; }
.bento-item.wide { grid-column: span 2; }
.bento-item.tall { grid-row: span 2; }
.bento-img {
  position: absolute; inset: 0;
  background: linear-gradient(145deg, #080810, #121220);
}
.bento-img img {
  width: 100%; height: 100%; object-fit: cover;
  transition: transform .6s; opacity: 0.9;
}
.bento-item:hover .bento-img img { transform: scale(1.06); }
.bento-overlay {
  position: absolute; inset: 0;
  background: linear-gradient(180deg, transparent 30%, rgba(5,5,8,0.92) 100%);
}
.bento-content {
  position: absolute; bottom: 0; left: 0; right: 0;
  padding: 24px; z-index: 2;
}
.bento-badge {
  display: inline-block; padding: 5px 12px; border-radius: 8px;
  background: linear-gradient(135deg, var(--accent), var(--accent-tertiary));
  color: #000; font-size: 10px; font-weight: 700;
  font-family: var(--font-display); letter-spacing: 1px;
  margin-bottom: 10px;
}
.bento-brand {
  font-family: var(--font-display); font-size: 12px; font-weight: 600;
  color: var(--accent); letter-spacing: 2px; margin-bottom: 6px;
}
.bento-name {
  font-size: 16px; font-weight: 600; color: var(--text-primary); line-height: 1.3;
  margin-bottom: 10px;
}
.bento-item.large .bento-name { font-size: 22px; }
.bento-price {
  font-family: var(--font-display); font-size: 22px; font-weight: 700;
  color: var(--accent); text-shadow: 0 0 12px rgba(0,240,255,0.15);
}
.bento-price::before { content: '¥'; font-size: 13px; margin-right: 3px; }

/* ── 丝滑 SVG 滚动路径背景 ── */
.scroll-lines-bg {
  position: absolute;
  top: 0; bottom: auto;
  left: calc(50% - 720px);
  width: 1600px;
  height: 100%;
  z-index: 0;
  pointer-events: none;
  overflow: visible;
  background: linear-gradient(180deg, rgba(5,5,8,0.15) 0%, rgba(10,10,18,0.35) 40%, rgba(10,10,18,0.35) 60%, rgba(5,5,8,0.15) 100%);
  mask-image: linear-gradient(90deg, transparent 0%, black 5%, black 95%, transparent 100%);
  -webkit-mask-image: linear-gradient(90deg, transparent 0%, black 5%, black 95%, transparent 100%);
}
.scroll-lines-bg svg {
  position: absolute; top: 0; left: 0;
  width: 100%; height: 100%;
  filter: blur(0.5px); opacity: 0.55;
}
.scroll-lines-bg use {
  fill: none; stroke: url(#cl1); stroke-linecap: round;
  stroke-width: var(--dot, 30px);
  stroke-dashoffset: var(--strokeDashoffset);
}
.scroll-lines-bg use[href="#linePath02"] {
  --dot: 34px; --gap: 60px;
  stroke-dasharray: var(--dot) var(--gap) 120px var(--gap) var(--dot) var(--gap) 300px var(--gap) var(--dot) var(--gap) 150px var(--gap) var(--dot) 20000px;
}
.scroll-lines-bg use[href="#linePath03"] {
  --dot: 25px; --gap: 40px;
  stroke-dasharray: var(--dot) var(--gap) 120px var(--gap) var(--dot) var(--gap) 250px var(--gap) var(--dot) var(--gap) 150px var(--gap) var(--dot) 20000px;
}
.scroll-lines-bg use[href="#linePath04"] {
  --dot: 40px; --gap: 70px;
  stroke-dasharray: var(--dot) var(--gap) 100px var(--gap) var(--dot) var(--gap) 200px var(--gap) var(--dot) 20000px;
}

.scroll-lines-blur {
  position: absolute;
  top: 0; bottom: auto;
  left: calc(50% - 720px);
  width: 1600px;
  height: 100%;
  z-index: 0;
  pointer-events: none;
  backdrop-filter: blur(8px) saturate(1.1);
  -webkit-backdrop-filter: blur(8px) saturate(1.1);
  mask-image: linear-gradient(180deg, black 80%, transparent 100%);
  -webkit-mask-image: linear-gradient(180deg, black 80%, transparent 100%);
}

/* ── 横向滚动推荐 ── */
.scroll-section { max-width: 1440px; margin: 80px auto 0; padding: 0 40px; position: relative; z-index: 2; overflow: hidden; }
.scroll-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 28px; }
.scroll-title {
  font-family: var(--font-display); font-size: 24px; font-weight: 700;
  letter-spacing: 2px;
  background: linear-gradient(135deg, var(--accent), var(--neon-violet, var(--accent-tertiary)));
  -webkit-background-clip: text; -webkit-text-fill-color: transparent;
  background-clip: text;
}
.scroll-track {
  display: flex; gap: 20px;
  width: max-content;
  animation: scroll-new 35s linear infinite;
}
.scroll-track:hover { animation-play-state: paused; }
@keyframes scroll-new {
  0% { transform: translateX(0); }
  100% { transform: translateX(-50%); }
}
.sitem {
  flex: 0 0 280px; scroll-snap-align: start;
  border-radius: 20px; overflow: hidden;
  border: 1px solid var(--border); background: var(--bg-card);
  cursor: pointer; transition: all .4s;
}
.sitem:hover { border-color: var(--border-hover); transform: translateY(-4px); box-shadow: 0 8px 24px rgba(0,0,0,0.3); }
.sitem-img { width: 100%; height: 220px; background: linear-gradient(145deg, #0a0a16, #131326); }
.sitem-img img { width: 100%; height: 100%; object-fit: cover; }
.sitem-body { padding: 14px; }
.sitem-name { font-size: 13px; color: var(--text-primary); line-height: 1.4; margin-bottom: 8px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
.sitem-price { font-family: 'Orbitron', sans-serif; font-size: 17px; font-weight: 700; color: var(--accent); text-shadow: 0 0 8px rgba(0,240,255,0.15); }
.sitem-price::before { content: '¥'; font-size: 12px; margin-right: 2px; }

/* ── 促销横幅 ── */
.promo { max-width: 1440px; margin: 48px auto 0; padding: 0 40px; display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
.promo-card { position: relative; height: 200px; border-radius: 20px; overflow: hidden; cursor: pointer; display: flex; align-items: center; padding: 36px; border: 1px solid var(--border); transition: all .3s; }
.promo-card:hover { transform: translateY(-4px); box-shadow: var(--shadow-glow); }
.promo-card h3 { font-size: 24px; font-weight: 700; margin-bottom: 8px; position: relative; z-index: 2; }
.promo-card p { font-size: 14px; opacity: 0.7; position: relative; z-index: 2; }
.promo-tag { display: inline-block; padding: 6px 14px; border-radius: 6px; font-size: 12px; font-weight: 700; margin-top: 16px; position: relative; z-index: 2; }
.p1 { background: linear-gradient(135deg, #0f0c29, #302b63); }
.p1 h3, .p1 .promo-tag { color: var(--accent); }
.p1 .promo-tag { background: rgba(0,240,255,0.12); border: 1px solid rgba(0,240,255,0.25); }
.p2 { background: linear-gradient(135deg, #1a1a2e, #16213e); }
.p2 h3, .p2 .promo-tag { color: var(--accent-secondary); }
.p2 .promo-tag { background: rgba(255,42,138,0.12); border: 1px solid rgba(255,42,138,0.25); }

/* ── 服务保障 ── */
.service { max-width: 1440px; margin: 48px auto 0; padding: 0 40px 60px; }
.svc-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }
.svc { background: var(--bg-card); border: 1px solid var(--border); border-radius: 16px; padding: 24px; display: flex; align-items: center; gap: 16px; }
.svc-icon { font-size: 32px; }
.svc h4 { font-size: 14px; font-weight: 700; color: var(--text-primary); margin-bottom: 4px; }
.svc p { font-size: 12px; color: var(--text-muted); }

@media (max-width: 1024px) {
  .hero { height: auto; min-height: auto; padding: 60px 0; }
  .hero-slide-content { grid-template-columns: 1fr; text-align: center; padding: 0 20px; }
  .hero-title { font-size: 42px; }
  .hero-desc { margin: 0 auto 32px; }
  .hero-btns { justify-content: center; }
  .hero-slide-visual { display: none; }
  .hero-scroll { display: none; }
  .hero-arrows { display: none; }
  .cats-grid { grid-template-columns: repeat(3, 1fr); }
  .cats { margin-top: 40px; padding: 0 20px; }
  .brand-strip { margin-top: 32px; }
  .bento-grid { grid-template-columns: repeat(2, 1fr); grid-auto-rows: 200px; }
  .bento-item.large, .bento-item.wide { grid-column: span 2; }
  .bento-item.tall { grid-row: span 2; }
  .promo { grid-template-columns: 1fr; }
  .svc-grid { grid-template-columns: repeat(2, 1fr); }
}
@media (max-width: 768px) {
  .hero { padding: 40px 0; }
  .hero-title { font-size: 32px; }
  .cats, .bento-section, .scroll-section, .promo, .service { padding: 0 20px; }
  .cats-grid { grid-template-columns: repeat(3, 1fr); }
  .bento-grid { grid-template-columns: 1fr; grid-auto-rows: 220px; }
  .bento-item.large { grid-column: span 1; grid-row: span 1; }
  .bento-item.wide { grid-column: span 1; }
  .bento-item.tall { grid-row: span 1; }
  .svc-grid { grid-template-columns: 1fr; }
}
</style>
