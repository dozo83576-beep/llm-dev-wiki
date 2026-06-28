---
title: "Database design"
category: "database"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["schema", "design"]
source_priority: "mixed"
---

# Database design

Проектируй от бизнес-инвариантов: сущности, связи, кардинальность, ownership, lifecycle, audit, multi-tenancy, soft delete.

Правила: нормализуй по умолчанию, денормализуй под измеренную нагрузку, индексы добавляй под реальные запросы, uniqueness закрепляй на уровне БД.

## Когда использовать

Проектирование данных обязательно до реализации CRUD, billing, permissions, audit, marketplace, multi-tenancy и reporting.

## Когда не использовать

Не делай детальную enterprise-модель для throwaway prototype, но даже MVP должен иметь понятные entities, ownership и constraints.

## Production-паттерны

Сначала фиксируй бизнес-инварианты, затем сущности, связи, lifecycle, constraints, indexes, delete policy, audit и backup.

## Частые ошибки

Проверять uniqueness только в коде, использовать JSON blob вместо модели без причины, не проектировать ownership, не думать о deletion и retention.

## Проверка

Schema review, migration review, tests на constraints, permission queries, query plans для hot paths.

## Источники

См. [PostgreSQL Constraints](https://www.postgresql.org/docs/current/ddl-constraints.html), [Multi-tenancy](Multi-tenancy.md).
