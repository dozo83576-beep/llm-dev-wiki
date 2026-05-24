---
title: "Frontend routing"
category: "frontend"
updated: "2026-05-24"
status: "active"
tags: ["routing", "nextjs", "react"]
source_priority: "official-docs"
---

# Frontend routing

Routing определяет URL-структуру, навигацию, layouts, protected routes и SEO-поведение. Для Next.js используй App Router; для SPA используй React Router или framework routing.

## Когда использовать

- Next.js App Router: SEO, SSR/RSC, layouts, nested routing, full-stack pages.
- React Router: client-only SPA, embedded tools, internal dashboards без SEO.
- File-based routing: когда команда хочет меньше ручной конфигурации маршрутов.

## Когда не использовать

- Не делай custom router, если framework уже покрывает задачу.
- Не прячь критичное состояние только в memory state, если URL должен быть shareable.

## Production-паттерны

- URL должен отражать ресурс, фильтр или рабочий контекст.
- Protected routes проверяются на сервере, а не только через client redirect.
- Для dashboard-фильтров используй query params.
- 404/403/500 состояния должны быть отдельными UX-сценариями.

## Частые ошибки

- Client-only guard для приватной страницы.
- Нестабильные query params, которые ломают deep link.
- Смешивание route state и server state без правила владения.

## Проверка

- E2E: прямой переход на protected URL не показывает приватные данные.
- E2E: refresh сохраняет фильтры и выбранную вкладку.
- Smoke: 404 и permission denied выглядят осмысленно.

Источники: [Next.js App Router](https://nextjs.org/docs/app), [React Router](https://reactrouter.com/).

