---
title: "Hono"
category: "backend"
updated: "2026-06-04"
status: "active"
tags: ["hono", "edge", "workers", "api"]
source_priority: "official-docs"
---

# Hono

Hono — lightweight TypeScript web framework на Web Standards для edge/serverless API, BFF и Workers-first приложений. Он полезен там, где NestJS тяжёлый, а Route Handlers недостаточно переносимы.

## Когда использовать

- API/BFF должен работать на Cloudflare Workers, Bun, Deno, Node или другом Web Fetch runtime.
- Нужны быстрые typed routes, middleware, validation и small bundle.
- Проект edge-first: гео-близкие endpoints, webhooks, lightweight auth, API для Vite/React SPA.
- Backend логика компактная и не требует NestJS modules, DI и сложной доменной структуры.

## Когда не использовать

- Большой enterprise backend с heavy domain model, CQRS, dependency graph и background workers.
- Нужны long-running jobs, raw TCP, native Node APIs или stateful WebSocket server вне edge constraints.
- Команда ожидает batteries-included ORM/auth/admin framework.

## Production-паттерны

- Держи route handlers тонкими: validation, auth, call service, normalize response.
- Runtime bindings типизируй явно: KV, R2, D1, Durable Objects, secrets, service bindings.
- Shared middleware покрывает request id, logging, CORS, rate limit, auth context and error contract.
- Webhook handlers идемпотентны и сохраняют provider event id.
- Для frontend BFF возвращай typed JSON или HTML fragments, но не смешивай контракты без явной границы.

## Частые ошибки

- Использовать Node-only пакеты в Workers runtime.
- Не тестировать локально в workerd/miniflare-like runtime.
- Делать один catch-all route без contract tests.
- Хранить secrets в client env или static assets.

## Security risks

CORS должен быть allowlist, а не wildcard для credentialed requests. Edge endpoints нуждаются в rate limiting, body size limits и validation. Bindings с доступом к storage должны иметь минимальные права.

## Performance risks

Cold start обычно мал, но latency растёт от remote database round trips. Для Postgres нужен pooler/HTTP driver или региональная стратегия. Большие dependencies ухудшают edge bundle.

## Testing strategy

Unit tests для services, integration tests для routes with bindings mocks, contract tests для API clients, replay tests для webhooks, smoke deploy на preview Worker.

## Edge cases

Region mismatch с базой, Durable Object hot key, KV eventual consistency, secret rotation, webhook retry storm, incompatible npm dependency.

## Источники

- [Hono Docs](https://www.honojs.com/docs/)
- [Hono Getting Started](https://hono.dev/docs/getting-started/basic)
- См. [Cloudflare Workers fullstack](../08-devops-deploy/Cloudflare-Workers-fullstack.md), [API architecture](API-architecture.md), [Webhooks](Webhooks.md).
