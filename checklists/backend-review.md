---
title: "Backend review checklist"
category: "checklist"
updated: "2026-05-24"
status: "active"
tags: ["backend", "review"]
source_priority: "internal"
---

# Backend review checklist

Gated checklist для backend-фичи или сервиса. Формат: критерий — проверка — owner — severity — ссылка.

## Architecture & layering

- [ ] **Бизнес-логика** не в controller / route handler — service layer обязателен — backend owner — block — [service-layer pattern](../patterns/backend/service-layer.md).
- [ ] **Repository pattern** для DB-доступа — backend owner — warn.
- [ ] **Domain types** отделены от DTO API — backend owner — warn.
- [ ] **Циклические зависимости** между модулями отсутствуют — backend owner — block.

## Input & validation

- [ ] **Validation на границе API** через zod / pydantic / class-validator — backend owner — block — [API architecture](../docs/03-backend/API-architecture.md).
- [ ] **Type coercion** в schema, не в коде — backend owner — warn.
- [ ] **Default values** разрешены только для optional полей с понятной семантикой — backend owner — warn.

## Authorization

- [ ] **Authz проверяется до** доступа к объекту (object-level), не только role-level — security owner — block — [Authorization](../docs/05-auth-security/Authorization.md).
- [ ] **Tenant boundary** во всех queries — security owner — block — [tenant-isolation pattern](../patterns/security/tenant-isolation.md).
- [ ] **Negative permission tests** для каждого endpoint — security owner — block.

## Errors

- [ ] **Единый error contract** в response — backend owner — block — [Error contracts](../docs/06-api-design/Error-contracts.md).
- [ ] **Не утекают** stack trace / SQL / секреты — backend owner — block — [Error handling](../docs/03-backend/Error-handling.md).
- [ ] **Custom error types** для бизнес-сценариев (NotFound, Conflict, Validation) — backend owner — warn.

## External calls

- [ ] **Timeout** на каждом внешнем HTTP-вызове (≤ 30s по умолчанию) — backend owner — block.
- [ ] **Circuit breaker / retry с backoff** для нестабильных downstream — backend owner — warn.
- [ ] **Idempotency** ключи для критичных POST к внешним API — backend owner — block.
- [ ] **External call** не внутри DB-транзакции — backend owner — block — [Transactions](../docs/04-databases/Transactions.md).

## Transactions

- [ ] **Транзакции** покрывают целостные бизнес-операции; одна сущность — одна транзакция — backend owner — block — [Transactions](../docs/04-databases/Transactions.md).
- [ ] **Уникальные constraints** на инвариантах бизнес-уровня — backend owner — block.
- [ ] **Конкурентный доступ** покрыт оптимистическим / row lock'ом — backend owner — warn.

## Logs & observability

- [ ] **Logs structured** (JSON), без PII / секретов — devops owner — block — [Logging](../docs/03-backend/Logging.md).
- [ ] **Correlation id** прокидывается через async-jobs — devops owner — warn.
- [ ] **Metrics** на критичных операциях (latency, success rate) — devops owner — warn.

## Tests

- [ ] **Unit tests** для чистой логики (pricing, validators, permissions) — backend owner — block — [Unit testing](../docs/09-testing/Unit-testing.md).
- [ ] **Integration tests** для DB-операций и external adapters — backend owner — block — [Integration testing](../docs/09-testing/Integration-testing.md).
- [ ] **Coverage** для критичной логики ≥ baseline — backend owner — warn.

## Background work

- [ ] **Background jobs** для долгих операций (email, image processing, sync) — backend owner — warn — [Background jobs](../docs/03-backend/Background-jobs.md).
- [ ] **Job idempotent** by design — backend owner — block — [background-job-retry pattern](../patterns/backend/background-job-retry.md).
- [ ] **Dead-letter queue** или явная failure policy — backend owner — warn.
