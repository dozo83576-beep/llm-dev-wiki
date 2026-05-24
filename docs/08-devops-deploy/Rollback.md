---
title: "Rollback"
category: "devops"
updated: "2026-05-24"
status: "active"
tags: ["rollback", "incident"]
source_priority: "internal"
---

# Rollback

Rollback должен быть определен до deploy. Код откатить легче, чем данные.

## Production-паттерны

- Backward-compatible migrations.
- Feature flags для рискованных функций.
- Separate deploy и data migration, если изменение опасное.
- Runbook с командами и владельцем решения.

## Проверка

- Smoke rollback на staging.
- Документированное условие, когда откатывать.
- Post-incident failure case после реального отката.

