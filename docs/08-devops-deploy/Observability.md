---
title: "Observability"
category: "devops"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["observability", "monitoring", "telemetry"]
source_priority: "internal"
---

# Observability

Observability отвечает на вопрос "что и почему происходит сейчас в production". Минимум: logs + metrics + traces + error tracking + uptime + alerts, объединённые correlation id.

## Когда использовать

- Любой production-сервис с реальными пользователями.
- Сервисы с внешними зависимостями (третьи API, очереди, БД) — нужны traces.
- Команды, которые регулярно дежурят / отвечают на инциденты.

## Когда не использовать

- Pet-проекты на free-tier — достаточно error tracker + uptime monitor.
- Прототипы, где нет SLA и нет on-call.

## Production-паттерны

- **Logs**: structured JSON, обязательные поля: timestamp, level, service, env, correlation_id, user_id (если есть), без PII.
- **Metrics**: RED (Rate, Errors, Duration) для каждого endpoint, USE (Utilization, Saturation, Errors) для ресурсов.
- **Traces**: OpenTelemetry instrumentation, sampling 10–25% performance, 100% errors.
- **Error tracking**: Sentry / GlitchTip с release tag и environment.
- **Uptime**: synthetic checks из нескольких регионов, alert на критичные user-journey.
- **Alerts**: SLO-based, не на единичный спайк; severity-routing в pager/slack.
- **Correlation id** прокидывается через все слои (frontend → backend → workers → external API).

## Anti-patterns

- Логировать всё подряд без структуры — поиск превращается в "find in haystack".
- Алерт на каждый CPU-спайк — alert fatigue, реальные инциденты пропускаются.
- Метрики без labels (или, наоборот, с high-cardinality user_id в labels) — взрыв стоимости.
- Traces без sampling — счёт в облаке.

## Частые ошибки

- PII в logs (email, телефоны, токены).
- Алертить on `error_rate > 0` вместо SLO-budget.
- Не настроить `release` / `version` метку — регрессии теряются.
- Несоответствие SLO в коде и в alerting — алерты не соответствуют контракту.

## Security risks

Утечка PII / секретов в logs и traces, открытый Grafana / Prometheus без auth, передача user-token в HTTP-span attribute.

## Performance risks

Тяжёлый sync logger в hot path, агрессивный sampling traces в малом сервисе (всё равно дорого), большие log-blobs (request body) на каждый запрос.

## Testing strategy

- Smoke-сценарии после деплоя: видны ли logs / traces / metrics с нужными метками.
- Synthetic check критичного flow раз в минуту.
- Тестовый alert с известным симптомом раз в квартал.
- Прогон incident drill против реальной observability-стека.

## Edge cases

- Multi-tenant SaaS: tenant_id в labels — балансировать cardinality.
- Async-flow (queues, retries) — correlation id через job context.
- Cross-region — clock skew и порядок логов.

## Источники

- [Google SRE Workbook — SLOs](https://sre.google/workbook/implementing-slos/) — проверено 2026-05-24.
- См. [OpenTelemetry](OpenTelemetry.md), [Sentry](Sentry.md), [Logging](../03-backend/Logging.md), [Incident workflow](Incident-workflow.md).
