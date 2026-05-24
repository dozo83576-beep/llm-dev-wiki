---
title: "Payments"
category: "backend"
updated: "2026-05-24"
status: "active"
tags: ["payments", "billing"]
source_priority: "internal"
---

# Payments

Payments — high-risk зона. Используй mature provider, не храни card data, проектируй idempotency и webhooks с самого начала.

## Production-паттерны

- Provider-hosted checkout, если возможно.
- Webhook signature verification.
- Subscription state derived from provider events and local audit.
- Idempotency keys for create payment/subscription operations.

## Частые ошибки

- Доступ к paid feature до подтвержденного payment state.
- Дубли подписок из-за повторной отправки формы.
- Отсутствие тестов на failed payment и refund.

## Проверка

- E2E: successful checkout, failed payment, cancel, refund, subscription renewal.
- Integration: duplicate webhook, out-of-order webhook.

## Когда использовать

Используй payments flow для SaaS subscriptions, checkout, marketplace payouts, invoices и paid feature access.

## Когда не использовать

Не реализуй card handling самостоятельно. Используй provider-hosted checkout или compliant provider primitives.

## Источники

См. документацию выбранного payment provider, [Webhooks](Webhooks.md), [Secrets](../05-auth-security/Secrets.md).

