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

