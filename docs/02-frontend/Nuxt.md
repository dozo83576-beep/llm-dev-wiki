---
title: "Nuxt"
category: "frontend"
updated: "2026-06-04"
status: "active"
tags: ["nuxt", "vue", "ssr", "frontend"]
source_priority: "official-docs"
---

# Nuxt

Nuxt — Vue full-stack/meta-framework для SSR/SSG, routing, layouts, server endpoints, content sites и Vue ecosystem projects. Он нужен wiki как non-React production option.

Если вопрос звучит как "когда выбрать Nuxt вместо React", используй Nuxt, когда команда и component ecosystem уже на Vue, а продукту нужны SSR/SSG, content pages и server routes.

## Когда использовать

- Команда сильнее во Vue, чем в React.
- Нужны SSR/SSG, content pages, layouts, server routes и хорошая DX вокруг Vue SFC.
- Проект — marketing/content site, dashboard, storefront или app shell в Vue ecosystem.
- Уже есть Vue component library, design system или legacy Vue app.

## Когда не использовать

- Команда и SDK стандартизированы на React/Next/Vite.
- Нужны React-only UI packages, shadcn/ui или TanStack-first architecture.
- Маленький static landing проще сделать на Astro.
- Backend/API лучше отделить от frontend framework.

## Production-паттерны

- Rendering mode фиксируется per route: SSR, SSG, ISR-like caching or client-only where justified.
- Server routes работают как BFF, но не заменяют heavy backend.
- Content module/headless CMS flow должен иметь preview, redirects, sitemap and metadata.
- Runtime config разделяет public/private env.
- Component auto-imports и composables документируются, чтобы не терять ownership.

## Частые ошибки

- Не понимать server/client runtime config и случайно раскрыть секреты.
- Делать все страницы client-only ради простоты.
- Не тестировать Nitro/deploy target отдельно от dev server.
- Смешивать CMS preview и public cache.

## Security risks

Private runtime config не должен попадать в public payload. Server routes проверяют auth и validation. Preview routes закрываются auth/noindex.

## Performance risks

Hydration cost, heavy Vue plugins, неоптимизированные images, duplicate data fetching и third-party scripts могут съесть SSR benefit.

## Testing strategy

Проверяй build target, SSR HTML, metadata, protected routes, server route auth, content preview, Playwright key flows и Lighthouse для public pages.

## Edge cases

Hybrid rendering cache invalidation, i18n route generation, plugin server/client mismatch, payload size, CMS webhook rebuild failure.

## Источники

- [Nuxt Docs](https://nuxt.com/docs/getting-started)
- [Nuxt Server Docs](https://nuxt.com/docs/getting-started/server)
- См. [Frontend blueprints](Frontend-blueprints.md), [CMS content](CMS-content.md), [Stack selection](../01-development-process/stack-selection.md).
