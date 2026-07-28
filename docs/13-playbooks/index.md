---
title: "Project playbooks"
category: "playbooks"
updated: "2026-07-21"
status: "active"
tags: ["playbooks", "delivery", "contract-v2"]
source_priority: "internal"
---

# Project playbooks

Router выбирает по продукту ровно один primary playbook, а явные platform constraints добавляет
как supporting guides. Полный реестр и совместимые delivery profiles находятся в
[`site-pipeline-contract.json`](../../resources/site-pipeline-contract.json).

## Primary playbooks

- [Landing](landing.md)
- [Content/CMS site](content-site.md)
- [SaaS](saas.md)
- [E-commerce](ecommerce.md)
- [Admin dashboard](admin-dashboard.md)
- [Marketplace](marketplace.md)
- [AI/RAG app](ai-rag-app.md)
- [API-only backend](api-only-backend.md)
- [Real-time app](real-time-app.md)

## Supporting guides

- [Headless commerce](headless-commerce.md)
- [Shopify Hydrogen](shopify-hydrogen.md)
- WordPress, WooCommerce, Webflow и edge-runtime guides из contract.

Supporting guide уточняет стек и риски, но не заменяет primary product playbook. Например:
`Playbook: ecommerce` + `Supporting-Guides: shopify-hydrogen, headless-commerce`.

## Definition of Done

Discovery и acceptance зафиксированы; архитектура, security, testing, deploy/rollback/monitoring и
learning review пройдены по применимому графу. Любое отклонение отражено в status v2 и принято verifier.
