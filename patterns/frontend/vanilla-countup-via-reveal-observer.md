---
title: "Pattern: Count-up чисел через существующий IntersectionObserver, без нового острова"
category: "pattern"
updated: "2026-07-02"
status: "active"
tags: ["frontend", "astro", "vanilla-js", "intersection-observer", "animation", "islands"]
source_priority: "internal"
area: "frontend"
date: "2026-07-02"
---

# Pattern: Count-up чисел через существующий IntersectionObserver, без нового острова

## Назначение

Дать статистике/цифрам на статичной Astro-секции (12 лет, 40+, 100% и т.п.) анимацию count-up
(0 → значение при попадании в вьюпорт) **не заводя новый React-остров** ради одной короткой анимации.

## Когда использовать

- Секция уже статичный Astro-компонент, на странице уже есть общий scroll-reveal через
  `IntersectionObserver` (см. `src/lib/reveal.ts` в проекте) для fade-in анимаций.
- Нужна анимация ровно одного типа (числовой counter), без оркестровки/stagger/AnimatePresence —
  то, что реально требует Framer Motion, см. `astro-react-island-animated-hero.md`.

## Когда не использовать

- Уже нужна оркестровка нескольких элементов, ротация контента, scroll-linked parallax — тогда это
  уже кейс для React-острова (не плоди два разных механизма анимации на одной странице).
- Секция сама по себе React-компонент — тогда count-up естественнее сделать через
  `useInView`+`useMotionValue` из той же Framer Motion, отдельный vanilla-путь не нужен.

## Структура

- Разметка: `<span data-count-to={value}>0</span>` — сразу рендерим `0` как безопасный SSR-фолбэк
  (не финальное число), сам observer подставит анимацию или финальное значение на клиенте.
- Один `IntersectionObserver` на все `[data-count-to]` сразу (не по одному наблюдателю на элемент).
- `requestAnimationFrame`-цикл с ease-out (кубический), не `setInterval` — плавнее и не блокирует поток.
- Уважение `prefers-reduced-motion`: сразу выставить финальное значение, без анимации и без
  `IntersectionObserver` вообще (тот же флаг, что уже гейтит fade-in reveal в этом же файле).
- Функция регистрируется в общем `init()` рядом с существующим `initReveal()` — один общий
  `DOMContentLoaded`/immediate-запуск на страницу, не второй отдельный `<script>`.

## Реализация (пример)

```ts
// src/lib/reveal.ts — рядом с уже существующим initReveal()
function initCountUp() {
  const els = document.querySelectorAll<HTMLElement>("[data-count-to]");
  if (!els.length) return;

  const setFinal = (el: HTMLElement) => { el.textContent = el.dataset.countTo ?? "0"; };

  if (prefersReduced || !("IntersectionObserver" in window)) {
    els.forEach(setFinal);
    return;
  }

  const animate = (el: HTMLElement) => {
    const target = parseInt(el.dataset.countTo ?? "0", 10);
    if (!target) return setFinal(el);
    const duration = 1400;
    const start = performance.now();
    const step = (now: number) => {
      const progress = Math.min(1, (now - start) / duration);
      const eased = 1 - Math.pow(1 - progress, 3);
      el.textContent = String(Math.round(eased * target));
      if (progress < 1) requestAnimationFrame(step);
    };
    requestAnimationFrame(step);
  };

  const io = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        animate(entry.target as HTMLElement);
        io.unobserve(entry.target);
      }
    });
  }, { rootMargin: "0px 0px -10% 0px", threshold: 0.4 });
  els.forEach((el) => io.observe(el));
}
```
```astro
<p><span data-count-to={stat.value}>0</span>{stat.suffix}</p>
```

## Production-паттерны

- `threshold: 0.4` (выше, чем у обычного fade-in reveal, там обычно 0.15) — цифра не должна начинать
  считаться, когда карточка едва показалась на 15% высоты; для counter естественнее ждать, пока
  большая часть карточки видна.
- `io.unobserve(entry.target)` после первого срабатывания — считаем один раз за посещение, не при
  каждом скролле туда-обратно.
- Если элемент уже в зоне видимости сразу при загрузке страницы (например, пользователь открыл сайт
  уже проскроленным по anchor-ссылке) — анимация просто отыграет сразу на `DOMContentLoaded`, это
  нормально и не требует отдельной обработки.

## Частые ошибки

- Отдельный `IntersectionObserver` на каждый элемент вместо одного на все `[data-count-to]` —
  не критично при 4 цифрах, но не масштабируется и плодит наблюдатели без причины.
- `setInterval` вместо `requestAnimationFrame` — рвано анимируется и не синхронизировано с рендером.
- Забыть SSR-фолбэк `0` в разметке — при отключённом JS/до гидратации показывается пустота вместо
  разумного дефолта.
- Заводить React-остров ради одной этой анимации — прямое нарушение принципа «остров минимальный» из
  `astro-react-island-animated-hero.md`; эта секция была и осталась чистым Astro.

## Альтернативы

- Framer Motion `useInView` + `useMotionValue`/`animate()` — оправдано, только если секция и так уже
  React-остров (см. `astro-react-island-animated-hero.md`) или нужна более сложная оркестровка.
- CSS `@property`+`counter-reset` анимация — работает без JS вообще, но нет ease-out кастомизации и
  Safari-поддержка исторически неровная; JS-путь даёт больше контроля за похожую сложность кода.

## Источники

- Внутренний кейс: блок цифр (12 лет/40+/1 на 1/100%) на
  [LUMA premium beauty landing](../../case-studies/successes/2026-06-29-luma-premium-beauty-animated-landing.md),
  добавлен при слиянии секций Философия+Почему-ЛУМА.
- [Pattern: Анимированный hero как React-остров в Astro](astro-react-island-animated-hero.md) —
  принцип «остров минимальный», который этот паттерн реализует за пределами hero.
