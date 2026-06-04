---
title: "Playbook: Admin dashboard"
category: "playbooks"
updated: "2026-06-04"
status: "active"
tags: ["admin", "dashboard", "rbac", "audit"]
source_priority: "internal"
---

# Playbook: Admin dashboard

Internal-tool для операторов, support, finance, moderators. Цель — операторская эффективность плюс безопасность destructive actions.

## Когда использовать

- Нужен read/write интерфейс для сотрудников: support tickets, refunds, user management, content moderation.
- Команды без bandwidth на собственный фронт — берётся Retool/Forest, но иногда сам пишется.

## Когда не использовать

- Достаточно read-only metabase / Looker — не нужен полноценный admin UI.
- Очень узкая операция — CLI-скрипт быстрее, чем dashboard.

## Стек по умолчанию

Next.js/React + typed API + RBAC + audit log + dense tables/forms/charts + Playwright smoke. Для CRUD-heavy internal tools проверь [htmx](../02-frontend/HTMX.md) как более простой server-rendered вариант.

## Порядок разработки

1. **Roles & permissions**: определить роли (support / finance / admin), что каждая может видеть и делать.
2. **High-risk actions inventory**: delete, export PII, refund > X, role change, send mass email.
3. **Navigation & search**: dense layout, поиск с фильтрами, bulk-actions.
4. **Tables & forms**: server-side pagination, явные empty / error / loading states.
5. **Confirmations & two-step**: destructive action требует подтверждения, money/refund — двойного.
6. **Audit log**: каждое state-changing действие логируется (actor, action, target, before/after).
7. **Permission tests**: integration test на каждый endpoint (admin OK, support 403, не-admin 403).
8. **Smoke E2E**: критичные flow проходят на каждый релиз.

## Production-паттерны

- RBAC с явным `can(user, action, resource)` API, не разбросанные `if user.role === ...`.
- Soft-delete по умолчанию для критичных сущностей, hard delete — отдельный pipeline.
- Rate limit на admin-endpoints — защита от инсайдерских скриптов.
- Export данных — отдельная функция с audit и approval flow.

## Анти-паттерны

- Красивый dashboard без операторской эффективности (нет горячих клавиш, нет bulk-actions).
- Нет audit trail — невозможно расследовать инциденты.
- Одинаковый UI для safe action и destructive action.
- Admin-доступ через одну роль для всех сотрудников.

## Security risks

- IDOR на admin-endpoints (доступ к чужим объектам по id).
- PII в logs / экспортных файлах.
- Session-fixation, hijacked admin-cookie без MFA.
- Tabnabbing / clickjacking — нужны frame-ancestors / sameSite cookies.

## Testing strategy

- Permission grid в integration tests: матрица "роль × endpoint × ожидаемый код".
- E2E smoke: login → пройти критичный flow → logout.
- Audit-log assertion: после каждого write — есть запись.

## Edge cases

- Bulk action на 10k записей — нужен background job, не sync endpoint.
- Impersonation (admin "стать" другим user) — особый audit + visual indicator + ограничения.
- Concurrent edits на один объект — optimistic locking / version number.

## Источники

- См. [htmx](../02-frontend/HTMX.md), [Authorization](../05-auth-security/Authorization.md), [RBAC/ABAC](../05-auth-security/RBAC-ABAC.md), [Audit log](../04-databases/Audit-log.md), [deny-by-default pattern](../../patterns/security/deny-by-default.md).
