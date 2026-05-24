---
title: "Node.js"
category: "backend"
updated: "2026-05-24"
status: "active"
tags: ["nodejs", "backend"]
source_priority: "official-docs"
---

# Node.js

Node.js подходит для API, serverless, webhooks, real-time и TypeScript-единства. Следи за event loop blocking: CPU-heavy задачи выноси в worker/очередь/отдельный сервис.

Правила: structured logging, graceful shutdown, env validation, timeouts на внешние запросы, централизованная обработка ошибок.

Источник: [Node.js Learn](https://nodejs.org/en/learn).

## Когда использовать

Используй Node.js для TypeScript backend, BFF, webhooks, API, real-time, serverless и задач, где важна JavaScript-экосистема.

## Когда не использовать

Не используй Node.js для CPU-heavy обработки без workers/native services. Event loop blocking разрушит latency.

## Production-паттерны

Timeouts на внешние запросы, graceful shutdown, health checks, env validation, structured logs, worker threads/queue для тяжелых задач.

## Частые ошибки

Blocking CPU в request path, unhandled promise rejections, отсутствие request timeout, process.env без validation, memory leaks в global cache.

## Проверка

Unit/integration tests, load smoke для hot endpoints, graceful shutdown test, dependency audit.

