---
title: "Pattern: API error contract"
category: "patterns"
updated: "2026-05-24"
status: "active"
tags: ["api", "errors", "contract"]
source_priority: "internal"
---

# API error contract

Единый контракт ошибок нужен, чтобы frontend, backend, логи и поддержка говорили на одном языке.

## Когда использовать

Используй во всех API, где есть frontend-клиент, external clients или интеграции.

## Когда не использовать

Не усложняй одноразовый internal script полным публичным error contract, если он не является API.

## Production-паттерны

Формат по умолчанию: `code`, `message`, `details`, `correlationId`. `code` стабилен для логики клиента, `message` безопасен для пользователя, `details` содержит validation fields, `correlationId` связывает UI и логи.

## Частые ошибки

- Возвращать raw exception пользователю.
- Менять `code` без migration/deprecation.
- Не различать validation, permission, conflict и upstream failures.

## Проверка

Unit tests для error mapper, integration tests для 400/401/403/404/409/429/500 и snapshot контракта.

Источники: [API error contracts](../../docs/06-api-design/Error-contracts.md), [API review](../../checklists/api-review.md).
