---
title: "TanStack Query"
category: "frontend"
updated: "2026-05-24"
status: "active"
tags: ["tanstack-query", "react-query", "server-state", "cache"]
source_priority: "official-docs"
---

# TanStack Query

TanStack Query управляет client-side server state: queries, mutations, cache, invalidation, refetch, optimistic UI и SSR hydration. Это не replacement для domain store и не authorization boundary.

## Когда использовать

- Данные загружаются в browser через API и должны refetch/invalidate без ручного `useEffect`.
- Нужны optimistic updates, infinite/paginated lists, background refetch, retry и cache lifecycle.
- Next.js App Router использует Server Components для initial data, а интерактивная часть живёт на клиенте.

## Когда не использовать

- Static/SEO data лучше получить в Server Component или build-time pipeline.
- Простая форма с server action не требует долгоживущего client cache.
- Sensitive server-only data не должна сериализоваться в client cache.

## Production-паттерны

- Query keys типизируются и строятся из resource + filters + tenant/user scope.
- Mutations в `onSuccess` инвалидируют точные query keys, а не весь cache.
- `staleTime`, retry и refetch policy задаются по типу данных.
- SSR/hydration используется только там, где initial render действительно должен иметь данные.
- Error boundary и empty/loading states проектируются как часть UI contract.

## Частые ошибки

- Использовать TanStack Query как global state store.
- Не включать tenant/user/filter в query key.
- Инвалидировать весь cache после каждой mutation.
- Дублировать один server state между Zustand/Redux и TanStack Query.
- Смешивать Next.js cache revalidation и client query invalidation без явного ownership.

## Проверка

- Unit: query key factory, mapper, optimistic update rollback.
- Integration: mutation invalidates expected keys, error envelope мапится в UI.
- E2E: stale list обновляется после create/update/delete без reload.

## Источники

- [TanStack Query Invalidation](https://tanstack.com/query/latest/docs/framework/react/guides/query-invalidation) — проверено 2026-05-24.
- [TanStack Query Mutations](https://tanstack.com/query/latest/docs/framework/react/guides/mutations) — проверено 2026-05-24.
- [TanStack Query SSR](https://tanstack.com/query/latest/docs/framework/react/guides/ssr) — проверено 2026-05-24.
