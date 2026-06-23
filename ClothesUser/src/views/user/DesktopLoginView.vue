<script setup lang="ts">
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { showFailToast, showToast } from 'vant'
import { userApi } from '@/api/user'
import { useUserStore } from '@/stores/user'
import * as THREE from 'three'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const isLogin = ref(true)
const loading = ref(false)
const showPwd = ref(false)
const showRegPwd = ref(false)
const successShow = ref(false)

// 3D tilt
const cardRef = ref<HTMLElement | null>(null)
let tiltCleanup: (() => void) | null = null

// Login form
const login = reactive({ username: '', password: '' })
// Register form
const reg = reactive({ username: '', password: '', confirmPwd: '', phone: '', nickname: '' })

// ── Canvas 粒子连线 ──
let canvasCtx: CanvasRenderingContext2D | null = null
let particles: any[] = []
let W = 0, H = 0, animId = 0

class CanvasParticle {
  x: number; y: number; vx: number; vy: number; size: number
  constructor() {
    this.x = Math.random() * W; this.y = Math.random() * H
    this.vx = (Math.random() - 0.5) * 0.4; this.vy = (Math.random() - 0.5) * 0.4
    this.size = Math.random() * 1.5 + 0.5
  }
  update() {
    this.x += this.vx; this.y += this.vy
    if (this.x < 0 || this.x > W) this.vx *= -1
    if (this.y < 0 || this.y > H) this.vy *= -1
  }
  draw() {
    if (!canvasCtx) return
    canvasCtx.beginPath()
    canvasCtx.arc(this.x, this.y, this.size, 0, Math.PI * 2)
    canvasCtx.fillStyle = 'rgba(0,240,255,0.2)'
    canvasCtx.fill()
  }
}

function initCanvas() {
  const canvas = document.getElementById('bg-canvas') as HTMLCanvasElement
  if (!canvas) return
  canvasCtx = canvas.getContext('2d')
  if (!canvasCtx) return
  resizeCanvas()
  window.addEventListener('resize', resizeCanvas)
  for (let i = 0; i < 50; i++) particles.push(new CanvasParticle())
  animateParticles()
}
function resizeCanvas() {
  const canvas = document.getElementById('bg-canvas') as HTMLCanvasElement
  if (!canvas) return
  W = canvas.width = window.innerWidth; H = canvas.height = window.innerHeight
}
function drawLines() {
  if (!canvasCtx) return
  for (let i = 0; i < particles.length; i++) {
    for (let j = i + 1; j < particles.length; j++) {
      const dx = particles[i].x - particles[j].x
      const dy = particles[i].y - particles[j].y
      const dist = Math.sqrt(dx * dx + dy * dy)
      if (dist < 150) {
        canvasCtx.beginPath()
        canvasCtx.moveTo(particles[i].x, particles[i].y)
        canvasCtx.lineTo(particles[j].x, particles[j].y)
        canvasCtx.strokeStyle = `rgba(0,240,255,${0.08 * (1 - dist / 150)})`
        canvasCtx.lineWidth = 0.5
        canvasCtx.stroke()
      }
    }
  }
}
function animateParticles() {
  if (!canvasCtx) return
  canvasCtx.clearRect(0, 0, W, H)
  particles.forEach(p => { p.update(); p.draw() })
  drawLines()
  animId = requestAnimationFrame(animateParticles)
}

// ── Three.js 3D 等离子球体 ──
let threeCleanup: (() => void) | null = null

