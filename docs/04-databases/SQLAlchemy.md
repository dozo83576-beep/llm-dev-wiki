---
title: "SQLAlchemy"
category: "database"
updated: "2026-05-24"
status: "active"
tags: ["sqlalchemy", "python"]
source_priority: "official-docs"
---

# SQLAlchemy

SQLAlchemy используй для Python backend с FastAPI/Django-adjacent сервисами, когда нужен зрелый ORM/Core и контроль над SQL.

Правила: Alembic для миграций, explicit sessions, transaction boundary в service layer, тесты на критичные запросы.

Источник: [SQLAlchemy Docs](https://docs.sqlalchemy.org/).

## Когда использовать

Выбирай SQLAlchemy для Python backend, где нужен зрелый ORM/Core, контроль SQL и совместимость с Alembic migrations.

## Когда не использовать

Не выбирай SQLAlchemy, если проект полностью Django и стандартный Django ORM закрывает требования без отдельной data layer.

## Production-паттерны

Session lifecycle явный, transaction boundary в service layer, Alembic migrations, eager loading для борьбы с N+1, raw SQL тестируется.

## Частые ошибки

Session leak, lazy loading в hot path, бизнес-логика в model methods без тестов, отсутствие migration review.

## Проверка

pytest integration tests, transaction rollback tests, query count assertion (SQLAlchemy `event.listen`), Alembic upgrade/downgrade на staging, EXPLAIN на критичные запросы.

## Edge cases

- Async (SQLAlchemy 2.x async) — отдельная сессия, не миксовать с sync в одном scope.
- Identity map: один и тот же объект из разных query — нюанс при тестах.
- `expire_on_commit=True` (default) делает invalidation полей после commit — учитывать в API responses.
- ORM relationships с `lazy="joined"` на больших коллекциях — потенциальный perf hit.

## Security risks

Mass-assignment через `**kwargs` без allowlist, raw SQL через `text()` с user-input без `:param`, утечка через repr модели в логах.

## Источники

- [SQLAlchemy Docs](https://docs.sqlalchemy.org/) — проверено 2026-05-24.
- См. [PostgreSQL](PostgreSQL.md), [Migrations](Migrations.md), [Transactions](Transactions.md), [FastAPI](../03-backend/FastAPI.md).

