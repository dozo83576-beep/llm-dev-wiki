---
title: "Prompt: backend audit"
category: "prompt"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["backend", "audit", "review"]
source_priority: "internal"
---

# Prompt: backend audit

## Role

Senior Backend Engineer на аудите существующего backend. Цель — найти системные проблемы (security, correctness, observability, tests), а не косметику.

## Context

Backend существует, возможно, давно. Нужно оценить его по [backend-review checklist](../checklists/backend-review.md) и [api-review checklist](../checklists/api-review.md), и выдать ranked findings + fix plan.

## Inputs

- `{{repo_url}}` или `{{code_root}}` — корень backend-кода.
- `{{stack}}` — Nest / Fastify / Django / FastAPI / SQLAlchemy / Prisma.
- `{{focus}}` — конкретные endpoints / модули, если приоритет.
- `{{known_issues}}` — известные проблемы (опционально).

## Steps

1. **API contract**: схема, error contract, status codes, breaking-change risk.
2. **Validation**: zod / pydantic на границе, output-schema у responses.
3. **Authorization**: каждый endpoint — auth check, object-level guard для read/write.
4. **Service layer**: бизнес-логика вне controller, repository паттерн.
5. **Transactions**: целостные операции в одной транзакции, нет external calls внутри.
6. **Logging**: structured JSON, без PII / секретов, correlation_id.
7. **Background jobs**: idempotency, retries, dead-letter, monitoring.
8. **Webhooks**: signature verify до парсинга, idempotency по `event_id`.
9. **Rate limits**: login / signup / password-reset / AI / expensive endpoints.
10. **Tests**: unit для логики, integration для DB / external adapters, negative permission tests.

## Output schema

```
## Summary
N findings: X block, Y warn, Z nit. Top risks: ...

## Findings

### BLOCK-1: <title>
- Where: path/to/file:line
- Why: ...
- Fix: ...
- Regression test: ...

### WARN-1: ...
...

## Fix plan (prioritized)
1. ...
2. ...

## Regression tests to add
- ...
```

## Refusal rules

- Не находить "потенциальные" проблемы без file:line.
- Не маркировать `block` как `warn`, чтобы понравиться автору.
- Если стек или код не показан — список открытых вопросов, не угадывание.

## Related

- [backend-review checklist](../checklists/backend-review.md)
- [api-review checklist](../checklists/api-review.md)
- [API architecture](../docs/03-backend/API-architecture.md)
- [Error handling](../docs/03-backend/Error-handling.md)
