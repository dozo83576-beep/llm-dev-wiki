---
title: "Next.js"
category: "frontend"
updated: "2026-05-24"
status: "active"
tags: ["nextjs", "fullstack"]
source_priority: "official-docs"
---

# Next.js

Используй Next.js для full-stack React, SEO, Server Components, API route handlers, layouts и production deploy на Vercel. Не выбирай Next.js, если нужен чистый API без UI или команда не готова к server/client boundary.

Правила: данные по умолчанию получать на сервере, интерактивность изолировать в Client Components, external API оформлять Route Handlers, формы валидировать на серверной границе.

Частые ошибки: перенос всей страницы в `"use client"`, смешивание секретов с клиентским кодом, отсутствие cache/revalidate политики, API без typed validation.

Источник: [Next.js Docs](https://nextjs.org/docs).

## Когда использовать

Выбирай Next.js для SEO, full-stack React, Server Components, dashboards, SaaS, маркетплейсов, e-commerce и сайтов с preview/deploy workflow.

## Когда не использовать

Не выбирай Next.js для API-only backend, embedded SPA без SSR/SEO или команды, которая не готова понимать server/client boundary и caching.

## Production-паттерны

Server Components по умолчанию, Client Components только для интерактивности. Route Handlers для внешних API/webhooks. Metadata, image optimization, cache policy и env validation обязательны.

## Частые ошибки

Глобальный `"use client"`, секреты в client bundle, неявный cache, Route Handler без validation, server action без authorization, отсутствие loading/error states.

## Проверка

`next build`, typecheck, Playwright smoke, проверка protected routes, проверка metadata публичных страниц и отсутствие server-only env в client code.

