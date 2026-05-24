---
title: "Query optimization"
category: "database"
updated: "2026-05-24"
status: "active"
tags: ["postgresql", "performance"]
source_priority: "official-docs"
---

# Query optimization

Оптимизируй запросы после измерения. Главный инструмент PostgreSQL — `EXPLAIN` / `EXPLAIN ANALYZE`.

## Production-паттерны

- Индексы создаются под реальные where/order/join patterns.
- Проверяй N+1 на уровне ORM.
- Cursor pagination для больших таблиц.
- Slow query log включен на production.

## Частые ошибки

- Индекс на каждое поле без понимания нагрузки.
- Offset pagination на больших таблицах.
- Сортировка по неиндексированному полю в hot endpoint.

Источник: [PostgreSQL EXPLAIN](https://www.postgresql.org/docs/current/using-explain.html).

