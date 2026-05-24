---
title: "Fastify"
category: "backend"
updated: "2026-05-24"
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

Unit tests для services, injection tests для routes, load smoke для hot endpoints.

