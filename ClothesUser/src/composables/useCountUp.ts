import { ref, watch, type Ref } from 'vue'

export function useCountUp(target: Ref<number | string | undefined | null>, duration = 600) {
  const display = ref('0')

  watch(target, (val) => {
    const num = Number(val) || 0
    if (num <= 0) { display.value = '0'; return }

    const start = performance.now()
    const animate = (now: number) => {
      const elapsed = now - start
      const progress = Math.min(elapsed / duration, 1)
      // ease-out quad
      const eased = 1 - (1 - progress) * (1 - progress)
      display.value = String(Math.floor(eased * num))
      if (progress < 1) requestAnimationFrame(animate)
      else display.value = String(num)
    }
    requestAnimationFrame(animate)
  }, { immediate: true })

  return display
}
