---
title: "Stack: Next.js Fullstack"
category: "stack"
updated: "2026-05-24"
status: "active"
tags: ["nextjs", "typescript", "postgresql"]
source_priority: "official-docs"
---

# Next.js Fullstack

Используй для SaaS, личных кабинетов, админок и проектов, где SEO/UI важны так же, как backend-логика.

## Состав

- Next.js App Router, React, TypeScript.
- Tailwind CSS + shadcn/ui.
- PostgreSQL + Prisma или Drizzle.
- Auth.js или Supabase Auth.
- Vitest для unit-тестов, Playwright для E2E.
- Vercel для frontend/serverless, Render/Fly для отдельного backend при росте сложности.

## Правила

- Данные, которые можно получать на сервере, получай в Server Components.
- Client Components используй для интерактивности, browser API и локального состояния.
- Route Handlers оставляй для API-интеграций, webhooks и внешних клиентов.
- Валидация входа через Zod на границе API/server action.

Источники: [Next.js App Router](https://nextjs.org/docs/app), [React Docs](https://react.dev/), [Prisma Docs](https://www.prisma.io/docs).

