---
title: "Prisma"
category: "database"
updated: "2026-05-24"
status: "active"
tags: ["prisma", "orm"]
source_priority: "official-docs"
---

# Prisma

Prisma подходит для TypeScript-проектов, где важны типобезопасность, migrations и developer experience.

Правила: не прячь сложные запросы за неясными helper-ами, проверяй N+1, используй транзакции для атомарных операций, миграции ревьюить как production-код.

Источник: [Prisma ORM Docs](https://www.prisma.io/docs/orm).

## Когда использовать

Выбирай Prisma для TypeScript-проектов, где важны schema workflow, generated client, migrations и быстрый developer experience.

## Когда не использовать

Не выбирай Prisma, если команда хочет писать почти весь SQL вручную или нужна тонкая оптимизация query layer на каждом endpoint.

## Production-паттерны

Schema ревьюится как контракт, migrations проходят staging, transactions используются для use cases, raw SQL изолируется и тестируется.

## Частые ошибки

Не замечать N+1, делать destructive migration без review, использовать generated types вместо runtime validation на API boundary.

## Проверка

Integration tests с тестовой БД, migration deploy dry-run, query logs для hot paths, negative tests на constraints.

