---
title: "Выбор стека"
category: "process"
updated: "2026-06-10"
status: "active"
tags: ["stack", "architecture"]
source_priority: "official-docs"
---

# Выбор стека

| Тип проекта | Frontend | Backend | Database | Auth | Hosting | Тесты | Когда не выбирать |
|---|---|---|---|---|---|---|---|
| SaaS | Next.js 16, React 19, TypeScript 6, Tailwind 4, shadcn/ui | Next.js Route Handlers или NestJS 11 | PostgreSQL + Prisma 7/Drizzle | Auth.js, Clerk или Supabase | Vercel/Render | Vitest, Playwright | Если нужен тяжелый backend с очередями и сложной доменной моделью без отдельного API |
| Лендинг | Astro или Next.js static | Нет или serverless forms | Нет или headless CMS | Не требуется | Vercel/Cloudflare Pages | Lighthouse, Playwright smoke | Если есть личный кабинет и сложные роли |
| Маркетплейс | Next.js | NestJS/FastAPI | PostgreSQL + Redis | Auth.js/Supabase/custom RBAC | Vercel + Render/Fly | unit, integration, E2E | Если команда не готова к сложной модерации, платежам и спорам |
| AI-приложение | Next.js | FastAPI или Next.js API | PostgreSQL + pgvector/Qdrant | Auth.js/Supabase | Vercel + managed DB | evaluation, integration | Если нет бюджета на токены, evals и observability |
| API-only | Нет | NestJS/FastAPI/Fastify | PostgreSQL | JWT/OAuth2 | Render/Fly/Kubernetes | contract, integration | Если продукт требует SEO/UI как основной канал |
| Enterprise CRUD | Next.js | NestJS или Django | PostgreSQL | SSO/OIDC + RBAC | Cloud/VPC | integration, E2E | Если нужен быстрый маленький MVP без сложных ролей |
| Админка | React SPA + API или Next.js | Existing API или NestJS | Existing DB | SSO/RBAC | Vercel/internal | E2E key flows | Если админка должна быть embedded в legacy без SPA |
| Контентный сайт | Astro/Next.js + CMS | CMS | CMS/PostgreSQL | CMS auth | Vercel/Cloudflare | visual smoke, SEO | Если нужен real-time app |
| E-commerce | Next.js | Commerce backend/NestJS | PostgreSQL | Customer auth | Vercel + backend host | checkout E2E | Если платежные и налоговые требования не проработаны |
| Real-time | Next.js/React | NestJS/Fastify + WebSocket | PostgreSQL + Redis | JWT/OIDC | Fly/Render | load + E2E | Если real-time не является ключевой ценностью |
| React full-stack alternative | TanStack Start | Server functions / отдельный API | PostgreSQL/managed DB | Auth provider | Vercel/Netlify/Cloudflare | route + mutation tests | Если Next.js уже является командным стандартом |
| Vue/Svelte продукт | Nuxt или SvelteKit | Framework server routes или API | PostgreSQL/CMS | OIDC/provider | Vercel/Netlify/Cloudflare | SSR/forms/E2E | Если команда и SDK завязаны на React |
| Edge-first app | Vite/React или static frontend | Hono on Cloudflare Workers | D1/KV/R2/external DB | JWT/OIDC | Cloudflare Workers | Worker smoke + contract | Если backend требует Node-only APIs или long-running jobs |
| Hypermedia CRUD | Server-rendered HTML + htmx | Django/Laravel/FastAPI/NestJS templates | Existing DB | Server session | Any server host | form + fragment tests | Если нужен rich offline/client-heavy UI |
| WordPress/editorial | WordPress block/classic theme или headless frontend | WordPress | MySQL/MariaDB | WordPress roles/MFA | Managed WP/VPS/headless host | editorial + security smoke | Если нужен custom SaaS или строгий TS domain model |
| Visual builder marketing | Webflow | Webflow CMS/API | Webflow CMS | Webflow roles | Webflow | site audit + visual QA | Если есть сложная product logic/auth/checkout |
| Headless CMS site | Astro/Next/Nuxt | Payload/Strapi/Sanity/Directus/WordPress | CMS DB/content lake | CMS roles | Vercel/Cloudflare/CMS host | preview + publish tests | Если контент developer-only |
| Shopify commerce | Shopify Hydrogen | Shopify Storefront API | Shopify | Shopify customer accounts | Shopify Oxygen/custom | cart/checkout E2E | Если commerce backend не Shopify |
| Static docs/blog | Astro/Eleventy/Hugo | None/static forms | Filesystem content | None/CMS optional | CDN/static host | link/SEO/site audit | Если нужен auth/app state |
| Laravel UI | Blade/Livewire | Laravel | PostgreSQL/MySQL | Laravel auth/policies | VPS/Render/Fly | form + policy tests | Если команда не PHP/Laravel |
| Enterprise Angular | Angular SSR | API/NestJS/.NET/Java | Project-specific | SSO/OIDC | Enterprise cloud | SSR/hydration/E2E | Если Angular не является стандартом команды |

