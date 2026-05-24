---
title: "Authentication"
category: "security"
updated: "2026-05-24"
status: "active"
tags: ["auth", "authentication"]
source_priority: "official-docs"
---

# Authentication

Authentication отвечает на вопрос "кто пользователь". Для web-приложений выбирай session/OIDC/[Auth.js](Authjs.md)/Supabase Auth/[Clerk](Clerk.md) вместо самописной auth, если нет жесткой причины.

Правила: secure cookies, MFA для админов, password hashing через Argon2/bcrypt, reset tokens с TTL, audit log для входов и критичных изменений.

Источники: [Auth.js Docs](https://authjs.dev/), [Clerk Docs](https://clerk.com/docs/), [Supabase Auth Docs](https://supabase.com/docs/guides/auth).

## Когда использовать

Authentication нужен для любого продукта с аккаунтами, персональными данными, платным доступом, organization/workspace моделью или admin actions.

## Когда не использовать

Не делай собственную password/session систему, если managed auth, OIDC, [Auth.js](Authjs.md), [Clerk](Clerk.md) или Supabase закрывают требования. Самописная auth — высокий security-риск.

## Production-паттерны

Secure HTTP-only cookies, session rotation, MFA для админов, rate limit на login/reset, audit log для auth events, password hashing через зрелую библиотеку.

## Частые ошибки

Хранить JWT в localStorage без оценки XSS-риска, reset token без TTL, отсутствие brute force защиты, разные ошибки для existing/non-existing email.

## Проверка

Integration tests для login/logout/session expiry/reset, negative tests для reuse reset token, rate-limit checks, audit log checks.
