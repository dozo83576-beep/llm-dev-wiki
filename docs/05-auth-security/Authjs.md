---
title: "Auth.js"
category: "security"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["auth", "authjs", "nextjs", "session"]
source_priority: "official-docs"
---

# Auth.js

Auth.js подходит, когда нужна open-source authentication в Next.js/React-приложении без передачи всей identity-плоскости managed SaaS-провайдеру. Это слой sign-in/sign-out, providers, sessions, callbacks и adapters; authorization всё равно проектируется отдельно.

## Когда использовать

- Next.js / full-stack app с OAuth, email magic links, passkeys или credentials provider.
- Нужен контроль над БД, session model, callbacks и user/account tables.
- Команда готова обслуживать auth-конфигурацию, secrets, cookies, email delivery и migrations.

## Когда не использовать

- Нужны enterprise SSO, organizations, hosted account management и готовый UI быстрее, чем кастомизация.
- Нет команды, которая понимает cookie/session security и auth incident response.
- Требуется turnkey B2B multi-tenancy с roles/permissions из коробки — см. [Clerk](Clerk.md).

## Production-паттерны

- Session strategy выбирается явно: `jwt` для stateless/simple flow, database sessions для server-side revocation и auditability.
- OAuth providers настраиваются через official provider packages, redirect URLs фиксируются по окружениям.
- Credentials provider используется только с сильным password hashing, rate limit, MFA/admin policy и audit log.
- Auth callbacks не становятся authorization engine: проверка tenant/object permission остаётся на backend.
- `AUTH_SECRET`, provider secrets и email credentials живут только в secret manager.

## Частые ошибки

- Хранить role/tenant claims в session и считать их вечной правдой без server-side проверки.
- Смешивать session callback и бизнес-authorization.
- Не тестировать expired/revoked session, account linking и failed OAuth callback.
- Делать email magic links без защиты от enumeration и без TTL.

## Проверка

- Integration: sign-in/sign-out, callback URL allowlist, expired session, revoked user, provider error.
- Security: brute-force/rate-limit на credentials, cookie flags, secret rotation drill.
- E2E: OAuth happy path, denied callback, admin route denied for non-admin.

## Источники

- [Auth.js Docs](https://authjs.dev/) — проверено 2026-05-24.
- [Auth.js Session Strategies](https://authjs.dev/concepts/session-strategies) — проверено 2026-05-24.
- [Auth.js OAuth](https://authjs.dev/getting-started/authentication/oauth) — проверено 2026-05-24.
