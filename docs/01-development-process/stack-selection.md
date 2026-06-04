---
title: "Выбор стека"
category: "process"
updated: "2026-06-04"
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

Базовый выбор по умолчанию: [Next.js Fullstack](../../stacks/nextjs-fullstack.md) + TypeScript + PostgreSQL + Prisma/Drizzle + Auth.js/Clerk/Supabase. Отклоняйся от него только при конкретной причине.

## Правила выбора

- Если страница публичная и должна привлекать трафик, сначала проверь [SEO](../02-frontend/SEO.md), [Performance](../02-frontend/Performance.md) и rendering strategy.
- Если приложение живёт после логина и API уже отделён, смотри [React SPA + API](../../stacks/react-spa-api.md), [Vite + React](../02-frontend/Vite-React.md) и [React Router](../02-frontend/React-Router.md).
- Если сайт контентный или маркетинговый, смотри [Astro](../02-frontend/Astro.md), [CMS content](../02-frontend/CMS-content.md) и [landing playbook](../13-playbooks/landing.md).
- Если есть платежи, роли, tenant isolation или персональные данные, stack choice нельзя закрывать без security review.

## Проверка

Перед стартом проекта выбранный стек должен иметь: scaffold command, env vars, auth/data/cache boundaries, CI gates, deploy target и acceptance checklist. Если этих пунктов нет, сначала дополни профильный stack blueprint.

## Источники

- [Next.js Docs](https://nextjs.org/docs)
- [React Docs](https://react.dev/)
- [Astro Docs](https://docs.astro.build/)
- См. [Frontend blueprints](../02-frontend/Frontend-blueprints.md), [project discovery](../../checklists/project-discovery.md), [release readiness](../../checklists/release-readiness.md).
