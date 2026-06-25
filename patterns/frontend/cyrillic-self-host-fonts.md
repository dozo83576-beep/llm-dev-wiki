---
title: "Pattern: Cyrillic / self-host fonts"
category: "patterns"
updated: "2026-06-19"
status: "active"
tags: ["frontend", "fonts", "cyrillic", "i18n", "performance"]
source_priority: "internal"
area: "frontend"
date: "2026-06-19"
---

# Cyrillic / self-host fonts

## Назначение

Паттерн предотвращает «tofu» (квадраты вместо букв) и пропадание текста, когда премиум-шрифт не поддерживает кириллицу или не прогружается по региону. Особенно критично для СНГ-аудитории и условно-бесплатных display-гарнитур, которые часто латиница-онли.

## Когда использовать

- Сайт с кириллическим контентом и подобранным под нишу display-шрифтом.
- Аудитория в регионах, где сторонние CDN (Google Fonts) могут резаться или тормозить.
- Любая продакшен-страница, где первый экран не должен моргать или сыпаться в системный шрифт.

## Когда не использовать

- Прототип/демо латиницей, который не уйдёт в прод.
- Уже настроенный self-host пайплайн с проверенным шрифтом — не усложняй повторно.

## Production-паттерны

- **Проверь поддержку кириллицы ДО выбора.** Многиe condensed / дисплейные гарнитуры покрывают только латиницу. Открой набор глифов (на странице шрифта или в инструменте), убедись, что есть Cyrillic-subset.
- **Self-host для прода / СНГ.** Зашивай шрифт локально (`@font-face` с локальными `.woff2`), не полагайся на Google Fonts CDN — он может не прогрузиться по региону и упасть в системный.
- **Subset по `unicode-range`.** Грузи отдельный кириллический subset, чтобы не тянуть лишние глифы.
- **Качай оба subset: `latin` И `cyrillic`.** Кириллический subset Fontsource НЕ
  содержит цифр и базовой латиницы (его `unicode-range` ≈ `U+0301, U+0400-045F,
  U+0490-0491, U+04B0-04B1, U+2116`). Если положить только его, цифры (телефон,
  цены), латинские слова и пунктуация свалятся в системный фолбэк → разнобой
  шрифтов. Бери оба файла на каждое начертание и объяви по два `@font-face` с
  соответствующими `unicode-range`. Источник весов:
  `https://cdn.jsdelivr.net/fontsource/fonts/<family>@latest/<subset>-<weight>-normal.woff2`
  (subset = `latin` и `cyrillic`).
- **`font-display: swap`** — текст виден сразу системным фолбэком, затем подменяется (см. [Performance](../../docs/02-frontend/Performance.md)).
- **Ограничь weights/styles** — только реально используемые начертания.
- **Системный фолбэк-стек** в `font-family`, перекрывающий кириллицу.

## Реализация (пример)

```css
@font-face {
  font-family: "Display";
  src: url("/fonts/display-cyrillic.woff2") format("woff2");
  font-weight: 400 700;
  font-display: swap;
  unicode-range: U+0400-04FF, U+0500-052F; /* Cyrillic + supplement */
}

:root {
  --font-display: "Display", "Segoe UI", system-ui, sans-serif;
}
```

## Частые ошибки

- Взять красивый condensed-дисплей и увидеть tofu только на проде.
- Полагаться на Google Fonts CDN для СНГ-аудитории без локального фолбэка.
- Грузить все weights ради одного-двух начертаний — лишний вес и медленный LCP.
- Забыть системный фолбэк — при сбое загрузки текст исчезает или прыгает.

## Security / performance risks

- Сторонний CDN — внешняя зависимость и точка отказа первого экрана; self-host убирает её.
- Лишние weights и subset-ы раздувают page weight и бьют по LCP.

## Testing strategy

- Рендер кириллической копии в целевом шрифте: нет квадратов/пропусков глифов.
- Throttle/блок внешнего CDN — текст всё равно читаем через фолбэк.
- Lighthouse: `font-display` не вызывает layout shift (CLS в норме).

## Edge cases

- Смешанные языки (латиница + кириллица) — проверь оба набора в одном шрифте.
- Variable font: убедись, что кириллический subset присутствует в variable-файле.
- Тонкие/жирные начертания иногда теряют кириллицу даже если regular её имеет.

## Источники

- [Frontend performance](../../docs/02-frontend/Performance.md)
- [Pattern: Anti-AI-slop design](anti-ai-slop-design.md)
- MDN `@font-face` / `unicode-range`: https://developer.mozilla.org/en-US/docs/Web/CSS/@font-face
