---
title: "API versioning"
category: "api"
updated: "2026-05-24"
reviewed: "2026-06-29"
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

## Edge cases

- URL versioning (`/v1/`) vs header (`Accept: application/vnd.api.v2+json`) — выбирай один стиль на проект.
- Sunset header (`Sunset: Sat, 31 Dec 2026 23:59:59 GMT`) — стандартный способ объявить дату отключения версии.
- Параллельное сосуществование v1 и v2: feature parity vs новый функционал только в v2.
- Deprecation для отдельных полей внутри живой версии (`Deprecation: true` header).
- Internal versioning через schema-evolution без bump'а URL — допустимо, если изменения backward-compatible.

## Security risks

Старая версия с известной CVE остаётся в production "потому что у клиентов нет апгрейда" — нужна явная политика и дата sunset. Утечка debug-полей в legacy version.

## Источники

См. [OpenAPI](OpenAPI.md), [REST](REST.md), [Contract testing](../09-testing/Contract-testing.md).

