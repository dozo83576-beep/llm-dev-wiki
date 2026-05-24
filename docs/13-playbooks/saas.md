---
title: "Playbook: SaaS"
category: "playbooks"
updated: "2026-05-24"
status: "active"
tags: ["saas", "nextjs", "postgresql"]
source_priority: "internal"
---

# Playbook: SaaS

## Стек по умолчанию

Next.js + TypeScript + PostgreSQL + Prisma/Drizzle + Auth.js/Supabase + Stripe + Playwright + Sentry.

## Порядок разработки

1. Discovery: роли, тарифы, tenant model, billing, onboarding.
2. Data model: users, organizations, memberships, subscriptions, audit log.
3. Auth: signup, invite, login, password reset, role changes.
4. Core flows: onboarding, dashboard, CRUD, billing.
5. Security: tenant isolation, object-level permissions, rate limits.
6. Testing: permissions, billing webhooks, subscription states, E2E happy path.
7. Deploy: preview, migration review, production monitoring.
8. Knowledge capture: success/failure/lesson.

## Анти-паттерны

- Начинать с billing до ясной модели tenant/roles.
- Проверять доступ только на frontend.
- Игнорировать failed payment и webhook replay.

