---
title: "Supabase"
category: "backend"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["supabase", "postgres", "auth", "rls", "realtime"]
source_priority: "vendor-docs"
---

# Supabase

Supabase — managed PostgreSQL platform с Auth, Storage, Realtime, Edge Functions и auto-generated APIs. Главный production-инвариант: если frontend ходит напрямую в Supabase, безопасность должна жить в Postgres Row Level Security, а не в UI.

## Когда использовать

- Быстрый запуск продукта на PostgreSQL с Auth, Storage и Realtime без отдельной backend-команды.
- MVP/SMB SaaS, internal tools, realtime dashboards, простые CRUD-продукты.
- Команда готова писать SQL migrations и RLS policies как production-код.

## Когда не использовать

- Сложный домен требует service-layer, workflow engine, outbox и много backend-инвариантов.
- Команда не готова ревьюить RLS и SQL migrations.
- Нужен portable self-hosted stack без зависимости от managed platform features.

## Production-паттерны

- RLS включается на все таблицы, доступные через client/API; default policy — deny.
- `service_role` key никогда не попадает в browser, mobile app, logs или screenshots.
- Migrations идут через CLI и code review; ручные изменения в dashboard не считаются source of truth.
- Storage buckets получают отдельные policies; file metadata связывается с tenant/user.
- Realtime channels защищаются через auth/JWT и RLS policy, если данные tenant-scoped.

## Частые ошибки

- Создать таблицу без `enable row level security`.
- Проверять tenant только в React-коде и отдавать anon key с широкими policies.
- Использовать dashboard hotfix без migration file.
- Смешивать Supabase Auth users с public profile без sync/audit правил.

## Проверка

- SQL tests: anon не видит чужой tenant, authenticated видит только свой tenant, service_role используется только server-side.
- Migration review: каждая новая таблица имеет RLS decision и индексы для policy predicates.
- E2E: login, read/write own data, denied cross-tenant read/write, storage upload denied для чужого tenant.

## Источники

- [Supabase Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security) — проверено 2026-05-24.
- [Supabase CLI migrations](https://supabase.com/docs/reference/cli) — проверено 2026-05-24.
- [Supabase Realtime Authorization](https://supabase.com/docs/guides/realtime/authorization) — проверено 2026-05-24.
