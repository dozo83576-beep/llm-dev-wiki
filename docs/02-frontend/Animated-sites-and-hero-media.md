---
title: "Animated sites and hero media"
category: "frontend"
updated: "2026-08-10"
status: "active"
tags: ["frontend", "animation", "hero", "video", "motion", "accessibility"]
source_priority: "official-docs"
area: "frontend"
---

# Animated sites and hero media

Нативная модель выбирает дизайн движения и пишет код. Этот документ нужен для границ технологии,
медиаконтракта и factual verification; он не активирует отдельный animation skill.

## Когда использовать

- hero должен объяснять продукт, задавать атмосферу или показывать реальный product demo;
- взаимодействие зависит от scroll, gestures, state machine, видео или 3D-объекта;
- нужно упаковать media с проверяемыми правами, размерами и fallback.

## Когда не использовать

- движение не связано с задачей пользователя и добавляется только ради эффекта;
- страница регулируемая, информационная или рассчитана на слабые устройства без отдельного motion-brief;
- статичный poster/иллюстрация решает задачу быстрее и понятнее.

## Production-паттерны

Сначала определить минимально достаточный уровень:

- **Base:** CSS animations, Web Animations API, View Transitions и progressive scroll-driven CSS.
  Motion подключается в React/Astro island, когда нужны gestures, layout transition или reactive scroll.
- **Cinematic:** GSAP ScrollTrigger только для явно требуемого pin/scrub/snap и многочастного
  scroll-storytelling. Перед зависимостью проверяется текущая лицензия.
- **Specialized:** Rive только с `.riv` и state/data-binding contract; Three.js — с реальной 3D-сценой
  или моделью. Обоим нужен статический fallback.

Отдельный hero остаётся `direct`. В полном проекте `site-design` фиксирует решение,
`site-frontend` интегрирует пакет, `site-review` подтверждает render. Новый skill не нужен.

## Режимы hero-video

### Decorative loop

- `muted autoplay loop playsinline`, без аудиодорожки, с poster и `aria-hidden`;
- доступная pause-кнопка для непрерывного движения дольше пяти секунд;
- `prefers-reduced-motion` и Save-Data оставляют poster;
- video приостанавливается вне viewport;
- mobile по умолчанию получает poster, если движение не несёт отдельной ценности.

### Meaningful video

Не запускать автоматически: нативные controls, captions/WebVTT, transcript и
`preload="metadata"` либо `none`. Смысл не должен зависеть только от аудио или движения.

### Synchronized overlays

Для DOM/canvas, синхронных с реально показанным кадром, использовать
`requestVideoFrameCallback()`. Scroll-scrubbed video — отдельный cinematic сценарий, а не default.

## Производство медиапакета

Локальный default — `D:\kontent`:

```powershell
py content_agent.py web-hero --brief hero-media-brief.json --output hero-media-package --dry-run
```

После проверки убрать `--dry-run`. Выход: MP4/H.264, WebM/VP9, `poster.webp`,
`media-manifest.json`, `generation-log.json`; meaningful video также содержит captions и transcript.
Raw provider output в сайт не встраивается.

Remotion создаёт детерминированный master, FFmpeg делает delivery variants и ffprobe-проверку.
Remotion Player не является обычным hero playback: он нужен только параметризованному редактору.

Sora Videos API — временный opt-in provider: OpenAI пометил Sora 2 deprecated и объявил shutdown
24 сентября 2026 года. Нужны свежий price snapshot, обезличивание, подтверждение terms/rights,
`--approve-paid-generation` и `--max-cost-usd`; после sunset адаптер блокируется. Сайт не должен
зависеть от доступности этого provider.

## Частые ошибки

- навязывание GSAP, Rive, Three.js или generative video без связи с brief;
- autoplay со звуком, отсутствие pause/captions/reduced-motion;
- raw provider MP4 или Remotion Player вместо оптимизированного delivery package;
- desktop crop на mobile, video без poster, лицензии или source provenance;
- объявление browser/performance проверки без фактического запуска.

## Проверка

В одном desktop/mobile осмотре проверить poster до первого кадра, читаемость текста, pause с
клавиатуры, reduced-motion/Save-Data, mobile crop, captions, layout shift, media/console errors,
LCP/INP/CLS, transfer bytes и long tasks. Исправить пакет находок и сделать подтверждающий smoke.

## Официальные источники

- [MDN View Transition API](https://developer.mozilla.org/en-US/docs/Web/API/View_Transition_API)
- [MDN scroll-driven animations](https://developer.mozilla.org/en-US/docs/Web/CSS/Guides/Scroll-driven_animations)
- [Motion scroll](https://motion.dev/docs/scroll), [GSAP ScrollTrigger](https://gsap.com/docs/v3/Plugins/ScrollTrigger/)
- [Rive Web runtime](https://rive.app/docs/runtimes/web/web-js), [Three.js fundamentals](https://threejs.org/manual/en/fundamentals.html)
- [MDN video](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/video), [web.dev video performance](https://web.dev/learn/performance/video-performance)
- [WCAG Pause, Stop, Hide](https://www.w3.org/WAI/WCAG22/Understanding/pause-stop-hide.html)
- [Remotion render](https://www.remotion.dev/docs/render), [Remotion license](https://www.remotion.dev/license)
- [OpenAI video generation](https://developers.openai.com/api/docs/guides/video-generation)

## Связанное

- [Motion](Motion.md)
- [Performance](Performance.md)
- [Hero video delivery](../../patterns/frontend/hero-video-delivery.md)
