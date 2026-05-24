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

## Когда использовать

Используй audit log для auth, role changes, billing, destructive actions, exports, admin/support access и compliance-sensitive операций.

## Когда не использовать

Не используй audit log как обычный application log или analytics. Он должен фиксировать значимые действия, а не каждый read-запрос.

## Частые ошибки

Хранить секреты в audit payload, не фиксировать actor/target, разрешать редактирование audit rows, не логировать failed sensitive attempts.

## Источники

См. [Authorization](../05-auth-security/Authorization.md), [Tenant isolation](../../patterns/security/tenant-isolation.md).

