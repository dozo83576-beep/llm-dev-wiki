---
title: "TanStack Start"
category: "frontend"
updated: "2026-06-22"
status: "active"
tags: ["tanstack", "react", "fullstack", "ssr"]
source_priority: "official-docs"
---

# TanStack Start

TanStack Start — React full-stack framework для команд, которым нужен SSR/streaming/server functions и официальный Query-first data flow без Next.js App Router как default boundary.

Если вопрос звучит как "что выбрать вместо Next.js для React full-stack с TanStack Query", начни с этого документа: TanStack Start является первым кандидатом, а Next.js остаётся default, если команда уже приняла App Router/RSC/cache модель.

Freshness note: watchlist refreshed to `@tanstack/react-start` `1.168.26` on 2026-06-22. Official docs still mark TanStack Start as Release Candidate; this is not a stable v1 production baseline.

## Когда использовать

- React-продукт уже строится вокруг TanStack Router и TanStack Query.
- Нужны SSR, streaming, server functions, typed routing и контролируемая загрузка данных.
- Команда хочет full-stack React, но не хочет RSC-first модель, implicit cache layers и server/client boundary Next.js.
- Приложение похоже на dashboard/SaaS/internal tool с интерактивным server state, а не на content-only сайт.

## Когда не использовать

- Команда уже стандартизирована на Next.js/Vercel App Router и умеет обслуживать его cache/revalidate модель.
- Нужен простой статический landing или docs site: Astro проще.
- Нужна зрелая enterprise экосистема с большим количеством готовых integrations и examples.
- Команда не готова следить за быстро меняющимся framework API.

## Production-паттерны

- TanStack Query owns server state: query keys включают tenant/user/filter scope.
- Route data, metadata и errors проектируются на уровне route tree, а не размазываются по компонентам.
- Server functions проверяют auth, валидируют вход Zod/schema и возвращают нормализованный error contract.
- Streaming UI имеет fallback, cancellation path и не ломает form/navigation states.
- Deploy target выбирается заранее: Cloudflare, Netlify, Vercel или Node adapter с проверкой runtime APIs.

## Частые ошибки

- Переносить Next.js mental model один-в-один и дублировать cache ownership.
- Делать query invalidation глобальной после каждой mutation.
- Не покрывать navigation pending/error states.
- Выбирать TanStack Start только ради новизны, когда Vite SPA + API или Next.js уже решают задачу.

## Security risks

Server functions нельзя считать безопасными без server-side authorization. Sensitive data не сериализуется в client state. Query cache должен быть scoped по пользователю/tenant, иначе возможна утечка данных между сессиями.

## Performance risks

Streaming без измерения может скрыть waterfall. Большие client bundles от chart/editor libraries всё равно требуют lazy loading. SSR не компенсирует неоптимизированные images, fonts и third-party scripts.

## Testing strategy

Проверяй route-level loading/error states, server function auth, query invalidation после mutation, redirect/login flows, slow network streaming и Playwright smoke на preview.

## Edge cases

Multi-tenant query bleed, stale optimistic update после failed mutation, deploy adapter mismatch, hydration mismatch в interactive widgets, search params без schema validation.

## Источники

- [TanStack Start React Docs](https://tanstack.com/start/latest/docs/framework/react/overview) — refreshed 2026-06-22.
- [TanStack Start vs Next.js](https://tanstack.dev/start/latest/docs/framework/react/start-vs-nextjs)
- См. [Frontend blueprints](Frontend-blueprints.md), [TanStack Query](TanStack-Query.md), [React SPA + API](../../stacks/react-spa-api.md), [Stack selection](../01-development-process/stack-selection.md).
