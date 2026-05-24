---
title: "Redis"
category: "database"
updated: "2026-05-24"
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

Integration tests на key builder/invalidation, load smoke, failure mode при недоступном Redis.

