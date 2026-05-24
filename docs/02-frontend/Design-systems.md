---
title: "Design systems"
category: "frontend"
updated: "2026-05-24"
status: "active"
tags: ["design-system", "ui"]
source_priority: "internal"
---

# Design systems

Design system нужен, когда интерфейс должен масштабироваться без визуального распада: tokens, typography, spacing, states, components, accessibility.

## Когда использовать

- Несколько страниц или продуктов.
- Команда часто добавляет UI.
- Нужна стабильная визуальная система.

## Когда не использовать

- Не строй тяжелую design system для одноэкранного прототипа.
- Не копируй чужую систему без адаптации под домен.

## Production-паттерны

- Design tokens: color, spacing, typography, radius, shadow.
- Компоненты имеют variants и states.
- Accessibility встроена в primitives.
- Документируй, где использовать каждый компонент.

## Проверка

- Visual smoke для основных экранов.
- Contrast и keyboard navigation.
- Нет карточек внутри карточек и неконтролируемого overflow текста.