function initThreeOrb() {
  const container = document.getElementById('three-orb-container')
  if (!container) return
  const width = container.clientWidth
  const height = container.clientHeight

  const scene = new THREE.Scene()
  const camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 100)
  camera.position.z = 2.6

  const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true })
  renderer.setSize(width, height)
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
  renderer.toneMapping = THREE.ACESFilmicToneMapping
  renderer.toneMappingExposure = 1.1
  container.appendChild(renderer.domElement)

  const mainGroup = new THREE.Group()
  scene.add(mainGroup)

  // GLSL Noise
  const noiseFns = `
    vec3 mod289(vec3 x){return x-floor(x*(1.0/289.0))*289.0;}
    vec4 mod289(vec4 x){return x-floor(x*(1.0/289.0))*289.0;}
    vec4 permute(vec4 x){return mod289(((x*34.0)+1.0)*x);}
    vec4 taylorInvSqrt(vec4 r){return 1.79284291400159-0.85373472095314*r;}
    float snoise(vec3 v){
      const vec2 C=vec2(1.0/6.0,1.0/3.0);
      const vec4 D=vec4(0.0,0.5,1.0,2.0);
      vec3 i=floor(v+dot(v,C.yyy));
      vec3 x0=v-i+dot(i,C.xxx);
      vec3 g=step(x0.yzx,x0.xyz);
      vec3 l=1.0-g;
      vec3 i1=min(g.xyz,l.zxy);
      vec3 i2=max(g.xyz,l.zxy);
      vec3 x1=x0-i1+C.xxx;
      vec3 x2=x0-i2+C.yyy;
      vec3 x3=x0-D.yyy;
      i=mod289(i);
      vec4 p=permute(permute(permute(i.z+vec4(0.0,i1.z,i2.z,1.0))+i.y+vec4(0.0,i1.y,i2.y,1.0))+i.x+vec4(0.0,i1.x,i2.x,1.0));
      float n_=0.142857142857;
      vec3 ns=n_*D.wyz-D.xzx;
      vec4 j=p-49.0*floor(p*ns.z*ns.z);
      vec4 x_=floor(j*ns.z);
      vec4 y_=floor(j-7.0*x_);
      vec4 x=x_*ns.x+ns.yyyy;
      vec4 y=y_*ns.x+ns.yyyy;
      vec4 h=1.0-abs(x)-abs(y);
      vec4 b0=vec4(x.xy,y.xy);
      vec4 b1=vec4(x.zw,y.zw);
      vec4 s0=floor(b0)*2.0+1.0;
      vec4 s1=floor(b1)*2.0+1.0;
      vec4 sh=-step(h,vec4(0.0));
      vec4 a0=b0.xzyw+s0.xzyw*sh.xxyy;
      vec4 a1=b1.xzyw+s1.xzyw*sh.zzww;
      vec3 p0=vec3(a0.xy,h.x);
      vec3 p1=vec3(a0.zw,h.y);
      vec3 p2=vec3(a1.xy,h.z);
      vec3 p3=vec3(a1.zw,h.w);
      vec4 norm=taylorInvSqrt(vec4(dot(p0,p0),dot(p1,p1),dot(p2,p2),dot(p3,p3)));
      p0*=norm.x;p1*=norm.y;p2*=norm.z;p3*=norm.w;
      vec4 m=max(0.6-vec4(dot(x0,x0),dot(x1,x1),dot(x2,x2),dot(x3,x3)),0.0);
      m=m*m;
      return 42.0*dot(m*m,vec4(dot(p0,x0),dot(p1,x1),dot(p2,x2),dot(p3,x3)));
    }
    float fbm(vec3 p){
      float total=0.0,amplitude=0.5,frequency=1.0;
      for(int i=0;i<3;i++){total+=snoise(p*frequency)*amplitude;amplitude*=0.5;frequency*=2.0;}
      return total;
    }
  `

  // Glass shell
  const shellGeo = new THREE.SphereGeometry(1.0, 64, 64)
  const shellVert = `varying vec3 vNormal;varying vec3 vViewPosition;
    void main(){vNormal=normalize(normalMatrix*normal);vec4 mvPosition=modelViewMatrix*vec4(position,1.0);vViewPosition=-mvPosition.xyz;gl_Position=projectionMatrix*mvPosition;}`
  const shellFrag = `varying vec3 vNormal;varying vec3 vViewPosition;uniform vec3 uColor;uniform float uOpacity;
    void main(){float fresnel=pow(1.0-dot(normalize(vNormal),normalize(vViewPosition)),2.5);gl_FragColor=vec4(uColor,fresnel*uOpacity);}`

  mainGroup.add(new THREE.Mesh(shellGeo, new THREE.ShaderMaterial({
    vertexShader: shellVert, fragmentShader: shellFrag,
    uniforms: { uColor: { value: new THREE.Color(0x2a0044) }, uOpacity: { value: 0.3 } },
    transparent: true, blending: THREE.AdditiveBlending, side: THREE.BackSide, depthWrite: false
  })))
  mainGroup.add(new THREE.Mesh(shellGeo, new THREE.ShaderMaterial({
    vertexShader: shellVert, fragmentShader: shellFrag,
    uniforms: { uColor: { value: new THREE.Color(0xb829f7) }, uOpacity: { value: 0.45 } },
    transparent: true, blending: THREE.AdditiveBlending, side: THREE.FrontSide, depthWrite: false
  })))

  // Plasma
  const plasmaGeo = new THREE.SphereGeometry(0.998, 128, 128)
  const plasmaMat = new THREE.ShaderMaterial({
    uniforms: {
      uTime: { value: 0 }, uScale: { value: 0.22 }, uBrightness: { value: 1.4 },
      uThreshold: { value: 0.09 },
      uColorDeep: { value: new THREE.Color(0x0a001a) },
      uColorMid: { value: new THREE.Color(0x00f0ff) },
      uColorBright: { value: new THREE.Color(0xff2a8a) }
    },
    vertexShader: `varying vec3 vPosition;varying vec3 vNormal;varying vec3 vViewPosition;
      void main(){vPosition=position;vNormal=normalize(normalMatrix*normal);vec4 mvPosition=modelViewMatrix*vec4(position,1.0);vViewPosition=-mvPosition.xyz;gl_Position=projectionMatrix*mvPosition;}`,
    fragmentShader: `
      uniform float uTime,uScale,uBrightness,uThreshold;
      uniform vec3 uColorDeep,uColorMid,uColorBright;
      varying vec3 vPosition,vNormal,vViewPosition;
      ${noiseFns}
      void main(){
        vec3 p=vPosition*uScale;
        vec3 q=vec3(fbm(p+vec3(0.0,uTime*0.05,0.0)),fbm(p+vec3(5.2,1.3,2.8)+uTime*0.05),fbm(p+vec3(2.2,8.4,0.5)-uTime*0.02));
        float density=fbm(p+2.0*q);
        float t=(density+0.4)*0.8;
        float alpha=smoothstep(uThreshold,0.7,t);
        vec3 color=mix(uColorDeep,uColorMid,smoothstep(uThreshold,0.5,t));
        color=mix(color,uColorBright,smoothstep(0.5,0.8,t));
        color=mix(color,vec3(1.0),smoothstep(0.8,1.0,t));
        float facing=dot(normalize(vNormal),normalize(vViewPosition));
        gl_FragColor=vec4(color*uBrightness,alpha*(0.02+0.98*((facing+1.0)*0.5)));
      }`,
    transparent: true, blending: THREE.AdditiveBlending, side: THREE.DoubleSide, depthWrite: false
  })
  const plasmaMesh = new THREE.Mesh(plasmaGeo, plasmaMat)
  mainGroup.add(plasmaMesh)

  // Particles
  const pCount = 600
  const pPos = new Float32Array(pCount * 3)
  const pSizes = new Float32Array(pCount)
  for (let i = 0; i < pCount; i++) {
    const r = 0.95 * Math.cbrt(Math.random())
    const theta = Math.random() * Math.PI * 2
    const phi = Math.acos(2 * Math.random() - 1)
    pPos[i*3] = r * Math.sin(phi) * Math.cos(theta)
    pPos[i*3+1] = r * Math.sin(phi) * Math.sin(theta)
    pPos[i*3+2] = r * Math.cos(phi)
    pSizes[i] = Math.random()
  }
  const pGeo = new THREE.BufferGeometry()
  pGeo.setAttribute('position', new THREE.BufferAttribute(pPos, 3))
  pGeo.setAttribute('aSize', new THREE.BufferAttribute(pSizes, 1))
  const pMat = new THREE.ShaderMaterial({
    uniforms: { uTime: { value: 0 }, uColor: { value: new THREE.Color(0x00f0ff) } },
    vertexShader: `uniform float uTime;attribute float aSize;varying float vAlpha;
      void main(){vec3 pos=position;pos.y+=sin(uTime*0.2+pos.x)*0.02;pos.x+=cos(uTime*0.15+pos.z)*0.02;vec4 mvPosition=modelViewMatrix*vec4(pos,1.0);gl_PointSize=(8.0*aSize+4.0)*(1.0/-mvPosition.z);gl_Position=projectionMatrix*mvPosition;vAlpha=0.8+0.2*sin(uTime+aSize*10.0);}`,
    fragmentShader: `uniform vec3 uColor;varying float vAlpha;
      void main(){vec2 uv=gl_PointCoord-vec2(0.5);float dist=length(uv);if(dist>0.5)discard;float glow=pow(1.0-dist*2.0,1.8);gl_FragColor=vec4(uColor,glow*vAlpha);}`,
    transparent: true, blending: THREE.AdditiveBlending, depthWrite: false
  })
  const particleSystem = new THREE.Points(pGeo, pMat)
  mainGroup.add(particleSystem)

  // Point light
  mainGroup.add(new THREE.PointLight(0x0088ff, 2.5, 10))

  // Animation
  const clock = new THREE.Clock()
  let threeAnimId = 0
  function animate() {
    threeAnimId = requestAnimationFrame(animate)
    const t = clock.getElapsedTime()
    plasmaMat.uniforms.uTime.value = t * 1.2
    pMat.uniforms.uTime.value = t
    plasmaMesh.rotation.y = t * 0.08
    mainGroup.rotation.y += 0.003
    camera.position.x = Math.sin(t * 0.15) * 2.6
    camera.position.z = 2.6
    camera.lookAt(0, 0, 0)
    renderer.render(scene, camera)
  }
  animate()

  // Resize
  const ro = new ResizeObserver(() => {
    const w = container.clientWidth, h = container.clientHeight
    camera.aspect = w / h; camera.updateProjectionMatrix()
    renderer.setSize(w, h)
  })
  ro.observe(container)

  threeCleanup = () => {
    cancelAnimationFrame(threeAnimId)
    ro.disconnect()
    renderer.dispose()
    container.removeChild(renderer.domElement)
  }
}

