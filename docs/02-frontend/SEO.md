---
title: "SEO for web apps"
category: "frontend"
updated: "2026-05-24"
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

## Частые ошибки

- Client-only rendering для SEO-страниц.
- Дублированные title/description.
- Скрытый контент, который не соответствует странице.

Источники: [Google Search Central](https://developers.google.com/search/docs), [Next.js metadata](https://nextjs.org/docs/app/building-your-application/optimizing/metadata).

## Когда использовать

Используй SEO для страниц, которые должны привлекать органический трафик: landing, docs, blog, catalog, marketplace listings, product pages.

## Когда не использовать

SEO не является приоритетом для закрытых dashboard pages, internal admin и authenticated-only tools.

## Проверка

Проверь metadata, canonical, sitemap, robots, heading structure, structured data validity, Core Web Vitals и индексируемость server-rendered контента.

