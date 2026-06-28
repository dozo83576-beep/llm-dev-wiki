---
title: "Playbook: Real-time app"
category: "playbooks"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["realtime", "websocket", "sse", "presence"]
source_priority: "internal"
---

# Playbook: Real-time app

Чат, collaborative editing, live-обновления, presence, dashboards, аукционы. Главная сложность — не WebSocket сам по себе, а consistency, reconnect, authorization на каждом сообщении и authoritative state.

## Когда использовать

- Чат / messaging / комментарии в реальном времени.
- Collaborative редакторы (Notion-like).
- Live-дашборды с частыми обновлениями.
- Presence (кто online), typing indicators.
- Аукционы / тикеры / live-feeds.

## Когда не использовать

- Обновления раз в минуту — достаточно polling.
- Уведомления, которые можно прислать push-сервисом.
- Прямая видео/аудио связь — это WebRTC, не WebSocket.

## Стек по умолчанию

React/Next.js + WebSocket (Socket.IO / native ws / Ably / Pusher / Supabase Realtime) или SSE + Redis pub/sub для fan-out + PostgreSQL для authoritative state + presence/state reconciliation.

## Порядок разработки

1. **Events catalog**: какие события, какая consistency (at-least-once / exactly-once), ordering.
2. **Transport**: WebSocket vs SSE vs polling — выбирать по нагрузке и требованиям bidirectional.
3. **Auth**: JWT в connect handshake; revalidation по сроку.
4. **Rooms & tenant isolation**: явный access check на subscribe/join, не "клиент знает room id".
5. **Authoritative state в DB**: realtime — это transport, а не source of truth.
6. **Reconnect strategy**: backoff с jitter, replay missed events с last-known-id.
7. **Backpressure**: rate limit per connection, drop / coalesce при заторе.
8. **Scaling**: pub/sub (Redis / NATS / managed) для multi-instance.
9. **Observability**: connection count, message rate, lag, dropped events.

## Production-паттерны

- Event sourcing для критичных flow: каждый event сохраняется и replayable.
- Optimistic UI + reconciliation после server ACK.
- Idempotent event handlers (client может перезатопить дубликаты).
- Heartbeat / ping-pong для обнаружения мёртвых соединений.
- Pub/sub channel naming по tenant + room для изоляции.
- CSRF-protection на WebSocket-upgrade (Origin check + auth token).

## Анти-паттерны

- Использовать WebSocket для редких обновлений (один раз в минуту) — overkill.
- Хранить authoritative state только в memory — после рестарта данные теряются.
- Не проверять access при subscribe/join room — клиент подписывается на чужой канал.
- Отправлять весь объект на каждый чих — большой payload, no diff.
- Игнорировать порядок сообщений в multi-instance — пользователь видит несогласованности.

## Security risks

Authorization обходится после connect, message spoofing (один пользователь шлёт от имени другого), XSS через сообщения чата без sanitization, утечка чужих room/channel id.

## Performance risks

Memory leak от подвисших connections, broadcast O(N) на популярный room, hot key в Redis pub/sub, дорогое JSON.stringify на каждое событие.

## Testing strategy

- Reconnect / replay сценарии: убить connection → продолжить с последнего event id.
- Duplicate events: тот же event дважды — без double-effect.
- Out-of-order events: серверная упорядочиваемость через sequence id.
- Permission tests: запрос подписки на чужой канал → отказ.
- Load test: N concurrent connections и broadcast.

## Edge cases

- Mobile network: switch wifi/4G, restore connection.
- Proxy / corporate firewall блокирует WebSocket — fallback на SSE / long-poll.
- Multi-device: одна учётка, несколько вкладок — sync state без петель.
- TTL для presence: graceful timeout vs reconnect grace.

## Источники

- См. [WebSockets](../06-api-design/WebSockets.md), [Caching](../03-backend/Caching.md), [Redis](../04-databases/Redis.md), [Background jobs](../03-backend/Background-jobs.md), [Observability](../08-devops-deploy/Observability.md).