Базовый выбор по умолчанию: [Next.js Fullstack](../../stacks/nextjs-fullstack.md) + TypeScript + PostgreSQL + Prisma/Drizzle + Auth.js/Clerk/Supabase. Отклоняйся от него только при конкретной причине.

## Автономный выбор по запросу

Если пользователь описывает сайт свободным текстом, сначала пропусти запрос через [site architecture decision router](site-architecture-decision-router.md). Wiki может рекомендовать стек только при `high` или `medium` confidence: тип продукта, SEO/auth/data constraints и hosting должны быть понятны. При `low` confidence не выбирай стек "из головы" — задай до 3 вопросов, которые сильнее всего меняют архитектуру.

## Правила выбора

- Если страница публичная и должна привлекать трафик, сначала проверь [SEO](../02-frontend/SEO.md), [Performance](../02-frontend/Performance.md) и rendering strategy.
- Если приложение живёт после логина и API уже отделён, смотри [React SPA + API](../../stacks/react-spa-api.md), [Vite + React](../02-frontend/Vite-React.md) и [React Router](../02-frontend/React-Router.md).
- Если сайт контентный или маркетинговый, смотри [Astro](../02-frontend/Astro.md), [CMS content](../02-frontend/CMS-content.md) и [landing playbook](../13-playbooks/landing.md).
- Если нужен React full-stack без Next.js default model, смотри [TanStack Start](../02-frontend/TanStack-Start.md).
- Если нужен edge-first runtime, смотри [Cloudflare Workers full-stack](../08-devops-deploy/Cloudflare-Workers-fullstack.md), [Hono](../03-backend/Hono.md) и [Runtime selection](runtime-selection.md).
- Если команда не на React, сравни [Nuxt](../02-frontend/Nuxt.md) и [SvelteKit](../02-frontend/SvelteKit.md) по ecosystem fit.
- Если UI в основном CRUD/forms/tables, проверь [htmx](../02-frontend/HTMX.md) до выбора SPA.
- Если проект editorial/marketing с существующей CMS-командой, проверь [WordPress](../02-frontend/WordPress.md), [Webflow](../02-frontend/Webflow.md), [CMS content](../02-frontend/CMS-content.md).
- Если commerce завязан на Shopify, проверь [Shopify Hydrogen](../13-playbooks/shopify-hydrogen.md) до generic storefront.
- Если сайт статический docs/blog, сравни [Astro](../02-frontend/Astro.md), [Eleventy](../02-frontend/Eleventy.md), [Hugo](../02-frontend/Hugo.md).
- Если есть платежи, роли, tenant isolation или персональные данные, stack choice нельзя закрывать без security review.

## Проверка

Перед стартом проекта выбранный стек должен иметь: scaffold command, env vars, auth/data/cache boundaries, CI gates, deploy target и acceptance checklist. Если этих пунктов нет, сначала дополни профильный stack blueprint.

## Источники

- [Next.js Docs](https://nextjs.org/docs)
- [React Docs](https://react.dev/)
- [Astro Docs](https://docs.astro.build/)
- См. [Site architecture decision router](site-architecture-decision-router.md), [Frontend blueprints](../02-frontend/Frontend-blueprints.md), [Runtime selection](runtime-selection.md), [project discovery](../../checklists/project-discovery.md), [release readiness](../../checklists/release-readiness.md).
