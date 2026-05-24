---
title: "Cron and scheduled jobs"
category: "backend"
updated: "2026-05-24"
status: "active"
tags: ["cron", "scheduler"]
source_priority: "internal"
---

# Cron and scheduled jobs

Cron подходит для регулярных задач: billing sync, cleanup, reminders, reports, indexing.

## Production-паттерны

- Job idempotent by design.
- Distributed lock, если возможен параллельный запуск.
- Каждый запуск логирует started, completed, failed, duration.
- Failure alert для критичных jobs.

## Частые ошибки

- Cron запускается дважды на нескольких инстансах.
- Нет retry и dead-letter стратегии.
- Job меняет много данных без checkpoint.

