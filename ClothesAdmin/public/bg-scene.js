/* NEXUS Admin - 3D Background Scene (admin-login-demo style) */
import * as THREE from 'three';
import { EffectComposer } from 'three/addons/postprocessing/EffectComposer.js';
import { RenderPass } from 'three/addons/postprocessing/RenderPass.js';
import { UnrealBloomPass } from 'three/addons/postprocessing/UnrealBloomPass.js';
import { OutputPass } from 'three/addons/postprocessing/OutputPass.js';

const container = document.getElementById('three-bg');
if (!container) throw new Error('#three-bg not found');

const renderer = new THREE.WebGLRenderer({antialias:true,alpha:true});
renderer.setSize(innerWidth,innerHeight);
renderer.setPixelRatio(Math.min(devicePixelRatio,2));
renderer.toneMapping=THREE.ACESFilmicToneMapping;
renderer.toneMappingExposure=1.15;
renderer.setClearColor(0x000000,0);
container.appendChild(renderer.domElement);

const scene=new THREE.Scene();
scene.fog=new THREE.FogExp2(0x050508,0.008);

const camera=new THREE.PerspectiveCamera(45,innerWidth/innerHeight,0.1,1000);
camera.position.set(3,2,5);camera.lookAt(0,0,0);

const composer=new EffectComposer(renderer);
composer.addPass(new RenderPass(scene,camera));
composer.addPass(new UnrealBloomPass(new THREE.Vector2(innerWidth,innerHeight),0.6,0.3,0.5));
composer.addPass(new OutputPass());

const ambient=new THREE.AmbientLight(0x222222);scene.add(ambient);
const mainLight=new THREE.DirectionalLight(0xffffff,1.2);mainLight.position.set(2,3,4);scene.add(mainLight);
scene.add(new THREE.PointLight(0x4466cc,0.6,10).position.set(-2,1,-3));
scene.add(new THREE.PointLight(0xffaa66,0.5,10).position.set(1.5,1,2));
scene.add(new THREE.PointLight(0xffaa44,0.8,10).position.set(1,1,2));

const starsGeo=new THREE.BufferGeometry();
const starsPos=new Float32Array(800*3);
for(let i=0;i<800;i++){starsPos[i*3]=200*(Math.random()-0.5);starsPos[i*3+1]=100*(Math.random()-0.5);starsPos[i*3+2]=80*(Math.random()-0.5)-40;}
starsGeo.setAttribute('position',new THREE.BufferAttribute(starsPos,3));
scene.add(new THREE.Points(starsGeo,new THREE.PointsMaterial({color:0xaaccff,size:0.08,transparent:true,opacity:0.6})));

const auraGroup=new THREE.Group();
auraGroup.position.set(-2.2,0.1,0);auraGroup.scale.setScalar(0.75);
scene.add(auraGroup);

const icoGeo=new THREE.IcosahedronGeometry(1.1,0);
const coreMat=new THREE.MeshStandardMaterial({color:0x4a7c4c,emissive:0x112233,roughness:0.28,metalness:0.75,transparent:true,opacity:0.92});
const coreMesh=new THREE.Mesh(icoGeo,coreMat);auraGroup.add(coreMesh);
const wireMat=new THREE.MeshBasicMaterial({color:0x66ccff,wireframe:true,transparent:true,opacity:0.25});
const wireIco=new THREE.Mesh(icoGeo,wireMat);wireIco.scale.setScalar(1.08);auraGroup.add(wireIco);

// Ring particles
const rCount=1200;const rGeo=new THREE.BufferGeometry();
const rPos=new Float32Array(rCount*3),rCol=new Float32Array(rCount*3);
for(let i=0;i<rCount;i++){const t=(i/rCount)*Math.PI*2,r=1.55;rPos[i*3]=Math.cos(t)*r;rPos[i*3+1]=0.35*Math.sin(3*t);rPos[i*3+2]=Math.sin(t)*r;rCol[i*3]=0.4+0.6*Math.sin(t);rCol[i*3+1]=0.3+0.7*Math.cos(1.7*t);rCol[i*3+2]=0.8+0.2*Math.sin(2.3*t);}
rGeo.setAttribute('position',new THREE.BufferAttribute(rPos,3));rGeo.setAttribute('color',new THREE.BufferAttribute(rCol,3));
const rParticles=new THREE.Points(rGeo,new THREE.PointsMaterial({size:0.05,vertexColors:true,transparent:true,blending:THREE.AdditiveBlending}));auraGroup.add(rParticles);

const torusMat=new THREE.MeshStandardMaterial({color:0x88aadd,emissive:0x225522,roughness:0.3,metalness:0.9});
const t1=new THREE.Mesh(new THREE.TorusGeometry(1.45,0.045,64,500),torusMat);auraGroup.add(t1);
const t2=new THREE.Mesh(new THREE.TorusGeometry(1.68,0.03,64,500),torusMat.clone());t2.material.color.setHex(0xffcc66);t2.material.emissive.setHex(0x442200);auraGroup.add(t2);

const cCount=800;const cGeo=new THREE.BufferGeometry();const cPos=new Float32Array(cCount*3);
for(let i=0;i<cCount;i++){cPos[i*3]=5*(Math.random()-0.5);cPos[i*3+1]=3*(Math.random()-0.5);cPos[i*3+2]=4*(Math.random()-0.5)-1;}
cGeo.setAttribute('position',new THREE.BufferAttribute(cPos,3));
auraGroup.add(new THREE.Points(cGeo,new THREE.PointsMaterial({color:0x77aaff,size:0.025,transparent:true,opacity:0.4,blending:THREE.AdditiveBlending})));

let time=0,animId=0;
function animate(){animId=requestAnimationFrame(animate);time+=0.006;
  // 星球式自转：整体平滑旋转
  auraGroup.rotation.x=time*0.12;
  auraGroup.rotation.y=time*0.2;
  auraGroup.rotation.z=time*0.06;
  coreMesh.rotation.x=Math.sin(time*0.3)*0.08;
  t1.rotation.x=Math.PI/2;t1.rotation.z=time*0.4;t2.rotation.x=Math.PI/2+0.3;t2.rotation.z=time*0.5;
  composer.render();}
animate();

window.addEventListener('resize',()=>{camera.aspect=innerWidth/innerHeight;camera.updateProjectionMatrix();renderer.setSize(innerWidth,innerHeight);composer.setSize(innerWidth,innerHeight);});