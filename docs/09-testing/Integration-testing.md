---
title: "Integration testing"
category: "testing"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["integration-tests", "api", "database"]
source_priority: "internal"
---

# Integration testing

Integration-тесты проверяют связку нескольких слоёв: API → service → DB, очередь → worker → side-effect, adapter → внешний API. Их ценность — ловить баги, которых не видно в unit-тестах (SQL, ORM lazy-load, транзакции, сериализация).

## Когда использовать

- Любая критичная связка API + БД.
- Background workers с DB / queue.
- External adapters (Stripe, S3, email) — против sandbox / MSW / replay.
- Permission-flow с реальными ролями и tenants.

## Когда не использовать

- Чистая логика без внешних эффектов — unit-уровень.
- Полноценный user journey с UI — E2E.
- Smoke против production — это monitoring, не тест.

## Production-паттерны

- **Real DB**: PostgreSQL в Docker / Testcontainers / ephemeral schema. Не SQLite-имитация.
- **Cleanup**: транзакционный rollback в `afterEach` или truncate всех таблиц перед каждым тестом.
- **HTTP**: вызывать API через supertest / httpx как настоящий клиент, не вызывать handler напрямую.
- **External services**: sandbox-аккаунты (Stripe test), MSW для HTTP, fake S3 (minio).
- **Time**: frozen clock через библиотеку, не реальный `Date.now()`.
- **Parallel**: каждый воркер CI получает свою БД / schema.

## Частые ошибки

- Делить одну тестовую БД между тестами без cleanup — race conditions.
- Мокать собственный DB-слой — теряется ценность теста (вернулись к unit).
- Зависимость от порядка тестов.
- Использовать реальный production endpoint Stripe / GitHub без идемпотентности.
- Игнорировать DB-таймауты — flaky на нагруженном CI.

## Security risks

Тестовая БД с PII из production-дампа; забытые тестовые credentials в репо; sandbox-токены, мигрирующие в production через конфиг.

## Performance risks

Slow integration suite (> 10 мин) убивает feedback loop; неконтролируемое создание данных раздувает БД; cold start Docker / Testcontainers.

## Testing strategy

- Suite split: fast (in-memory deps) vs db (real DB). Fast — на every commit, db — на PR.
- Parallel workers с изолированными schemes.
- Snapshot тестов response для контракта.
- Coverage по критичным flow, не по % покрытия.

## Edge cases

- Транзакционные граничные кейсы: rollback, deadlock, serialization failure.
- Eventual-consistency (queue → worker → DB) — тесты ждут с polling, не sleep.
- Pagination / sorting — отдельные тесты на boundary.
- Multi-tenant isolation тесты.

## Источники

- [Testcontainers](https://testcontainers.com/) — проверено 2026-05-24.
- См. [Unit testing](Unit-testing.md), [Test pyramid](Test-pyramid.md), [Fixtures](Fixtures.md), [Database design](../04-databases/Database-design.md).
