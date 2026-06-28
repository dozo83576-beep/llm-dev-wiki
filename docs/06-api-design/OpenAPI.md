---
title: "OpenAPI"
category: "api"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["openapi", "contract"]
source_priority: "official-docs"
---

# OpenAPI

OpenAPI фиксирует контракт API для frontend, backend, тестов и external clients. Генерируй types/client только из проверенной спецификации.

Источник: [OpenAPI Specification](https://spec.openapis.org/oas/latest.html).

## Когда использовать

Используй OpenAPI для REST API, external integrations, generated clients, contract tests и документации для frontend/backend teams.

## Когда не использовать

Не поддерживай OpenAPI вручную отдельно от кода, если команда не обновляет его в PR. Устаревшая спецификация вреднее отсутствующей.

## Production-паттерны

Spec генерируется из typed routes или проверяется в CI, содержит auth schemes, error responses, pagination, examples и versioning policy.

## Частые ошибки

Документировать только happy path, не описывать error contract, не фиксировать auth, генерировать client из stale spec.

## Проверка

CI schema validation, contract tests (`openapi-validator`), generated client build, diff review для breaking changes (`openapi-diff`), пример каждого response и request body.

## Edge cases

- Polymorphism: `oneOf` / `anyOf` / `discriminator` — генераторы клиентов справляются по-разному, тестировать.
- Файловые поля (`multipart/form-data`) — особенности в TypeScript-генераторе.
- Auth schemes: `bearerAuth`, OAuth2 flows, API keys — каждый endpoint должен явно указать `security`.
- Schema reuse через `$ref` — следить за глубиной и циклами.

## Security risks

Раскрытие внутренних полей (debug, internal ids) в публичной schema, утечка структуры через `additionalProperties: true`, отсутствие auth-секции у defaults.

## Источники

- [OpenAPI Specification](https://spec.openapis.org/oas/latest.html) — проверено 2026-05-24.
- См. [REST](REST.md), [Versioning](Versioning.md), [Contract testing](../09-testing/Contract-testing.md), [error-contract pattern](../../patterns/api/error-contract.md).

