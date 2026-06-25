---
title: "Lesson: Astro 7 + Tailwind v4 — vite-плагин, не postcss"
category: "lesson"
updated: "2026-06-23"
status: "active"
tags: ["astro", "tailwind", "build", "rolldown", "frontend"]
source_priority: "internal"
date: "2026-06-23"
project_type: "landing"
---

# Lesson: Astro 7 + Tailwind v4 — vite-плагин, не postcss

## TL;DR

На **Astro 7** Tailwind v4 подключай через `@tailwindcss/vite`
(`vite: { plugins: [tailwindcss()] }`) — он собирается чисто. Обходной путь
через `@tailwindcss/postcss` нужен только для **Astro 6**; на Astro 7 он,
наоборот, ломает prod-сборку.

## Контекст

Лендинг на Astro 7 (rolldown-vite) + Tailwind v4. Память проекта фиксировала
Astro-6-правило «использовать `@tailwindcss/postcss`, не `@tailwindcss/vite`»
(в Astro 6 vite-плагин падал: `Missing field tsconfigPaths ...`,
withastro/astro#16542).

## Что произошло

Применили Astro-6-рецепт на Astro 7: `postcss.config.mjs` с
`@tailwindcss/postcss` + `@import "tailwindcss"` в CSS. `npm run build` упал:

```
[postcss] ENOENT: no such file or directory, open '.../tailwindcss'
  at parseStyles (postcss-import.js)
```

Переключение на `@tailwindcss/vite` (`npx … ` вручную: добавить плагин в
`astro.config` `vite.plugins`, удалить `postcss.config.mjs`) — сборка зелёная.

## Корень

В Astro 7 встроенный rolldown-vite сам прогоняет `postcss-import`, который
пытается резолвить bare-спецификатор `@import "tailwindcss"` как файл и не
читает `exports`-карту пакета Tailwind v4 → ENOENT. `@tailwindcss/vite`
перехватывает `@import "tailwindcss"` раньше и резолвит корректно. Баг Astro 6
с `tsconfigPaths`, из-за которого раньше избегали vite-плагина, в Astro 7 уже
исправлен.

## Новое правило

- Когда **Astro 7+ и Tailwind v4** → подключай `@tailwindcss/vite`, не postcss.
- Когда **Astro 6 и Tailwind v4** → `@tailwindcss/postcss` + `postcss.config.mjs`
  (vite-плагин там падает).
- Всегда после первой сборки проверяй `npm run build` (dev может работать, а
  prod — нет): обе связки «работают в dev».

## Применимость

Только Astro + Tailwind v4. Для Vite-проектов без Astro `@tailwindcss/vite` —
дефолт всегда. Self-host шрифтов в `public/fonts/` остаётся обязательным в обеих
версиях (rolldown не эмитит `@fontsource` woff2 из CSS-пакета).

## Обновлённые документы

- [docs/02-frontend/Astro.md](../docs/02-frontend/Astro.md) — добавить версию-зависимое
  правило подключения Tailwind v4.

## Ссылки

- [Pattern: Cyrillic / self-host fonts](../patterns/frontend/cyrillic-self-host-fonts.md)
- withastro/astro#16542 (Astro 6 vite-плагин), Tailwind v4 docs (vite plugin)
