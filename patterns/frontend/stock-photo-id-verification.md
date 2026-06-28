---
title: "Pattern: Проверка stock-фото (не доверять ID по памяти)"
category: "patterns"
updated: "2026-06-29"
status: "active"
tags: ["frontend", "images", "unsplash", "pexels", "playwright", "content", "verification"]
source_priority: "internal"
area: "frontend"
date: "2026-06-23"
---

# Проверка stock-фото (не доверять ID по памяти)

## Назначение

Паттерн предотвращает «фото-не-по-смыслу» на проде: когда захардкоженные
ID картинок (Unsplash и т.п.) ведут не на тот кадр. ID, взятые «из головы»
модели, ненадёжны — это не факт, а догадка.

## Когда использовать

- Лендинг/сайт берёт фото по фиксированным URL stock-сервиса (Unsplash,
  Pexels) без DAM/CMS.
- Подбираешь несколько тематических кадров (герои-карточки, меню, галерея).

## Корень проблемы

ID вида `photo-1516280440614-...` непрозрачны: по строке не видно, что на
фото. Модель «вспоминает» ID неверно — на практике в одной сессии
встретились: микрофон вместо кошки, собака в очках вместо кошки, серый кот
там, где в alt «рыжий», айс-кофе вместо латте. Сборка при этом зелёная —
картинка грузится (HTTP 200), просто не та.

## Production-паттерны

1. **Не доверяй ID по памяти.** Реальные ID бери из живого поиска stock-сервиса
   (WebFetch страницы поиска → вытащить `https://images.unsplash.com/photo-...`).
2. **Сверяй визуально перед коммитом.** Отрендерь тест-грид кандидатов в
   preview и сделай скриншот — глазами проверь, что на каждом кадре то, что
   нужно. Дёшево и ловит все промахи разом:
   ```js
   // в preview_eval: временный оверлей со всеми кандидатами + подписью ID
   bar.innerHTML = ids.map(id =>
     `<figure><img src="https://images.unsplash.com/photo-${id}?w=320&q=60">
      <figcaption>${id}</figcaption></figure>`).join('');
   ```
3. **Согласуй alt с реальным кадром.** Если на фото нет ребёнка — не пиши в alt
   «ребёнок». Подгоняй копию/alt под то, что видно, а не наоборот.
4. **HTTP 200 ≠ верный кадр.** `naturalWidth > 0` подтверждает загрузку, не
   содержание. Только визуальная проверка/скриншот валидирует смысл.
5. **Alt ненадёжен по внешности/этничности.** Подпись на странице stock-сервиса
   («brunette», «portrait») часто не отражает реальную внешность — на практике alt
   «brunette» вёл на восточноазиатскую модель. Если есть требование к внешности
   моделей (напр. европейская/славянская под RU-аудиторию) — **Read каждого
   портрета глазами** перед установкой, alt-у не верить.
6. **Реальные URL — из живого поиска через браузер.** На Pexels удобно вытащить
   прямые `images.pexels.com/photos/...` скрейпом DOM в Playwright (не только WebFetch):
   ```js
   // browser_evaluate на странице поиска: собрать кандидаты с alt
   [...document.querySelectorAll('img')]
     .map(i => ({src:(i.src||'').split('?')[0], alt:i.alt.slice(0,70)}))
     .filter(o => o.src.includes('images.pexels.com/photos/'));
   ```
7. **Lazy-картинки — форсить `eager` для скрин-проверки.** Element-screenshot
   off-screen секции **не отрисовывает** `loading="lazy"` картинки вне вьюпорта
   (выходит чёрный блок). Перед визуальной проверкой: `img.loading='eager'` (и
   переустановить `src`) либо проскроллить в реальный вьюпорт; иначе проверишь пустоту.

## Частые ошибки

- Захардкодить «знакомый» ID и не открыть картинку глазами.
- Считать зелёную сборку доказательством корректности фото.
- Оставить alt от задумки, когда найденное фото показывает другое.
- Брать с референс-сайтов кадры без проверки лицензии (бери free: Unsplash/Pexels).

## Связано

- [Pattern: portfolio case screenshot gallery](portfolio-case-screenshot-gallery.md)
- [Lesson: headless preview verification](../../lessons-learned/2026-06-11-headless-preview-verification.md)
- [Case: LUMA premium beauty animated landing](../../case-studies/successes/2026-06-29-luma-premium-beauty-animated-landing.md)
- [resources/design-inspiration.md](../../resources/design-inspiration.md)
