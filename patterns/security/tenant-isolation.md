---
title: "Pattern: Tenant isolation"
category: "patterns"
updated: "2026-05-24"
status: "active"
tags: ["security", "multi-tenancy", "saas"]
source_priority: "internal"
---

# Tenant isolation

Tenant isolation предотвращает доступ пользователя одной организации к данным другой.

## Когда использовать

Любой SaaS, marketplace или admin, где есть organizations, workspaces, projects или accounts.

## Когда не использовать

Не нужен для single-tenant продукта без разделения клиентов, но object-level permissions все равно могут понадобиться.

## Production-паттерны

`tenant_id` включается в queries, unique constraints, indexes, audit log и permission tests. Support/admin доступ логируется отдельно.

## Частые ошибки

- Проверять tenant только в UI.
- Получать объект по `id` без `tenant_id`.
- Делать global unique там, где нужна tenant-scoped uniqueness.

## Проверка

Negative tests: user A не читает, не меняет и не экспортирует объекты tenant B.

Источники: [Multi-tenancy](../../docs/04-databases/Multi-tenancy.md), [Security review](../../checklists/security-review.md).
