---
title: "Component-driven development"
category: "frontend"
updated: "2026-07-21"
status: "active"
tags: ["storybook", "components", "visual-testing", "design-system"]
source_priority: "official-docs"
---

# Component-driven development

Component-driven development строит UI через изолированные component states before pages: stories, variants, interaction tests, visual regression and accessibility checks.

## Когда использовать

- Есть design system, reusable widgets, complex forms, tables, cards, pricing, checkout or dashboards.
- Команда часто меняет UI и хочет видеть states до интеграции в route.
- Нужны component tests, visual snapshots, accessibility checks and design review.
- UI генерируется LLM/агентом и нужен state matrix для проверки качества.

## Когда не использовать

- Одноразовая страница без reusable components and production lifecycle.
- Команда не будет поддерживать stories after feature delivery.
- Компонент зависит от full app state, который нельзя стабильно замокать.

## Production-паттерны

- Для каждого сложного компонента есть stories: default, loading, empty, error, disabled, long text, mobile, dark/light.
- Stories используют stable fixtures, not production secrets or live APIs.
- Interaction tests покрывают keyboard, validation, submit, open/close and destructive confirmation.
- Visual tests запускаются для critical UI states, not every tiny component.
- Storybook docs connect component usage rules with design tokens.

## Частые ошибки

- Stories показывают только happy path.
- Моки отличаются от реального API contract.
- Visual snapshots флейкуют из-за random data, animations or current date.
- Storybook становится отдельной витриной, не связанной с app components.

## Security risks

Не публикуй Storybook с внутренними данными, PII, token examples or admin-only flows без auth. Fixtures должны быть synthetic.

## Performance risks

Storybook не заменяет page performance checks. Тяжёлые components должны тестироваться и в реальном route, потому что layout, fonts, images and data waterfalls видны только там.

## Testing strategy

Storybook component/interaction tests, axe checks, visual regression for selected states, Playwright E2E for integrated user journeys, screenshot review for responsive breakpoints.

## Edge cases

Theming, localization, long content, reduced motion, high contrast mode, async race after interaction, portal/modal focus, virtualized tables.

## Источники

- [Storybook UI testing](https://storybook.js.org/docs/writing-tests) — `storybook` 10.5.3 reviewed 2026-07-21; component-testing guidance unchanged.
- [Storybook component testing](https://storybook.js.org/docs/8/writing-tests/component-testing)
- См. [Design systems](Design-systems.md), [Frontend testing](Frontend-testing.md), [Visual testing](../09-testing/Visual-testing.md), [Frontend review checklist](../../checklists/frontend-review.md).
