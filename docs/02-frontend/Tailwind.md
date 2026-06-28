---
title: "Tailwind CSS"
category: "frontend"
updated: "2026-06-22"
status: "active"
tags: ["tailwind", "css"]
source_priority: "official-docs"
---

# Tailwind CSS

Используй Tailwind для быстрых, согласованных интерфейсов с design tokens. Не используй как замену дизайну: spacing, typography, states и responsive behavior должны быть спроектированы.

Правила: компоненты выделять при повторении, не плодить произвольные значения без причины, хранить цвета и радиусы в теме, проверять мобильные размеры.

Источник: [Tailwind CSS Docs](https://tailwindcss.com/docs). Freshness note: `tailwindcss` 4.3.1 — patch release with CLI, `@apply`, `@source`, Vite sourcemap and scanner fixes; guidance unchanged.

## Когда использовать

Используй Tailwind для быстрых production UI, где команда готова работать через tokens, utility classes и component extraction.

## Когда не использовать

Не используй Tailwind как замену UI-архитектуре. Если дизайн требует строгого enterprise design system с готовыми компонентами, одного Tailwind мало.

## Production-паттерны

Повторяемые композиции выноси в компоненты, tokens держи в config/theme, arbitrary values ограничивай, responsive states проверяй на реальных viewport.

## Частые ошибки

Копипастить длинные className без компонента, использовать случайные цвета/spacing, не учитывать dark mode, hover-only interactions на touch devices.

## Проверка

Visual review, responsive smoke, contrast, отсутствие overflow текста, отсутствие one-off palette drift.

## Источники

- [Tailwind CSS Docs](https://tailwindcss.com/docs) — refreshed against `tailwindcss` 4.3.1 on 2026-06-22.
- См. [Styling systems](Styling-systems.md), [Design systems](Design-systems.md).
