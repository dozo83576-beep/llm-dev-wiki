---
title: "Database review checklist"
category: "checklist"
updated: "2026-05-24"
status: "active"
tags: ["database", "review", "migrations"]
source_priority: "internal"
---

# Database review checklist

Gated checklist для изменений в схеме, миграций или новой data-модели. Формат: критерий — проверка — owner — severity — ссылка.

## Schema design

- [ ] **Сущности** имеют понятный lifecycle (создание / переходы / удаление) — backend owner — block — [Database design](../docs/04-databases/Database-design.md).
- [ ] **Foreign keys** на всех связях, где есть инвариант — backend owner — block.
- [ ] **Unique constraints** отражают бизнес-инварианты (email, slug, composite uniqueness) — backend owner — block.
- [ ] **CHECK constraints** для нетривиальных доменных инвариантов — backend owner — warn.
- [ ] **Naming convention** соблюдена (snake_case, plurals, suffix `_id` для FK) — backend owner — warn.

## Indexes

- [ ] **Индексы** покрывают реальные WHERE / ORDER BY / JOIN patterns — backend owner — block — [Query optimization](../docs/04-databases/Query-optimization.md).
- [ ] **Partial / covering indexes** для устойчивых фильтров — backend owner — warn.
- [ ] **Нет неиспользуемых индексов** (проверить `pg_stat_user_indexes`) — backend owner — warn.

## Migrations

- [ ] **Миграции** проверены на staging или локальной копии — backend owner — block — [Migrations](../docs/04-databases/Migrations.md).
- [ ] **Backward-compatible** или explicit expand-contract — backend owner — block — [expand-contract pattern](../patterns/database/expand-contract-migration.md).
- [ ] **Reversible** или с явным "no rollback" обоснованием — backend owner — block — [Rollback](../docs/08-devops-deploy/Rollback.md).
- [ ] **Long-running** миграции (≥ 30s) запускаются отдельным шагом, не в startup — devops owner — block.
- [ ] **Locks** на больших таблицах учтены: `CREATE INDEX CONCURRENTLY`, lock_timeout — backend owner — block.
- [ ] **Backfill** для NOT NULL колонок выполнен порциями — backend owner — block.

## Data lifecycle

- [ ] **Soft delete** применён только где есть бизнес-кейс восстановления — backend owner — warn — [Audit log](../docs/04-databases/Audit-log.md).
- [ ] **Audit log** для critical сущностей (orders, payments, roles) — backend owner — block.
- [ ] **Retention policy** для логов / временных данных задокументирована — backend owner — warn.
- [ ] **GDPR / privacy**: delete request покрыт пайплайном — backend owner — warn.

## Multi-tenancy

- [ ] **Tenant ID** во всех таблицах с tenant-scoped данными — backend owner — block — [Multi-tenancy](../docs/04-databases/Multi-tenancy.md).
- [ ] **Tenant boundary tests** на каждом list endpoint — backend owner — block — [tenant-isolation pattern](../patterns/security/tenant-isolation.md).
- [ ] **RLS** (Row-Level Security) включена для критичных таблиц где доступна — backend owner — warn.

## Backup & restore

- [ ] **Backup** активен; retention policy определена — devops owner — block — [Backups](../docs/04-databases/Backups.md).
- [ ] **Restore-drill** пройден в текущем квартале — devops owner — warn.
- [ ] **PITR** (point-in-time recovery) включён для production — devops owner — warn.

## Performance

- [ ] **EXPLAIN ANALYZE** прогнан для новых hot queries — backend owner — block — [Query optimization](../docs/04-databases/Query-optimization.md).
- [ ] **N+1** проверки на новых list endpoints — backend owner — block.
- [ ] **Connection pool** размер соответствует нагрузке — devops owner — warn.
