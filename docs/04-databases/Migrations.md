---
title: "Database migrations"
category: "database"
updated: "2026-05-24"
status: "active"
tags: ["migrations", "database"]
source_priority: "internal"
---

# Database migrations

Миграция — production-риск. Для больших таблиц избегай блокирующих операций, делай expand-and-contract, backfill отдельным job, проверяй rollback-путь.

Перед deploy: backup, dry-run на staging, оценка lock time, совместимость старого и нового кода на период rollout.

## Когда использовать

Каждое изменение schema, constraints, indexes, seed/reference data и backfill должно проходить через migration process.

## Когда не использовать

Не запускай ручные SQL-изменения в production без фиксации в migration history, кроме emergency repair с последующим документированием.

## Production-паттерны

Expand-contract для breaking changes, concurrent indexes где поддерживается, backfill отдельным job, backward-compatible app deploy.

## Частые ошибки

Blocking alter на большой таблице, удаление поля до обновления кода, migration с внешними API вызовами, отсутствие rollback notes.

## Проверка

Staging dry-run, lock analysis, backup verification, migration rollback plan, app compatibility test.

## Источники

См. [Expand-contract migration](../../patterns/database/expand-contract-migration.md), [PostgreSQL ALTER TABLE](https://www.postgresql.org/docs/current/sql-altertable.html).

