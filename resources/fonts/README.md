---
title: "Шрифты — starter-pack (OFL, кириллица)"
category: "resource"
updated: "2026-06-20"
status: "active"
tags: ["resources", "fonts", "cyrillic", "ofl"]
source_priority: "mixed"
---

# Шрифты — starter-pack (self-host, OFL, кириллица)

Готовый стартовый набор `.woff2` для самостоятельного хостинга. **Все шрифты — под SIL Open Font
License 1.1 (OFL)**, свободны для коммерческого использования, **все имеют кириллический subset**
(файлы — именно cyrillic-subset, скачаны с [Fontsource](https://fontsource.org) / jsDelivr,
проверено 2026-06-20).

Это пример-стартер, а не вся библиотека. Полный каталог с подбором по нише, парами и инструкцией
self-host — в [docs/02-frontend/Typography-fonts.md](../../docs/02-frontend/Typography-fonts.md).

## Как использовать

Скопируй нужные `.woff2` в проект (`/public/fonts/`) и подключи через `@font-face` с
`font-display: swap` и `unicode-range` для кириллицы — по паттерну
[cyrillic-self-host-fonts.md](../../patterns/frontend/cyrillic-self-host-fonts.md). Бери только те
начертания, что реально нужны. Нужны другие веса/стили — тяни с того же Fontsource:
`https://cdn.jsdelivr.net/fontsource/fonts/<family>@latest/cyrillic-<weight>-normal.woff2`.

## Состав (имя — категория — веса — лицензия)

| Файл(ы) | Шрифт | Категория | Веса | Лицензия |
|---|---|---|---|---|
| `manrope-*` | Manrope | Grotesque sans (UI/body) | 400, 700 | OFL 1.1 |
| `onest-*` | Onest | Modern sans (UI/body) | 400, 600 | OFL 1.1 |
| `golos-text-*` | Golos Text | Sans, родная кириллица (body) | 400, 600 | OFL 1.1 |
| `geist-*` | Geist | Neo-grotesque sans (UI) | 400, 600 | OFL 1.1 |
| `unbounded-*` | Unbounded | Geometric display | 700, 800 | OFL 1.1 |
| `lora-*` | Lora | Editorial serif (body/headings) | 400, 600 | OFL 1.1 |
| `cormorant-*` | Cormorant | High-contrast display serif | 500, 700 | OFL 1.1 |
| `jetbrains-mono-*` | JetBrains Mono | Monospace (метки/код) | 400, 700 | OFL 1.1 |

## Правила

- В этот набор попадают **только OFL / free-for-commercial + кириллица**. Платные шрифты (Klim,
  Commercial Type, платные тиры Pangram и т.п.) сюда **не кладём** и не копируем с чужих сайтов —
  только определяем «вайб» и берём free-лукалайк. См. лицензионные правила в Typography-fonts.md.
- Полный текст OFL: <https://openfontlicense.org>. Атрибуция и текст лицензии хранятся у правообладателя
  шрифта на Google Fonts / Fontsource; при распространении продукта прикладывай `OFL.txt` шрифта.
