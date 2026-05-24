---
title: "OpenAPI"
category: "api"
updated: "2026-05-24"
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

CI schema validation, contract tests, generated client build, diff review для breaking changes.

