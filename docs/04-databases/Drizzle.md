---
title: "Drizzle ORM"
category: "database"
updated: "2026-05-24"
status: "active"
tags: ["drizzle", "orm"]
source_priority: "official-docs"
---

# Drizzle ORM

Drizzle выбирай, когда нужен TypeScript ORM ближе к SQL и сильный контроль над запросами.

Правила: схемы держать рядом с доменом, миграции ревьюить, сложные запросы покрывать integration-тестами.

Источник: [Drizzle Docs](https://orm.drizzle.team/docs/overview).

## Когда использовать

Выбирай Drizzle, когда нужен TypeScript-first доступ к SQL, контроль над запросами и легкий ORM/query builder.

## Когда не использовать

Не выбирай Drizzle, если команда ожидает более opinionated ORM с богатым schema workflow и migration ergonomics Prisma.

## Production-паттерны

Схемы держи типизированными, сложные queries покрывай integration tests, migrations ревьюй отдельно, SQL performance проверяй через EXPLAIN.

## Частые ошибки

Считать типобезопасность заменой runtime constraints, не тестировать joins, делать ad hoc migrations без review.

## Проверка

Integration tests с PostgreSQL, migration dry-run, query plan для hot endpoints.

