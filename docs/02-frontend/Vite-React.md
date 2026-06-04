---
title: "Vite + React"
category: "frontend"
updated: "2026-06-04"
status: "active"
tags: ["vite", "react", "spa", "typescript"]
source_priority: "official-docs"
---

# Vite + React

Vite + React — быстрый baseline для SPA, embedded apps, internal tools и frontend, который живёт отдельно от API. Он требует явного API contract и не заменяет SSR/SEO framework.

## Когда использовать

- UI после логина, админка, операционный tool, CRM, BI-lite dashboard.
- Backend уже есть и отдаёт OpenAPI/GraphQL contract.
- Нужны быстрый dev server, простой static deploy и client-heavy interaction.
- SEO не является главным каналом привлечения пользователей.

## Когда не использовать

- Landing, blog, docs, каталог и страницы, которые должны индексироваться как основной канал.
- Full-stack product, где выгоднее Server Components, route handlers и unified deploy.
- Приложение с большим количеством серверной персонализации на first render.

## Production-паттерны

- TanStack Query для server state; local state только для UI.
- React Router для routing; protected routes проверяют access server-side через API, не только frontend guard.
- Typed env через `import.meta.env` wrapper и schema validation.
- API client генерируется из OpenAPI или поддерживает typed request/response вручную.
- Bundle splitting для тяжёлых charts/editors/maps; route-level lazy loading.

## Частые ошибки

- `useEffect(fetch)` в каждом компоненте вместо query layer.
- Хранить access token в localStorage без threat-model решения.
- Прятать API contract в ad hoc fetch calls.
- Не тестировать CORS/cookie поведение на preview domains.

## Проверка

```bash
pnpm lint
pnpm typecheck
pnpm test
pnpm build
pnpm exec playwright test
```

Проверяй loading/error/empty/success states, unauthorized flow, slow API, mobile shell и bundle size после добавления тяжёлых библиотек.

## Источники

- [Vite Docs](https://vite.dev/)
- [React Docs](https://react.dev/)
- [TanStack Query](https://tanstack.com/query/latest)
- См. [React SPA + API](../../stacks/react-spa-api.md), [React Router](React-Router.md), [Data fetching](Data-fetching.md).