// ── Form handlers ──
function switchTo(target: 'login' | 'register') {
  isLogin.value = target === 'login'
}

function onRipple(e: MouseEvent) {
  const btn = e.currentTarget as HTMLElement
  if (btn.classList.contains('loading')) return
  const ripple = document.createElement('span')
  ripple.className = 'btn__ripple'
  const rect = btn.getBoundingClientRect()
  const size = Math.max(rect.width, rect.height)
  ripple.style.width = ripple.style.height = size + 'px'
  ripple.style.left = (e.clientX - rect.left - size / 2) + 'px'
  ripple.style.top = (e.clientY - rect.top - size / 2) + 'px'
  btn.appendChild(ripple)
  setTimeout(() => ripple.remove(), 600)
}

async function handleLogin() {
  if (!login.username.trim() || !login.password) { showToast('请输入用户名和密码'); return }
  loading.value = true
  try {
    const data: any = await userApi.login({ username: login.username, password: login.password })
    userStore.setUserInfo(data.userInfo)
    if (data.token) userStore.setToken(data.token)
    successShow.value = true
    loading.value = false
    setTimeout(() => {
      const redirect = (route.query.redirect as string) || '/'
      router.replace(redirect)
    }, 1400)
  } catch (e: any) { showFailToast(e?.message || '登录失败'); loading.value = false }
}

