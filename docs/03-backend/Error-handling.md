---
title: "Error handling"
category: "backend"
updated: "2026-05-24"
status: "active"
tags: ["errors", "api"]
source_priority: "internal"
---

# Error handling

Ошибки дели на validation, auth, permission, not found, conflict, rate limit, upstream, internal. Клиенту возвращай стабильный код, сообщение и correlation id; внутренние детали оставляй в логах.

Повторяемые ошибки должны иметь тесты и попадать в `case-studies/failures`, если повлияли на проект.

## Когда использовать

Всегда в backend API, workers, webhooks и integrations. Error handling — часть публичного контракта системы.

## Когда не использовать

Не скрывай все ошибки под generic 500 в местах, где клиенту нужен корректный action: validation, auth, conflict, retry later.

## Production-паттерны

Typed domain errors мапятся в API error contract. Internal details остаются в structured logs. Upstream failures имеют timeout, retry или graceful degradation.

## Частые ошибки

Возвращать stack trace, терять correlation id, смешивать 401 и 403, retry permanent failures, swallowing exceptions в worker.

## Проверка

Unit tests для mapper, integration tests для типовых error classes, E2E для validation and permission errors.

## Источники

См. [[../06-api-design/Error-contracts|API error contracts]], [[Logging|Logging]].

