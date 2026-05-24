---
title: "Multi-tenancy"
category: "database"
updated: "2026-05-24"
status: "active"
tags: ["multi-tenancy", "saas"]
source_priority: "internal"
---

# Multi-tenancy

Multi-tenancy определяет изоляцию данных между организациями или клиентами.

## Модели

- Shared schema + `tenant_id`: проще и дешевле, требует строгих permission tests.
- Schema per tenant: сильнее изоляция, сложнее миграции.
- Database per tenant: максимальная изоляция, выше эксплуатационная стоимость.

## Production-паттерны

- `tenant_id` входит в unique constraints, indexes и permission checks.
- Тесты на cross-tenant access обязательны.
- Admin/support access логируется.

## Когда использовать

Используй multi-tenancy для SaaS, agencies, workspaces, organizations, marketplaces и любых систем с изоляцией клиентов.

## Когда не использовать

Не добавляй multi-tenancy, если продукт всегда single-tenant и isolation решается отдельным deployment.

## Частые ошибки

Запрос по `id` без `tenant_id`, global uniqueness вместо tenant-scoped, отсутствие cross-tenant negative tests, support access без audit.

## Проверка

Negative tests на read/write/delete/export между tenants, query review, индекс `tenant_id + business key`.

## Источники

См. [[../../patterns/security/tenant-isolation|Tenant isolation]], [[../05-auth-security/Authorization|Authorization]].

