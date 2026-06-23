/* ===== Canvas 粒子连线背景 ===== */
const canvas = document.getElementById('bg-canvas');
const ctx = canvas.getContext('2d');
let W, H, particles = [];

function resize() {
  W = canvas.width = window.innerWidth;
  H = canvas.height = window.innerHeight;
}
resize();
window.addEventListener('resize', resize);

class Particle {
  constructor() {
    this.x = Math.random() * W;
    this.y = Math.random() * H;
    this.vx = (Math.random() - 0.5) * 0.4;
    this.vy = (Math.random() - 0.5) * 0.4;
    this.size = Math.random() * 1.5 + 0.5;
  }
  update() {
    this.x += this.vx; this.y += this.vy;
    if (this.x < 0 || this.x > W) this.vx *= -1;
    if (this.y < 0 || this.y > H) this.vy *= -1;
  }
  draw() {
    ctx.beginPath();
    ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
    ctx.fillStyle = 'rgba(0,240,255,0.2)';
    ctx.fill();
  }
}

for (let i = 0; i < 50; i++) particles.push(new Particle());

function drawLines() {
  for (let i = 0; i < particles.length; i++) {
    for (let j = i + 1; j < particles.length; j++) {
      const dx = particles[i].x - particles[j].x;
      const dy = particles[i].y - particles[j].y;
      const dist = Math.sqrt(dx * dx + dy * dy);
      if (dist < 150) {
        ctx.beginPath();
        ctx.moveTo(particles[i].x, particles[i].y);
        ctx.lineTo(particles[j].x, particles[j].y);
        ctx.strokeStyle = `rgba(0,240,255,${0.06 * (1 - dist / 150)})`;
        ctx.lineWidth = 0.5;
        ctx.stroke();
      }
    }
  }
}

function animate() {
  ctx.clearRect(0, 0, W, H);
  particles.forEach(p => { p.update(); p.draw(); });
  drawLines();
  requestAnimationFrame(animate);
}
animate();

/* ===== 滚动显现动画 ===== */
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible');
      observer.unobserve(entry.target);
    }
  });
}, { threshold: 0.08 });

document.querySelectorAll('.reveal').forEach(el => observer.observe(el));

/* ===== Hero 轮播图逻辑 ===== */
const heroSlides = document.querySelectorAll('.hero-slide');
const heroDots = document.querySelectorAll('.hero-dot');
const heroPrev = document.getElementById('hero-prev');
const heroNext = document.getElementById('hero-next');
let currentSlide = 0;
let slideInterval;

function showSlide(index) {
  heroSlides.forEach((slide, i) => {
    slide.classList.toggle('active', i === index);
  });
  heroDots.forEach((dot, i) => {
    dot.classList.toggle('active', i === index);
  });
  currentSlide = index;
}

function nextSlide() {
  showSlide((currentSlide + 1) % heroSlides.length);
}

function prevSlide() {
  showSlide((currentSlide - 1 + heroSlides.length) % heroSlides.length);
}

function startAutoplay() {
  slideInterval = setInterval(nextSlide, 5000);
}

function stopAutoplay() {
  clearInterval(slideInterval);
}

heroNext.addEventListener('click', () => { stopAutoplay(); nextSlide(); startAutoplay(); });
heroPrev.addEventListener('click', () => { stopAutoplay(); prevSlide(); startAutoplay(); });

heroDots.forEach(dot => {
  dot.addEventListener('click', () => {
    stopAutoplay();
    showSlide(Number(dot.dataset.index));
    startAutoplay();
  });
});

startAutoplay();

/* ===== 3D 球体鼠标交互 ===== */
document.querySelectorAll('[data-orb]').forEach(orb => {
  orb.addEventListener('mousemove', e => {
    const rect = orb.getBoundingClientRect();
    const x = (e.clientX - rect.left) / rect.width - 0.5;
    const y = (e.clientY - rect.top) / rect.height - 0.5;
    orb.style.transform = `rotateY(${x * 50}deg) rotateX(${-y * 50}deg) scale(1.06)`;
  });
  orb.addEventListener('mouseleave', () => {
    orb.style.transform = '';
  });
});
