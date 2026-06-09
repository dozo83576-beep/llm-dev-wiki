---
title: "Hugo"
category: "frontend"
updated: "2026-06-10"
status: "active"
tags: ["hugo", "static-site", "docs", "go"]
source_priority: "official-docs"
---

# Hugo

Hugo — быстрый Go-based static site generator для больших docs/blog/content сайтов, где build speed, taxonomy and static output важнее JavaScript framework ecosystem.

## Когда использовать

- Большой docs/content site с тысячами страниц, taxonomy, multilingual content and fast builds.
- Команда принимает Go templating and Hugo content model.
- Нужен static output для CDN/simple hosting.
- Интерактивность минимальна или подключается отдельными widgets.

## Когда не использовать

- Нужны React/Vue/Svelte components as first-class authoring model.
- Marketing team требует visual builder/CMS.
- Нужен full-stack app, auth, dashboard or checkout.
- Команда не готова к Hugo templates/modules learning curve.

## Production-паттерны

- Разделяй content, layouts, partials, shortcodes and assets.
- Используй taxonomy/menu/section rules вместо ручной навигации.
- Images/assets проходят Hugo Pipes или external pipeline.
- Multilingual routing and canonical/hreflang проверяются автоматически.
- Theme/modules pinned and reviewed.

## Частые ошибки

- Ставить Hugo, если нужен app framework.
- Завязывать критичный контент на theme без ownership.
- Не тестировать broken links and generated aliases.
- Shortcodes превращают content в непроверяемый HTML.

## Проверка

Проверь build time, broken links, aliases/redirects, sitemap, RSS, hreflang, image output, accessibility and site audit на preview.

## Источники

- [Hugo Docs](https://gohugo.io/documentation/)
- [Hugo homepage](https://gohugo.io/)
- См. [Eleventy](Eleventy.md), [Astro](Astro.md), [SEO](SEO.md).
