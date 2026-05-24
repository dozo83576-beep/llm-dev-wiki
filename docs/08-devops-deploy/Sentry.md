---
title: "Sentry"
category: "devops"
updated: "2026-05-24"
status: "active"
tags: ["sentry", "errors", "observability"]
source_priority: "vendor-docs"
---

# Sentry

Sentry закрывает error tracking, performance traces, release health, session replay и crash reporting. Главная ценность — связь между ошибкой, релизом, пользователем и трассой.

## Когда использовать

- Production-приложения, где нужен alert на новые и регрессирующие ошибки.
- Frontend SPA / Next.js с source maps и release tracking.
- Backend Node/Python/Go с tracing критичных эндпоинтов.

## Когда не использовать

- Pet-проекты, где free-tier overkill и не нужен PII-scrubbing.
- Требования к on-prem без self-hosted Sentry.
- Только метрики/логи — лучше Grafana/Loki/OpenTelemetry стек.

## Production-паттерны

- Загружать source maps в Sentry на каждом релизе, не оставлять public в браузере.
- `release` тег = git SHA или semver; `environment` = production/staging/preview.
- PII scrubbing включён, `beforeSend` фильтрует чувствительные поля.
- Alert routing: PagerDuty/Slack по severity, owner на каждый проект.
- Sampling: 100% errors, 10–25% performance traces, 1–5% session replays.
- Quota alerts включены, чтобы не упереться в лимит молча.

## Частые ошибки

- Загружать source maps в production bundle (`sourceMappingURL` доступен публично) вместо upload в Sentry.
- DSN от admin-project с правами на все environments в одной переменной.
- Не настроить `release` — все ошибки группируются в "unknown" и регрессии теряются.
- Логировать тела запросов с PII / токенами без фильтра.

## Security risks

Утечка PII в breadcrumbs/state, утечка JWT/cookies в HTTP-request snapshot, открытые public DSN с write-permissions, доступ к admin-project для всех разработчиков.

## Performance risks

Слишком высокий traces-sampling — счёт за events; тяжёлые before-send хуки на каждом событии; забытый verbose breadcrumb для каждого fetch.

## Testing strategy

- Тестовое исключение из CI/staging — убедиться, что событие пришло в правильный environment с release.
- Source map validation после деплоя (`sentry-cli sourcemaps explain`).
- Прогон критичных flow с включённым performance tracing.

## Edge cases

- Cross-origin frontend → backend trace propagation требует `sentry-trace` / `baggage` headers и CORS.
- Mobile / SSR / Workers — разные SDK, разные quirks.
- Релиз hotfix без bump version — события слипаются с предыдущим релизом.

## Источники

- [Sentry Docs](https://docs.sentry.io/) — проверено 2026-05-24.
- См. [Observability](Observability.md), [OpenTelemetry](OpenTelemetry.md), [Incident workflow](Incident-workflow.md).
