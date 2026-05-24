---
title: "Audit log"
category: "database"
updated: "2026-05-24"
status: "active"
tags: ["audit", "compliance"]
source_priority: "internal"
---

# Audit log

Audit log фиксирует критичные действия: auth, role changes, billing, deletion, data export, admin actions.

## Production-паттерны

- Храни actor, action, target, before/after summary, timestamp, request id.
- Не храни секреты и полный sensitive payload.
- Audit log append-only для критичных доменов.

## Проверка

- Integration tests: critical action creates audit record.
- Negative tests: audit не содержит secret fields.

