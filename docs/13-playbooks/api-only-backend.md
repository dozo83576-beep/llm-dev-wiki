---
title: "Playbook: API-only backend"
category: "playbooks"
updated: "2026-06-04"
status: "active"
tags: ["api", "backend", "rest", "openapi"]
source_priority: "internal"
---

# Playbook: API-only backend

Backend без собственного frontend: обслуживает mobile, third-party интеграции, SDK, internal-сервисы. Контракт публичен и долго живёт — ломать его дорого.

## Когда использовать

- Mobile-приложение и web-frontend используют один backend.
- B2B API для интеграций (вебхуки, REST/GraphQL).
- Service в составе микросервисной архитектуры.

## Когда не использовать

- Маленький one-shot веб-сайт — full-stack Next.js быстрее.
- Только internal-tool с одной командой — overkill.

## Стек по умолчанию

NestJS / FastAPI / Fastify + PostgreSQL + OpenAPI/GraphQL schema + integration tests + observability (logs/metrics/traces). Для lightweight edge/BFF API см. [Hono](../03-backend/Hono.md) и [Cloudflare Workers full-stack](../08-devops-deploy/Cloudflare-Workers-fullstack.md).

## Порядок разработки

1. **Define clients and contracts**: кто будет вызывать, какие SLA, какая совместимость.
2. **Resource modeling**: entities, relationships, permissions, error contract.
3. **Validation at boundary**: schemas на входе (zod / pydantic), типизация всех запросов и ответов.
4. **Service layer**: бизнес-логика отделена от транспорта, явные transaction boundaries.
5. **OpenAPI / GraphQL schema** как source of truth; генерация клиентов.
6. **Contract tests**: response matches schema, breaking-change check в CI.
7. **Rate limits & quotas**: на endpoint, на user/tenant, на IP.
8. **Observability**: structured logs, RED metrics, traces для критичных endpoints.
9. **Healthchecks**: `/health`, `/ready` с проверкой dep'ов.
10. **Versioning policy**: `/v1`, deprecation window, sunset headers.

## Production-паттерны

- Error contract единый (см. [Error contracts](../06-api-design/Error-contracts.md)): `code`, `message`, `details`, `traceId`.
- Pagination через cursor для больших коллекций.
- Idempotency keys для критичных POST.
- API keys / OAuth с явными scopes.
- Webhook receiver — отдельный паттерн (signature, idempotency).

## Анти-паттерны

- API без стабильного error contract — клиенты пишут регекспы на текст ошибок.
- Версионирование начинается только после первого breaking change.
- Отсутствие negative permission tests (admin/owner/other).
- Pagination через `offset` на больших таблицах.

## Security risks

IDOR, broken authentication, rate-limit bypass через распределённые источники, SSRF в URL-параметрах, mass-assignment в request body.

## Performance risks

N+1 в ORM, отсутствие индексов под фильтры, тяжёлый JSON serialization, неконтролируемые joins.

## Testing strategy

- Integration tests на каждый endpoint (happy + permission + validation + error).
- Contract tests против OpenAPI/GraphQL schema.
- Load tests на hot endpoints перед запуском.
- Negative auth tests обязательны.

## Edge cases

- Long-running запросы — async pattern с job id + polling / webhook.
- Большие списки — streaming / pagination.
- Multi-tenant isolation: tenant_id во всех запросах.
- Backward compatibility: добавлять поля можно, удалять — только через deprecation.

## Источники

- См. [Hono](../03-backend/Hono.md), [Cloudflare Workers full-stack](../08-devops-deploy/Cloudflare-Workers-fullstack.md), [API architecture](../03-backend/API-architecture.md), [REST](../06-api-design/REST.md), [OpenAPI](../06-api-design/OpenAPI.md), [Error contracts](../06-api-design/Error-contracts.md), [Versioning](../06-api-design/Versioning.md), [error-contract pattern](../../patterns/api/error-contract.md), [api-review checklist](../../checklists/api-review.md).
