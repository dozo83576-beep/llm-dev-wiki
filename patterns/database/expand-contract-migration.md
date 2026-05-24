---
title: "Pattern: Expand-contract migration"
category: "patterns"
updated: "2026-05-24"
status: "active"
tags: ["database", "migrations", "deploy"]
---

# Expand-contract migration

Expand-contract снижает риск при изменениях схемы, которые требуют совместимости старого и нового кода.

## Когда использовать

Переименование колонок, split/merge таблиц, изменение required fields, backfill больших таблиц.

## Когда не использовать

Для маленьких локальных таблиц без production traffic можно использовать простую миграцию, если rollback понятен.

## Production-паттерны

Expand: добавить новую структуру без удаления старой. Migrate: backfill и двойная запись/чтение. Contract: удалить старое после подтверждения.

## Частые ошибки

- Удалить колонку в том же deploy, где код еще может ее читать.
- Делать большой blocking backfill в migration.
- Не иметь rollback-плана.

## Проверка

Staging migration, compatibility tests старого/нового кода, rollback smoke.

Источники: [Migrations](../../docs/04-databases/Migrations.md), [Rollback](../../docs/08-devops-deploy/Rollback.md).

