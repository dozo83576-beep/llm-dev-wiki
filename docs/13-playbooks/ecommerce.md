---
title: "Playbook: E-commerce"
category: "playbooks"
updated: "2026-05-24"
status: "active"
tags: ["ecommerce", "checkout", "payments"]
source_priority: "internal"
---

# Playbook: E-commerce

## Стек по умолчанию

Next.js + commerce backend/provider + PostgreSQL + payment provider + analytics + E2E checkout tests.

## Порядок разработки

1. Catalog: products, variants, inventory, prices.
2. Cart: persistence, taxes, shipping, discounts.
3. Checkout: provider-hosted where possible.
4. Orders: state machine, payment events, fulfillment.
5. Customer account: orders, refunds, support.
6. Testing: successful checkout, failed payment, inventory edge cases.

## Анти-паттерны

- Цена считается только на client.
- Нет inventory race handling.
- Payment success считается до provider confirmation.

