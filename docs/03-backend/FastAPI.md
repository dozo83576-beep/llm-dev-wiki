---
title: "FastAPI"
category: "backend"
updated: "2026-05-24"
status: "active"
tags: ["fastapi", "python"]
source_priority: "official-docs"
---

# FastAPI

FastAPI выбирай для Python API, AI-интеграций, typed validation через Pydantic и автоматического OpenAPI.

Правила: dependency injection для сервисов, Pydantic schemas на границе API, SQLAlchemy/Alembic для данных, background jobs для долгих операций.

Источник: [FastAPI Docs](https://fastapi.tiangolo.com/).

## Когда использовать

Выбирай FastAPI для Python API, AI/ML integrations, typed OpenAPI, async endpoints и data-heavy backend.

## Когда не использовать

Не выбирай FastAPI только из-за моды, если проекту нужен Django admin или команда сильнее в TypeScript/NestJS.

## Production-паттерны

Pydantic schemas на границе, dependency injection для auth/db/services, SQLAlchemy sessions с явным lifecycle, Alembic migrations, structured errors.

## Частые ошибки

DB session leak, blocking CPU work в async endpoint, business logic в route functions, отсутствие auth dependencies на protected routes.

## Проверка

pytest для services, TestClient/httpx integration tests, OpenAPI contract checks, permission negative tests.

