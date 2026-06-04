---
title: "Visual testing"
category: "testing"
updated: "2026-06-04"
status: "active"
tags: ["visual", "ui", "regression"]
source_priority: "internal"
---

# Visual testing

Visual regression testing ловит то, что не видят unit/integration: ломанный layout, ушедший шрифт, лопнувший grid, исчезнувшая иконка. Скриншоты сравниваются с baseline; человек ревьюит diff.

## Когда использовать

- Дизайн-системы и component libraries.
- Маркетинговые сайты, где визуал — основной продукт.
- Charts / data viz / canvas-компоненты.
- Email templates / PDF generators.

## Когда не использовать

- Высоко-динамичный UI без stable data — суйт превращается в "approve all".
- POC / прототипы с частой переделкой layout.
- A/B экспериментальные варианты, которые скоро удалятся.

## Инструменты

- **Chromatic** (Storybook + хостинг) — лучший вариант для component libraries.
- **Percy** — для full-page screenshots.
- **Playwright + toMatchSnapshot** — встроенный вариант без сервиса.
- **Loki** — Storybook + local.

## Production-паттерны

- Скриншоты для ключевых viewports (mobile / tablet / desktop / large).
- Stable test data: frozen clock, seeded random, fixed images.
- Маскировка/игнорирование динамических областей (timestamps, ads, user avatars).
- Baseline хранится в git (или у сервиса) и ревьюится как код.
- Diff-thresholds: pixel-perfect для critical, soft threshold для остального.
- Темы (light/dark/contrast) покрыты отдельными screenshots.

## Частые ошибки

- Approve all без вчитывания — реальные регрессии прокликиваются мимо.
- Хранить baseline в git LFS-без-LFS — репо распухает.
- Скриншоты в разных runtimes (Linux vs macOS) — антиалиасинг даёт false positives.
- Динамический контент без mask — тест зелёный/красный случайно.

## Performance risks

Большие baseline-наборы замедляют CI и storage; параллельный screenshot run без proper concurrency приводит к OOM.

## Testing strategy

- Storybook stories покрывают каждое состояние компонента (default, hover, error, loading, empty).
- Component-driven development задаёт state matrix before implementation: long text, dark/light, mobile, disabled and destructive states.
- Critical pages (home, pricing, checkout) — отдельный visual job.
- Diff review обязателен в PR — нельзя auto-approve.

## Edge cases

- Web fonts loading: дождаться загрузки перед скриншотом.
- Animations: пауза/disable перед снимком.
- Lazy-loaded images: scroll / await before snapshot.
- iframes / external embeds: маскируются.

## Источники

- [Storybook + Chromatic](https://www.chromatic.com/docs/) — проверено 2026-05-24.
- [Playwright Screenshots](https://playwright.dev/docs/screenshots) — проверено 2026-05-24.
- См. [Component-driven development](../02-frontend/Component-driven-development.md), [Frontend testing](../02-frontend/Frontend-testing.md), [E2E testing](E2E-testing.md), [Design systems](../02-frontend/Design-systems.md).
