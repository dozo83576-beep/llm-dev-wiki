---
title: "REST API"
category: "api"
updated: "2026-05-24"
status: "active"
tags: ["rest", "api"]
source_priority: "internal"
---

# REST API

REST выбирай по умолчанию для CRUD и интеграций. Используй ресурсы, HTTP methods, status codes, idempotency для risky mutations, pagination/filtering/sorting.

Ошибки возвращай единым контрактом: `code`, `message`, `details`, `correlationId`.

## Когда использовать

Выбирай REST по умолчанию для CRUD, SaaS API, backend-for-frontend, external integrations, webhooks management и simple resource workflows.

## Когда не использовать

Не растягивай REST на real-time, complex graph queries или streaming AI responses, если WebSockets/SSE/GraphQL лучше соответствуют задаче.

## Production-паттерны

Resource-oriented URLs, correct HTTP methods, idempotency keys для risky POST, consistent errors, pagination, versioning, auth scopes.

## Частые ошибки

RPC-style endpoints без модели ресурсов, `200 OK` для ошибок, destructive GET, отсутствие idempotency для payments/orders.

## Проверка

Contract tests, negative auth tests, idempotency retry tests, OpenAPI validation, frontend integration smoke.

## Источники

См. [OpenAPI](OpenAPI.md), [Error contracts](Error-contracts.md), [MDN HTTP](https://developer.mozilla.org/en-US/docs/Web/HTTP).

