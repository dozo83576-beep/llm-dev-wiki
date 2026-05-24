---
title: "shadcn/ui"
category: "frontend"
updated: "2026-05-24"
status: "active"
tags: ["shadcn", "ui"]
source_priority: "official-docs"
---

# shadcn/ui

Используй shadcn/ui для доступных UI-примитивов, которые можно владеть в кодовой базе. Это не npm-компонентная библиотека в классическом смысле: код компонентов копируется в проект и становится частью приложения.

Правила: не менять базовые компоненты хаотично, выносить доменные варианты отдельно, сохранять accessibility props.

Источник: [shadcn/ui Docs](https://ui.shadcn.com/docs).

## Когда использовать

Используй shadcn/ui, когда нужна owned component base, совместимая с Tailwind, accessibility primitives и быстрая сборка SaaS/admin UI.

## Когда не использовать

Не используй shadcn/ui как неизменяемую black-box библиотеку. Если команда не готова владеть кодом компонентов, выбери managed UI kit.

## Production-паттерны

Базовые primitives держи стабильными, доменные variants выноси отдельно, tokens централизуй, destructive/loading/disabled states проектируй явно.

## Частые ошибки

Редактировать primitives под одну страницу, ломать accessibility props, плодить несовместимые variants, смешивать design tokens и random values.

## Проверка

Visual smoke, keyboard navigation, contrast, form states, modal focus trap, responsive проверка сложных components.

