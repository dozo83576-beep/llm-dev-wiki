---
title: "Directus"
category: "frontend"
updated: "2026-06-10"
status: "active"
tags: ["cms", "directus", "headless", "database"]
source_priority: "official-docs"
---

# Directus

Directus — headless CMS/data platform поверх SQL database: существующая схема становится REST/GraphQL API и admin studio. Это сильный вариант, когда database ownership важнее CMS abstraction.

## Когда использовать

- Уже есть PostgreSQL/MySQL/SQLite schema, которую нужно открыть как managed content/admin interface.
- Нужны REST/GraphQL APIs, permissions, field-level access, flows and no-code admin.
- Команда хочет не прятать данные за proprietary content model.
- Internal tools/content operations должны работать поверх той же SQL модели.

## Когда не использовать

- Нужен opinionated editorial page builder или visual editing для marketing.
- Product DB содержит sensitive data, а команда не готова к строгому permission design.
- Контент проще хранить в filesystem или code-first CMS.
- Нет владельца schema migrations и access policy.

## Production-паттерны

- Database schema остаётся source of truth; Directus permissions — отдельный security boundary.
- Field-level permissions обязательны для PII/internal fields.
- Public API выдаёт только published/allowed projections.
- Flows/webhooks проходят review как backend automation.
- Backups/migrations тестируются вне Directus UI.

## Частые ошибки

- Считать auto-generated API безопасным без permission matrix.
- Давать editors прямой доступ к чувствительным collections.
- Менять schema через UI без migration/review.
- Смешивать product writes and editorial writes без audit log.

## Проверка

Проверь role matrix, field permissions, API tokens, public/draft boundary, flows side effects, audit log, backup restore, rate limits and frontend cache invalidation.

## Источники

- [Directus Docs](https://directus.com/docs/)
- [Directus Data API](https://developers.directus.com/)
- См. [CMS content](CMS-content.md), [API architecture](../03-backend/API-architecture.md), [Security testing](../09-testing/Security-testing.md).
