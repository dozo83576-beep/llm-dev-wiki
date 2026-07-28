---
title: "Supporting guide: Shopify Hydrogen"
category: "playbooks"
updated: "2026-07-21"
status: "active"
tags: ["shopify", "hydrogen", "commerce", "react-router"]
source_priority: "official-docs"
---

# Supporting guide: Shopify Hydrogen

Используется только как supporting guide к primary `ecommerce` при явном требовании Shopify/Hydrogen.
Слова «каталог», «товар» или «checkout» без Shopify не активируют этот guide.

Shopify Hydrogen — Shopify-first custom storefront stack. Он built on React Router and Storefront API, а Shopify остаётся source of truth для catalog, cart, checkout and commerce operations.

Freshness note: Hydrogen 2026.4.4 is a patch release; the 2026.4 line updated Storefront API and Customer Account API to 2026-04, made the Storefront API proxy mandatory and enabled backend consent mode. Custom storefronts must review proxy, consent and cart/metafield edge cases before upgrade.

## Когда использовать

- Бизнес уже на Shopify и хочет custom React storefront.
- Нужны Shopify catalog, inventory, discounts, checkout, markets and operations.
- Команда хочет больше контроля над UX, чем theme storefront, но не хочет строить commerce backend.
- Checkout должен оставаться в Shopify boundary.

## Когда не использовать

- Commerce backend не Shopify или нужен marketplace/split-payments вне Shopify model.
- Требуется generic storefront, который должен легко сменить commerce provider.
- Команда не готова к Shopify platform constraints and API limits.
- Один товар/subscription проще закрыть Stripe Checkout.

## Production-паттерны

- Shopify — source of truth; local cache/search только производные данные.
- React Router routes проектируются вокруг product, collection, cart, account and content routes.
- Storefront API tokens and customer data не попадают в client beyond intended public scope.
- Price, inventory, discounts and checkout state берутся с server/provider boundary.
- Preview/staging uses non-production store or protected environment.

## Частые ошибки

- Строить custom checkout вместо Shopify checkout без compliance plan.
- Кешировать price/inventory без invalidation.
- Смешивать CMS/product content без ownership.
- Считать Hydrogen универсальной заменой Next.js e-commerce.

## Проверка

Проверь product/collection pages, cart mutations, checkout redirect, discount edge cases, inventory changes, localization/markets, SEO metadata, analytics and site audit.

## Источники

- [Shopify Hydrogen Docs](https://shopify.dev/docs/api/hydrogen/latest) — refreshed against `@shopify/hydrogen` 2026.4.4 on 2026-06-22.
- [Hydrogen React](https://shopify.dev/docs/api/hydrogen-react/latest)
- См. [Headless commerce](headless-commerce.md), [E-commerce](ecommerce.md), [React Router](../02-frontend/React-Router.md), [Payments](../03-backend/Payments.md).
