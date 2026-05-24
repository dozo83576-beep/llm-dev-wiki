---
title: "Background jobs"
category: "backend"
updated: "2026-05-24"
status: "active"
tags: ["jobs", "queues"]
source_priority: "official-docs"
---

# Background jobs

Фоновые задачи нужны для email, webhooks retry, media processing, AI jobs, imports, billing sync. Не держи долгую работу в HTTP request.

Требования: idempotency key, retry policy, dead-letter handling, structured logs, metrics, visibility для операторов.

Источники: [BullMQ Docs](https://docs.bullmq.io/), [Celery Docs](https://docs.celeryq.dev/).

