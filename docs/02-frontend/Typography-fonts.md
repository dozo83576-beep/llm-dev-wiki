---
title: "Типографика и библиотека шрифтов"
category: "frontend"
updated: "2026-06-20"
status: "active"
tags: ["frontend", "fonts", "typography", "design", "cyrillic"]
source_priority: "mixed"
area: "frontend"
---

# Типографика и библиотека шрифтов

## Назначение

Каталог современных шрифтов (актуально на июнь 2026), которые дают «дорогой», не-шаблонный вид, плюс
готовые пары и правило выбора под бриф. Цель — быстро взять характерный шрифт вместо дефолтного
Inter/Arial, не нарушив лицензию и не словив «tofu» на кириллице. Дополняет
[Anti-AI-slop design](../../patterns/frontend/anti-ai-slop-design.md) и
[Cyrillic / self-host fonts](../../patterns/frontend/cyrillic-self-host-fonts.md).

### Лицензии (читать первым)

- В библиотеку и проекты берём **только free-for-commercial + self-hostable**: SIL Open Font License
  (OFL, напр. Google Fonts) или явно free-commercial (Fontshare).
- **Нельзя копировать платные шрифты** (`.woff2`) с референс-сайтов (Awwwards/Dribbble и т.п.).
  Топовые сайты часто на платных фундри (Klim, Commercial Type, платные тиры Pangram). Правильно —
  определить характер шрифта и взять **free-лукалайк** (ниже есть замены), либо купить лицензию.
- Кириллица — обязательна для СНГ-аудитории. У каждого шрифта ниже явный флаг **Cyr ✓/✗**
  (проверено по cyrillic-subset на Fontsource, 2026-06-20). `✗` = латиница-онли: для русского текста
  бери лукалайк или другой шрифт.

## Когда использовать

- Подбор гарнитуры под лендинг/продукт по [design-direction-brief](../../prompts/design-direction-brief.md).
- Нужен характерный display + читаемый body, а не один дефолтный шрифт «на всё».
- Есть референс с платным шрифтом — нужен бесплатный аналог того же вайба.

## Когда не использовать

- У клиента жёсткий бренд-гайд с купленным шрифтом — следуй ему (и его лицензии), каталог не нужен.
- Внутренняя админка/дашборд — хватит системного стека или одного нейтрального sans (плотность важнее вайба).

## Production-паттерны

### Каталог — кириллица ✓ (безопасно для русского текста)

**Sans / grotesque (UI + body):**
- **Manrope** — Cyr ✓, OFL. Геометричный, нейтрально-современный, отличный body/UI. Дефолт-замена Inter.
- **Onest** — Cyr ✓, OFL. Современный sans, изначально с кириллицей; чистый UI.
- **Golos Text** — Cyr ✓, OFL. Родная кириллица (Paratype); надёжный body для рус. текста.
- **Geist** — Cyr ✓, OFL. Neo-grotesque от Vercel; «техно/SaaS» характер.
- **IBM Plex Sans** — Cyr ✓, OFL. Корпоративно-премиальный, читаемый в UI.
- **Wix Madefor Text** — Cyr ✓, OFL. Дружелюбный гуманистический sans.
- **Commissioner / Jost / Rubik / Raleway** — Cyr ✓, OFL. Разные характеры (low-contrast гуманист /
  геометрик a-la Futura / скруглённый / элегантный тонкий).
- _Осторожно (перегреты):_ **Inter**, **Montserrat** — Cyr ✓, но «AI-вид»; бери только осознанно.

**Display / заголовки:**
- **Unbounded** — Cyr ✓, OFL. Жирный геометрик-дисплей, сильный характер для hero.
- **Tektur** — Cyr ✓, OFL. Техно/механический, угловатый.
- **Yeseva One** — Cyr ✓, OFL. Контрастный элегантный дисплей-serif.
- **Philosopher / El Messiri / Cuprum** — Cyr ✓, OFL. Характерные дисплеи с кириллицей.
- **Ruslan Display** — Cyr ✓, OFL. Декоративный, для акцентных надписей.
- _Осторожно:_ **Oswald**, **Playfair Display** — Cyr ✓, но затёрты.

**Editorial serif (body/headings):**
- **Lora** — Cyr ✓, OFL. Спокойный редакционный serif, хорош в длинном тексте.
- **Cormorant** — Cyr ✓, OFL. Высокий контраст, «люкс/мода» в крупном кегле.

**Mono (метки/индексы/код):**
- **JetBrains Mono** — Cyr ✓, OFL. Чёткий моно для mono-меток, ghost-индексов, код-блоков.

### Каталог — латиница-онли (тренд 2026, для латинских сайтов; иначе — лукалайк)