async function handleRegister() {
  if (!reg.username.trim()) { showToast('请设置用户名'); return }
  if (reg.username.trim().length < 3) { showToast('用户名至少3个字符'); return }
  if (!reg.password || reg.password.length < 6) { showToast('密码至少6位'); return }
  if (reg.confirmPwd !== reg.password) { showToast('两次密码不一致'); return }
  if (reg.phone && !/^1[3-9]\d{9}$/.test(reg.phone)) { showToast('手机号格式不正确'); return }
  loading.value = true
  try {
    await userApi.register({ username: reg.username, password: reg.password, phone: reg.phone || undefined, nickname: reg.nickname || undefined })
    showToast('注册成功，请登录')
    Object.assign(reg, { username: '', password: '', confirmPwd: '', phone: '', nickname: '' })
    isLogin.value = true
  } catch (e: any) { showFailToast(e?.message || '注册失败') }
  finally { loading.value = false }
}

function showForgotPwd() { showToast({ message: '请联系客服重置密码: admin@clothes-demo.com', duration: 3000 }) }

// ── Lifecycle ──
onMounted(() => {
  initCanvas()
  initThreeOrb()
  const card = cardRef.value
  if (!card) return
  const onMove = (e: MouseEvent) => {
    if (window.innerWidth < 960) return
    const rect = card.getBoundingClientRect()
    const x = Math.max(0, Math.min(1, (e.clientX - rect.left) / rect.width))
    const y = Math.max(0, Math.min(1, (e.clientY - rect.top) / rect.height))
    // 3D rotation: follow mouse, max ±10deg
    card.style.transform = `perspective(800px) rotateX(${(y - 0.5) * -20}deg) rotateY(${(x - 0.5) * 20}deg)`
    // 全息光晕：径向渐变跟随鼠标位置
    const glow = card.querySelector('.card-glow') as HTMLElement
    if (glow) {
      glow.style.background = `radial-gradient(circle at ${x * 100}% ${y * 100}%, rgba(0,240,255,0.12), rgba(184,41,247,0.06) 30%, transparent 55%)`
      glow.style.opacity = '1'
    }
  }
  const onLeave = () => {
    card.style.transform = 'perspective(800px) rotateX(0deg) rotateY(0deg)'
    const glow = card.querySelector('.card-glow') as HTMLElement
    if (glow) { glow.style.background = ''; glow.style.opacity = '0' }
  }
  card.addEventListener('mousemove', onMove)
  card.addEventListener('mouseleave', onLeave)
  tiltCleanup = () => {
    card?.removeEventListener('mousemove', onMove)
    card?.removeEventListener('mouseleave', onLeave)
  }
})

onUnmounted(() => {
  tiltCleanup?.()
  cancelAnimationFrame(animId)
  threeCleanup?.()
})
</script>

