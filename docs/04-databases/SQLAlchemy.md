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

pytest integration tests, transaction rollback tests, query count, Alembic upgrade/downgrade на staging.

