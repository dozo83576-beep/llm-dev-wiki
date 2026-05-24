---
title: "State management"
category: "frontend"
updated: "2026-05-24"
status: "active"
tags: ["state", "react"]
source_priority: "official-docs"
---

# State management

Не выноси состояние в глобальный store без причины. Выбор:

- local state: UI-переключатели, формы, модалки;
- URL state: фильтры, пагинация, вкладки, shareable состояние;
- TanStack Query: server state, cache, refetch, mutations;
- Zustand/Jotai: небольшое глобальное client state;
- Redux Toolkit: сложные приложения с строгим predictable flow.

Источник: [TanStack Query Docs](https://tanstack.com/query/latest/docs/framework/react/overview), [Redux Toolkit Docs](https://redux-toolkit.js.org/).

## Когда использовать

Выбирай state tool по типу состояния: local UI, URL state, server state, глобальное client state или сложный predictable workflow.

## Когда не использовать

Не добавляй Redux/Zustand/Jotai до появления реальной shared state проблемы. Большая часть состояния должна жить локально, в URL или в server cache.

## Production-паттерны

Server state — через TanStack Query или framework data fetching. URL state — для shareable filters. Global store — только для cross-cutting UI/session state.

## Частые ошибки

Дублировать server data в global store, не инвалидировать cache, хранить sensitive data в persisted client store, делать URL несинхронизированным с фильтрами.

## Проверка

Unit tests для reducers/selectors, E2E для refresh/deep link, integration tests для query invalidation после mutation.

