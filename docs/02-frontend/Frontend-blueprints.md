---
title: "Frontend blueprints"
category: "frontend"
updated: "2026-06-04"
status: "active"
tags: ["frontend", "blueprint", "site", "production"]
source_priority: "internal"
---

# Frontend blueprints

Blueprint фиксирует минимальный production-контур сайта до генерации кода: стек, rendering strategy, routes, data boundaries, visual system, states, tests и deploy gates.

## Когда использовать

- Перед созданием нового landing, SaaS, admin dashboard, content site, e-commerce storefront или SPA.
- Когда LLM/агент должен сгенерировать сайт без угадывания архитектуры.
- Когда нужно сравнить Next.js, Astro и Vite + React по рискам, а не по популярности.

## Когда не использовать

- Маленький throwaway prototype без deploy, users и production acceptance.
- Локальный UI sketch, который не будет подключаться к backend, analytics или SEO.

## Production-паттерны

- **Landing/content**: Astro или Next static, минимальный JS, CMS/content schema, SEO metadata, form endpoint, Lighthouse gates.
- **SaaS/dashboard**: Next.js fullstack, server-side auth, tenant boundary, typed env, form validation, Playwright protected routes.
- **React SPA + API**: Vite, React Router, TanStack Query, OpenAPI contract, CORS/cookie tests, static hosting.
- **React full-stack alternative**: TanStack Start, route tree, server functions, Query-first invalidation, adapter/runtime check.
- **Vue/Svelte**: Nuxt или SvelteKit, adapter/rendering strategy, framework-native forms/data, ecosystem fit.
- **Edge-first**: Vite/React/static frontend + Cloudflare Workers + Hono, bindings, runtime limits, preview Worker smoke.
- **Hypermedia CRUD**: htmx + server-rendered fragments, CSRF, form validation, full-page fallback.
- **CMS/editorial**: Payload/headless CMS, preview auth, media pipeline, redirects, SEO fields and revalidation.
- **E-commerce**: Next.js storefront, server-side price/tax, provider-hosted checkout, webhook idempotency, inventory race tests.
- **Admin dashboard**: dense layout, tables, filters in URL, permission denied states, audit log and destructive action confirmation.

## Частые ошибки

- Начинать с компонентной библиотеки до content model, routes and acceptance criteria.
- Делать hero/design без реального продукта, screenshots, media or proof.
- Не фиксировать loading/error/empty/success states до реализации.
- Выбирать SPA для SEO-first страниц или Next.js для статического one-page landing без причины.

## Проверка

Минимальный blueprint готов, когда есть: route map, rendering strategy per route, data source per route, auth policy, env vars, design tokens, responsive breakpoints, critical states, analytics events, test commands and deploy target.

## Источники

- См. [Stack selection](../01-development-process/stack-selection.md), [Runtime selection](../01-development-process/runtime-selection.md), [Astro](Astro.md), [TanStack Start](TanStack-Start.md), [Vite + React](Vite-React.md), [React Router](React-Router.md), [Nuxt](Nuxt.md), [SvelteKit](SvelteKit.md), [htmx](HTMX.md), [Payload CMS](Payload-CMS.md), [Next.js](Nextjs.md), [UI architecture](UI-architecture.md), [Design systems](Design-systems.md).
