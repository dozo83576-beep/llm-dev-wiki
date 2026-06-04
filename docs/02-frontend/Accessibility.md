---
title: "Accessibility"
category: "frontend"
updated: "2026-05-27"
status: "active"
tags: ["a11y", "ux"]
source_priority: "official-docs"
---

# Accessibility

Доступность — часть качества, а не отдельная опция. Проверяй keyboard navigation, focus states, labels, contrast, semantic HTML, error announcements.

Минимальный стандарт: WCAG 2.2 AA для публичных интерфейсов и критичных рабочих инструментов.

Источник: [WCAG 2.2](https://www.w3.org/TR/WCAG22/).

## Когда использовать

Всегда для публичных страниц, SaaS-интерфейсов, админок, форм, checkout и рабочих панелей. Доступность особенно критична там, где пользователь должен завершить задачу без мыши или с assistive technologies.

## Когда не использовать

Не откладывай accessibility “на финальный polish”: поздняя правка семантики, focus order и клавиатурной навигации обычно дороже, чем правильная реализация сразу.

## Production-паттерны

Используй semantic HTML, явные labels, visible focus, keyboard navigation, aria только когда семантики HTML недостаточно. Ошибки форм должны быть связаны с полями и объявляться screen reader.

Для страниц со смешанными светлыми и темными секциями проверяй фактический `computedStyle.color` у выбранных элементов и contrast ratio с реальным фоном. CSS-переменная с хорошим названием не гарантирует контраст, если она наследуется из другой поверхности.

## Частые ошибки

Иконка без label, div вместо button, focus trap в модалке без выхода, слабый contrast, error state только цветом, отключенный outline без замены, один глобальный `--text` для темных и светлых поверхностей.

## Проверка

Проверь keyboard-only сценарий, axe/Lighthouse, contrast, focus order, модалки, dropdowns и форму с ошибками. Для критичных flow добавь Playwright smoke; для визуально спорных элементов измеряй computed color и contrast ratio.

Связанный паттерн: [Semantic theme text tokens](../../patterns/frontend/semantic-theme-text-tokens.md).
