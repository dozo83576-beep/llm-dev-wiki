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

Integration tests с PostgreSQL (Testcontainers / Docker), migration dry-run, query plan через `db.execute(sql\`EXPLAIN ANALYZE ...\`)` для hot endpoints.

## Edge cases

- Migrations через `drizzle-kit` генерятся из diff — ревьюить вручную перед apply.
- Relations API хорош для типизации, но raw SQL остаётся лучшим инструментом для сложных аналитических запросов.
- `prepare` для повторяющихся queries — выигрыш на hot path.
- pg connection pool: тот же pgbouncer / Neon pooler, что и для Prisma.

## Security risks

Raw `sql\`\${userInput}\`` без `sql.placeholder` — потенциальный SQL injection. Открытые миграции с DROP/TRUNCATE без явного approval.

## Источники

- [Drizzle Docs](https://orm.drizzle.team/docs/overview) — проверено 2026-05-24.
- См. [Prisma](Prisma.md), [Migrations](Migrations.md), [PostgreSQL](PostgreSQL.md).

