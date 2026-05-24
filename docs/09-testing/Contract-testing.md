---
title: "Contract testing"
category: "testing"
updated: "2026-05-24"
status: "active"
tags: ["contract-tests", "api", "openapi"]
source_priority: "internal"
---

# Contract testing

Contract tests фиксируют контракт между producer (API) и consumer (frontend, mobile, third-party) и ловят несовместимые изменения до того, как они доедут до клиента.

## Когда использовать

- Публичное API с внешними клиентами.
- Микросервисы / отдельные frontend и backend деплои.
- Mobile-приложения с долгим upgrade-циклом — нельзя ломать старые версии.
- SDK / public clients генерируемые из спеки.

## Когда не использовать

- Монолит с одним deploy unit и одним consumer — unit + integration достаточно.
- Прототипы без external clients.

## Подходы

- **Schema-first contract** (OpenAPI / GraphQL schema / protobuf): спека — source of truth, генерируемые клиенты и валидаторы; CI проверяет, что реальные ответы соответствуют схеме.
- **Consumer-driven contracts** (Pact): consumer пишет ожидания, broker делится с provider, provider верифицирует.
- **Schema diff** в CI: новый коммит → diff с prod-схемой → block breaking changes без `version: vN+1` или deprecation.

## Production-паттерны

- OpenAPI / GraphQL schema лежит в репо и обновляется в одном PR с реализацией.
- Генерация TypeScript-клиента / Python-клиента из спеки.
- Negative cases в spec: 400/401/403/404/409/422/429/500 c примерами тел.
- Breaking changes требуют major bump и/или deprecation window.
- Provider-тесты прогоняются в CI на каждый PR.

## Частые ошибки

- "Документация догонит код" — schema устаревает в день написания.
- Сломать поле в schema без bump версии — клиенты ломаются молча.
- Тестировать только happy path — отсутствует контракт ошибок.
- Считать contract test заменой integration test.

## Security risks

В схему попадают внутренние поля (debug info, internal ids), которых не должно быть в публичном контракте.

## Testing strategy

- Schema validation: запросы и ответы валидируются против OpenAPI/GraphQL в test/integration.
- Breaking-change check в CI (`openapi-diff`, `graphql-inspector`).
- Consumer suite запускается на provider side в CI (Pact verify).
- Periodic test против sandbox внешнего API чтобы ловить vendor breaking changes.

## Edge cases

- Версионирование: `/v1`, `/v2` живут параллельно — нужны отдельные contract tests.
- Async API (webhook, событие в очереди) — контракт описан в AsyncAPI.
- Условные поля в зависимости от tier/role — отдельные variants схемы.

## Источники

- [OpenAPI Specification](https://spec.openapis.org/) — проверено 2026-05-24.
- [Pact Documentation](https://docs.pact.io/) — проверено 2026-05-24.
- См. [OpenAPI](../06-api-design/OpenAPI.md), [Versioning](../06-api-design/Versioning.md), [api-review checklist](../../checklists/api-review.md).
