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

## Источники

См. [[Authorization|Authorization]], [[../../patterns/security/tenant-isolation|Tenant isolation]].

