---
title: "Playbook: Headless commerce"
category: "playbooks"
updated: "2026-06-04"
status: "active"
tags: ["commerce", "ecommerce", "headless", "checkout"]
source_priority: "mixed"
---

# Playbook: Headless commerce

Headless commerce отделяет storefront, catalog, checkout, payments, fulfillment и content. Главный выбор: купить готовую commerce-платформу или строить custom commerce с минимальным PCI/tax/inventory риском.

## Когда использовать

- Каталог, checkout, promotions, fulfillment или marketplace сложнее простого Stripe Payment Link.
- Нужны custom storefront, multi-channel sales, headless CMS, subscriptions или multi-vendor.
- Бизнес готов поддерживать operations: returns, refunds, inventory, tax, support, fraud.

## Когда не использовать

- Один товар, waitlist, donation или invoice flow: Stripe Checkout/Payment Links проще.
- Нет владельца catalog/order operations.
- Команда не готова тестировать платежи, inventory race and webhook replay.

## Production-паттерны

- **Stripe Checkout / Embedded Checkout**: simple one-off/subscription, low PCI scope, limited UI customization.
- **Shopify Hydrogen**: Shopify operations + custom React storefront; Shopify remains source of truth.
- **Medusa**: custom commerce modules/workflows when team owns backend logic.
- **Saleor**: GraphQL commerce API for custom storefront/marketplace needs.
- Provider event is source of truth for payment state; local order state follows webhook/reconciliation.
- Server calculates price, tax, discounts and inventory reservations.

## Частые ошибки

- Строить custom checkout без PCI/tax/fraud plan.
- Считать оплату успешной по browser redirect instead of webhook.
- Не иметь reconciliation between provider, order DB and fulfillment.
- Выбирать platform по developer taste, а не по operations model.

## Security risks

PCI scope, price manipulation, coupon abuse, account takeover, webhook spoofing, admin order edits and PII leakage. Checkout/provider webhooks require signature verification and idempotency.

## Performance risks

Slow catalog search, no CDN for product images, dynamic pricing without cache strategy, GraphQL overfetching, checkout scripts delaying LCP.

## Testing strategy

E2E checkout with test cards, failed payment, refund, webhook replay, inventory race, tax/shipping edge, guest checkout, account merge and fulfillment state transition.

## Edge cases

Multi-currency rounding, partial refunds, subscription plus one-off cart, split payments, marketplace disputes, out-of-stock after payment authorization, cross-border taxes.

## Источники

- [Medusa Docs](https://docs.medusajs.com/learn)
- [Saleor Docs](https://docs.saleor.io/docs/3.x/)
- [Stripe Checkout](https://docs.stripe.com/payments/checkout)
- См. [E-commerce](ecommerce.md), [Marketplace](marketplace.md), [Stripe](../03-backend/Stripe.md), [Payments](../03-backend/Payments.md), [Webhooks](../03-backend/Webhooks.md).
