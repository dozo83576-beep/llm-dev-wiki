---
title: "Clerk"
category: "security"
updated: "2026-05-24"
status: "active"
tags: ["auth", "clerk", "b2b", "organizations"]
source_priority: "vendor-docs"
---

# Clerk

Clerk — managed authentication и user management для web-приложений. Сильная сторона — быстрый запуск sign-in/sign-up, sessions, Organizations, Roles/Permissions и готовые UI-компоненты. Слабая сторона — vendor lock-in и необходимость держать backend authorization отдельно от UI guards.

## Когда использовать

- B2B SaaS с organizations/workspaces, invitations, roles и permissions.
- Нужны готовые auth-компоненты, быстрый onboarding, SSO/MFA и hosted account management.
- Команда принимает зависимость от managed identity provider.

## Когда не использовать

- Требуется полностью self-hosted auth или строгий запрет на внешнего identity provider.
- Нужна кастомная auth-модель, которую проще выразить через Auth.js + собственную БД.
- Нельзя платить за managed auth при росте users/organizations.

## Production-паттерны

- `orgId`, `orgRole` и permissions из Clerk используются как вход в policy, но object-level authorization проверяется на backend.
- Active Organization считается частью request context; endpoints без `orgId` должны отвечать deny-by-default.
- Clerk webhooks обрабатываются идемпотентно: user/org membership sync, retries, signature verification.
- Sensitive actions требуют server-side authorization, re-verification или MFA policy.
- Локальная БД хранит только нужные projection fields, а не полную копию identity provider.

## Частые ошибки

- Считать скрытую кнопку в Clerk UI достаточной защитой endpoint.
- Не учитывать переключение active organization в нескольких вкладках.
- Синхронизировать users/orgs webhook'ами без idempotency и audit log.
- Привязывать billing tenant к email domain без ручной проверки ownership.

## Проверка

- Integration: user without org, wrong org, member vs admin, deleted membership, webhook replay.
- E2E: organization switch, protected route, invite flow, downgrade role.
- Security: backend negative tests для каждого sensitive endpoint.

## Источники

- [Clerk Next.js SDK](https://clerk.com/docs/reference/nextjs/overview) — проверено 2026-05-24.
- [Clerk Organizations](https://clerk.com/docs/guides/organizations/overview) — проверено 2026-05-24.
- [Clerk Webhooks](https://clerk.com/docs/reference/webhooks) — проверено 2026-05-24.
