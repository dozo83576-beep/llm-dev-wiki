---
title: "Transactions"
category: "database"
updated: "2026-05-24"
status: "active"
tags: ["transactions", "postgresql"]
source_priority: "official-docs"
---

# Transactions

Transaction boundary должен соответствовать бизнес-операции, а не случайному repository call.

## Production-паттерны

- Все изменения одного инварианта в одной транзакции.
- External API calls не держат DB transaction открытой.
- Для конкуренции используй unique constraints, row locks или optimistic locking.
- Retry только для безопасных transient failures.

## Частые ошибки

- Частично записанное состояние после ошибки.
- Долгая транзакция вокруг network call.
- Проверка uniqueness только в коде.

Источник: [PostgreSQL Transactions](https://www.postgresql.org/docs/current/tutorial-transactions.html).

## Когда использовать

Используй transactions для операций, где несколько изменений должны быть атомарными: orders, payments, role changes, inventory, audit.

## Когда не использовать

Не держи транзакцию открытой вокруг внешнего HTTP API, AI request, file upload или долгого job.

## Проверка

Integration tests на partial failure, concurrent mutation, unique constraint race, rollback side effects, advisory lock на критичных секциях.

## Edge cases

- Isolation level: REPEATABLE READ / SERIALIZABLE для критичных операций; обрабатывать `serialization_failure` с retry.
- Savepoints для частичного rollback внутри большой операции.
- Deadlocks: одинаковый порядок locking ресурсов между транзакциями.
- Long-running transaction блокирует VACUUM — vacuum bloat и tuple visibility.
- Cross-service transactions: нет distributed transaction — выходим через saga / outbox.

## Security risks

`SELECT ... FOR UPDATE` без WHERE-фильтра по tenant — может лочить лишние строки и утекать данные через timing. Открытая транзакция вокруг external API даёт DoS-вектор.

## Источники

- [PostgreSQL Transactions](https://www.postgresql.org/docs/current/tutorial-transactions.html) — проверено 2026-05-24.
- См. [Multi-tenancy](Multi-tenancy.md), [Migrations](Migrations.md), [Query optimization](Query-optimization.md).
