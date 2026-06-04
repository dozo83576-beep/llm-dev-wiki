---
title: "Astro"
category: "frontend"
updated: "2026-06-04"
status: "active"
tags: ["astro", "ssg", "content", "landing"]
source_priority: "official-docs"
---

# Astro

Astro — default choice для быстрых статических landing, marketing sites, docs, blogs и контентных сайтов, где JavaScript должен попадать на клиент только для реальных islands интерактива.

## Когда использовать

- Landing, docs, blog, changelog, портфолио, content hub, SEO pages.
- Нужны SSG, Markdown/MDX content collections, image optimization и минимальный JS.
- Формы отправляются в serverless endpoint, CRM, email provider или backend API.
- React/Vue/Svelte islands нужны точечно: калькулятор, carousel, pricing toggle, search.

## Когда не использовать

- Продуктовый dashboard с большим количеством client state, protected routes и realtime widgets.
- Full-stack SaaS с server actions, complex auth и shared database logic: выбирай Next.js.
- API-only backend или long-running workers.

## Production-паттерны

- Статика по умолчанию; SSR включай только для страниц с персонализацией или runtime content.
- Content collections валидируются схемой; slug, title, description, canonical и OG image обязательны для SEO pages.
- Islands держи маленькими; не превращай всю страницу в React SPA.
- Images: фиксированные размеры, lazy loading ниже first viewport, AVIF/WebP, отдельный mobile crop для hero.
- Forms: honeypot, rate limit, server validation, fallback message, notification retry.

## Частые ошибки

- Тянуть React runtime ради простого accordion.
- Делать один общий layout без per-page metadata.
- Публиковать Markdown без схемы и проверки broken links.
- Использовать hero video без poster, dimensions и reduced-motion fallback.

## Проверка

```bash
pnpm astro check
pnpm build
pnpm exec playwright test
```

Дополнительно: Lighthouse performance >= 90, a11y >= 95, SEO >= 95; проверить sitemap, robots, canonical, structured data и mobile 360px viewport.

## Источники

- [Astro Docs](https://docs.astro.build/)
- [Astro Content Collections](https://docs.astro.build/en/guides/content-collections/)
- См. [Landing playbook](../13-playbooks/landing.md), [CMS content](CMS-content.md), [Performance](Performance.md), [SEO](SEO.md).
