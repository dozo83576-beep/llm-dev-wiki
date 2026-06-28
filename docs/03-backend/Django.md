---
title: "Django"
category: "backend"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["django", "backend"]
source_priority: "official-docs"
---

# Django

Django выбирай для зрелых CRUD/backend систем, где важны ORM, migrations, admin, auth и convention-over-configuration.

Правила: держи бизнес-логику вне views, проверяй permissions на queryset/object level, не отключай CSRF без архитектурной причины.

Источник: [Django Docs](https://docs.djangoproject.com/).

## Когда использовать

Выбирай Django для CRUD, admin-heavy систем, internal tools, enterprise backend и проектов, где зрелые batteries included важнее тонкой кастомизации.

## Когда не использовать

Не выбирай Django, если команда стандартизирована на TypeScript, нужен tight Next.js full-stack workflow или Python в проекте не нужен.

## Production-паттерны

Views остаются тонкими, permissions проверяются на object/queryset level, migrations ревьюятся, admin actions логируются, settings разделены по окружениям.

## Частые ошибки

Business logic в views, отключенный CSRF, N+1 queries в DRF serializers, широкие permissions, secrets в settings.

## Проверка

pytest/django tests для models/services/views, permission tests, migration test, query count для горячих endpoints.

