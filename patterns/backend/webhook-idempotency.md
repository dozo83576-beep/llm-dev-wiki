---
title: "Pattern: Webhook idempotency"
category: "patterns"
updated: "2026-05-24"
status: "active"
tags: ["webhooks", "idempotency", "backend"]
---

# Webhook idempotency

Webhook provider может отправить одно событие несколько раз. Backend должен обрабатывать повтор без дублей.

## Когда использовать

Payments, billing, CRM, email events, storage notifications, CI/deploy hooks.

## Когда не использовать

Не нужен для полностью синхронных internal callbacks, где повтор невозможен и источник контролируется.

## Production-паттерны

Проверяй подпись, сохраняй `event_id` с unique constraint, быстро отвечай provider, бизнес-обработку отправляй в queue.

## Частые ошибки

- Создавать подписку/платеж повторно при replay.
- Проверять подпись после бизнес-логики.
- Не обрабатывать out-of-order events.

## Проверка

Integration tests: valid signature, invalid signature, duplicate event, out-of-order event.

Источники: [Webhooks](../../docs/03-backend/Webhooks.md), [success case](../../case-studies/successes/2026-05-24-webhook-idempotency.md).

