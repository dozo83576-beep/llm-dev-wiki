---
title: "Backend caching"
category: "backend"
updated: "2026-05-24"
reviewed: "2026-06-29"
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

## Edge cases

- Cache stampede при expire популярного ключа: нужен probabilistic early expiration или single-flight lock.
- Multi-region: разделять региональные кеши, не делиться через cross-region replication без контроля consistency.
- Negative caching (cached "не найдено") — отдельный TTL, иначе долго не увидим появление данных.
- Перегрев hot key в Redis — sharding по составному ключу или local in-process cache как L1.

## Security risks

Утечка чужих данных через неправильный key scope (cache key без user/tenant context), side-channel через timing на cache hit/miss, отравление кеша через user-controlled input в составе ключа.

## Источники

См. [Redis](../04-databases/Redis.md), [Data fetching](../02-frontend/Data-fetching.md).

