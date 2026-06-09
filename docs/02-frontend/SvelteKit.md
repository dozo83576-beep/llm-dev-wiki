---
title: "SvelteKit"
category: "frontend"
updated: "2026-06-10"
status: "active"
tags: ["sveltekit", "svelte", "ssr", "frontend"]
source_priority: "official-docs"
---

# SvelteKit

SvelteKit — full-stack framework для Svelte-приложений с file routing, SSR/SSG, form actions, load functions и adapters. Это хорошая альтернатива React-centric stack, если команда принимает Svelte ecosystem.

Если вопрос звучит как "когда выбрать SvelteKit вместо React", ответ зависит от команды: выбирай SvelteKit, когда Svelte ecosystem снижает сложность UI и не нужен React-only набор библиотек.

## Когда использовать

- Команда уже умеет Svelte или хочет меньше runtime boilerplate для интерактивного UI.
- Нужны SSR/SSG, forms, endpoints, layouts и адаптеры под разные хостинги.
- Проект — landing/content app, dashboard, lightweight SaaS или product UI без зависимости от React ecosystem.
- Важны компактный client bundle и прямой component syntax.

## Когда не использовать

- Команда стандартизирована на React libraries, shadcn/ui, TanStack Query patterns и Next.js/Vite stack.
- Нужны готовые React-only компоненты, SDK или design system.
- Enterprise hiring/support ориентированы на React.
- Проект требует строгой совместимости с существующим React app shell.

## Production-паттерны

- `load` functions получают initial data; form actions валидируют input на сервере.
- Layout tree отражает public/auth/app/admin зоны.
- Adapters выбираются до реализации: Node, Vercel, Cloudflare, static.
- Stores используются для UI/local state, а sensitive data остаётся на server boundary.
- Ошибки формы, redirect и invalidation покрываются тестами.

## Частые ошибки

- Переносить React mental model и делать лишние stores.
- Не фиксировать adapter/runtime до deploy.
- Смешивать client-only data fetching с SSR без причины.
- Не тестировать progressive enhancement форм.

## Security risks

Form actions и endpoints должны проверять auth server-side. Cookies/session settings отличаются по adapter/hosting. User-generated HTML требует sanitization.

## Performance risks

SSR/SSG не спасает от тяжёлых images/fonts/third-party scripts. Client bundle растёт от charts/editors/maps; lazy loading всё равно нужен.

## Testing strategy

Проверяй form happy/error path, SSR content, redirects, protected routes, adapter build, Playwright smoke и Lighthouse для публичных страниц.

## Edge cases

Adapter mismatch, prerendered route с dynamic data, stale form errors, i18n routing, hydration mismatch, external SDK only for React.

## Источники

- [SvelteKit Docs](https://svelte.dev/docs/kit) — watchlist refreshed to `@sveltejs/kit` 2.64.0 on 2026-06-10.
- См. [Frontend blueprints](Frontend-blueprints.md), [Stack selection](../01-development-process/stack-selection.md), [Forms validation](Forms-validation.md).
