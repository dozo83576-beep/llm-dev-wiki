---
title: "GraphQL"
category: "api"
updated: "2026-05-24"
status: "active"
tags: ["graphql", "api"]
source_priority: "official-docs"
---

# GraphQL

GraphQL выбирай, когда клиентам нужны гибкие выборки, много типов клиентов и strong schema. Не выбирай GraphQL для простого CRUD без явной выгоды.

Риски: N+1, сложность authorization на поле/объекте, persisted queries, query cost limits.

Источник: [GraphQL Docs](https://graphql.org/learn/).

## Когда использовать

Выбирай GraphQL, если есть несколько клиентов с разными требованиями к выборке данных, сложный graph domain или потребность в strong schema для frontend teams.

## Когда не использовать

Не выбирай GraphQL для простого CRUD/API-only backend без реальной проблемы overfetch/underfetch. REST + OpenAPI будет проще.

## Production-паттерны

Schema-first или строго типизированный code-first, DataLoader для N+1, query depth/cost limits, persisted queries, field/object-level authorization.

## Частые ошибки

Authorization только на resolver верхнего уровня, N+1 queries, неограниченная query complexity, отсутствие schema version/deprecation policy.

## Проверка

Resolver unit tests, integration tests для permissions, query cost tests, schema breaking-change checks.

