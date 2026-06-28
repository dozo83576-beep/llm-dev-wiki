---
title: "Sanity"
category: "frontend"
updated: "2026-06-22"
status: "active"
tags: ["cms", "sanity", "visual-editing", "content"]
source_priority: "official-docs"
---

# Sanity

Sanity — hosted content platform для structured content, editorial workflow, visual editing and live preview. Сильнее всего подходит, когда редакторский опыт важен не меньше frontend code.

Freshness note: Sanity Studio 6.1.0 is an improvements/bugfix release; version actions and Studio timing telemetry changed, but content-model and preview guidance remains unchanged.

## Когда использовать

- Нужен content lake, structured content, custom Studio and preview.
- Marketing/editorial team хочет visual editing, live preview and reusable content blocks.
- Frontend — Next.js/Astro/Nuxt, а content workflow должен быть SaaS-managed.
- Нужны быстрые редакторские изменения без деплоя приложения.

## Когда не использовать

- Требуется self-hosted CMS из compliance/security причин.
- Content model должен жить только в app repo и проходить тот же deploy cycle.
- Команда не готова проектировать structured content вместо page HTML blobs.
- Маленький static сайт без редакторов.

## Production-паттерны

- Schema проектируй как product model: portable text, references, slugs, SEO fields, media metadata.
- Preview/draft mode закрывай auth и запрещай index.
- Visual editing wiring фиксируй как интеграцию, а не “магическую” feature.
- CDN/cache policy разделяет public published content and draft preview.
- Content migrations/references проверяй до удаления fields.

## Частые ошибки

- Делать универсальный rich text blob вместо typed sections.
- Preview URL доступен без auth.
- Нет fallback для missing references/images.
- Frontend зависит от draft fields в production.

## Проверка

Проверь schema validation, preview auth, visual editing, publish/unpublish, cache revalidation, broken references, image pipeline, localized content and SEO metadata.

## Источники

- [Sanity Docs](https://www.sanity.io/docs) — refreshed against Sanity Studio 6.1.0 on 2026-06-22.
- [Sanity Visual Editing](https://www.sanity.io/docs/visual-editing/introduction-to-visual-editing)
- [Visual Editing with Next.js App Router](https://www.sanity.io/docs/visual-editing/visual-editing-with-next-js-app-router)
- См. [CMS content](CMS-content.md), [SEO](SEO.md), [Frontend blueprints](Frontend-blueprints.md).
