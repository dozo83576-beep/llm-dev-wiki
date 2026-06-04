---
title: "Qwik"
category: "frontend"
updated: "2026-06-04"
status: "active"
tags: ["qwik", "performance", "resumability", "frontend"]
source_priority: "official-docs"
---

# Qwik

Qwik — performance-niche framework вокруг resumability: цель снизить hydration cost и запускать JavaScript при необходимости. В wiki это watch doc, а не default recommendation.

## Когда использовать

- Public site/app имеет много интерактива, но first load должен оставаться минимальным.
- Команда готова изучить resumability model and Qwik City routing.
- Performance constraints жёстче, чем удобство React/Vue ecosystem.
- Есть бюджет на framework-specific QA and hiring risk.

## Когда не использовать

- Команда уже продуктивна на Next/Astro/Vite и performance budget достигается проще.
- Нужна широкая ecosystem compatibility, готовые UI kits and integrations.
- Маленький landing можно сделать на Astro без framework risk.
- Enterprise требует mainstream hiring/support.

## Production-паттерны

- Сначала измерь проблему hydration/client JS; Qwik выбирается только при доказанном bottleneck.
- Islands/resumability boundaries проектируются до component implementation.
- Third-party scripts, images and fonts всё равно оптимизируются отдельно.
- Deploy adapter/runtime фиксируется заранее.
- Документируй incompatibilities with existing React/Vue components.

## Частые ошибки

- Выбирать Qwik как “быстрее по умолчанию” без Lighthouse/WebPageTest baseline.
- Недооценивать migration/hiring/tooling cost.
- Использовать heavy third-party scripts and lose performance benefit.
- Не тестировать resume/interactivity path после SSR.

## Security risks

Все server endpoints/actions остаются server-authorized. Client-delayed interactivity не является security boundary.

## Performance risks

Resumability не исправляет large images, slow API, unbounded analytics tags or layout shift. Framework overhead может быть не главным bottleneck.

## Testing strategy

Measure before/after Core Web Vitals, test first interaction latency, Playwright smoke for delayed interactivity, build/deploy adapter check and visual regression for SSR/resumed states.

## Edge cases

Third-party widgets, analytics consent, form resume, browser extension interference, SSR/client mismatch, unsupported component libraries.

## Источники

- [Qwik Docs](https://qwik.dev/docs/)
- См. [Performance](Performance.md), [Frontend blueprints](Frontend-blueprints.md), [Astro](Astro.md).
