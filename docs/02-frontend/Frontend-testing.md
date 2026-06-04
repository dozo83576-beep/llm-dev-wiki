---
title: "Frontend testing"
category: "frontend"
updated: "2026-06-04"
status: "active"
tags: ["testing", "frontend"]
source_priority: "official-docs"
---

# Frontend testing

Минимум: unit-тесты для чистой логики, component tests для сложных компонентов, [Playwright](../09-testing/Playwright.md) E2E для критических пользовательских путей. Для design-system компонентов добавляй Storybook/component-driven states.

Проверяй не implementation details, а поведение: видимый текст, role, navigation, network outcome, persisted data.

Источники: [Vitest Docs](https://vitest.dev/), [Playwright Docs](https://playwright.dev/).

## Когда использовать

Всегда для production UI. Минимум: unit tests для логики, E2E smoke для критичных маршрутов, accessibility checks для форм и модалок.

## Когда не использовать

Не покрывай каждый пиксель E2E-тестами: это даст медленную и нестабильную suite. Для чистой логики E2E избыточен.

## Production-паттерны

Тестируй поведение через role/text/state, а не внутренние implementation details. Держи fixtures стабильными, network mocks явными, screenshots детерминированными. Component stories должны покрывать state matrix до E2E интеграции.

## Частые ошибки

Проверять CSS-классы вместо результата, делать тесты зависимыми от порядка выполнения, не покрывать error/empty/loading states, заводить stories только для happy path.

## Проверка

CI запускает unit/component tests и [Playwright smoke](../09-testing/Playwright.md). Перед release проверь auth, forms, navigation, permission denied, responsive viewports и visual/story states для критичных компонентов.

## Источники

- [Vitest Docs](https://vitest.dev/)
- [Playwright Docs](https://playwright.dev/)
- См. [Component-driven development](Component-driven-development.md), [Visual testing](../09-testing/Visual-testing.md), [Frontend review checklist](../../checklists/frontend-review.md).
