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

