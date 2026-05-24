---
title: "OpenTelemetry"
category: "devops"
updated: "2026-05-24"
status: "active"
tags: ["opentelemetry", "tracing", "metrics"]
source_priority: "official-docs"
---

# OpenTelemetry

OpenTelemetry (OTel) — стандарт CNCF для сбора traces, metrics и logs. Используется, чтобы избавиться от привязки к конкретному vendor: один SDK, любой backend (Jaeger, Tempo, Datadog, Honeycomb, Grafana Cloud).

## Когда использовать

- Распределённая система: несколько сервисов, очереди, внешние API.
- Желание не зависеть от одного APM-провайдера.
- Сложные latency-проблемы, где нужен полный trace через все слои.

## Когда не использовать

- Один монолит с простым stack — Sentry + structured logs могут быть достаточны.
- Команда не готова поддерживать collector / pipeline.
- Нужен только error tracking — Sentry самостоятельно справится.

## Production-паттерны

- Использовать **OpenTelemetry Collector** как промежуточный агент: SDK → collector → backend(ы). Это даёт sampling, batching, retry, multi-export.
- Auto-instrumentation для frameworks (Express, FastAPI, Nest), ручная — для бизнес-критичных границ.
- Sampling: head-based (10–25%) или tail-based (collector решает после полного span'а), всегда 100% для error/slow traces.
- Resource attributes: `service.name`, `service.version`, `deployment.environment`, `k8s.*` если применимо.
- Распространение context: `traceparent` header через все слои, включая async-jobs.
- Logs коррелированы со spans через `trace_id` / `span_id`.

## Частые ошибки

- Инструментировать всё подряд без sampling — счёт в backend / OOM в коллекторе.
- Класть user-input в span attributes без фильтрации — PII в трейсах.
- Не подменять `service.name` / `service.version` — все сервисы сливаются.
- Использовать deprecated semantic conventions — поломки при апгрейде backend.
- Запускать OTel SDK в edge runtime без проверки совместимости.

## Security risks

PII в span attributes, exposure внутренней топологии через trace context в публичных API, утечка секретов в logs прикреплённых к span.

## Performance risks

Sync-export без batching, тяжёлый context-propagation в hot path, OOM на коллекторе при high-cardinality attributes.

## Testing strategy

- Тестовый trace критичного flow в staging, проверка целостности (нет orphan spans).
- Smoke after deploy: видны ли spans для нового релиза.
- Конфиг collector тестируется через `otelcol --dry-run`.

## Edge cases

- Cross-language: Python/Node/Go SDK имеют разный feature parity — проверять semantic conventions.
- Serverless: cold start добавляет overhead; для FaaS использовать lightweight wrappers.
- Frontend OTel: больший RUM-overhead, обычно sampling 1–5%.

## Источники

- [OpenTelemetry Docs](https://opentelemetry.io/docs/) — проверено 2026-05-24.
- [OTel Semantic Conventions](https://opentelemetry.io/docs/specs/semconv/) — проверено 2026-05-24.
- См. [Observability](Observability.md), [Sentry](Sentry.md), [Logging](../03-backend/Logging.md).
