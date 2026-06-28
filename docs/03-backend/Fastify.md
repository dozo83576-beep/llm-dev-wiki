---
title: "Fastify"
category: "backend"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["fastify", "api"]
source_priority: "official-docs"
---

# Fastify

Fastify подходит для быстрых Node.js API с низким overhead. Используй schema validation, plugins, typed routes и централизованную обработку ошибок.

Не выбирай Fastify, если проекту нужна opinionated enterprise-структура NestJS.

Источник: [Fastify Docs](https://fastify.dev/docs/latest/).

## Когда использовать

Выбирай Fastify для быстрых Node.js API, webhooks, BFF и сервисов, где нужен низкий overhead без NestJS-слоя.

## Когда не использовать

Не выбирай Fastify для большой команды, которой нужны opinionated modules, DI и guards из коробки.

## Production-паттерны

JSON schema validation, plugins для cross-cutting concerns, typed routes, централизованный error handler, graceful shutdown.

## Частые ошибки

Регистрировать plugins в неправильном scope, обходить schema validation, смешивать transport и domain logic.

## Проверка

Unit tests для services, injection tests для routes (fastify.inject), load smoke для hot endpoints, schema validation tests на edge cases.

## Edge cases

- Plugin encapsulation: scope plugin к prefix через `register(plugin, { prefix: '/v1' })`, не глобально без причины.
- Декораторы (`fastify.decorate`) не type-safe без явных module-аугментаций — добавить `.d.ts`.
- Async hooks (preHandler / onRequest) для auth и rate-limit, не middleware-стиль Express.
- Body limit по умолчанию 1 МБ — увеличивать осознанно, чтобы не открыть DoS.

## Security risks

Отключённая schema validation — невалидированный input уходит дальше. CORS-плагин без origin allowlist. Раскрытие stack trace через дефолтный error handler в production.

## Источники

- [Fastify Docs](https://fastify.dev/docs/latest/) — проверено 2026-05-24.
- См. [Nodejs](Nodejs.md), [API architecture](API-architecture.md), [Error handling](Error-handling.md).

