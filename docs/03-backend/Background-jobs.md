---
title: "Background jobs"
category: "backend"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["jobs", "queues"]
source_priority: "official-docs"
---

# Background jobs

Фоновые задачи нужны для email, webhooks retry, media processing, AI jobs, imports, billing sync. Не держи долгую работу в HTTP request.

Требования: idempotency key, retry policy, dead-letter handling, structured logs, metrics, visibility для операторов.

Источники: [BullMQ Docs](https://docs.bullmq.io/), [Celery Docs](https://docs.celeryq.dev/).

## Когда использовать

Используй jobs для email, imports, reports, AI tasks, media processing, webhook retry, billing sync и всего, что дольше нормального HTTP request.

## Когда не использовать

Не выноси простую синхронную операцию в queue, если это усложняет consistency без выигрыша по latency или надежности.

## Production-паттерны

Job должен быть идемпотентным, иметь retry policy, timeout, dead-letter handling, structured logs и metrics. Для batch jobs нужны checkpoints.

## Частые ошибки

Infinite retry, отсутствие idempotency, потеря ошибок в worker logs, отсутствие visibility для stuck jobs.

## Проверка

Integration tests: success, transient failure retry, permanent failure, duplicate job, dead-letter path.

