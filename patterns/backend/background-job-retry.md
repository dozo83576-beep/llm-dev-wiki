---
title: "Pattern: Background job retry"
category: "patterns"
updated: "2026-05-24"
status: "active"
tags: ["backend", "jobs", "retry"]
---

# Background job retry

Retry делает систему устойчивее только если задача идемпотентна и имеет предел повторов.

## Когда использовать

Email, webhooks, imports, AI jobs, billing sync, report generation.

## Когда не использовать

Не retry business validation failures: они не станут успешными от повторения.

## Production-паттерны

Разделяй transient и permanent failures, используй exponential backoff, dead-letter queue и idempotency keys.

## Частые ошибки

- Infinite retry без alert.
- Повтор задачи создает дубли.
- Нет visibility для stuck jobs.

## Проверка

Integration tests: transient failure succeeds on retry, permanent failure moves to dead-letter, duplicate job safe.

Источники: [Background jobs](../../docs/03-backend/Background-jobs.md).

