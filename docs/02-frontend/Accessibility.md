---
title: "Accessibility"
category: "frontend"
updated: "2026-05-24"
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

## Частые ошибки

Иконка без label, div вместо button, focus trap в модалке без выхода, слабый contrast, error state только цветом, отключенный outline без замены.

## Проверка

Проверь keyboard-only сценарий, axe/Lighthouse, contrast, focus order, модалки, dropdowns и форму с ошибками. Для критичных flow добавь Playwright smoke.

