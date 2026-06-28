---
title: "Astro 7 → Vercel статикой: без адаптера, деплой через GitHub-import"
category: "lesson"
updated: "2026-06-29"
status: "active"
tags: ["astro", "vercel", "deploy", "static", "github"]
source_priority: "internal"
---

# Astro 7 → Vercel статикой: без адаптера, деплой через GitHub-import

## Контекст

Статический Astro-сайт (output по умолчанию `static`) деплоится на Vercel **без `@astrojs/vercel`**.
Vercel сам определяет фреймворк Astro: build `astro build`, output `dist`, отдаёт как статику.
Адаптер `@astrojs/vercel` нужен только для `output: 'server'/'hybrid'` (SSR-эндпоинты).

## Урок

- **Не добавляй адаптер для чисто статичного сайта** — лишняя зависимость и конфиг. Адаптер — только
  если есть серверные роуты/`output: 'server'` (тогда см. lesson про import-path адаптера, ниже).
- **Деплой через GitHub-import** (без шаринга секретов, без интерактивного `vercel login`):
  ```
  git -C <dir> init -b main
  git -C <dir> add -A; git -C <dir> commit -m "init"
  gh repo create <name> --private --source <dir> --remote origin --push
  ```
  Затем в Vercel «New → Import» выбрать репозиторий (для приватного — выдать доступ Vercel GitHub App).
  Дальше авто-деплой на каждый push в `main`.
- **Пропиши `site` в `astro.config`** под прод-домен (`https://<project>.vercel.app` или кастомный)
  — иначе `@astrojs/sitemap`, canonical и OG берут плейсхолдер. Дефолтный домен проекта обычно
  `<repo-name>.vercel.app`; если занят — обновить `site` под фактический и запушить.
- **Windows-нюанс:** `npm run build` печатает `Complete!`, но процесс может вернуть **exit code 9**
  (libuv teardown на выходе) — сборка при этом валидна, артефакты в `dist` целы. Проверять по
  наличию `dist/index.html` и эмиту ассетов, а не только по коду возврата.

## Проверка

- `npm run build` → `dist/index.html` существует, woff2/изображения в `dist`.
- После деплоя: страница открывается, шрифты/изображения грузятся, `0` ошибок в консоли (Playwright).
- `site` совпадает с фактическим прод-доменом (canonical/OG/sitemap корректны).

## Связано

- [Lesson: Astro 7 + Vercel adapter (SSR, import-path, audit)](2026-06-25-astro7-vercel-adapter.md)
- [Lesson: Astro 7 + Tailwind v4 vite-плагин](2026-06-23-astro7-tailwind4-vite-plugin.md)
- [Pattern: preview before production](../patterns/devops/preview-before-production.md)
- [Case: LUMA premium beauty animated landing](../case-studies/successes/2026-06-29-luma-premium-beauty-animated-landing.md)
