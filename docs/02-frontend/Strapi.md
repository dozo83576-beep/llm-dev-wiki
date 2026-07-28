---
title: "Strapi"
category: "frontend"
updated: "2026-07-21"
status: "active"
tags: ["cms", "strapi", "headless", "content"]
source_priority: "official-docs"
---

# Strapi

Strapi — self-hosted headless CMS для команд, которым нужен быстрый content API, редакторская админка, RBAC и контроль над backend deployment.

Freshness note: Strapi 5.50.2 reviewed 2026-07-21; API exposure, RBAC and media-permission guidance unchanged.

## Когда использовать

- Нужен headless CMS для Next.js, Astro, Nuxt или mobile clients.
- Контентная модель быстро меняется, но должна жить в управляемой CMS, а не Markdown.
- Команда готова self-host и обслуживать database, media, roles, backups and upgrades.
- Нужны REST/GraphQL APIs, roles, permissions, i18n and plugin ecosystem.

## Когда не использовать

- Нужен code-first CMS рядом с TypeScript app: сначала смотри [Payload CMS](Payload-CMS.md).
- Редакторам нужен сильный visual editing/page builder workflow: проверь [Sanity](Sanity.md) или Webflow.
- Команда не готова поддерживать CMS backend, migrations and plugin lifecycle.
- Контент полностью developer-owned: Astro content collections проще.

## Production-паттерны

- Content model версионируй через review: поля, relations, slugs, SEO, localization.
- Public API выдаёт только published content; preview endpoints требуют auth.
- Media storage выноси в managed object storage/CDN.
- Cache invalidation на publish/update/delete событиях.
- RBAC настраивай по ролям редакторов, не через shared admin account.

## Частые ошибки

- Открытый API отдаёт draft/private fields.
- Schema changes делаются в админке без review и ломают frontend.
- Нет backup/restore drill для CMS DB and media.
- Frontend overfetches CMS API на каждый request без CDN/cache.

## Проверка

Проверь roles, published/draft boundary, preview auth, slug collision, webhooks, media permissions, backup restore, API rate limits, cache purge and SEO metadata.

## Источники

- [Strapi Docs](https://docs.strapi.io/) — refreshed against Strapi 5.50.2 on 2026-07-21.
- [Strapi Next.js integration](https://strapi.io/integrations/nextjs-cms)
- См. [CMS content](CMS-content.md), [Next.js](Nextjs.md), [Astro](Astro.md), [Security testing](../09-testing/Security-testing.md).
