---
title: "Успешное решение: server/client boundary в Next.js"
category: "case-study"
updated: "2026-05-24"
status: "validated"
tags: ["nextjs", "frontend", "performance"]
source_priority: "mixed"
date: "2026-05-24"
project_type: "SaaS"
stack: ["Next.js", "React", "TypeScript"]
---

# Контекст

SaaS-dashboard требовал SEO для публичных страниц и быстрый authenticated UI для пользователей.

# Решение

Страницы оставлены Server Components по умолчанию. Client Components выделены только для форм, модалок, interactive tables и browser API.

# Почему сработало

Снизился client bundle, секреты остались на серверной стороне, data fetching стал проще проверять.

# Кодовые и архитектурные паттерны

Повторять паттерн [server/client boundary](../../patterns/frontend/server-client-boundary.md).

# Ограничения

Не подходит для embedded SPA, где весь runtime обязан жить на клиенте.

# Проверка

Typecheck, production build, Playwright smoke для authenticated route, проверка отсутствия server secrets в client bundle.

# Ссылки

[Next.js](../../docs/02-frontend/Nextjs.md), [Next.js App Router](https://nextjs.org/docs/app).
