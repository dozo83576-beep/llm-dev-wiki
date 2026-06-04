---
title: "Stack: Next.js Fullstack"
category: "stack"
updated: "2026-06-04"
status: "active"
tags: ["nextjs", "typescript", "postgresql", "fullstack"]
source_priority: "official-docs"
---

# Next.js Fullstack

Production baseline для SaaS, личных кабинетов, админок, e-commerce storefront и сайтов, где SEO/UI важны так же, как backend-логика. Актуальная линия: Next.js 16, React 19, TypeScript 6, Tailwind CSS 4, Zod 4, Prisma 7 или Drizzle.

## Когда использовать

- Нужны SSR/SSG/ISR, App Router, layouts, metadata, Server Components и preview deploys.
- Backend умеренный: route handlers, server actions, webhooks, auth callbacks, BFF endpoints.
- Команда готова явно проектировать server/client boundary, cache policy и env separation.
- Продукту важны SEO, быстрый first viewport, формы, dashboard и protected routes в одном репозитории.

## Когда не использовать

- Нужен API-only backend без UI: выбирай NestJS/FastAPI/Fastify.
- Нужны long-running workers, тяжёлые очереди, WebSocket-сервер или сложная доменная модель: вынеси backend отдельно.
- Команда не готова поддерживать cache/revalidate, Server Components и auth на серверной границе.
- Статический landing без интерактива дешевле сделать на Astro.

## Scaffold commands

```bash
pnpm create next-app@latest app --ts --eslint --tailwind --app --src-dir --import-alias "@/*"
cd app
pnpm add zod @hookform/resolvers react-hook-form
pnpm add prisma @prisma/client
pnpm add -D vitest @testing-library/react @testing-library/jest-dom playwright
pnpm exec prisma init
pnpm exec playwright install --with-deps
```

Для shadcn/ui добавляй компоненты только после фикса design tokens:

```bash
pnpm dlx shadcn@latest init
pnpm dlx shadcn@latest add button form input dialog dropdown-menu table
```

## Структура проекта

```text
src/app/                 routes, layouts, metadata, loading/error pages
src/app/api/             route handlers for webhooks and external clients
src/features/<name>/     feature UI, server actions, schemas, tests
src/components/ui/       design-system primitives
src/lib/auth/            session, providers, permission helpers
src/lib/db/              Prisma/Drizzle client and transaction helpers
src/lib/env.ts           typed server/client env validation
src/lib/cache.ts         cache tags, revalidate helpers, fetch policy
tests/e2e/               Playwright critical journeys
```

Feature code may know domain rules. `components/ui` must not import database, auth providers or route handlers.

## Env vars

- Server-only: `DATABASE_URL`, auth secrets, Stripe/webhook secrets, email tokens.
- Client-safe: only public analytics IDs and feature flags with `NEXT_PUBLIC_`.
- Validate env at boot with Zod and fail build/deploy when required variables are missing.
- Preview/staging/prod must have separate database, auth callback URLs and webhook secrets.

## Data, auth and cache boundaries

- Fetch initial sensitive data in Server Components or server functions; do not serialize secrets into client props.
- Use Client Components only for browser APIs, local interaction, optimistic UI and widgets that need client state.
- Every mutation checks authorization on the server, validates input with Zod and invalidates the smallest cache scope.
- Every data read has an explicit cache policy: static, dynamic, `revalidate`, cache tag or no-store.
- Route Handlers are for external API clients, webhooks, health checks and BFF endpoints; they must normalize errors.

## CI/test/deploy gates

```bash
pnpm lint
pnpm typecheck
pnpm test
pnpm build
pnpm exec playwright test
pnpm audit --prod
```

Deploy through preview environments. Production merge requires passing build, migration review, Playwright smoke on preview, protected route checks, metadata check and post-deploy smoke.

## Acceptance checklist

- `next build` passes without server/client env leakage.
- Public pages have metadata, canonical when needed, sitemap/robots and optimized images.
- Protected routes deny anonymous and unauthorized users server-side.
- Forms cover loading, disabled, error, success and server validation errors.
- Core Web Vitals targets are documented for public pages and checkout/onboarding.
- Database migrations are reversible or use expand-contract rollout.

## Источники

- [Next.js App Router](https://nextjs.org/docs/app)
- [React Docs](https://react.dev/)
- [TypeScript Docs](https://www.typescriptlang.org/docs/)
- [Prisma Docs](https://www.prisma.io/docs)
- См. [Next.js](../docs/02-frontend/Nextjs.md), [Frontend blueprints](../docs/02-frontend/Frontend-blueprints.md), [Vercel](../docs/08-devops-deploy/Vercel.md), [SaaS playbook](../docs/13-playbooks/saas.md).
