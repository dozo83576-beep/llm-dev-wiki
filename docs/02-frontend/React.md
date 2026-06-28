---
title: "React"
category: "frontend"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["react", "ui"]
source_priority: "official-docs"
---

# React

Используй React для компонентного UI, сложных интерактивных интерфейсов и экосистемы Next.js/Vite. Не используй React для простого статического сайта, если Astro или чистый HTML решают задачу быстрее.

Паттерны: маленькие компоненты, controlled forms для сложных форм, composition вместо глубокого наследования, Server Components в Next.js там, где не нужна интерактивность.

Production checklist: typed props, error boundaries для рискованных зон, accessibility labels, отсутствие лишних глобальных состояний, тесты ключевых пользовательских сценариев.

Источник: [React Docs](https://react.dev/).

## Когда использовать

Используй React для интерактивных интерфейсов, dashboards, форм, rich UI, design systems и приложений, где component composition дает реальную выгоду.

## Когда не использовать

Не используй React как автоматический выбор для простого статического сайта, документации без интерактива или landing page, где Astro/HTML быстрее и проще.

## Production-паттерны

Компоненты маленькие, props typed, side effects изолированы, server state не смешивается с local UI state. Composition предпочтительнее глубокого prop drilling и глобального store.

## Частые ошибки

Хранить derived state, использовать global store для local UI, делать fetch в каждом компоненте, забывать cleanup effects, игнорировать accessibility.

## Проверка

Unit tests для logic hooks, component tests для сложных widgets, Playwright для user journeys, React profiler для подозрительных rerenders.

