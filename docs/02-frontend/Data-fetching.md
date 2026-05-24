---
title: "Frontend data fetching"
category: "frontend"
updated: "2026-05-24"
status: "active"
tags: ["data-fetching", "nextjs", "server-state"]
source_priority: "official-docs"
---

# Frontend data fetching

Data fetching должен иметь явное место: Server Components, Route Handlers, server actions, TanStack Query или API client. Главный риск — неочевидный cache и дублирование источников правды.

## Когда использовать

- Server Components: initial page data, SEO, sensitive server-side data.
- TanStack Query: client-side server state, refetch, optimistic updates.
- Route Handlers: external clients, webhooks, BFF endpoints.

## Когда не использовать

- Не делай `useEffect(fetch)` для initial page data в Next.js без причины.
- Не клади секреты в client-side fetch.

## Production-паттерны

- У каждого запроса есть cache/revalidate policy.
- Ошибки API мапятся в понятные UI-состояния.
- Mutations инвалидируют только нужные queries.
- Sensitive data не попадает в serialized client props.

## Проверка

- Unit: mappers и error normalization.
- Integration: API contract.
- E2E: loading/error/empty/success состояния.

## Частые ошибки

Дублировать один server state в нескольких stores, делать initial fetch через `useEffect` без причины, не задавать cache policy, смешивать sensitive server data с client props, не инвалидировать данные после mutation.

Источник: [Next.js data fetching](https://nextjs.org/docs/app/building-your-application/data-fetching), [TanStack Query](https://tanstack.com/query/latest/docs/framework/react/overview).
