---
title: "Rate limiting"
category: "security"
updated: "2026-05-24"
status: "active"
tags: ["rate-limit", "abuse"]
source_priority: "internal"
---

# Rate limiting

Rate limiting нужен для login, signup, password reset, AI endpoints, expensive search, webhooks и публичных API.

Ключи лимита: IP, user id, tenant id, API key, route group. Для AI добавляй budget limits и usage alerts.

## Когда использовать

Login, signup, password reset, public API, webhooks, expensive search, AI endpoints, file uploads и payment-sensitive операции.

## Когда не использовать

Не используй один грубый глобальный лимит для всех пользователей, если он ломает legitimate enterprise/tenant usage.

## Production-паттерны

Лимиты по IP + user/tenant/API key, разные buckets для дорогих routes, понятный 429 error contract, allowlist для trusted internal systems.

## Частые ошибки

Rate limit только по IP за NAT, отсутствие лимитов на reset password, не учитывать стоимость AI tokens, не логировать abuse attempts.

## Проверка

Integration tests на 429, load smoke, bypass tests для authenticated/anonymous, alert на всплески.

## Источники

См. [OWASP Rate Limiting](https://cheatsheetseries.owasp.org/cheatsheets/Denial_of_Service_Cheat_Sheet.html), [API error contracts](../06-api-design/Error-contracts.md).

