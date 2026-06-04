---
title: "Design systems"
category: "frontend"
updated: "2026-06-04"
status: "active"
tags: ["design-system", "ui"]
source_priority: "internal"
---

# Design systems

Design system нужен, когда интерфейс должен масштабироваться без визуального распада: tokens, typography, spacing, states, components, accessibility, media rules и responsive behavior.

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
- Typography scale ограничена ролью экрана: hero type только для hero, dashboard/card/sidebar используют плотные размеры.
- Responsive tokens фиксируют grid gaps, max-width, min-width и aspect-ratio для cards, media, tables, toolbar и form rows.
- Media rules описывают image crop, focal point, alt text, poster для video, lazy/eager loading и допустимый page weight.
- Interaction states обязательны: hover, focus-visible, active, disabled, loading, destructive, selected, empty и error.
- Pricing, checkout, CTA и lead form sections имеют отдельные layout recipes, потому что они критичны для conversion и ошибок оплаты.

## Проверка

- Visual smoke для основных экранов.
- Contrast и keyboard navigation.
- Нет карточек внутри карточек и неконтролируемого overflow текста.
- 360px, 768px, 1280px и wide desktop viewport без overlap, clipped labels и непредсказуемого wrapping.
- Long content: длинные имена, email, SKU, translated labels и pricing copy не ломают grid.
- Media audit: hero image/video имеет размеры, оптимизированный формат, fallback и не ухудшает LCP.
- Design tokens используются вместо one-off colors/spacing; palette не распадается между страницами.

## Частые ошибки

Создать набор компонентов без tokens, менять primitives под конкретную страницу, использовать разные spacing шкалы, не документировать destructive/loading/disabled states, делать hero/card/panel с одинаковой типографикой, использовать изображения без размеров и focal point.

## Источники

См. [shadcn/ui](Shadcn.md), [Accessibility](Accessibility.md), [UI architecture](UI-architecture.md), [Frontend blueprints](Frontend-blueprints.md), [semantic text tokens](../../patterns/frontend/semantic-theme-text-tokens.md) и [W3C Design Tokens Community Group](https://www.w3.org/community/design-tokens/).
