---
title: "WebSockets"
category: "api"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["websocket", "realtime"]
source_priority: "official-docs"
---

# WebSockets

WebSockets нужны для real-time collaboration, live dashboards, chats, multiplayer, low-latency updates. Для редких обновлений достаточно polling/SSE.

Правила: auth при connect, heartbeat, reconnect strategy, backpressure, room/tenant isolation.

Источник: [MDN WebSocket](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket).

## Когда использовать

Используй WebSockets для bidirectional real-time: chat, collaboration, live dashboards, multiplayer, trading-like updates.

## Когда не использовать

Не используй WebSockets для редких обновлений, где достаточно polling, webhook или SSE. Они усложняют auth, scaling и observability.

## Production-паттерны

Authenticate connection, authorize room join, heartbeat, reconnect/backoff, backpressure, message schema, tenant isolation, graceful disconnect.

## Частые ошибки

Проверить auth только при HTTP login, не проверять permission на subscribe, хранить authoritative state только в memory, не обрабатывать reconnect.

## Проверка

E2E reconnect, duplicate/out-of-order messages, permission denied on room join, load smoke, disconnect cleanup.

