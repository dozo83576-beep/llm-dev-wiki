---
title: "Authorization"
category: "security"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["authorization", "permissions"]
source_priority: "mixed"
---

# Authorization

Authorization отвечает на вопрос "что пользователь может сделать". Проверяй права на сервере для каждого действия и объекта.

Правила: deny by default, object-level permissions, tenant isolation, tests на чужие ID, audit для privilege changes.

## Когда использовать

Всегда после authentication, если есть роли, owners, tenants, paid features, admin actions или приватные объекты.

## Когда не использовать

Не заменяй authorization скрытием UI. Frontend guard — UX, не security boundary.

## Production-паттерны

Deny by default, object-level checks, tenant-scoped queries, central permission helpers, audit log для privilege changes. Managed auth claims из [Clerk](Clerk.md) или session claims из [Auth.js](Authjs.md) — вход в policy, не замена backend authorization.

## Частые ошибки

Проверять роль без проверки ownership, делать `findById` без tenant/user scope, забывать export/download endpoints, не тестировать negative cases.

## Проверка

Negative integration tests: чужой объект нельзя читать, менять, удалять, экспортировать. Проверяй 403 отдельно от 404 policy.

## Источники

См. [Deny by default](../../patterns/security/deny-by-default.md), [Tenant isolation](../../patterns/security/tenant-isolation.md), [Clerk](Clerk.md), [Auth.js](Authjs.md), [OWASP Broken Access Control](https://owasp.org/Top10/A01_2021-Broken_Access_Control/).