Очень характерные, но **без кириллицы (Cyr ✗)** — для рус. текста подбери замену из списка выше:
- **Space Grotesk** ✗ → кириллица-замена: Geist / Unbounded.
- **Bricolage Grotesque** ✗ → замена: Onest / Manrope.
- **Fraunces** ✗ (вариативный «old-style» serif) → замена: Lora / Cormorant.
- **Instrument Serif** ✗ / **Instrument Sans** ✗ → замена: Cormorant / Geist.
- **Schibsted Grotesk** ✗, **Hanken Grotesk** ✗, **Figtree** ✗, **Plus Jakarta Sans** ✗, **Sora** ✗,
  **Spline Sans** ✗ → замена: Manrope / Onest / Commissioner.
- **Fontshare (free-commercial, не OFL):** **Clash Display**, **General Sans**, **Switzer** — модно,
  но в основном латиница; для кириллицы — лукалайк. Лицензия Fontshare free, но это **не OFL** — проверь условия.

### Готовые пары (display + body) с токенами

Подставляй в `:root`; начертания self-host по cyrillic-паттерну. Все пары ниже — Cyr ✓.

```css
/* A. SaaS / tech — чисто и современно */
--font-display: "Geist", system-ui, sans-serif;
--font-body:    "Manrope", system-ui, sans-serif;

/* B. Премиум / редакционный — контраст serif + спокойный sans */
--font-display: "Cormorant", Georgia, serif;
--font-body:    "Onest", system-ui, sans-serif;

/* C. Бренд / афиша — жирный геометрик + нейтральный body */
--font-display: "Unbounded", system-ui, sans-serif;
--font-body:    "Golos Text", system-ui, sans-serif;

/* D. Editorial / блог — serif заголовки + serif body */
--font-display: "Yeseva One", Georgia, serif;
--font-body:    "Lora", Georgia, serif;

/* mono-акцент для меток/индексов в любой паре */
--font-mono: "JetBrains Mono", ui-monospace, monospace;
```

### Как выбрать по брифу

1. Есть референс → возьми ДНК (контраст, ширина, насечки), подбери из каталога такой же характер
   (платный референс → free-лукалайк), проверь Cyr.
2. Нет референса → исходи из настроения брифа: tech→A, премиум→B, бренд/афиша→C, контент→D. Не дефолти
   на Inter «по привычке» (см. анти-повторяемость в [anti-ai-slop](../../patterns/frontend/anti-ai-slop-design.md)).
3. Зафиксируй `--font-display/--font-body/--font-mono` в `DESIGN-DIRECTION.md`.

### Self-host

Стартовый набор `.woff2` (8 шрифтов, OFL, кириллица) лежит в
[resources/fonts/](../../resources/fonts/README.md). Подключение — `@font-face` + `font-display: swap`
+ `unicode-range` по [cyrillic-self-host-fonts](../../patterns/frontend/cyrillic-self-host-fonts.md).
Другие веса: `https://cdn.jsdelivr.net/fontsource/fonts/<family>@latest/cyrillic-<weight>-normal.woff2`.

## Частые ошибки

- Взять модный латиница-онли шрифт (Space Grotesk, Clash Display, Fraunces) на рус. сайт → tofu.
- Скопировать платный `.woff2` с чужого сайта — нарушение лицензии.
- Дефолт на Inter/Montserrat «потому что привычно» → AI-вид.
- Грузить все веса ради двух начертаний → лишний вес, медленный LCP.
- Брать дисплей-шрифт в body — нечитаемо в длинном тексте.

## Security / performance risks

- Внешний CDN шрифтов (Google Fonts) — точка отказа первого экрана для СНГ; self-host убирает её.
- Лишние веса/стили раздувают page weight и бьют по LCP (см. [Performance](Performance.md)).
- Fontshare/сторонние лицензии меняются — фиксируй условия и дату проверки в проекте.

## Testing strategy

- Рендер кириллической копии в выбранном шрифте — нет квадратов/пропусков глифов.
- Блок/throttle внешнего CDN — текст читаем через системный фолбэк.
- Lighthouse: `font-display: swap`, без layout shift (CLS в норме); first-load в бюджете.
- Лицензия каждого используемого шрифта зафиксирована (OFL.txt в поставке продукта).

## Edge cases

- Variable font: убедись, что кириллический subset есть в variable-файле, а не только в латинском.
- Тонкие/жирные начертания иногда теряют кириллицу даже если regular её имеет — проверь по весам.
- Смешанные языки (лат+кир) в одном заголовке — оба набора в одном шрифте.

## Источники

- [Cyrillic / self-host fonts](../../patterns/frontend/cyrillic-self-host-fonts.md), [Anti-AI-slop design](../../patterns/frontend/anti-ai-slop-design.md)
- [Color-palettes](Color-palettes.md), [Premium-components](Premium-components.md), [Performance](Performance.md)
- [resources/fonts/ (starter-pack)](../../resources/fonts/README.md), [resources/design-inspiration.md](../../resources/design-inspiration.md)
- Google Fonts: https://fonts.google.com · Fontshare: https://fontshare.com · Fontsource: https://fontsource.org (проверено 2026-06-20)
- Typewolf (fonts in use): https://www.typewolf.com · Fonts In Use: https://fontsinuse.com · OFL: https://openfontlicense.org
