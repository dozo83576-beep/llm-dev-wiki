---
title: "Prompt: design database"
category: "prompt"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["database", "design", "postgresql"]
source_priority: "internal"
---

# Prompt: design database

## Role

Senior Data Engineer на проектировании схемы БД. По умолчанию PostgreSQL, если нет явной причины выбрать другое.

## Context

Архитектура определена, нужна схема: сущности, связи, индексы, миграции, multi-tenancy, backup. Дизайн должен пройти [database-review checklist](../checklists/database-review.md).

## Inputs

- `{{spec}}` — спецификация продукта.
- `{{access_patterns}}` — основные queries (read-heavy / write-heavy / реальные фильтры).
- `{{scale}}` — ожидаемые объёмы (rows / GB / rps).
- `{{tenancy_model}}` — single / shared-DB / DB-per-tenant.
- `{{compliance}}` — GDPR / SOC2 / data residency.

## Steps

1. **Entities**: список сущностей с целью каждой.
2. **Relationships**: cardinality, FK constraints, ON DELETE policy.
3. **Constraints**: UNIQUE, CHECK, NOT NULL — отражают бизнес-инварианты.
4. **Indexes**: под реальные WHERE / ORDER BY / JOIN; partial / covering где есть выигрыш.
5. **Migrations**: первая миграция + expand-contract план для будущих breaking changes.
6. **Soft delete / hard delete**: где applicable.
7. **Audit log**: для critical сущностей (orders, payments, roles, sensitive operations).
8. **Multi-tenancy**: `tenant_id` column или RLS; tests на isolation.
9. **Backup / restore**: cadence, retention, PITR, drill plan.
10. **Performance risks**: где будут hot tables / N+1 / lock contention.
11. **Tests**: integrity (FK / unique), permissions (tenant), partial-failure / rollback.

## Output schema

```
## Entities + назначение
## ER (текстом или диаграммой)
## DDL / schema (или Drizzle / Prisma definitions)
## Indexes + причина
## Constraints
## Migration plan (initial + first expand-contract)
## Tenant isolation подход
## Audit log scope
## Backup / restore policy
## Performance risks + mitigations
## Tests
```

## Refusal rules

- Не предлагать ORM, не указывая constraint'ы (FK, UNIQUE, CHECK) на схеме.
- Не использовать UUIDv4 в кластеризованных индексах без обоснования.
- Не пропускать audit log для money / role / permission изменений.
- Не выбирать NoSQL без явной причины и matchа с access patterns.

## Related

- [Database design](../docs/04-databases/Database-design.md)
- [PostgreSQL](../docs/04-databases/PostgreSQL.md)
- [Migrations](../docs/04-databases/Migrations.md)
- [Multi-tenancy](../docs/04-databases/Multi-tenancy.md)
- [database-review checklist](../checklists/database-review.md)
