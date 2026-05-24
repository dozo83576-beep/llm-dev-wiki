---
title: "Успешное решение: server/client boundary в Next.js"
project_type: "SaaS"
stack: ["Next.js", "React", "TypeScript"]
status: "validated"
date: "2026-05-24"
tags: ["nextjs", "frontend", "performance"]
---

# Контекст

SaaS-dashboard требовал SEO для публичных страниц и быстрый authenticated UI для пользователей.

# Решение

Страницы оставлены Server Components по умолчанию. Client Components выделены только для форм, модалок, interactive tables и browser API.

# Почему сработало

Снизился client bundle, секреты остались на серверной стороне, data fetching стал проще проверять.

# Кодовые и архитектурные паттерны

Повторять паттерн [[../../patterns/frontend/server-client-boundary|server/client boundary]].

# Ограничения

Не подходит для embedded SPA, где весь runtime обязан жить на клиенте.

# Проверка

Typecheck, production build, Playwright smoke для authenticated route, проверка отсутствия server secrets в client bundle.

# Ссылки

[[../../docs/02-frontend/Nextjs|Next.js]], [Next.js App Router](https://nextjs.org/docs/app).

