---
title: "Выбор стека"
category: "process"
updated: "2026-05-24"
status: "active"
tags: ["stack", "architecture"]
source_priority: "official-docs"
---

# Выбор стека

| Тип проекта | Frontend | Backend | Database | Auth | Hosting | Тесты | Когда не выбирать |
|---|---|---|---|---|---|---|---|
| SaaS | Next.js, TypeScript, Tailwind, shadcn/ui | Next.js Route Handlers или NestJS | PostgreSQL + Prisma | Auth.js или Supabase | Vercel/Render | Vitest, Playwright | Если нужен тяжелый backend с очередями и сложной доменной моделью без отдельного API |
| Лендинг | Astro или Next.js | Нет или serverless forms | Нет или headless CMS | Не требуется | Vercel/Cloudflare Pages | Lighthouse, Playwright smoke | Если есть личный кабинет и сложные роли |
| Маркетплейс | Next.js | NestJS/FastAPI | PostgreSQL + Redis | Auth.js/Supabase/custom RBAC | Vercel + Render/Fly | unit, integration, E2E | Если команда не готова к сложной модерации, платежам и спорам |
| AI-приложение | Next.js | FastAPI или Next.js API | PostgreSQL + pgvector/Qdrant | Auth.js/Supabase | Vercel + managed DB | evaluation, integration | Если нет бюджета на токены, evals и observability |
| API-only | Нет | NestJS/FastAPI/Fastify | PostgreSQL | JWT/OAuth2 | Render/Fly/Kubernetes | contract, integration | Если продукт требует SEO/UI как основной канал |
| Enterprise CRUD | Next.js | NestJS или Django | PostgreSQL | SSO/OIDC + RBAC | Cloud/VPC | integration, E2E | Если нужен быстрый маленький MVP без сложных ролей |
| Админка | React/Next.js | Existing API или NestJS | Existing DB | SSO/RBAC | Vercel/internal | E2E key flows | Если админка должна быть embedded в legacy без SPA |
| Контентный сайт | Astro/Next.js | CMS | CMS/PostgreSQL | CMS auth | Vercel/Cloudflare | visual smoke, SEO | Если нужен real-time app |
| E-commerce | Next.js | Commerce backend/NestJS | PostgreSQL | Customer auth | Vercel + backend host | checkout E2E | Если платежные и налоговые требования не проработаны |
| Real-time | Next.js/React | NestJS/Fastify + WebSocket | PostgreSQL + Redis | JWT/OIDC | Fly/Render | load + E2E | Если real-time не является ключевой ценностью |

Базовый выбор по умолчанию: Next.js + TypeScript + PostgreSQL + Prisma + Auth.js/Supabase. Отклоняйся от него только при конкретной причине.

