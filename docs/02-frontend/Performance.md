---
title: "Frontend performance"
category: "frontend"
updated: "2026-05-24"
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

## Частые ошибки

Большие hero images без размеров, тяжелые client библиотеки, analytics scripts без контроля, waterfall запросов, rerender больших таблиц.

## Проверка

Lighthouse/WebPageTest для публичных страниц, bundle analyzer при росте bundle, Playwright smoke на slow network для ключевых flows.

