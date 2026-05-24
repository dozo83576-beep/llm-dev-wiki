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

## Когда использовать

Используй cron для регулярных задач, где допустим запуск по расписанию: cleanup, reminders, reports, sync, reindex.

## Когда не использовать

Не используй cron для задач, которые должны запускаться сразу после бизнес-события: там лучше queue/event.

## Проверка

Проверь idempotency, distributed lock, повторный запуск, failure alert и safe resume после частичной обработки.

## Edge cases

- Пропущенный запуск во время downtime — нужна стратегия (catch-up vs skip) и явная политика.
- Time zone и DST: фиксируй UTC и явный TZ в расписании, не "локальное серверное время".
- Долгие jobs пересекаются с следующим запуском — нужен mutex и оповещение о переполнении.
- Crash посередине: checkpoint / resume-точка, idempotent steps.
- Tenant-aware jobs: запускать на каждый tenant отдельно с rate-limit, не в одну транзакцию.

## Security risks

Cron под привилегированной ролью с доступом ко всем tenants — minimal scope на job-уровне. Утечка через logs с user-payload. Cron, выполняющий пользовательский ввод (eval) — критическая дыра.

## Источники

См. [Background jobs](Background-jobs.md), [Incident workflow](../08-devops-deploy/Incident-workflow.md).

