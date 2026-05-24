---
title: "UI architecture"
category: "frontend"
updated: "2026-05-24"
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

## Частые ошибки

- Один огромный page component.
- Глобальный store для каждого UI-переключателя.
- Компонент одновременно делает fetch, validation, rendering, routing и analytics.

## Проверка

- Component tests для сложных widgets.
- Playwright для ключевых маршрутов.
- Storybook или локальная страница состояний для UI-компонентов, если интерфейс большой.

## Когда использовать

Используй явную UI-архитектуру, когда приложение имеет несколько страниц, reusable components, формы, async data и роли пользователей.

## Когда не использовать

Не вводи тяжелую feature-sliced структуру для маленького одноэкранного prototype. Архитектура должна снижать сложность, а не создавать ее.

## Источники

См. [[React|React]], [[Nextjs|Next.js]], [[Design-systems|Design systems]].

