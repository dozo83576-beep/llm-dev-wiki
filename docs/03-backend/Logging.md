---
title: "Logging"
category: "backend"
updated: "2026-05-24"
status: "active"
tags: ["logging", "observability"]
source_priority: "internal"
---

# Logging

Логи должны отвечать: что случилось, где, для какого request/user/entity, с каким correlation id, какой outcome.

Не логируй пароли, токены, cookies, полные платежные данные и приватные payloads. Для Node.js используй Pino/Winston, для Python structlog/loguru/standard logging.

## Когда использовать

Всегда в API, workers, cron, webhooks и integrations. Логи нужны для debugging, audit, incident response и product operations.

## Когда не использовать

Не используй logs как основное хранилище бизнес-событий или audit trail: они могут ротироваться, фильтроваться и теряться.

## Production-паттерны

Structured JSON logs, correlation id, request id, user/tenant context без PII, event outcome, duration, error class.

## Частые ошибки

Логировать secrets, отсутствие correlation id, разные форматы по сервисам, слишком шумный info level, swallowing errors без log.

## Проверка

Integration smoke: запрос создает log с request id, error path содержит class/outcome, secret scanner не находит чувствительные поля.

## Источники

См. [[../08-devops-deploy/Observability|Observability]], [[../05-auth-security/Secrets|Secrets]].

