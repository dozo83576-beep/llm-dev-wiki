---
title: "SEO for web apps"
category: "frontend"
updated: "2026-06-04"
status: "active"
tags: ["seo", "metadata"]
source_priority: "official-docs"
---

# SEO for web apps

SEO важно для лендингов, контентных сайтов, маркетплейсов и e-commerce. Для закрытых SaaS-dashboard SEO обычно вторично.

## Production-паттерны

- У каждой публичной страницы есть title, description, canonical при необходимости.
- Структура heading логична и не используется только ради размера.
- Sitemap и robots отражают реальные публичные страницы.
- Structured data добавляется только когда соответствует содержимому.
- Core Web Vitals контролируются до релиза.
- Content model фиксирует slug, locale, publish status, updated date, author/organization, OG image и redirect policy.
- Product/category/listing pages серверно рендерят основной контент; фильтры не создают бесконечные indexable URL без canonical/noindex.
- Multi-language pages имеют отдельные URL, `hreflang`, localized metadata и не смешивают языки на одной canonical странице.
- Draft/preview pages закрыты auth, noindex и не кешируются как public.

## Частые ошибки

- Client-only rendering для SEO-страниц.
- Дублированные title/description.
- Скрытый контент, который не соответствует странице.
- Structured data для сущностей, которых нет на странице.
- Менять slug без redirect.
- Индексировать A/B variants, preview, search results или internal filters.

Источники: [Google Search Central](https://developers.google.com/search/docs), [Next.js metadata](https://nextjs.org/docs/app/building-your-application/optimizing/metadata).

## Когда использовать

Используй SEO для страниц, которые должны привлекать органический трафик: landing, docs, blog, catalog, marketplace listings, product pages.

## Когда не использовать

SEO не является приоритетом для закрытых dashboard pages, internal admin и authenticated-only tools.

## Проверка

Проверь metadata, canonical, sitemap, robots, heading structure, structured data validity, Core Web Vitals и индексируемость server-rendered контента. Для контентных сайтов дополнительно проверь preview auth, old slug redirect, OG image, localized URLs и отсутствие duplicate canonicals.

## Источники

- [Google Search Central](https://developers.google.com/search/docs)
- [Next.js metadata](https://nextjs.org/docs/app/building-your-application/optimizing/metadata)
- См. [CMS content](CMS-content.md), [Astro](Astro.md), [Performance](Performance.md), [I18n](I18n.md).
