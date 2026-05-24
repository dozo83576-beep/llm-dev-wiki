---
title: "Release flow"
category: "devops"
updated: "2026-05-24"
status: "active"
tags: ["release", "deploy"]
source_priority: "internal"
---

# Release flow

Release flow должен быть скучным и проверяемым.

## Шаги

1. PR review и CI.
2. Preview/staging deploy.
3. Smoke tests.
4. Migration dry-run или staging migration.
5. Security checklist.
6. Production deploy.
7. Monitoring window.
8. Knowledge capture.

## Stop conditions

- Failing tests.
- Unknown migration impact.
- Missing rollback.
- Secrets not configured.
- Critical security finding.

