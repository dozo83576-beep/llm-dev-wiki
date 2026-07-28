---
title: "PostgreSQL"
category: "database"
updated: "2026-07-21"
reviewed: "2026-07-21"
status: "active"
tags: ["postgresql", "database"]
source_priority: "official-docs"
---

# PostgreSQL

PostgreSQL — база по умолчанию для production web-приложений. Используй constraints, indexes, transactions, migrations, backups и least-privilege users.

Правила: внешние ключи для целостности, уникальные индексы для бизнес-инвариантов, `EXPLAIN` для медленных запросов, транзакции для связанных изменений.

**Поддерживаемые patch-линии на 2026-07-21:** PostgreSQL `18.4`, `17.10`, `16.14`, `15.18`, `14.23`. Обновляй текущую major-линию до её последнего patch без ожидания feature release; major upgrade требует отдельной репетиции migration/rollback. PostgreSQL 14 достигает EOL 2026-11-12, поэтому для него уже нужен план перехода на поддерживаемую major-линию.

Источники: [PostgreSQL Docs](https://www.postgresql.org/docs/) и [релиз 18.4/17.10/16.14/15.18/14.23](https://www.postgresql.org/about/news/postgresql-184-1710-1614-1518-and-1423-released-3297/) — проверено 2026-07-21.

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

