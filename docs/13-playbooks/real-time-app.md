---
title: "Playbook: Real-time app"
category: "playbooks"
updated: "2026-05-24"
status: "active"
tags: ["realtime", "websocket"]
source_priority: "internal"
---

# Playbook: Real-time app

## Стек по умолчанию

React/Next.js + WebSocket/SSE + Redis pub/sub + PostgreSQL + presence/state reconciliation.

## Порядок разработки

1. Define real-time events and consistency requirements.
2. Choose WebSocket, SSE or polling.
3. Design auth, rooms, tenant isolation.
4. Add reconnect and backpressure strategy.
5. Persist authoritative state in database.
6. Test reconnect, duplicate events, out-of-order events, permission boundaries.

## Анти-паттерны

- Использовать WebSocket для редких обновлений.
- Хранить authoritative state только в memory.
- Не проверять access при subscribe/join room.

