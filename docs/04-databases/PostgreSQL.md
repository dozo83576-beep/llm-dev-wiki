---
title: "PostgreSQL"
category: "database"
updated: "2026-05-24"
status: "active"
tags: ["postgresql", "database"]
source_priority: "official-docs"
---

# PostgreSQL

PostgreSQL — база по умолчанию для production web-приложений. Используй constraints, indexes, transactions, migrations, backups и least-privilege users.

Правила: внешние ключи для целостности, уникальные индексы для бизнес-инвариантов, `EXPLAIN` для медленных запросов, транзакции для связанных изменений.

Источник: [PostgreSQL Docs](https://www.postgresql.org/docs/).

## Когда использовать

Используй PostgreSQL по умолчанию для SaaS, marketplaces, admin, e-commerce, API и проектов с relational data, transactions и reporting.

## Когда не использовать

Не выбирай PostgreSQL как единственный store для ephemeral cache, high-volume time-series без оценки нагрузки или document-only workloads без relational needs.

## Production-паттерны

Constraints для инвариантов, transactions для атомарности, indexes под реальные queries, backups с restore test, roles с least privilege.

## Частые ошибки

Отсутствие foreign keys, N+1 через ORM, индексы без query plan, хранение secrets в таблицах без encryption policy.

## Проверка

Migration tests, EXPLAIN для hot queries, backup restore drill, permission tests, slow query monitoring.

