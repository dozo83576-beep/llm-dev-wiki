---
title: "Pattern: Cursor pagination"
category: "patterns"
updated: "2026-05-24"
status: "active"
tags: ["database", "pagination", "api"]
---

# Cursor pagination

Cursor pagination стабильнее offset pagination для больших или часто меняющихся списков.

## Когда использовать

Activity feeds, orders, events, search results, logs, large tables.

## Когда не использовать

Для маленьких административных справочников offset pagination проще и достаточно надежна.

## Production-паттерны

Cursor строится из стабильной сортировки: `created_at + id` или другой unique ordering. API возвращает `items` и `nextCursor`.

## Частые ошибки

- Cursor по неуникальному полю.
- Сортировка без индекса.
- Изменение порядка между запросами.

## Проверка

Integration tests: первая страница, следующая страница, удаление/добавление элемента между запросами.

Источники: [[../../docs/06-api-design/Pagination-filtering-sorting|Pagination, filtering, sorting]].