<template>
  <div class="page">
    <canvas id="bg-canvas"></canvas>

    <!-- 左侧品牌区 -->
    <div class="hero-side">
      <div class="hero-grid-lines"></div>
      <div class="hero-brand">
        <div class="mark">N</div>
        <div class="name">NEXUS</div>
      </div>
      <div class="hero-orb-wrap" id="three-orb-container"></div>
      <div class="hero-content">
        <h1 class="hero-title"><span class="gradient">探索未来</span><br />数码世界</h1>
        <p class="hero-desc">连接前沿科技，定义数字生活。精选全球优质数码品牌。</p>
      </div>
    </div>

    <!-- 右侧表单区 -->
    <div class="form-side">
      <div class="login-card" ref="cardRef">
        <div class="card-glow"></div>
        <div class="card-brand">
          <div class="mark">N</div>
          <div class="name">NEXUS</div>
          <div class="tagline">会员登录</div>
        </div>

        <!-- Tabs -->
        <div class="tabs">
          <div class="tab-pill" :class="{ register: !isLogin }"></div>
          <button class="tab" :class="{ active: isLogin }" @click="switchTo('login')">登录</button>
          <button class="tab" :class="{ active: !isLogin }" @click="switchTo('register')">注册</button>
        </div>

        <!-- 登录 -->
        <form class="form" :class="{ active: isLogin }" @submit.prevent="handleLogin">
          <div class="field">
            <input v-model="login.username" type="text" class="field-input" placeholder=" " autocomplete="username" />
            <label class="field-label">用户名 / 手机号</label>
          </div>
          <div class="field">
            <input v-model="login.password" :type="showPwd ? 'text' : 'password'" class="field-input" placeholder=" " autocomplete="current-password" />
            <label class="field-label">密码</label>
            <button type="button" class="field-icon" tabindex="-1" @click="showPwd = !showPwd">
              <svg v-if="!showPwd" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
              <svg v-else width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>
            </button>
          </div>
          <div class="options">
            <label class="checkbox"><input type="checkbox" checked /><span>记住我</span></label>
            <a href="#" class="link" @click.prevent="showForgotPwd">忘记密码？</a>
          </div>
          <button type="submit" class="btn" :class="{ loading }" :disabled="loading" @click="onRipple">
            <span class="btn__text">登 录</span>
            <span class="btn__spinner"><span class="spinner"></span></span>
          </button>
        </form>

        <!-- 注册 -->
        <form class="form" :class="{ active: !isLogin }" @submit.prevent="handleRegister">
          <div class="field">
            <input v-model="reg.username" type="text" class="field-input" placeholder=" " autocomplete="username" />
            <label class="field-label">用户名</label>
          </div>
          <div class="field">
            <input v-model="reg.nickname" type="text" class="field-input" placeholder=" " autocomplete="name" />
            <label class="field-label">昵称（选填）</label>
          </div>
          <div class="field">
            <input v-model="reg.phone" type="tel" class="field-input" placeholder=" " autocomplete="tel" />
            <label class="field-label">手机号（选填）</label>
          </div>
          <div class="field">
            <input v-model="reg.password" :type="showRegPwd ? 'text' : 'password'" class="field-input" placeholder=" " autocomplete="new-password" />
            <label class="field-label">密码</label>
            <button type="button" class="field-icon" tabindex="-1" @click="showRegPwd = !showRegPwd">
              <svg v-if="!showRegPwd" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
              <svg v-else width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>
            </button>
          </div>
          <div class="field">
            <input v-model="reg.confirmPwd" :type="showRegPwd ? 'text' : 'password'" class="field-input" placeholder=" " autocomplete="new-password" />
            <label class="field-label">确认密码</label>
          </div>
          <div class="terms">注册即代表同意 <a href="#" class="link" @click.prevent>用户协议</a> 和 <a href="#" class="link" @click.prevent>隐私政策</a></div>
          <button type="submit" class="btn" :class="{ loading }" :disabled="loading" @click="onRipple">
            <span class="btn__text">注 册</span>
            <span class="btn__spinner"><span class="spinner"></span></span>
          </button>
        </form>

        <div class="divider">或使用以下方式</div>
        <div class="social">
          <button class="social-btn" type="button">
            <svg viewBox="0 0 24 24" fill="currentColor"><path d="M8.691 2.188C3.891 2.188 0 5.476 0 9.53c0 2.212 1.17 4.203 3.002 5.55a.59.59 0 01.213.665l-.39 1.48c-.019.07-.048.141-.048.213 0 .163.13.295.29.295a.326.326 0 00.167-.054l1.903-1.114a.864.864 0 01.717-.098 10.16 10.16 0 002.837.403c.276 0 .543-.027.811-.05a6.093 6.093 0 01-.305-1.855c0-3.564 3.348-6.456 7.473-6.456.26 0 .515.013.768.037C15.627 4.69 12.47 2.188 8.691 2.188z"/></svg>微信
          </button>
          <button class="social-btn" type="button">
            <svg viewBox="0 0 24 24" fill="currentColor"><path d="M12.48 10.92v3.28h7.84c-.24 1.84-.853 3.187-1.787 4.133-1.147 1.147-2.933 2.4-6.053 2.4-4.827 0-8.6-3.893-8.6-8.72s3.773-8.72 12.173 12c3.573 0 6.267-1.173 8.373-3.36 2.16-2.16 2.84-5.213 2.84-7.667 0-.76-.053-1.467-.173-2.053H12.48z"/></svg>Google
          </button>
        </div>
      </div>
    </div>

    <!-- 登录成功覆盖层 -->
    <div class="success" :class="{ show: successShow }">
      <div class="pyramid-loader">
        <div class="wrapper">
          <span class="side side1"></span>
          <span class="side side2"></span>
          <span class="side side3"></span>
          <span class="side side4"></span>
          <span class="shadow"></span>
        </div>
      </div>
      <div class="success__text">登录成功，正在跳转…</div>
    </div>
  </div>
</template>

