---
title: "Accessibility testing"
category: "testing"
updated: "2026-05-24"
status: "active"
tags: ["a11y", "testing", "wcag"]
source_priority: "official-docs"
---

# Accessibility testing

Accessibility testing сочетает automated checks (быстро, шумно, ловят ~30% проблем) и ручную проверку клавиатурой / screen-reader. Цель — пройти WCAG 2.2 AA на критичных user-journey.

## Когда использовать

- Любой публичный продукт, особенно B2C и государственный сектор.
- Любой интерфейс с формами, таблицами, динамическим контентом.
- Команды с обязательством по a11y (legal/compliance).

## Когда не использовать

- Internal admin-tools без формальных требований (но всё равно проверять keyboard-навигацию).
- POC / прототипы — не блокируем, фиксируем для итерации.

## Что проверять (минимум)

- **Semantic HTML**: правильные landmarks (`main`, `nav`), heading hierarchy (h1 → h2 → h3 без скачков).
- **Keyboard navigation**: весь функционал доступен с клавиатуры, focus order логичен, нет focus-trap без выхода.
- **Focus visible**: видимая фокус-рамка не выключена через `outline: none` без замены.
- **Labels & errors**: каждый input имеет `<label>` или `aria-label`; error messages связаны через `aria-describedby`.
- **Contrast**: текст ≥ 4.5:1 (AA), крупный текст ≥ 3:1, UI-компоненты ≥ 3:1.
- **Reduced motion**: учитывать `prefers-reduced-motion`, анимации отключаемы.
- **Screen reader**: критичный flow проходится с VoiceOver / NVDA без неоднозначностей.

## Production-паттерны

- Автоматические тесты с **axe-core** / `@axe-core/playwright` / Storybook a11y addon.
- A11y-проверки в CI как required check на критичных страницах.
- Manual a11y review в DoR (Definition of Ready) для UI-фичей.
- Linter `eslint-plugin-jsx-a11y` на frontend.
- Дизайн-система имеет accessible-by-default компоненты (radix, react-aria).

## Частые ошибки

- Использовать `<div onClick>` вместо `<button>` — нет keyboard / ARIA по умолчанию.
- Placeholder как замена label.
- Color-only state (только цвет говорит "ошибка") — slепые увидят дублирование иконкой/текстом.
- Auto-focus без понимания контекста — ломает screen reader flow.
- Динамический контент без `aria-live` — screen reader не объявляет изменения.

## Security/UX risks

Captcha без accessible-альтернативы блокирует пользователей. Modal без focus-trap утечка фокуса в фоновый контент.

## Testing strategy

- Automated axe-scan на каждый PR (cover критичных страниц).
- Manual keyboard-only прогон критичных flow раз в спринт.
- Screen-reader тест на ключевых релизах (NVDA на Windows, VoiceOver на macOS/iOS).
- Lighthouse a11y score как baseline.

## Edge cases

- Charts / SVG: нужны текстовые альтернативы / data tables.
- Toasts / notifications: `role="status"` / `role="alert"`.
- Multi-step forms: progress announcement, ошибки прокручиваются в фокус.
- RTL и locale-зависимые компоненты.

## Источники

- [WCAG 2.2](https://www.w3.org/TR/WCAG22/) — проверено 2026-05-24.
- [axe DevTools](https://www.deque.com/axe/devtools/) — проверено 2026-05-24.
- [WAI-ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/) — проверено 2026-05-24.
- См. [Accessibility](../02-frontend/Accessibility.md), [E2E testing](E2E-testing.md), [frontend-review checklist](../../checklists/frontend-review.md).
