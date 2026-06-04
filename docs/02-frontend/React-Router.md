---
title: "React Router"
category: "frontend"
updated: "2026-06-04"
status: "active"
tags: ["react-router", "routing", "spa"]
source_priority: "official-docs"
---

# React Router

React Router — routing baseline для React SPA и framework-mode проектов, где URL, nested layouts, loaders/actions и navigation states должны быть явными.

## Когда использовать

- Vite + React SPA с несколькими layout zones, protected pages и nested routes.
- Internal tools, dashboards, embedded apps, где SEO вторичен.
- Нужны route-level code splitting, pending navigation states и error boundaries.
- Команда хочет routing отдельно от Next.js App Router.

## Когда не использовать

- SEO-first сайт: Astro или Next.js даст server-rendered контент проще.
- Full-stack Next.js app, где App Router уже решает layouts, metadata, server data и deploy.
- Простая одноэкранная форма без URL-состояний.

## Production-паттерны

- Route tree проектируется как продуктовая навигация: public, auth, app, admin, settings.
- Protected routes не являются единственной защитой; backend проверяет доступ на каждый запрос.
- Error boundaries размещаются на route/layout уровне, чтобы сбой widget не ломал весь app shell.
- Search params валидируются схемой; filters/sort/pagination отражаются в URL.
- Navigation pending state и scroll restoration проверяются в E2E.

## Частые ошибки

- Делать auth guard только на клиенте и считать API защищённым.
- Хранить filters только в local state, ломая deep links.
- Не иметь 404/permission denied/error route.
- Перерисовывать весь shell при переходе между sibling pages.

## Проверка

Покрывай Playwright сценариями: anonymous redirect, login return URL, permission denied, 404, search params, browser back/forward, mobile nav drawer и failed loader/action response.

## Источники

- [React Router Docs](https://reactrouter.com/)
- См. [Routing](Routing.md), [Vite + React](Vite-React.md), [Frontend testing](Frontend-testing.md), [Authorization](../05-auth-security/Authorization.md).
