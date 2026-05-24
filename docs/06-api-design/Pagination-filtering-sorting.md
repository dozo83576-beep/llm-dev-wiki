---
title: "Pagination, filtering, sorting"
category: "api"
updated: "2026-05-24"
status: "active"
tags: ["pagination", "filtering", "sorting"]
source_priority: "internal"
---

# Pagination, filtering, sorting

Для маленьких списков можно offset pagination. Для больших и live-changing списков используй cursor pagination.

Фильтры и сортировки должны иметь allowlist полей, иначе появляются security и performance риски.

## Когда использовать

Используй pagination/filtering/sorting для списков, таблиц, search, logs, orders, users, marketplace listings и admin dashboards.

## Когда не использовать

Не добавляй произвольную сортировку/фильтрацию по всем полям модели: это открывает performance и security проблемы.

## Production-паттерны

Allowlist fields, cursor pagination для больших списков, stable ordering, indexed filters, typed query params, max page size.

## Частые ошибки

Offset pagination на больших таблицах, сортировка по неиндексированному полю, filter injection, нестабильный порядок между страницами.

## Проверка

Integration tests для first/next page, invalid filters, max limit, cursor stability, query plan для hot lists.

## Источники

См. [Cursor pagination](../../patterns/database/cursor-pagination.md), [Query optimization](../04-databases/Query-optimization.md).

