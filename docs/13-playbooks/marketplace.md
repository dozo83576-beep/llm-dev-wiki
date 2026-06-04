---
title: "Playbook: Marketplace"
category: "playbooks"
updated: "2026-06-04"
status: "active"
tags: ["marketplace", "payments", "moderation", "trust-safety"]
source_priority: "internal"
---

# Playbook: Marketplace

Двух- или трёхсторонняя площадка: продавцы / покупатели / админы (+ опционально модераторы, доставщики, кураторы). Сложность не в коде, а в trust & safety, payments, диспутах и multi-side onboarding.

## Когда использовать

- Несколько продавцов и независимые покупатели в одном продукте.
- Прозрачные комиссии, payouts продавцам, dispute-flow.
- Curated catalog или открытый submit-flow с модерацией.

## Когда не использовать

- Один продавец и много покупателей — это e-commerce, не marketplace (см. [ecommerce playbook](ecommerce.md)).
- Не готовы к compliance (KYC, anti-fraud) — лучше начать с simpler модели.

## Стек по умолчанию

Next.js + NestJS / FastAPI + PostgreSQL + Redis + search (Meilisearch / Algolia / Elastic) + payments provider с Connect / split-payments ([Stripe](../03-backend/Stripe.md) Connect / Adyen MarketPay) + moderation workflow. Для выбора commerce backend см. [headless commerce](headless-commerce.md).

## Порядок разработки

1. **Sides & roles**: buyers, sellers, admins, moderators, support, payouts ops.
2. **Data model**: users, organizations, listings, orders, disputes, reviews, payouts, KYC docs.
3. **Listings & search**: фильтры, сортировки, индексы, гео-поиск если применимо.
4. **Moderation workflow**: state machine для listings (`draft → review → published → blocked`).
5. **Order lifecycle**: state machine со всеми переходами (cart → paid → fulfilled → completed | refunded | disputed).
6. **Payments**: split-payments через Connect; idempotent webhook receivers; reconciliation.
7. **Payouts**: schedule, hold periods, KYC requirements, налоги.
8. **Disputes**: chargebacks, manual review, evidence collection.
9. **Reviews & ratings**: anti-fake reviews, response from seller, moderation appeals.
10. **Abuse reporting**: report → triage → action → notify, не "report = ban".

## Production-паттерны

- KYC / KYB интеграция в onboarding продавцов (Stripe Identity / собственный) и compliance baseline до запуска.
- Payouts отделены от orders — отдельный schedule, retries, audit.
- Webhooks идемпотентны и хранят raw payload для аудита.
- Fraud-engine на signups / listings / orders (rules + score).
- Moderation tools с keyboard shortcuts — модератор обрабатывает сотни записей в час.
- Transactional emails: order, refund, dispute, payout — все обязательны и читаются.

## Анти-паттерны

- Запускать без trust/safety сценариев (отчёт о мошенничестве, dispute, кража аккаунта).
- Делать payments без idempotency — двойные списания, отрицательные балансы.
- Не проектировать dispute/refund flow до релиза — потом это переделывается с нуля.
- Один payment endpoint для всех сценариев — путаница в reconciliation.
- "Reviews показываем мгновенно" без модерации — каскад fake-отзывов.

## Security risks

Account takeover у продавца → утечка payouts; coupon/discount abuse; PII в публичных listings; CSRF на admin actions; race на reservation listings.

## Performance risks

Search без индексов / неверная стратегия пагинации; aggregation queries на large datasets; N+1 на listing + seller + reviews.

## Testing strategy

- Order lifecycle integration tests на все переходы state machine.
- Webhook replay tests (тот же event — без побочных эффектов).
- Permission boundary tests: buyer не может писать в seller-zone, и наоборот.
- Search relevance evaluation на golden queries.
- Cancellation / refund / dispute end-to-end.

## Edge cases

- Multi-currency / multi-country tax.
- Listing с opt-in shipping регионами.
- Seller-soft-delete при сохранении истории заказов.
- Refund после payout: вычет из следующего payout / collect from balance.
- Curated и self-serve каталог в одной системе.

## Источники

- См. [Headless commerce](headless-commerce.md), [Stripe](../03-backend/Stripe.md), [Payments](../03-backend/Payments.md), [Webhooks](../03-backend/Webhooks.md), [webhook-idempotency pattern](../../patterns/backend/webhook-idempotency.md), [Multi-tenancy](../04-databases/Multi-tenancy.md), [Authorization](../05-auth-security/Authorization.md), [Compliance baseline](../05-auth-security/Compliance-baseline.md), [tenant-isolation pattern](../../patterns/security/tenant-isolation.md), [Playwright](../09-testing/Playwright.md), [E2E testing](../09-testing/E2E-testing.md).
