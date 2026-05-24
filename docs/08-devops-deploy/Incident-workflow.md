---
title: "Incident workflow"
category: "devops"
updated: "2026-05-24"
status: "active"
tags: ["incident", "sre"]
source_priority: "internal"
---

# Incident workflow

Incident workflow нужен, чтобы быстро восстановить сервис и сохранить уроки.

## Шаги

1. Triage: impact, users, severity.
2. Stabilize: rollback, disable feature, scale, block abuse.
3. Communicate: owner, timeline, status.
4. Root cause: после стабилизации.
5. Prevention: tests, alerts, checklist, failure case.

## Правило

Каждый значимый incident завершаетcя записью в `case-studies/failures`.

