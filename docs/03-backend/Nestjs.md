---
title: "NestJS"
category: "backend"
updated: "2026-07-21"
status: "active"
tags: ["nestjs", "architecture"]
source_priority: "official-docs"
---

# NestJS

NestJS выбирай для сложного TypeScript backend. Архитектура: module, controller, provider/service, DTO, guards, interceptors, filters.

Частые ошибки: бизнес-логика в controllers, отсутствие transaction boundary, смешивание transport DTO и domain model, неявные зависимости между модулями.

Источник: [NestJS Docs](https://docs.nestjs.com/) — `@nestjs/core` 11.1.28 reviewed 2026-07-21; architecture guidance unchanged.

## Когда использовать

Выбирай NestJS для сложного TypeScript backend: modules, DI, guards, interceptors, queues, jobs, webhooks и enterprise API.

## Когда не использовать

Не выбирай NestJS для маленького serverless endpoint или простого BFF, где Fastify/Next.js Route Handler проще.

## Production-паттерны

Modules по bounded context, controllers тонкие, services содержат use cases, guards проверяют auth/authz, filters нормализуют errors, interceptors добавляют cross-cutting behavior.

## Частые ошибки

God module, business logic в controllers, circular dependencies, DTO как domain model, отсутствие transaction boundary.

## Проверка

Unit tests для providers, e2e tests через testing module, permission tests для guards, integration tests с DB.
