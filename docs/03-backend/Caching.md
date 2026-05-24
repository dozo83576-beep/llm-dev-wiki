---
title: "Backend caching"
category: "backend"
updated: "2026-05-24"
status: "active"
tags: ["cache", "performance"]
source_priority: "internal"
---

# Backend caching

Cache нужен для снижения latency и нагрузки, но добавляет риск устаревших данных.

## Production-паттерны

- Cache only read-heavy данные с понятным TTL.
- Cache key включает tenant/user/permission context.
- Invalidation привязана к mutation.
- Защита от cache stampede для дорогих запросов.

## Частые ошибки

- Кэширование персональных данных без user scope.
- Бесконечный TTL для меняющихся данных.
- Cache hides consistency bugs.

## Проверка

- Unit tests на key builder.
- Integration tests на invalidation после mutation.
- Load test для дорогих endpoints.

## Когда использовать

Используй cache для read-heavy endpoints, дорогих вычислений, reference data, rate limits и внешних API с высокой latency.

## Когда не использовать

Не кэшируй данные, где stale result нарушает безопасность, платежи, права доступа или юридически значимые решения.

## Источники

См. [[../04-databases/Redis|Redis]], [[../02-frontend/Data-fetching|Data fetching]].

