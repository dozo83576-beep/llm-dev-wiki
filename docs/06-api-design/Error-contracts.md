---
title: "API error contracts"
category: "api"
updated: "2026-05-24"
status: "active"
tags: ["errors", "contract"]
source_priority: "internal"
---

# API error contracts

Единый контракт ошибок упрощает frontend, поддержку и observability.

Рекомендуемая форма: `code`, `message`, `details`, `correlationId`. Не возвращай stack trace, SQL, секреты или внутренние enum без необходимости.

## Когда использовать

Используй error contract для любого API, которым пользуется frontend, mobile, external client, webhook consumer или integration partner.

## Когда не использовать

Не усложняй одноразовый internal script полноценным публичным контрактом, если он не является API boundary.

## Production-паттерны

`code` стабилен и машинно-читаем, `message` безопасен для пользователя, `details` структурирует validation errors, `correlationId` связывает UI, logs и support.

## Частые ошибки

Возвращать raw exception, менять `code` без deprecation, раскрывать SQL/stack trace, смешивать 401 и 403, не различать conflict и validation.

## Проверка

Contract tests для 400/401/403/404/409/429/500, snapshot response shape, frontend handling для validation и permission errors.

## Источники

См. [[../../patterns/api/error-contract|API error contract]], [[../03-backend/Error-handling|Error handling]].

