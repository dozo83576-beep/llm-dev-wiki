---
title: "Playbook: SaaS"
category: "playbooks"
updated: "2026-05-24"
status: "active"
tags: ["saas", "multi-tenant", "billing"]
source_priority: "internal"
---

# Playbook: SaaS

Multi-tenant продукт: организации, пользователи, тарифы, billing, onboarding, RBAC. Главные риски — tenant isolation, billing edge cases (failed payments, refunds, dunning), permission boundary, миграция данных без даунтайма.

## Когда использовать

- Подписочный продукт с несколькими организациями-клиентами.
- Self-serve onboarding с trial → paid конверсией.
- Команда готова поддерживать billing-флоу, support и compliance.

## Когда не использовать

- Single-tenant enterprise, развёртываемый on-prem — нужен другой подход.
- One-shot landing с одной формой — overkill (см. [landing playbook](landing.md)).

## Стек по умолчанию

Next.js + TypeScript + PostgreSQL + Prisma/Drizzle + Auth.js/Supabase/Clerk + Stripe + Playwright + Sentry + Vercel/Render.

## Порядок разработки

1. **Discovery**: роли (admin/member/billing/owner), тарифы, tenant model (single-DB-shared / DB-per-tenant), onboarding (email, invite, SSO).
2. **Data model**: users, organizations, memberships, subscriptions, audit_log, invitations, api_keys.
3. **Auth**: signup, invite, email verification, password reset, magic link / SSO (если enterprise).
4. **Tenant boundary**: каждое query фильтрует по `organization_id`, тест на cross-tenant leak.
5. **Core flows**: onboarding wizard, dashboard, CRUD основной сущности, settings.
6. **Billing**: Stripe Checkout/Portal, webhooks для `customer.subscription.*`, plan changes (prorate), failed payment dunning.
7. **Permissions**: явный `can(user, action, resource)` API.
8. **Security**: rate limits, CSP, security headers, secret scanning в CI.
9. **Testing**: permissions grid, billing webhook idempotency, subscription state transitions, E2E happy path.
10. **Deploy**: preview environments, migration review, production monitoring + alerts.
11. **Knowledge capture**: success/failure/lessons после major релизов.

## Production-паттерны

- Row-level security или явный `WHERE organization_id = $1` во всех queries.
- Stripe subscription state — source of truth для access; не "наша таблица перекрывает Stripe".
- Idempotent webhook handlers, retry-safe.
- Audit log на каждое state-changing действие.
- Feature flags для постепенной выкатки фичей по plan / organization.
- Email-инвайт со сроком жизни и одноразовым токеном.

## Анти-паттерны

- Начинать с billing до ясной модели tenant и ролей.
- Проверять доступ только на frontend — backend всё равно должен проверять.
- Игнорировать failed payment / webhook replay — пользователь сохраняет доступ после неуплаты.
- Один webhook endpoint для всего Stripe без routing по event type.
- "Все admins равны" — должен быть owner с эксклюзивным правом billing.

## Security risks

Cross-tenant data leak (самый частый и дорогой баг SaaS), session-fixation, утечка api keys в logs, IDOR на admin-endpoints, mass-assignment в org settings.

## Performance risks

Большие orgs (миллион записей в одной таблице без индексов), N+1 на dashboard, тяжёлые запросы из admin-impersonation.

## Testing strategy

- Permission grid integration tests.
- Tenant isolation tests (создать данные в org A, проверить, что user из org B их не видит).
- Stripe webhook replay tests с одинаковым event_id.
- E2E onboarding: signup → email verify → invite teammate → create resource.
- Subscription transitions: trial → active → past_due → canceled, и обратно (resume).

## Edge cases

- Multi-organization user (один email в нескольких orgs).
- Owner покидает организацию — transfer ownership.
- Downgrade plan: что с уже созданными ресурсами, превышающими новый лимит.
- Refund + partial payouts при annual prepay.
- GDPR / data export / deletion request.

## Источники

- См. [Authentication](../05-auth-security/Authentication.md), [Authorization](../05-auth-security/Authorization.md), [Multi-tenancy](../04-databases/Multi-tenancy.md), [Payments](../03-backend/Payments.md), [Webhooks](../03-backend/Webhooks.md), [tenant-isolation pattern](../../patterns/security/tenant-isolation.md), [admin-dashboard playbook](admin-dashboard.md).
