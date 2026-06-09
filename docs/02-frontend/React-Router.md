---
title: "React Router"
category: "frontend"
updated: "2026-06-10"
status: "active"
tags: ["react-router", "routing", "spa"]
source_priority: "official-docs"
---

# React Router

React Router — routing baseline для React SPA и framework-mode проектов, где URL, nested layouts, loaders/actions и navigation states должны быть явными. В v7 он также закрывает Remix-style framework mode: SSR, pre-rendering, streaming, loaders/actions and route typegen.

## Когда использовать

- Vite + React SPA с несколькими layout zones, protected pages и nested routes.
- Internal tools, dashboards, embedded apps, где SEO вторичен.
- Нужны route-level code splitting, pending navigation states и error boundaries.
- Команда хочет routing отдельно от Next.js App Router.
- Нужен React Router Framework как successor/upgrade path для Remix-style apps.

## Когда не использовать

- SEO-first сайт: Astro или Next.js даст server-rendered контент проще.
- Full-stack Next.js app, где App Router уже решает layouts, metadata, server data и deploy.
- Нужны Server Components/App Router conventions или Vercel-first Next.js platform features.
- Простая одноэкранная форма без URL-состояний.

## Production-паттерны

- Route tree проектируется как продуктовая навигация: public, auth, app, admin, settings.
- Protected routes не являются единственной защитой; backend проверяет доступ на каждый запрос.
- Error boundaries размещаются на route/layout уровне, чтобы сбой widget не ломал весь app shell.
- Search params валидируются схемой; filters/sort/pagination отражаются в URL.
- Navigation pending state и scroll restoration проверяются в E2E.
- Framework mode выбирай только если нужны server rendering, loaders/actions, pre-rendering or streaming; иначе Vite SPA + declarative/data mode проще.
- Remix migration фиксируй как dependency/import/codemod task, не как переписывание архитектуры.

## Частые ошибки

- Делать auth guard только на клиенте и считать API защищённым.
- Хранить filters только в local state, ломая deep links.
- Не иметь 404/permission denied/error route.
- Перерисовывать весь shell при переходе между sibling pages.
- Считать React Router Framework полной заменой Next.js без проверки metadata, cache, deploy and server runtime constraints.

## Проверка

Покрывай Playwright сценариями: anonymous redirect, login return URL, permission denied, 404, search params, browser back/forward, mobile nav drawer, failed loader/action response, SSR response and hydration.

## Источники

- [React Router Docs](https://reactrouter.com/)
- [React Router modes](https://reactrouter.com/start/modes)
- [Upgrading from Remix](https://reactrouter.com/upgrading/remix)
- См. [Routing](Routing.md), [Vite + React](Vite-React.md), [Frontend testing](Frontend-testing.md), [Shopify Hydrogen](../13-playbooks/shopify-hydrogen.md), [Authorization](../05-auth-security/Authorization.md).
