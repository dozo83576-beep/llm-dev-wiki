---
title: "RBAC and ABAC"
category: "security"
updated: "2026-05-24"
status: "active"
tags: ["rbac", "abac"]
source_priority: "internal"
---

# RBAC and ABAC

RBAC подходит для ролей: admin, manager, user. ABAC нужен, когда права зависят от атрибутов: владелец, tenant, статус, регион, тариф.

Практичный подход: RBAC для крупных возможностей, ABAC для object-level ограничений.

## Когда использовать

RBAC используй для ролей и feature groups. ABAC используй для ownership, tenant, status, plan, region, data sensitivity.

## Когда не использовать

Не моделируй сложный ABAC policy engine для маленького MVP с двумя ролями, если простые guards и object checks достаточны.

## Production-паттерны

RBAC отвечает “какие действия доступны роли”, ABAC отвечает “можно ли этому actor действовать над этим object сейчас”.

## Частые ошибки

Роль `admin` без scope, permissions в frontend-only config, отсутствие tests на downgrade роли, конфликт plan/role/ownership.

## Проверка

Permission matrix tests, object-level negative tests, audit для role/permission changes.

## Edge cases

- Inheritance ролей: явный `roles` граф или плоский — выбирать единый стиль, не миксовать.
- Time-bound permissions (temporary admin) — TTL и audit на grant/revoke.
- Impersonation (admin "стать" user) — отдельный actor в audit, ограниченные права.
- Delegated administration: org-admin не должен повысить себя выше своих прав.
- Permission caching: invalidation при изменении ролей; иначе пользователь "застрял" в старой роли.

## Security risks

Privilege escalation через mass-assignment в profile update, утечка через шумные error messages (`401 vs 403 vs 404`), отсутствие тестов на downgrade — пользователь сохраняет доступ после понижения роли.

## Источники

См. [Authorization](Authorization.md), [tenant-isolation pattern](../../patterns/security/tenant-isolation.md), [deny-by-default pattern](../../patterns/security/deny-by-default.md).

