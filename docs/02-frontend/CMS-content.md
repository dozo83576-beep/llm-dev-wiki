---
title: "CMS and content sites"
category: "frontend"
updated: "2026-06-10"
status: "active"
tags: ["cms", "content", "seo", "astro", "nextjs"]
source_priority: "mixed"
---

# CMS and content sites

Content site — это не просто страницы с текстом. Production-риск в том, что SEO, preview, редакторский workflow, structured data и cache invalidation становятся частью продукта.

Если вопрос звучит как "как выбрать CMS для контентного сайта", начни здесь: выбор между filesystem content, code-first CMS, vendor headless CMS, WordPress/Webflow и product database определяется редакторским workflow, preview, SEO, media and ownership.

## Когда использовать

- Blog, docs, help center, product pages, resource hub, newsroom, localized marketing site.
- Контент редактируют не только разработчики.
- Нужны draft preview, scheduled publish, media library, redirects и structured data.
- Органический трафик является частью бизнес-модели.

## Когда не использовать

- Одноразовый landing без редакторов: Astro content collections или статический Markdown проще.
- Закрытый dashboard после логина: CMS добавит лишнюю поверхность риска.
- Контент полностью генерируется из product database: лучше строить domain pages напрямую.

## Production-паттерны

- Выбери источник правды: filesystem content, headless CMS или product database. Не смешивай их без явного ownership.
- У каждой публичной страницы есть title, description, canonical, OG image, sitemap entry и redirect policy.
- Draft preview требует auth и не должен индексироваться.
- Cache invalidation привязана к publish событию: revalidate path/tag, webhook или rebuild.
- Media pipeline проверяет dimensions, alt text, compression, license and focal point.
- Payload CMS — code-first вариант, когда schema/access/hooks должны жить рядом с Next.js/TypeScript кодом.
- WordPress — вариант для существующего редакторского workflow, block themes, plugin ecosystem or headless legacy CMS.
- Strapi — self-hosted headless CMS, когда нужна админка и content API под контролем команды.
- Sanity — hosted structured content and visual editing, когда editorial UX важнее self-hosting.
- Directus — SQL-first CMS/data platform, когда database schema должна оставаться source of truth.
- Webflow — visual builder для marketing teams, не для custom product logic.
- Vendor CMS выбирай, если важнее редакторский workflow и SLA, чем полный code ownership.

## Частые ошибки

- Давать редакторам HTML без sanitization.
- Не иметь redirect map после изменения slug.
- Кешировать preview как public content.
- Делать structured data, не соответствующую видимому содержимому.

## Проверка

Проверь publish/unpublish, preview auth, slug collision, redirect from old slug, sitemap/robots, canonical, structured data validator, image alt text, localized hreflang и Lighthouse SEO.

## Источники

- [Google Search Central](https://developers.google.com/search/docs)
- [Astro Content Collections](https://docs.astro.build/en/guides/content-collections/)
- [Next.js CMS examples](https://nextjs.org/docs)
- См. [Payload CMS](Payload-CMS.md), [WordPress](WordPress.md), [Strapi](Strapi.md), [Sanity](Sanity.md), [Directus](Directus.md), [Webflow](Webflow.md), [SEO](SEO.md), [Astro](Astro.md), [Performance](Performance.md), [I18n](I18n.md).
- Паттерн: [Static site + dev-only CMS behind build flag](../../patterns/frontend/static-site-dev-only-cms-flag.md) — как держать Keystatic/Tina для редактирования, не ломая статический prerender.
