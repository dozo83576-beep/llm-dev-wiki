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

