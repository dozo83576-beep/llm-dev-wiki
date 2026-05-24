---
title: "Playbook: Marketplace"
category: "playbooks"
updated: "2026-05-24"
status: "active"
tags: ["marketplace", "payments", "moderation"]
source_priority: "internal"
---

# Playbook: Marketplace

## Стек по умолчанию

Next.js + NestJS/FastAPI + PostgreSQL + Redis + search + payments provider + moderation workflow.

## Порядок разработки

1. Define sides: buyers, sellers, admins, moderators.
2. Model listings, orders, disputes, reviews, payouts.
3. Build search/filter/sort with indexed queries.
4. Add moderation and abuse reporting.
5. Add payment lifecycle and webhook idempotency.
6. Test order lifecycle, cancellation, refund, permission boundaries.

## Анти-паттерны

- Запускать marketplace без trust/safety сценариев.
- Делать payments без idempotency.
- Не проектировать dispute/refund flow.

