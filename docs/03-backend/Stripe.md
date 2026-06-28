---
title: "Stripe"
category: "backend"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["stripe", "payments", "billing", "webhooks"]
source_priority: "vendor-docs"
---

# Stripe

Stripe закрывает hosted checkout, customer portal, subscriptions, invoices, payments и webhooks. Production-инвариант: Stripe — источник правды для payment/subscription state, локальная БД хранит projection и entitlement cache.

## Когда использовать

- SaaS subscriptions, one-time checkout, invoices, customer portal, paid feature access.
- Нужно снизить PCI burden через hosted Checkout/Elements и не хранить card data.
- Команда готова проектировать webhooks, idempotency, retries и billing audit.

## Когда не использовать

- Требуются local payment methods или acquiring, которые Stripe не поддерживает для нужной юрисдикции.
- Marketplace payouts/KYC сложнее, чем готовая модель Stripe Connect.
- Команда хочет хранить card data самостоятельно — это плохое решение без PCI-команды.

## Production-паттерны

- Checkout/Portal создаются server-side, с idempotency key и tenant/user ownership.
- Webhook signature verification обязательна; raw body не должен ломаться middleware.
- Webhook handler идемпотентен по event id и повторно читает актуальный объект из Stripe для critical state.
- Entitlements выдаются только после подтверждённого payment/subscription state.
- Test mode сценарии покрывают success, failed payment, cancellation, renewal, refund, replay.

## Частые ошибки

- Доверять redirect success URL вместо webhook-confirmed state.
- Обрабатывать только `checkout.session.completed` и пропускать subscription lifecycle events.
- Не хранить event id и получать двойное начисление при replay.
- Смешивать local plan state и Stripe price/product без migration strategy.

## Проверка

- Integration: duplicate webhook, out-of-order events, invalid signature, failed payment.
- E2E: checkout, portal cancel, subscription renewal, entitlement revoke.
- Audit: payment/subscription changes пишутся в append-only log.

## Источники

- [Stripe Checkout](https://docs.stripe.com/payments/checkout) — проверено 2026-05-24.
- [Stripe Webhooks](https://docs.stripe.com/webhooks) — проверено 2026-05-24.
- [Stripe subscription webhooks](https://docs.stripe.com/billing/subscriptions/webhooks) — проверено 2026-05-24.
- [Stripe security guide](https://docs.stripe.com/security/guide) — проверено 2026-05-24.