<style scoped>
.page {
  position: relative; z-index: 2;
  width: 100%; height: 100vh;
  display: flex;
  background: var(--bg, #050508);
  color: var(--text, #e8e8f0);
  font-family: var(--font-body, 'Noto Sans SC', sans-serif);
  overflow: hidden;
}

#bg-canvas { position: fixed; inset: 0; z-index: 0; pointer-events: none; }

/* ===== 左侧品牌区 ===== */
.hero-side {
  width: 55%; height: 100%;
  position: relative; z-index: 2;
  display: flex; flex-direction: column;
  justify-content: center; align-items: center;
  padding: 60px;
  overflow: hidden;
}
.hero-side::before {
  content: '';
  position: absolute; inset: 0;
  background: radial-gradient(ellipse at 30% 50%, rgba(0,240,255,0.06), transparent 55%),
              radial-gradient(ellipse at 70% 30%, rgba(184,41,247,0.04), transparent 50%);
}
.hero-grid-lines {
  position: absolute; inset: 0;
  background-image: linear-gradient(90deg, rgba(0,240,255,0.03) 1px, transparent 1px),
                    linear-gradient(0deg, rgba(0,240,255,0.03) 1px, transparent 1px);
  background-size: 80px 80px;
  mask-image: radial-gradient(ellipse at 50% 50%, black 20%, transparent 60%);
  -webkit-mask-image: radial-gradient(ellipse at 50% 50%, black 20%, transparent 60%);
}

.hero-brand { display: flex; align-items: center; gap: 16px; margin-bottom: 36px; position: relative; z-index: 3; }
.hero-brand .mark {
  width: 56px; height: 56px; border-radius: 16px;
  background: linear-gradient(135deg, var(--neon-blue, #00f0ff), var(--neon-violet, #b829f7));
  display: flex; align-items: center; justify-content: center;
  font-family: var(--font-display, 'Orbitron', sans-serif); font-weight: 800; font-size: 28px; color: #000;
  box-shadow: 0 0 36px rgba(0,240,255,0.4), inset 0 1px 0 rgba(255,255,255,0.3);
  position: relative; overflow: hidden;
}
.hero-brand .mark::after {
  content: ''; position: absolute; inset: 0;
  background: linear-gradient(135deg, transparent 40%, rgba(255,255,255,0.3) 50%, transparent 60%);
  animation: shine 3s infinite;
}
@keyframes shine { 0% { transform: translateX(-100%); } 100% { transform: translateX(100%); } }
.hero-brand .name {
  font-family: var(--font-display, 'Orbitron', sans-serif); font-size: 36px; font-weight: 700;
  letter-spacing: 6px;
  background: linear-gradient(135deg, var(--neon-blue, #00f0ff), var(--neon-violet, #b829f7), var(--neon-pink, #ff2a8a));
  background-size: 300% 300%;
  -webkit-background-clip: text; -webkit-text-fill-color: transparent;
  animation: gradient-flow 6s ease infinite;
}
@keyframes gradient-flow { 0% { background-position: 0% 50%; } 50% { background-position: 100% 50%; } 100% { background-position: 0% 50%; } }

.hero-orb-wrap { width: 320px; height: 320px; margin-bottom: 32px; position: relative; z-index: 3; }
#three-orb-container canvas { display: block; width: 100% !important; height: 100% !important; border-radius: 50%; }

.hero-content { position: relative; z-index: 3; text-align: center; }
.hero-title { font-size: 42px; font-weight: 700; line-height: 1.1; margin-bottom: 16px; font-family: var(--font-display, 'Orbitron', sans-serif); letter-spacing: 1px; }
.hero-title .gradient {
  background: linear-gradient(135deg, var(--neon-blue, #00f0ff), var(--neon-violet, #b829f7), var(--neon-pink, #ff2a8a), var(--neon-blue, #00f0ff));
  background-size: 300% 300%;
  -webkit-background-clip: text; -webkit-text-fill-color: transparent;
  animation: gradient-flow 6s ease infinite;
}
.hero-desc { font-size: 14px; color: var(--text2, #8a8aa8); line-height: 1.8; max-width: 360px; margin: 0 auto; }

/* ===== 右侧表单区 ===== */
.form-side {
  width: 45%; height: 100%;
  display: flex; align-items: center; justify-content: center;
  padding: 48px;
  position: relative; z-index: 2;
}
.form-side::before {
  content: '';
  position: absolute; inset: 0;
  background: radial-gradient(ellipse at 80% 50%, rgba(0,240,255,0.04), transparent 50%);
}

.login-card {
  width: 100%; max-width: 420px;
  background: linear-gradient(180deg, rgba(14,14,24,0.85), rgba(8,8,14,0.92));
  border: 1px solid var(--border, rgba(0,240,255,0.08));
  border-radius: 28px;
  padding: 40px 40px 36px;
  backdrop-filter: blur(32px) saturate(1.2);
  box-shadow: 0 32px 96px rgba(0,0,0,0.5), 0 0 60px rgba(0,240,255,0.04), inset 0 1px 0 rgba(255,255,255,0.04);
  transition: transform 0.4s cubic-bezier(0.22, 1, 0.36, 1);
  position: relative;
  transform-style: preserve-3d;
  will-change: transform;
}
.login-card::before {
  content: ''; position: absolute; top: 0; left: 40px; right: 40px; height: 1px;
  background: linear-gradient(90deg, transparent, var(--neon-blue, #00f0ff), var(--neon-violet, #b829f7), transparent);
  opacity: 0.6;
}

/* 全息光晕层 */
.card-glow {
  position: absolute; inset: 0;
  border-radius: 28px;
  pointer-events: none; z-index: 0;
  opacity: 0;
  transition: opacity 0.3s ease;
}
/* 所有卡片内容在光晕层之上 */
.login-card > :not(.card-glow) {
  position: relative; z-index: 1;
}

.card-brand { text-align: center; margin-bottom: 28px; }
.card-brand .mark {
  width: 48px; height: 48px; border-radius: 14px;
  background: linear-gradient(135deg, var(--neon-blue, #00f0ff), var(--neon-violet, #b829f7));
  display: flex; align-items: center; justify-content: center;
  font-family: var(--font-display, 'Orbitron', sans-serif); font-weight: 800; font-size: 22px; color: #000;
  margin: 0 auto 12px;
  box-shadow: 0 0 24px rgba(0,240,255,0.4);
}
.card-brand .name { font-family: var(--font-display, 'Orbitron', sans-serif); font-size: 22px; font-weight: 700; letter-spacing: 4px; margin-bottom: 4px; background: linear-gradient(135deg, var(--neon-blue, #00f0ff), var(--neon-violet, #b829f7)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
.card-brand .tagline { font-size: 11px; color: var(--text3, #5a5a78); letter-spacing: 2px; font-family: var(--font-display, 'Orbitron', sans-serif); text-transform: uppercase; }

/* Tabs */
.tabs { position: relative; display: flex; gap: 4px; background: rgba(255,255,255,0.03); padding: 4px; border-radius: 100px; margin-bottom: 28px; width: fit-content; margin-left: auto; margin-right: auto; border: 1px solid var(--border, rgba(0,240,255,0.08)); }
.tab { position: relative; z-index: 1; padding: 10px 32px; border-radius: 100px; border: none; background: transparent; font-family: inherit; font-size: 14px; font-weight: 600; color: var(--text3, #5a5a78); cursor: pointer; transition: color 0.35s ease; letter-spacing: 1px; }
.tab:hover { color: var(--text, #e8e8f0); }
.tab.active { color: #000; }
.tab-pill { position: absolute; top: 4px; left: 4px; width: calc(50% - 4px); height: calc(100% - 8px); background: linear-gradient(135deg, var(--neon-blue, #00f0ff), var(--neon-violet, #b829f7)); border-radius: 100px; box-shadow: 0 4px 24px rgba(0,240,255,0.15); transition: transform 0.45s cubic-bezier(0.34, 1.56, 0.64, 1); z-index: 0; }
.tab-pill.register { transform: translateX(100%); }

/* Form */
.form { display: none; }
.form.active { display: block; animation: formIn 0.5s cubic-bezier(0.22, 1, 0.36, 1); }
@keyframes formIn { from { opacity: 0; transform: translateY(14px); } to { opacity: 1; transform: translateY(0); } }

.field { position: relative; margin-bottom: 18px; }
.field-input {
  width: 100%; height: 54px; padding: 20px 46px 8px 16px;
  background: rgba(255,255,255,0.03);
  border: 1.5px solid rgba(0,240,255,0.1);
  border-radius: 14px;
  color: var(--text, #e8e8f0); font-family: inherit; font-size: 14px;
  outline: none; transition: all 0.3s cubic-bezier(0.22, 1, 0.36, 1);
  box-sizing: border-box;
}
.field-input:hover { border-color: rgba(0,240,255,0.18); }
.field-input:focus { border-color: var(--neon-blue, #00f0ff); background: rgba(0,240,255,0.02); box-shadow: 0 0 0 4px rgba(0,240,255,0.06), 0 0 24px rgba(0,240,255,0.08); }
.field-label {
  position: absolute; left: 16px; top: 50%; transform: translateY(-50%);
  font-size: 14px; color: var(--text3, #5a5a78); pointer-events: none;
  transition: all 0.25s cubic-bezier(0.22, 1, 0.36, 1); transform-origin: left top;
}
.field-input:focus + .field-label, .field-input:not(:placeholder-shown) + .field-label {
  top: 10px; transform: translateY(0) scale(0.72);
  color: var(--neon-blue, #00f0ff); font-weight: 600;
}
.field-icon {
  position: absolute; right: 14px; top: 50%; transform: translateY(-50%);
  background: none; border: none; color: var(--text3, #5a5a78);
  cursor: pointer; padding: 4px; display: flex;
  transition: color 0.3s, transform 0.2s cubic-bezier(0.34, 1.56, 0.64, 1);
}
.field-icon:hover { color: var(--neon-blue, #00f0ff); transform: translateY(-50%) scale(1.1); }

.options { display: flex; justify-content: space-between; align-items: center; margin: -2px 0 22px; font-size: 12px; }
.checkbox { display: flex; align-items: center; gap: 9px; color: var(--text2, #8a8aa8); cursor: pointer; font-weight: 500; transition: color 0.3s; }
.checkbox:hover { color: var(--text, #e8e8f0); }
.checkbox input { appearance: none; width: 17px; height: 17px; border: 1.5px solid var(--border, rgba(0,240,255,0.08)); border-radius: 5px; background: transparent; cursor: pointer; position: relative; transition: all 0.25s cubic-bezier(0.22, 1, 0.36, 1); flex-shrink: 0; }
.checkbox input:checked { background: linear-gradient(135deg, var(--neon-blue, #00f0ff), var(--neon-violet, #b829f7)); border-color: transparent; transform: scale(1.05); }
.checkbox input:checked::after { content: ''; position: absolute; left: 5px; top: 2px; width: 4px; height: 7px; border: solid white; border-width: 0 2px 2px 0; transform: rotate(45deg); animation: tick 0.3s cubic-bezier(0.34, 1.56, 0.64, 1); }
@keyframes tick { 0% { transform: rotate(45deg) scale(0); } 70% { transform: rotate(45deg) scale(1.2); } 100% { transform: rotate(45deg) scale(1); } }

.link { color: var(--neon-blue, #00f0ff); text-decoration: none; font-weight: 600; font-size: 12px; position: relative; transition: color 0.3s; }
.link::after { content: ''; position: absolute; left: 0; bottom: -2px; width: 0; height: 1px; background: linear-gradient(90deg, var(--neon-blue, #00f0ff), var(--neon-violet, #b829f7)); transition: width 0.3s cubic-bezier(0.22, 1, 0.36, 1); }
.link:hover { color: var(--neon-violet, #b829f7); }
.link:hover::after { width: 100%; }

.btn { width: 100%; height: 52px; border: none; border-radius: 16px; font-family: inherit; font-size: 14px; font-weight: 700; letter-spacing: 2px; cursor: pointer; position: relative; overflow: hidden; transition: all 0.4s cubic-bezier(0.22, 1, 0.36, 1); color: #000; background: linear-gradient(135deg, var(--neon-blue, #00f0ff), var(--neon-violet, #b829f7)); box-shadow: 0 8px 32px rgba(0,240,255,0.2); margin-top: 4px; }
.btn::before { content: ''; position: absolute; inset: 0; background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent); transform: translateX(-100%); transition: transform 0.6s; }
.btn:hover::before { transform: translateX(100%); }
.btn:hover { box-shadow: 0 14px 48px rgba(0,240,255,0.35), 0 0 20px rgba(184,41,247,0.15); transform: translateY(-2px); }
.btn:active { transform: translateY(0); }
.btn.loading { pointer-events: none; opacity: 0.8; }
.btn__text { position: relative; z-index: 2; transition: opacity 0.3s, transform 0.3s; }
.btn.loading .btn__text { opacity: 0; transform: translateY(-6px); }
.btn__spinner { position: absolute; left: 50%; top: 50%; transform: translate(-50%, -50%) scale(0.8); opacity: 0; transition: opacity 0.3s, transform 0.3s; z-index: 2; }
.btn.loading .btn__spinner { opacity: 1; transform: translate(-50%, -50%) scale(1); }
.btn__ripple { position: absolute; border-radius: 50%; background: rgba(255,255,255,0.3); transform: scale(0); animation: rippleAnim 0.6s ease-out; pointer-events: none; z-index: 3; }
@keyframes rippleAnim { to { transform: scale(4); opacity: 0; } }
.spinner { display: block; width: 22px; height: 22px; border: 2px solid rgba(0,0,0,0.2); border-top-color: #000; border-radius: 50%; animation: spin 0.8s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }

.divider { display: flex; align-items: center; gap: 16px; margin: 22px 0 16px; color: var(--text3, #5a5a78); font-size: 11px; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; font-family: var(--font-display, 'Orbitron', sans-serif); }
.divider::before, .divider::after { content: ''; flex: 1; height: 1px; background: linear-gradient(90deg, transparent, var(--border, rgba(0,240,255,0.08)), transparent); }

.social { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
.social-btn { height: 46px; background: rgba(255,255,255,0.03); border: 1.5px solid var(--border, rgba(0,240,255,0.08)); border-radius: 14px; color: var(--text2, #8a8aa8); font-family: inherit; font-size: 12px; font-weight: 600; cursor: pointer; transition: all 0.35s cubic-bezier(0.22, 1, 0.36, 1); display: flex; align-items: center; justify-content: center; gap: 8px; }
.social-btn:hover { border-color: var(--border-hover, rgba(0,240,255,0.25)); color: var(--text, #e8e8f0); background: rgba(0,240,255,0.03); transform: translateY(-2px); box-shadow: 0 12px 40px rgba(0,0,0,0.3); }
.social-btn svg { width: 18px; height: 18px; transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1); }
.social-btn:hover svg { transform: scale(1.15) rotate(-4deg); }

.terms { font-size: 11px; color: var(--text3, #5a5a78); line-height: 1.6; margin-bottom: 14px; text-align: center; }

/* ── 登录成功覆盖层 ── */
.success { position: fixed; inset: 0; z-index: 100; display: flex; flex-direction: column; align-items: center; justify-content: center; background: rgba(5,5,8,0.95); backdrop-filter: blur(12px); opacity: 0; pointer-events: none; transition: opacity 0.5s; }
.success.show { opacity: 1; pointer-events: auto; }
.success__text { margin-top: 60px; font-family: var(--font-display, 'Orbitron', sans-serif); font-size: 14px; color: var(--neon-blue, #00f0ff); letter-spacing: 2px; font-weight: 500; }

/* Pyramid Loader (保留原效果) */
.pyramid-loader { position: relative; width: 60px; height: 60px; display: block; transform-style: preserve-3d; transform: rotateX(-20deg); }
.wrapper { position: relative; width: 100%; height: 100%; transform-style: preserve-3d; animation: spin 2s linear infinite; }
@keyframes spin { 0% { transform: rotateY(0deg); } 100% { transform: rotateY(360deg); } }
.pyramid-loader .wrapper .side { width: 70px; height: 70px; position: absolute; top: 0; left: 0; right: 0; bottom: 0; margin: auto; transform-origin: center top; clip-path: polygon(50% 0%, 0% 100%, 100% 100%); }
.pyramid-loader .wrapper .side1 { transform: rotateZ(-30deg) rotateY(90deg); background: conic-gradient(var(--neon-blue, #00f0ff), var(--neon-violet, #b829f7)); }
.pyramid-loader .wrapper .side2 { transform: rotateZ(30deg) rotateY(90deg); background: conic-gradient(var(--neon-violet, #b829f7), var(--neon-pink, #ff2a8a)); }
.pyramid-loader .wrapper .side3 { transform: rotateX(30deg); background: conic-gradient(var(--neon-pink, #ff2a8a), var(--neon-blue, #00f0ff)); }
.pyramid-loader .wrapper .side4 { transform: rotateX(-30deg); background: conic-gradient(var(--neon-blue, #00f0ff), var(--neon-violet, #b829f7)); }
.pyramid-loader .wrapper .shadow { width: 70px; height: 70px; position: absolute; top: 0; left: 0; right: 0; bottom: 0; margin: auto; transform: rotateX(90deg) translateZ(-40px); filter: blur(12px); background: var(--neon-blue-glow, rgba(0,240,255,0.4)); }

@media (max-width: 960px) {
  .hero-side { display: none; }
  .form-side { width: 100%; padding: 32px 24px; }
  .login-card { max-width: 400px; padding: 32px 28px; }
}
</style>
