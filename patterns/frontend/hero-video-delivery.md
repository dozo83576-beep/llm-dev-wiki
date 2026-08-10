---
title: "Hero video delivery"
category: "pattern"
updated: "2026-08-10"
status: "active"
tags: ["frontend", "hero", "video", "accessibility", "performance"]
source_priority: "internal"
area: "frontend"
---

# Hero video delivery

## Проблема

Raw video или Remotion Player в первом экране увеличивает page weight, ломает autoplay/reduced-motion
и не оставляет проверяемого происхождения. Решение — предварительно собранный медиапакет с manifest.

## Контракт

```ts
type HeroMediaManifest = {
  schemaVersion: 1;
  projectId: string;
  purpose: "decorative-loop" | "product-demo" | "narrative-video" | "interactive-scene";
  decorative: boolean;
  loop: boolean;
  audio: "none" | "meaningful";
  sources: Record<"desktop" | "mobile", Array<{
    path: string; bytes: number; sha256: string; codec: string;
    width: number; height: number; durationSeconds: number; hasAudio: boolean;
  }>>;
  poster: {path: string; bytes: number; sha256: string};
  captions?: string | null;
  transcript?: string | null;
};
```

`mobile` может отсутствовать. Интегратор выбирает WebM/MP4 из manifest и не угадывает пути.

## Decorative implementation

Video получает `muted`, `autoplay`, `loop`, `playsinline`, poster и фиксированные размеры.
Pause-кнопка остаётся в accessibility tree, само декоративное video — нет. До загрузки и при
reduced-motion/Save-Data отображается poster. IntersectionObserver приостанавливает video вне viewport.

## Meaningful implementation

Video запускает пользователь, имеет controls и `<track kind="captions">`; рядом доступен transcript.
Не применять `aria-hidden`, autoplay без звука или скрытую custom-панель без keyboard semantics.

## Проверка

- manifest и SHA-256 соответствуют файлам;
- decorative output не содержит audio stream;
- poster существует до первого кадра и не вызывает CLS;
- pause, captions, reduced-motion, Save-Data и mobile crop проверены в браузере;
- media bytes входят в project-specific performance budget.

## Связанное

- [Animated sites and hero media](../../docs/02-frontend/Animated-sites-and-hero-media.md)
- [Performance](../../docs/02-frontend/Performance.md)
- [Accessibility](../../docs/02-frontend/Accessibility.md)
