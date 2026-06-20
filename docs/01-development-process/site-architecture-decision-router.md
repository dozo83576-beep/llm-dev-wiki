---
title: "Site architecture decision router"
category: "process"
updated: "2026-06-10"
status: "active"
tags: ["architecture", "stack", "site", "decision"]
source_priority: "internal"
---

# Site architecture decision router

Router превращает сырой запрос пользователя в проверяемое решение по архитектуре сайта. Он не заменяет discovery: если данных мало или есть high-risk область, агент обязан задать вопросы, а не угадывать стек.

Executable smoke для этой policy: `pwsh tools/site-stack-router.ps1 -Request "<raw request>"`. Скрипт rule-based, не использует LLM/API и нужен как preflight перед `create-new-project` или `choose-stack`.

## Когда использовать

- Пользователь просит "создать сайт", "сделать SaaS", "собрать лендинг", "нужна админка" или описывает продукт свободным текстом.
- Нужно выбрать playbook, stack blueprint и границы frontend/backend до реализации.
- Требуется объяснить, почему выбранный стек лучше альтернатив.

## Входные сигналы

- **Тип продукта**: landing, content site, SaaS, admin/internal CRUD, e-commerce, marketplace, AI/RAG, API-only, real-time.
- **Пользователи и доступ**: public pages, login, roles, tenant isolation, SSO, admin permissions.
- **SEO и content**: organic traffic, CMS/editorial workflow, preview, redirects, i18n.
- **Data model**: простые формы, CRUD, relational domain, search, files, vector data, audit log.
- **Интеграции**: payments, email, analytics, AI providers, external APIs, webhooks.
- **Runtime и hosting**: Vercel, Cloudflare, Render/Fly, internal network, data residency, edge constraints.
- **Нефункциональные требования**: compliance, budget, traffic, latency, team experience, timeline.

## Confidence policy

- **High**: тип продукта, SEO/auth/data/payment constraints и hosting понятны. Можно выбрать стек и сразу назвать assumptions.
- **Medium**: тип продукта понятен, но 1-2 вторичных ограничения неизвестны. Можно выбрать default stack, явно пометив assumptions и вопросы.
- **Low**: непонятны тип продукта, пользователи, auth/data или monetization. Не выбирай стек; задай до 3 вопросов, которые сильнее всего меняют архитектуру.
- **Blocker**: payments, PII, compliance, SSO, tenant isolation или production data упомянуты, но требования не ясны. Сначала discovery/security review.

## Routing rules

| Сигнал запроса | Primary route | Default stack | Когда спросить до выбора |
|---|---|---|---|
| Маркетинговый лендинг, SEO, форма заявки | [landing](../13-playbooks/landing.md) | Astro или Next.js static + serverless form | Неясны CMS, локали, аналитика, form delivery |
| Портфолио услуг, кейсы, форма заявки, VPS | [landing](../13-playbooks/landing.md) + [portfolio screenshot gallery](../../patterns/frontend/portfolio-case-screenshot-gallery.md) + [non-root VPS deploy](../../patterns/devops/non-root-vps-node-pm2-nginx-deploy.md) | Astro Node + server form + PM2/Nginx под non-root пользователем | Неясны публичные кейсы, канал заявки, домен/VPS |
| Контентный сайт, редакторы, публикации | [CMS content](../02-frontend/CMS-content.md) | Astro/Next.js + headless CMS/Payload | Неясны preview, media, roles, redirects |
| Существующий WordPress/editorial workflow | [WordPress](../02-frontend/WordPress.md) | WordPress theme или headless WordPress + Astro/Next | Неясны plugin policy, roles, cache, preview |
| Marketing team хочет visual builder | [Webflow](../02-frontend/Webflow.md) | Webflow CMS + forms/API boundary | Неясны custom logic, vendor lock-in, scripts |
| Static docs/blog без app state | [Eleventy](../02-frontend/Eleventy.md) / [Hugo](../02-frontend/Hugo.md) / [Astro](../02-frontend/Astro.md) | Static generator + CDN | Неясны редакторы, search, redirects |
| SaaS, подписки, личный кабинет | [saas](../13-playbooks/saas.md) | Next.js fullstack + PostgreSQL + Auth + Stripe | Неясны tenancy, roles, billing model, compliance |
| Админка или internal CRUD | [admin dashboard](../13-playbooks/admin-dashboard.md) | React SPA + API или Next.js | Неясны existing API, SSO, permissions, audit log |
| E-commerce или checkout | [e-commerce](../13-playbooks/ecommerce.md) + [headless commerce](../13-playbooks/headless-commerce.md) | Next.js storefront + commerce/payment backend | Неясны catalog, tax, inventory, refunds, marketplace |
| Shopify-first custom storefront | [Shopify Hydrogen](../13-playbooks/shopify-hydrogen.md) | Hydrogen + Shopify Storefront API + Shopify checkout | Неясны Shopify source of truth, checkout constraints |
| Edge-first, low latency, Cloudflare | [Cloudflare Workers full-stack](../08-devops-deploy/Cloudflare-Workers-fullstack.md) | Vite/React + Workers + Hono | Нужны Node-only APIs, long jobs, relational transactions |
| Rich app после логина с отдельным API | [React SPA + API](../../stacks/react-spa-api.md) | Vite + React Router + TanStack Query | Неясны SEO, cookie/CORS policy, auth owner |
| React full-stack без Next.js | [TanStack Start](../02-frontend/TanStack-Start.md) | TanStack Start + Query-first data flow | Команда не готова к RC/maturity risk |
| Vue/Svelte команда | [Nuxt](../02-frontend/Nuxt.md) или [SvelteKit](../02-frontend/SvelteKit.md) | Framework-native SSR/forms/data | SDK/design system завязаны на React |
| CRUD/forms/tables без rich client | [htmx](../02-frontend/HTMX.md) | Server-rendered HTML + htmx fragments | Нужен offline, complex canvas, heavy client state |

## Output contract

```
1. Decision confidence: high | medium | low
2. Chosen route: playbook + stack blueprint
3. Architecture: frontend, backend, data, auth, integrations, hosting
4. Assumptions: что принято без подтверждения
5. Open questions: максимум 3, только если они меняют архитектуру
6. Rejected alternatives: почему не выбраны 2-3 варианта
7. Acceptance gates: tests, security, performance, deploy checks
8. Wiki links: документы, которые нужно прочитать перед реализацией
```

## Что нельзя делать

- Выбирать Next.js, React SPA или Cloudflare только потому, что это familiar default.
- Выбирать WordPress/Webflow только потому, что редакторам удобно, если есть custom product logic.
- Считать "сайт" достаточным требованием для выбора БД, auth, платежей или hosting.
- Игнорировать compliance, PII, платежи, roles и tenant boundaries.
- Превращать low confidence в длинный implementation plan вместо коротких уточняющих вопросов.

## Источники

- [Stack selection](stack-selection.md)
- [Site stack router tool](site-stack-router-tool.md)
- [Frontend blueprints](../02-frontend/Frontend-blueprints.md)
- [Project discovery checklist](../../checklists/project-discovery.md)
- [Create new project prompt](../../prompts/create-new-project.md)
