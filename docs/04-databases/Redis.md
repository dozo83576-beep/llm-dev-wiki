---
title: "Redis"
category: "database"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["redis", "cache", "queue"]
source_priority: "official-docs"
---

# Redis

Redis используй для cache, rate limits, sessions, pub/sub и queue backend. Не используй Redis как единственное хранилище критичных данных без persistence/backup политики.

Правила: TTL для cache, namespace keys, защита от cache stampede, мониторинг memory eviction.

Источник: [Redis Docs](https://redis.io/docs/latest/).

## Когда использовать

Используй Redis для cache, rate limits, distributed locks, queues, pub/sub и short-lived session/state.

## Когда не использовать

Не используй Redis как единственный durable source для критичных платежных, пользовательских или юридически значимых данных.

## Production-паттерны

TTL по умолчанию, key namespace, memory policy, cache stampede protection, monitoring eviction и connection limits.

## Частые ошибки

Кэшировать tenant-specific данные без tenant key, бесконечный TTL, отсутствие invalidation, считать Redis replacement для relational DB.

## Проверка

Integration tests на key builder/invalidation, load smoke, failure mode при недоступном Redis (fallback / circuit breaker), memory eviction под нагрузкой.

## Edge cases

- Pub/sub at-most-once: для надёжной доставки бери Streams (XADD/XREAD) с consumer groups.
- `KEYS *` на проде — блокирующий, используй `SCAN`.
- Cluster vs standalone: разные ограничения на multi-key transactions и Lua.
- TLS-only connections в managed сервисах (Upstash, ElastiCache).
- Hot key в шардированном кластере — добавь user/tenant суффикс для распределения.

## Security risks

Default no-auth на open port (исторически частый incident), утечка через SSRF в Lua-скриптах, командная injection через user-input в имени ключа.

## Источники

- [Redis Docs](https://redis.io/docs/latest/) — проверено 2026-05-24.
- См. [Caching](../03-backend/Caching.md), [Background jobs](../03-backend/Background-jobs.md).

