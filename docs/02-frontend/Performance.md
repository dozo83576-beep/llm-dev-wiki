---
title: "Frontend performance"
category: "frontend"
updated: "2026-06-10"
status: "active"
tags: ["performance", "frontend"]
source_priority: "official-docs"
---

# Frontend performance

Проверяй Core Web Vitals, размер bundle, lazy loading, image optimization, cache policy, серверную загрузку данных и waterfall запросов.

Правила: не тащи тяжелые библиотеки в client bundle без причины, используй server-side rendering для SEO, измеряй Lighthouse/WebPageTest до и после оптимизаций.

Источники: [web.dev Core Web Vitals](https://web.dev/articles/vitals), [Next.js Image Optimization](https://nextjs.org/docs/app/building-your-application/optimizing/images).

## Когда использовать

Performance budget нужен для всех публичных страниц, checkout, onboarding, dashboards с таблицами и AI-интерфейсов с потоковыми ответами.

## Когда не использовать

Не оптимизируй вслепую. Если нет измерения, сначала добавь Lighthouse/WebPageTest/production metrics.

## Production-паттерны

Оптимизируй изображения, шрифты, critical CSS, server data fetching, cache, bundle splitting и third-party scripts. Для dashboards измеряй table rendering и filtering.

- Public pages: LCP < 2.5s, CLS < 0.1, INP < 200ms как baseline; для landing желательно LCP < 2s.
- Hero media: explicit dimensions, correct mobile crop, AVIF/WebP, `fetchpriority="high"` только для LCP image, poster для video.
- Fonts: self-host или trusted provider, `font-display: swap`, ограничить weights/styles.
- JavaScript: islands или lazy loading для charts, maps, editors, carousels, chat widgets.
- Third-party scripts: load after consent/interaction where possible, measure GTM/chat/analytics cost separately.
- Dashboards: virtualize large tables only when needed; сначала проверь pagination, server filtering и memoized cell rendering.

## Частые ошибки

Большие hero images без размеров, тяжелые client библиотеки, analytics scripts без контроля, waterfall запросов, rerender больших таблиц, skeleton с другой высотой, lazy loading LCP image, одинаковый desktop crop на mobile.

## Проверка

Lighthouse/WebPageTest для публичных страниц, bundle analyzer при росте bundle, Playwright smoke на slow network для ключевых flows. Перед handoff можно запустить `pwsh tools/site-audit.ps1 -Url <url>`: он сохранит Lighthouse HTML/JSON и проверит базовые headers. Проверяй at least mobile 360px, throttled network, first viewport screenshot, page weight, JS transferred, image weight и long tasks.

## Источники

- [web.dev Core Web Vitals](https://web.dev/articles/vitals)
- [Next.js Image Optimization](https://nextjs.org/docs/app/building-your-application/optimizing/images)
- См. [Astro](Astro.md), [Frontend blueprints](Frontend-blueprints.md), [Visual testing](../09-testing/Visual-testing.md), [Site audit tooling](../09-testing/Site-audit-tooling.md).
