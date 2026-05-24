---
title: "Webhooks"
category: "backend"
updated: "2026-05-24"
status: "active"
tags: ["webhooks", "integrations"]
source_priority: "internal"
---

# Webhooks

Webhook endpoint должен быть идемпотентным, проверять подпись и быстро отвечать.

## Production-паттерны

- Verify signature before parsing business payload.
- Store event id для idempotency.
- Долгую обработку отправлять в queue.
- Логировать provider, event type, event id, outcome.

## Частые ошибки

- Повтор webhook создает дубли.
- Нет проверки подписи.
- Endpoint падает из-за временной недоступности downstream.

## Проверка

- Integration tests: valid signature, invalid signature, duplicate event.
- Replay test: повтор события не меняет состояние второй раз.

