---
title: "Pattern: Fixed overlays vs backdrop-filter containing block"
category: "patterns"
updated: "2026-06-08"
status: "active"
tags: ["frontend", "css", "layout", "z-index", "modal"]
source_priority: "internal"
area: "frontend"
date: "2026-06-08"
---

# Fixed overlays vs backdrop-filter containing block

## Назначение

Предотвратить распространённый баг вёрстки: полноэкранный `position: fixed` элемент
(off-canvas drawer, модалка, затемнение-backdrop) внезапно обрезается до размеров
родителя/шапки или позиционируется не от вьюпорта. Причина — `backdrop-filter`
(как и `filter`, `transform`, `perspective`, `will-change` для этих свойств,
`contain: paint|layout|strict|content`) на предке создаёт новый **containing block
для fixed-потомков**.

## Симптом

- Бургер-drawer, вложенный в `<header>` с `backdrop-filter: blur()`, раскрывается не на
  весь экран, а только в пределах высоты шапки.
- `inset: 0` у fixed-элемента отсчитывается от ближайшего «фильтрованного/трансформированного»
  предка, а не от вьюпорта.
- Модалка или overlay внутри карточки с `transform`/`filter` смещается либо клиппится.

## Механизм

Для `position: fixed` containing block — вьюпорт, **кроме случая**, когда у предка есть
`transform`, `perspective`, `filter`, `backdrop-filter`, `will-change` одного из них или
`contain` со значением `paint`/`layout`/`strict`/`content`. Тогда containing block — этот
предок. Важно: `z-index` сам по себе такого эффекта НЕ даёт — он создаёт только stacking
context, но не containing block.

## Когда применять

Каждый раз, когда внутри элемента с фильтром/трансформом/`backdrop-filter` находится
fixed-overlay: drawer, модалка, «на весь экран» dropdown, tooltip/portal.

## Решения (по приоритету)

1. **Вынести overlay из «фильтрованного» предка** — рендерить drawer/модалку прямо в `<body>`
   (портал), а наложение разрулить `z-index` на корневом уровне.
2. **Убрать `backdrop-filter` с контейнера**, который должен содержать fixed-потомка.
   «Стеклянную» шапку сделать полупрозрачным фоном без блюра:
   ```css
   .header {
     background-color: var(--color-bg);                                   /* fallback */
     background-color: color-mix(in srgb, var(--color-bg) 88%, transparent);
   }
   ```
   Полупрозрачный фон + `z-index` создают stacking context, но НЕ containing block для
   fixed — drawer остаётся привязан к вьюпорту.
3. Если блюр критичен — вынести `backdrop-filter` на отдельный псевдоэлемент/слой, который
   НЕ является предком fixed-overlay.

## Управление z-index без containing-block-ловушки

Когда drawer остаётся внутри шапки (вариант 2), подними интерактивные контролы бара над
выехавшей панелью в той же stacking-context:

```css
.header__inner          { position: relative; z-index: 2; }
.logo, .header__actions { position: relative; z-index: 3; } /* над drawer, кликабельны */
.nav                    { z-index: 1; }                     /* off-canvas панель */
.nav-backdrop           { z-index: 0; }                     /* затемнение */
```

## Частые ошибки

- Считать, что `z-index` создаёт containing block для fixed (нет — только stacking context).
- Ставить «модный» `backdrop-filter` на sticky-`<header>`, внутри которого лежит мобильный drawer.
- Чинить симптом увеличением `height`/`top` drawer вместо устранения containing block.
- Проверять только на десктопе, где drawer скрыт (`display: none`), и не ловить баг на мобильном.

## Проверка

Открыть мобильный drawer/модалку и убедиться, что overlay покрывает весь вьюпорт (а не
родителя), закрывается кликом по затемнению и по `Esc`, а контролы бара кликабельны поверх
панели. Проверяемо через DOM/eval: `nav.classList.contains('is-open')` и
`nav.getBoundingClientRect().height ≈ window.innerHeight`.

## Источники

- [Pattern: Semantic theme text tokens](semantic-theme-text-tokens.md)
- [Accessibility](../../docs/02-frontend/Accessibility.md)
- MDN — «Layout and the containing block»: влияние `filter`/`transform`/`backdrop-filter`/`will-change` на fixed-позиционирование.
