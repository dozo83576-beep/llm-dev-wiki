---
title: "Премиальный анимированный одностраничник салона красоты (LUMA)"
category: "case-study"
updated: "2026-06-29"
status: "validated"
tags: ["frontend", "astro", "tailwind", "framer-motion", "lenis", "landing", "beauty", "cyrillic", "vercel"]
source_priority: "internal"
date: "2026-06-29"
project_type: "Landing"
stack: ["Astro 7", "Tailwind v4", "@astrojs/react", "Framer Motion (motion)", "Lenis", "Vercel (static)"]
---

# Контекст

Премиальный одностраничный сайт салона красоты (уход за лицом/телом, массаж, проблемная кожа, SPA)
для русскоязычной аудитории. Ключевое требование клиента — **не статичный hero, а динамичный
кинематографичный**, упакованный в стиле тёмной «сценической» дизайн-системы (референс с
styles.refero.design). Контент (тексты, фото, структуру) наполнял агент. Бренд «LUMA» вымышленный,
данные демонстрационные.

# Решение

- **Стек:** Astro 7 (output static) + Tailwind v4 через `@tailwindcss/vite`; **React-остров только
  для hero** (`@astrojs/react`, `client:load`) на **Framer Motion** (пакет `motion`); **Lenis**
  smooth-scroll; reveal остальных секций — лёгкий IntersectionObserver, без тяжёлых либ.
- **Шрифты self-host:** кириллические + латинские woff2-сабсеты (Cormorant display + Onest body +
  JetBrains Mono meta) с ручными `@font-face` и `unicode-range`; preload ключевых начертаний.
- **Дизайн-направление:** тёмная кинематографичная «сцена» (`#0a0a0b`) + один тёплый акцент (янтарь
  `#d9a35c`); семантические токены текста по поверхностям (on-dark / on-light); eyebrow-mono-лейблы,
  ghost-индексы, hairline-разделители, editorial image-cards, pill-кнопки.
- **Hero** — фоновое фото-интерьер с Ken-Burns + scroll-parallax, заголовок по словам (mask/stagger),
  ротация «принципов» справа, локальный scrim + text-shadow для читаемости поверх яркого фото,
  обязательный `prefers-reduced-motion`.
- **Структура:** одностраничный лендинг, секции на всю высоту (`min-h-[100svh]` + центрирование) —
  один блок на экран.
- **Деплой:** статикой на Vercel через GitHub-import — **без адаптера** (framework auto-detect:
  build `astro build`, output `dist`); `site` в `astro.config` прописан под прод-домен для
  canonical/OG/sitemap.

# Почему сработало

- React-остров изолировал «дорогую» анимацию в одном месте — остальной сайт остаётся статикой Astro
  с быстрым LCP/SEO. Богатая оркестровка hero там, где она реально нужна.
- Self-host кириллических woff2 убрал внешний CDN как точку отказа первого экрана и tofu на русском.
- Тёмная «сцена» + один тёплый акцент дали премиальный вид, отличный от шаблонного «AI-вида»
  (кремовый фон + serif + терракот), и не нарушили achromatic-дисциплину.
- Деплой статикой без адаптера — минимум конфигурации, авто-деплой на каждый push.

# Кодовые и архитектурные паттерны

- [Astro + React-island анимированный hero](../../patterns/frontend/astro-react-island-animated-hero.md)
  — Framer Motion + Lenis, reduced-motion, scrim для читаемости, детерминированный line-split ротации.
- [Cyrillic self-host fonts](../../patterns/frontend/cyrillic-self-host-fonts.md) — woff2 сабсеты вручную.
- [Semantic theme text tokens](../../patterns/frontend/semantic-theme-text-tokens.md) — text-on-dark/light.
- [Full-height first screen → один блок на экран](../../patterns/frontend/full-height-first-screen.md).
- [Проверка stock-фото](../../patterns/frontend/stock-photo-id-verification.md) — визуальная проверка
  каждого портрета, alt ненадёжен по внешности.

# Ограничения

- Подходит для маркетингового лендинга/контентного сайта; для SSR-эндпоинтов на Vercel нужен адаптер
  (см. lesson про `@astrojs/vercel`).
- Анимация hero вынесена в React-остров — это единственная клиентская гидратация; не злоупотреблять
  островами, иначе теряется выигрыш статики.
- Форма записи в проекте — дизайн-заглушка без backend; рабочая доставка заявок — отдельная задача.

# Проверка

- `npm run build` зелёный (на Windows печатает «Complete!», но процесс может вернуть exit code 9 —
  libuv teardown, безвредно).
- Прод-проверка: self-host шрифт подгружается, hero-изображение (2400px) и все фото грузятся,
  все секции рендерятся, кириллица без квадратов, **0 ошибок в консоли**.
- Визуальная верификация секций на desktop (1440/1920) и mobile (390), отсутствие горизонтального
  overflow; reduced-motion гасит анимации.

# Ссылки

- [Lesson: Astro 7 → Vercel статикой без адаптера](../../lessons-learned/2026-06-29-astro7-vercel-static-no-adapter.md)
- [Lesson: Astro 7 + Tailwind v4 vite-плагин](../../lessons-learned/2026-06-23-astro7-tailwind4-vite-plugin.md)
- [Pattern: purposeful motion](../../patterns/frontend/purposeful-motion.md)
- [docs/02-frontend/Typography-fonts](../../docs/02-frontend/Typography-fonts.md)
