---
title: "Webhooks"
category: "backend"
updated: "2026-05-24"
reviewed: "2026-06-29"
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

## Когда использовать

Используй webhooks для provider-driven событий: payments ([Stripe](Stripe.md)), auth providers ([Clerk](../05-auth-security/Clerk.md)), storage, CI/CD, email, CRM.

## Когда не использовать

Не используй webhook как замену синхронному API, если вызывающая сторона ожидает немедленный результат операции.

## Edge cases

- Out-of-order delivery: использовать `created_at` / event sequence, не порядок прихода.
- Replays через webhook console провайдера — handler должен оставаться идемпотентным.
- Signature через secret key — ротация требует overlap window с двумя валидными ключами.
- HTTP 2xx даже при downstream failure — обрабатывать асинхронно с собственной retry-машиной.
- Чрезвычайно большие payload (Stripe events с большими объектами) — буферизация в storage, не в memory.

## Security risks

Подмена событий без verify signature, IP spoofing если завязка на whitelist без подписи, replay attack без `event_id` cache, SSRF от webhook receiver, который тут же делает callback на user-controlled URL.

## Источники

См. [Webhook idempotency](../../patterns/backend/webhook-idempotency.md), [Background jobs](Background-jobs.md), [Payments](Payments.md), [Stripe](Stripe.md).
