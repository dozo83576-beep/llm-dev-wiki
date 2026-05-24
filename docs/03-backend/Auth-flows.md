---
title: "Backend auth flows"
category: "backend"
updated: "2026-05-24"
status: "active"
tags: ["auth", "backend"]
source_priority: "internal"
---

# Backend auth flows

Auth flow должен быть спроектирован как набор проверяемых сценариев: signup, login, logout, session refresh, password reset, MFA, invite, role change.

## Production-паттерны

- Session/cookie auth для browser apps, OAuth/OIDC для SSO, API keys для machine clients.
- Password reset tokens одноразовые, с TTL и audit log.
- Role changes требуют audit log и повторной проверки активных сессий.
- Admin endpoints имеют отдельные guards и rate limits.

## Частые ошибки

- Проверка роли только на frontend.
- JWT без revoke/session strategy.
- Password reset без rate limit.

## Проверка

- Integration tests на login/logout/session expiry.
- Negative tests: user не может получить чужую сессию или повысить роль.
- Security tests на brute force и reset abuse.

## Когда использовать

Используй auth flows для любого продукта с аккаунтами, организациями, платным доступом, админками или персональными данными.

## Когда не использовать

Не пиши самописную password/session систему, если Auth.js, Supabase Auth, OIDC или managed provider закрывают требования.

## Источники

См. [Authentication](../05-auth-security/Authentication.md), [Authorization](../05-auth-security/Authorization.md), [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html).

