---
title: "Eleventy"
category: "frontend"
updated: "2026-06-10"
status: "active"
tags: ["eleventy", "static-site", "docs", "content"]
source_priority: "official-docs"
---

# Eleventy

Eleventy — простой static site generator для docs, blogs, marketing pages and content sites, где важны HTML ownership, minimal JS and flexible templates.

## Когда использовать

- Нужен быстрый статический сайт без React runtime.
- Контент живёт в Markdown/Liquid/Nunjucks/JS data files.
- Команда хочет простой build output, который можно загрузить почти на любой host.
- Docs/blog/help center не требуют сложного app state.

## Когда не использовать

- Нужны islands интерактива, framework components and rich app UI: чаще проще Astro.
- Редакторам нужен CMS workflow, preview and media library.
- Нужен full-stack backend, auth or dashboard.
- Команда не хочет поддерживать template/data pipeline.

## Production-паттерны

- Content model: collections, front matter, slugs, taxonomies, redirects.
- Build output static; forms/search/comments подключаются отдельными services.
- Images optimized через build pipeline или external image service.
- SEO fields mandatory для public pages.
- Deploy cache invalidation привязан к content changes.

## Частые ошибки

- Писать custom JS framework поверх static site.
- Нет redirect map после slug changes.
- Markdown content содержит unsafe HTML без policy.
- Не тестировать generated URLs and sitemap.

## Проверка

Проверь build, broken links, sitemap, redirects, RSS, SEO metadata, accessibility and `pwsh tools/site-audit.ps1 -Url <preview-url>`.

## Источники

- [Eleventy Docs](https://www.11ty.dev/docs/)
- [Eleventy homepage](https://www.11ty.dev/)
- См. [Astro](Astro.md), [CMS content](CMS-content.md), [SEO](SEO.md).
