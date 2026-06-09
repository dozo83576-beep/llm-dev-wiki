---
title: "Vike"
category: "frontend"
updated: "2026-06-10"
status: "active"
tags: ["vike", "vite", "ssr", "meta-framework"]
source_priority: "official-docs"
---

# Vike

Vike — Vite-based meta-framework для команд, которым нужны SSR/SSG/SPA render modes и больше архитектурной свободы, чем в opinionated frameworks.

## Когда использовать

- Команда хочет выбирать React/Vue/Solid and runtime pieces самостоятельно.
- Нужны per-page render modes: SSR, pre-rendering, SPA, HTML-only.
- Existing Vite app нужно развить до SSR/SSG без перехода на Next/Nuxt.
- Есть senior ownership над routing, data loading, deploy and caching.

## Когда не использовать

- Команда хочет batteries-included framework and large ecosystem defaults.
- Нужен самый быстрый path для типового SaaS: Next.js/TanStack Start проще.
- Нужен content-first static site: Astro/Eleventy/Hugo проще.
- Нет времени проектировать conventions.

## Production-паттерны

- Render mode фиксируется per route and documented.
- Data fetching/cache ownership проектируется явно.
- Deployment adapter/runtime проверяется до реализации.
- Error boundaries, redirects, status codes and SEO metadata тестируются.
- Shared conventions нужно записать в project-local docs.

## Частые ошибки

- Выбирать Vike ради “свободы”, но не назначить owners for conventions.
- Смешивать render modes без cache/SEO contract.
- Недооценить complexity SSR deployment.
- Переносить Next.js assumptions без проверки.

## Проверка

Проверь route rendering, status codes, redirects, hydration, data errors, SEO metadata, deployment target and site audit.

## Источники

- [Vike Docs](https://vike.dev/)
- [Vike render modes](https://vike.dev/render-modes)
- См. [Vite + React](Vite-React.md), [Frontend blueprints](Frontend-blueprints.md), [Runtime selection](../01-development-process/runtime-selection.md).
