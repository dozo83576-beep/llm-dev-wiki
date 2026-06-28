---
title: "Pattern: Анимированный hero как React-остров в Astro"
category: "pattern"
updated: "2026-06-29"
status: "active"
tags: ["frontend", "astro", "react", "framer-motion", "lenis", "hero", "motion", "islands"]
source_priority: "internal"
area: "frontend"
date: "2026-06-29"
---

# Pattern: Анимированный hero как React-остров в Astro

## Назначение

Дать богатый кинематографичный hero (оркестрованная анимация, scroll-parallax, ротация контента) на
статичном Astro-сайте, **не теряя выигрыш статики**: «дорогая» клиентская анимация изолирована в
одном React-острове, остальные секции остаются чистым Astro/HTML с быстрым LCP.

## Когда использовать

- Премиальный лендинг/контентный сайт на Astro, где нужен выразительный первый экран.
- Нужна оркестровка (stagger, AnimatePresence, scroll-driven transforms), которую неудобно делать на
  голом CSS/IntersectionObserver.

## Когда не использовать

- Анимация простая (fade/translate на скролле) — хватает CSS + IntersectionObserver, остров не нужен.
- Хочется много островов по странице — теряется смысл статики; держи остров только там, где он оправдан.

## Структура

- `@astrojs/react`, остров `Hero.tsx` с `client:load` (текст рендерится в SSR-HTML → SEO/LCP ок).
- **Framer Motion** (пакет `motion`, импорт из `motion/react`): `useScroll`/`useTransform` для
  parallax, `motion.*` + variants для входной оркестровки, `AnimatePresence` для ротации.
- **Lenis** — smooth-scroll (инициализировать один раз; уважать reduced-motion).
- Остальные секции — статичный Astro + лёгкий IntersectionObserver-reveal.

## Production-паттерны

1. **`prefers-reduced-motion` обязателен.** `useReducedMotion()` гейтит parallax/ротацию/Ken-Burns;
   при reduce — статичный кадр и статичный список (без интервалов). CSS-ветка дублирует гейт.
2. **Анимируем только `transform`/`opacity`.** Входная оркестровка — один stagger (слова заголовка
   ~0.1s, элементы ~0.12s), без россыпи микро-интеракций (см. purposeful-motion).
3. **Легибельность текста поверх фото.** Над ярким фоном белый текст «вымывается». Слои:
   - многостоповый veil-градиент (затемнение слева/снизу, где лежит текст);
   - **локальный radial-scrim** только за второстепенным блоком (не затемняя весь кадр);
   - `text-shadow: 0 2px 18px rgba(0,0,0,.9)` на мелком тексте;
   - акцентный цвет ярче приглушённого (eyebrow в фирменном тёплом, а не сером).
4. **Ротация коротких фраз — детерминированный line-split.** Чтобы строки не ломались по одному
   слову, **хранить заранее разбитые строки** (массив строк по 2 слова), а не полагаться на
   автоперенос. Контейнеру задать **фикс-ширину** (`w-[…]`, не `max-w`): абсолютный, right-anchored
   элемент без явной ширины уходит в shrink-to-fit и переносит на каждом пробеле (столбик по слову).
   ```tsx
   // data: principles: string[][]  // каждый принцип = строки по 2 слова
   <div className="absolute right-[6%] top-1/2 w-[22rem] -translate-y-1/2 text-right">
     <AnimatePresence mode="wait">
       <motion.p key={i} initial={{opacity:0,y:16}} animate={{opacity:1,y:0}} exit={{opacity:0,y:-16}}
                 className="absolute right-0 top-0 w-full">
         {items[i].map(l => <span key={l} className="block">{l}</span>)}
       </motion.p>
     </AnimatePresence>
   </div>
   ```
   Слот ротации — фиксированной высоты (`h-[…]`), чтобы индикатор/точки не прыгали.
5. **Остров минимальный.** В острове — только hero; данные тянуть из общего `content.ts`, чтобы
   статичные секции и остров не расходились.

## Частые ошибки

- Absolute right-anchored текст без `w-[…]` → shrink-to-fit ломает фразу в один столбик по слову.
- Забыть reduced-motion в острове ИЛИ в CSS — анимация прорывается в одном из путей.
- Тяжёлый blur/particle-фон в острове — бьёт по INP/LCP.
- Белый текст поверх яркого фото без scrim/shadow — нечитаемо на светлых участках.
- Много `client:load`-островов — теряется смысл статичного Astro.

## Связано

- [Pattern: purposeful motion](purposeful-motion.md)
- [Pattern: semantic theme text tokens](semantic-theme-text-tokens.md)
- [Pattern: cyrillic self-host fonts](cyrillic-self-host-fonts.md)
- [Pattern: full-height first screen](full-height-first-screen.md)
- [Case: LUMA premium beauty animated landing](../../case-studies/successes/2026-06-29-luma-premium-beauty-animated-landing.md)
- [docs/02-frontend/Motion](../../docs/02-frontend/Motion.md)
