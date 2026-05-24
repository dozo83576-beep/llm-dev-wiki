---
title: "API versioning"
category: "api"
updated: "2026-05-24"
status: "active"
tags: ["versioning", "api"]
source_priority: "internal"
---

# API versioning

Версионируй публичные API. Для внутренних API предпочтительнее backward-compatible изменения и contract tests.

Правила: не ломай поля без deprecation window, добавления должны быть совместимыми, breaking changes документируются и тестируются.

## Когда использовать

Версионируй public API, mobile API, partner integrations и любые контракты, где clients не обновляются одновременно с backend.

## Когда не использовать

Для internal BFF, deployed вместе с frontend, чаще достаточно backward-compatible изменений и contract tests без URL version.

## Production-паттерны

Backward-compatible additions, deprecation window, changelog, contract tests, generated clients, explicit migration guide для breaking changes.

## Частые ошибки

Удалять поле без warning, менять enum semantics, считать frontend единственным client, не тестировать старый client.

## Проверка

API diff, contract tests для old/new clients, deprecation scan, changelog review.

## Источники

См. [[OpenAPI|OpenAPI]], [[REST|REST]].

