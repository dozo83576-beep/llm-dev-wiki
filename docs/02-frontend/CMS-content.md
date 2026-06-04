---
title: "CMS and content sites"
category: "frontend"
updated: "2026-06-04"
status: "active"
tags: ["cms", "content", "seo", "astro", "nextjs"]
source_priority: "mixed"
---

# CMS and content sites

Content site — это не просто страницы с текстом. Production-риск в том, что SEO, preview, редакторский workflow, structured data и cache invalidation становятся частью продукта.

Если вопрос звучит как "как выбрать CMS для контентного сайта", начни здесь: выбор между filesystem content, code-first CMS, vendor headless CMS и product database определяется редакторским workflow, preview, SEO, media and ownership.

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
- См. [Payload CMS](Payload-CMS.md), [SEO](SEO.md), [Astro](Astro.md), [Performance](Performance.md), [I18n](I18n.md).
