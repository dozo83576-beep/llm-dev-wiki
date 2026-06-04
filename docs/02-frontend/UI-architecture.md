---
title: "UI architecture"
category: "frontend"
updated: "2026-06-04"
status: "active"
tags: ["ui", "architecture"]
source_priority: "internal"
---

# UI architecture

UI-архитектура определяет, где живут компоненты, состояние, формы, data fetching, layout и доменная логика.

## Production-паттерны

- Разделяй page/container, feature components, shared UI primitives и domain widgets.
- UI primitives не знают о backend API.
- Feature components могут знать о домене, но не должны тащить глобальные side effects.
- Forms имеют schema, default values, submit state и серверные ошибки.
- Route/page component отвечает за composition и data boundary, но не содержит всю бизнес-логику.
- Каждая async zone имеет loading, error, empty и success state до реализации UI.
- Filters, pagination и sort для списков отражаются в URL или query key, чтобы deep links и cache были стабильны.
- Layout primitives задают стабильные размеры для grids, tables, cards, toolbars и sidebars, чтобы hover/loading text не двигали экран.

## Частые ошибки

- Один огромный page component.
- Глобальный store для каждого UI-переключателя.
- Компонент одновременно делает fetch, validation, rendering, routing и analytics.
- Shared UI импортирует domain API или auth session.
- Skeleton/loading state меняет высоту блока и вызывает CLS.
- Form component сам решает permissions, pricing или tenant boundary вместо серверной проверки.

## Проверка

- Component tests для сложных widgets.
- Playwright для ключевых маршрутов.
- Storybook или локальная страница состояний для UI-компонентов, если интерфейс большой.
- Route map review: public/auth/app/admin/settings зоны явно разделены.
- State matrix: loading/error/empty/success/permission denied покрыты для таблиц, форм и карточек.
- Responsive smoke: sidebar, topbar, modals, tables и forms проверены на 360px и desktop.

## Когда использовать

Используй явную UI-архитектуру, когда приложение имеет несколько страниц, reusable components, формы, async data и роли пользователей.

## Когда не использовать

Не вводи тяжелую feature-sliced структуру для маленького одноэкранного prototype. Архитектура должна снижать сложность, а не создавать ее.

## Источники

См. [React](React.md), [Next.js](Nextjs.md), [React Router](React-Router.md), [Vite + React](Vite-React.md), [Design systems](Design-systems.md), [Frontend blueprints](Frontend-blueprints.md).
