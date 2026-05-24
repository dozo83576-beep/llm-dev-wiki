---
title: "Secrets rotation"
category: "devops"
updated: "2026-05-24"
status: "active"
tags: ["secrets", "rotation"]
source_priority: "internal"
---

# Secrets rotation

Секреты должны иметь владельца, место хранения, scope, дату последней ротации и процедуру замены.

## Production-паттерны

- Separate secrets per environment.
- Least privilege scopes.
- Rotation without downtime для критичных ключей.
- Немедленная ротация при подозрении на утечку.

## Проверка

- `.env` не tracked.
- Secret scanning в CI/GitHub.
- Runbook для revoke/replace.

