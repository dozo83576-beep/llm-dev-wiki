---
title: "API review checklist"
category: "checklist"
updated: "2026-05-24"
status: "active"
tags: ["api", "review"]
source_priority: "internal"
---

# API review checklist

Gated checklist для API-эндпоинта или нового API-проекта. Формат: критерий — проверка — owner — severity — ссылка.

## Contract

- [ ] **API-контракт** описан в OpenAPI/GraphQL schema или выводится из typed routes — backend owner — block — [OpenAPI](../docs/06-api-design/OpenAPI.md), [GraphQL](../docs/06-api-design/GraphQL.md).
- [ ] **Examples** для request и response в schema — backend owner — warn.
- [ ] **Breaking changes** имеют major bump и deprecation window — backend owner — block — [Versioning](../docs/06-api-design/Versioning.md).
- [ ] **Generated clients** успешно собираются из текущей схемы — backend owner — warn — [Contract testing](../docs/09-testing/Contract-testing.md).

## Errors

- [ ] **Ошибки имеют стабильный формат**: `code`, `message`, `details`, `traceId` — backend owner — block — [Error contracts](../docs/06-api-design/Error-contracts.md), [error-contract pattern](../patterns/api/error-contract.md).
- [ ] **Status codes** соответствуют смыслу: 400/401/403/404/409/422/429/5xx — backend owner — block.
- [ ] **Validation errors** включают путь к полю и причину — backend owner — warn.
- [ ] **Не утекают** stack trace / SQL / секреты — backend owner — block — [Error handling](../docs/03-backend/Error-handling.md).

## Pagination & filters

- [ ] **Pagination** через cursor для больших коллекций; offset не выше 1000 — backend owner — block — [Pagination](../docs/06-api-design/Pagination-filtering-sorting.md), [cursor-pagination pattern](../patterns/database/cursor-pagination.md).
- [ ] **Filters / sort** имеют allowlist (не пускают произвольное поле в WHERE/ORDER BY) — backend owner — block.
- [ ] **Limit / max page size** задан и enforced — backend owner — block.

## Idempotency & retries

- [ ] **Mutations** идемпотентны там, где повтор возможен (POST с idempotency-key) — backend owner — block.
- [ ] **Webhook receivers** идемпотентны по `event_id` — backend owner — block — [webhook-idempotency pattern](../patterns/backend/webhook-idempotency.md).
- [ ] **Retry-Safe semantics** для GET; non-retry для побочных эффектов без идемпотентности — backend owner — warn.

## Security

- [ ] **Auth** обязателен на каждом не-public endpoint — security owner — block — [Authentication](../docs/05-auth-security/Authentication.md).
- [ ] **Authorization** проверяется до доступа к объектам (object-level) — security owner — block — [Authorization](../docs/05-auth-security/Authorization.md).
- [ ] **Rate limits** на login, AI, expensive endpoints — security owner — block — [Rate limiting](../docs/05-auth-security/Rate-limiting.md).
- [ ] **CORS** настроен корректно — security owner — block — [CORS-CSRF-CSP](../docs/05-auth-security/CORS-CSRF-CSP.md).
- [ ] **Input validation** на границе (zod / pydantic) — backend owner — block.

## Tests

- [ ] **Integration tests** для каждого endpoint (happy + permission + validation + error) — backend owner — block — [Integration testing](../docs/09-testing/Integration-testing.md).
- [ ] **Contract tests** против схемы или Pact — backend owner — block — [Contract testing](../docs/09-testing/Contract-testing.md).
- [ ] **Negative auth tests** (admin / user / anon) — security owner — block.
- [ ] **External API** покрыты contract или integration tests против sandbox — backend owner — warn.

## Observability

- [ ] **Logs** структурированные с `correlation_id` — devops owner — warn — [Logging](../docs/03-backend/Logging.md).
- [ ] **Metrics** RED (Rate / Errors / Duration) на endpoint — devops owner — warn — [Observability](../docs/08-devops-deploy/Observability.md).
- [ ] **Traces** через критичные endpoints — devops owner — warn — [OpenTelemetry](../docs/08-devops-deploy/OpenTelemetry.md).
