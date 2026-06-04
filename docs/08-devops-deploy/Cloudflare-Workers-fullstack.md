---
title: "Cloudflare Workers full-stack"
category: "devops"
updated: "2026-06-04"
status: "active"
tags: ["cloudflare", "workers", "vite", "edge", "fullstack"]
source_priority: "vendor-docs"
---

# Cloudflare Workers full-stack

Cloudflare Workers full-stack — подход, где static assets, React/Vite frontend, Workers API, Hono/BFF и bindings живут близко к edge runtime. Это не замена всем backend, а вариант для lightweight edge-first сайтов и приложений.

## Когда использовать

- Нужны низкая latency, CDN/edge proximity, cheap serverless и preview deploys.
- Frontend — Vite/React SPA или статический сайт, API — Worker/Hono.
- Storage подходит под Workers primitives: KV, R2, D1, Durable Objects, Queues или external HTTP DB.
- Команда готова проектировать runtime limits и bindings как часть архитектуры.

## Когда не использовать

- Нужны long-running jobs, heavy CPU, native Node modules, raw sockets или stateful backend outside Durable Objects.
- Основная БД живёт в одном регионе и каждый request требует несколько round trips.
- Команда хочет классический Node server без edge constraints.

## Production-паттерны

- Разработка использует Cloudflare Vite plugin или Wrangler так, чтобы local runtime был близок к production.
- Bindings объявлены по окружениям: preview/staging/prod имеют отдельные KV/R2/D1/secrets.
- Worker API возвращает нормализованные errors, request id и CORS headers из централизованного middleware.
- Static assets кешируются на edge; API routes имеют explicit cache/no-cache policy.
- Deploy gates: typecheck, build, route tests, preview Worker smoke, rollback plan.

## Частые ошибки

- Тестировать только Node dev server и получить runtime failures на Workers.
- Использовать npm dependency, которая требует Node APIs.
- Подключаться к Postgres напрямую без pooling/region strategy.
- Хранить preview secrets или production data в общем namespace.

## Security risks

Preview URLs с production bindings опасны. CORS/cookies на custom domains нужно тестировать отдельно. R2/KV/D1 access keys и bindings должны быть per-environment и rotated.

## Performance risks

Edge runtime не исправляет медленную origin database. KV eventual consistency может ломать auth/session assumptions. Durable Object hot spots требуют sharding или routing design.

## Testing strategy

Wrangler/Vite build, route integration tests with bindings, Playwright smoke against preview Worker, contract tests for API client, synthetic check for critical endpoints after deploy.

## Edge cases

Custom domains, SameSite cookies on preview domains, region-specific legal requirements, asset 404 fallback for SPA, queue retry poison messages, Durable Object migration.

## Источники

- [Cloudflare React + Workers guide](https://developers.cloudflare.com/workers/frameworks/framework-guides/react/)
- [Cloudflare Workers Docs](https://developers.cloudflare.com/workers/)
- См. [Cloudflare](Cloudflare.md), [Hono](../03-backend/Hono.md), [Vite + React](../02-frontend/Vite-React.md), [API-only backend playbook](../13-playbooks/api-only-backend.md).
