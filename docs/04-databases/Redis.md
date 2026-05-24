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

