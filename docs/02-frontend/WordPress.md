---
title: "WordPress"
category: "frontend"
updated: "2026-07-21"
reviewed: "2026-07-21"
status: "active"
tags: ["wordpress", "cms", "headless", "content"]
source_priority: "official-docs"
---

# WordPress

WordPress — production reality для редакторских сайтов, корпоративного marketing, newsroom, SEO-контента и legacy-платформ. Выбирай его как CMS/workflow decision, а не как default для custom SaaS.

**Security baseline:** WordPress `7.0.2` — security release. Обновляй core оперативно, но сначала прогоняй на staging совместимость plugins/themes, Block Editor, REST/headless preview и критичные checkout/form flows. Beta/pre-release ветки, включая 7.1 beta, не являются production baseline.

Если WordPress используется как **commerce/marketplace backend** (WooCommerce, кастомные REST-эндпоинты, mu-plugins, Action Scheduler, SPA-кабинеты) — см. [WordPress + WooCommerce backend](../03-backend/WordPress-WooCommerce-backend.md); этот документ покрывает editorial/CMS-сценарии.

## Когда использовать

- Редакторы уже работают в WordPress, есть обученная команда и контентный процесс.
- Нужны block themes, Full Site Editing, роли редакторов, media library, plugins, previews.
- Требуется headless CMS для Next.js/Astro storefront/content site с существующим WordPress backend.
- Бизнес ценит скорость редакторского workflow выше полного TypeScript ownership.

## Когда не использовать

- Custom SaaS, сложная доменная модель, realtime, multi-tenant permissions или API-first product.
- Нужны строгие typed schemas, code review для content model и deploy через один TS repo.
- Команда не готова обслуживать plugin/security/update lifecycle.
- Headless WordPress выбирается только потому, что “WordPress знакомый”, без cache/preview/security плана.

## Production-паттерны

- Classic/block theme: фиксируй theme ownership, allowed blocks, global styles, image sizes, SEO plugin policy.
- Headless: WordPress — content source of truth; frontend отвечает за rendering, cache, SEO, previews and redirects.
- REST API/GraphQL endpoints закрывай от лишних user fields, draft data and plugin leakage.
- Publish/update events должны инвалидировать cache или запускать rebuild.
- Plugin allowlist обязателен: каждый plugin имеет owner, update cadence, CVE monitoring and removal plan.
- Admin panel защищай MFA, least privilege roles, backups and staging update rehearsal.

## Частые ошибки

- Давать всем admin role вместо editor/custom role.
- Ставить plugins ради мелких функций без security review.
- Headless frontend кеширует stale content и не имеет preview auth.
- Менять slugs без redirect map.
- Пытаться строить сложный SaaS поверх posts/meta вместо нормальной доменной БД.

## Проверка

Проверь editor roles, draft preview, publish/unpublish, cache invalidation, redirects, sitemap, robots, media alt text, plugin updates, backup restore and security headers. Для frontend handoff запускай `pwsh tools/site-audit.ps1 -Url <url>`.

## Источники

- [WordPress Developer Resources](https://developer.wordpress.org/)
- [WordPress 7.0.2 Security Release](https://wordpress.org/news/2026/07/wordpress-7-0-2-release/) — проверено 2026-07-21.
- [WordPress REST API Handbook](https://developer.wordpress.org/rest-api/)
- [Block Editor Theme docs](https://developer.wordpress.org/block-editor/how-to-guides/themes/)
- См. [CMS content](CMS-content.md), [SEO](SEO.md), [Performance](Performance.md), [Security testing](../09-testing/Security-testing.md).
