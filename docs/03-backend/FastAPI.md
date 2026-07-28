---
title: "FastAPI"
category: "backend"
updated: "2026-07-21"
status: "active"
tags: ["fastapi", "python"]
source_priority: "official-docs"
---

# FastAPI

FastAPI выбирай для Python API, AI-интеграций, typed validation через Pydantic и автоматического OpenAPI.

Правила: dependency injection для сервисов, Pydantic schemas на границе API, SQLAlchemy/Alembic для данных, background jobs для долгих операций.

Источник: [FastAPI Docs](https://fastapi.tiangolo.com/). Freshness note: FastAPI 0.139.2 reviewed 2026-07-21; API-service and validation guidance unchanged.

## Когда использовать

Выбирай FastAPI для Python API, AI/ML integrations, typed OpenAPI, async endpoints и data-heavy backend.

## Когда не использовать

Не выбирай FastAPI только из-за моды, если проекту нужен Django admin или команда сильнее в TypeScript/NestJS.

## Production-паттерны

Pydantic schemas на границе, dependency injection для auth/db/services, SQLAlchemy sessions с явным lifecycle, Alembic migrations, structured errors.

## Частые ошибки

DB session leak, blocking CPU work в async endpoint, business logic в route functions, отсутствие auth dependencies на protected routes.

## Проверка

pytest для services, TestClient/httpx integration tests, OpenAPI contract checks, permission negative tests, mypy/ruff на каждый PR.

## Edge cases

- Background tasks через `BackgroundTasks` хорош для лёгких задач, но не заменяет очередь (Celery/Arq/Dramatiq).
- Async + блокирующие библиотеки (psycopg2 sync, requests) — нужны run_in_executor или async-альтернатива.
- Dependency-overrides для тестов — следить, чтобы не утекало между тестами.
- Стриминг (Server-Sent Events) — отдельный паттерн с `StreamingResponse`.

## Security risks

CORS slip с `allow_origins=["*"]`, утечка stack trace в JSON-ответе при DEBUG=True, отсутствие auth dependency по умолчанию — каждое route добавляет вручную.

## Источники

- [FastAPI Docs](https://fastapi.tiangolo.com/) — refreshed against FastAPI 0.139.2 on 2026-07-21.
- См. [Nodejs](Nodejs.md), [Background jobs](Background-jobs.md), [Error handling](Error-handling.md).
