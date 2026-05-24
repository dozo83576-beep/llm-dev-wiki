---
title: "Database migrations"
category: "database"
updated: "2026-05-24"
status: "active"
tags: ["migrations", "database"]
source_priority: "internal"
---

# Database migrations

Миграция — production-риск. Для больших таблиц избегай блокирующих операций, делай expand-and-contract, backfill отдельным job, проверяй rollback-путь.

Перед deploy: backup, dry-run на staging, оценка lock time, совместимость старого и нового кода на период rollout.

