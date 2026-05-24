---
title: "Playbook: E-commerce"
category: "playbooks"
updated: "2026-05-24"
status: "active"
tags: ["ecommerce", "checkout", "payments"]
source_priority: "internal"
---

# Playbook: E-commerce

Магазин: каталог → корзина → checkout → оплата → fulfillment → support. Деньги в каждой точке, ошибки видны клиентам сразу — критичны идемпотентность, надёжность платежей и inventory race protection.

## Когда использовать

- Продаём физические или цифровые товары online.
- Подписки + one-off покупки (микс).
- Marketplace с одним продавцом (для multi-vendor см. [marketplace playbook](marketplace.md)).

## Когда не использовать

- Один или два товара через простую форму — Stripe Checkout + лендинг быстрее.
- B2B-сделки с ручным закрытием — не нужен полный e-com.

## Стек по умолчанию

Next.js + commerce backend (свой или Saleor/Medusa/Shopify) + PostgreSQL + Stripe/Adyen + analytics + E2E checkout tests + observability на платёжных webhooks.

## Порядок разработки

1. **Catalog**: products, variants (size/color), SKU, inventory, prices с историей.
2. **Cart**: persistence (cookie/db), tax/shipping расчёт, скидки/промокоды.
3. **Checkout**: предпочтительно provider-hosted (Stripe Checkout / Payment Element) — меньше PCI scope.
4. **Orders**: state machine (`pending → paid → fulfilled → shipped → completed`), события платежа.
5. **Payments**: webhook идемпотентность, retry policy, reconciliation.
6. **Fulfillment**: WMS / 3PL интеграция или ручная сборка.
7. **Customer account**: orders, returns, refunds, support tickets.
8. **Analytics**: funnel (add to cart → checkout → paid), abandoned cart, top SKU.
9. **Testing**: успешный checkout, отказ оплаты, retry, race на inventory, refund.

## Production-паттерны

- Цена и налоги считаются на сервере; клиент только показывает.
- Inventory: оптимистичный лок или резервирование на checkout-старте с TTL.
- Order id != payment id; провайдер event — авторитет на статус.
- Webhook receivers идемпотентны по `event_id`.
- Refund flow с audit и подтверждением; partial refunds учитывают tax.
- Customer-facing errors не раскрывают provider-specific детали.

## Анти-паттерны

- Считать цену только на клиенте — переписывается через DevTools.
- Нет inventory race handling — двое купили последний товар.
- Считать payment success до webhook от провайдера.
- Хранить полные карты на стороне приложения (PCI scope!).
- Send email "ваш заказ оформлен" по `paid` без последующих ретраев / fallback.

## Security risks

PCI / тайные данные карт, account takeover через credential stuffing, coupon abuse (one-per-user обходится через новые аккаунты), price manipulation в API.

## Performance risks

Heavy catalog query без индексов, N+1 на список заказов с items, нет CDN на product images, ISR-инвалидация не покрывает обновления цен.

## Testing strategy

- Successful checkout end-to-end на staging с test cards.
- Failed payment (insufficient funds, fraud) — retry / fallback path.
- Inventory race: два параллельных checkout на последний товар.
- Webhook replay: тот же event дважды — без побочных эффектов.
- Refund flow: full / partial / cross-currency.

## Edge cases

- Multi-currency и round-off при налогах.
- Подписка + upsell + промокод одновременно.
- Возврат частично доставленного заказа.
- Гость-чекаут vs зарегистрированный пользователь — merge корзин при логине.
- Inventory у разных warehouses / dropship suppliers.

## Источники

- См. [Payments](../03-backend/Payments.md), [Webhooks](../03-backend/Webhooks.md), [webhook-idempotency pattern](../../patterns/backend/webhook-idempotency.md), [E2E testing](../09-testing/E2E-testing.md), [SaaS playbook](saas.md).
