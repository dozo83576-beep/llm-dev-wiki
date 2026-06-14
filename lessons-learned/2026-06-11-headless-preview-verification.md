---
title: "Lesson: Верификация статики в headless/sandbox-превью"
category: "lesson"
updated: "2026-06-13"
status: "active"
tags: ["frontend", "testing", "preview", "verification", "css-animation", "third-party"]
source_priority: "internal"
date: "2026-06-11"
project_type: "landing"
---

# Lesson: Верификация статики в headless/sandbox-превью

## TL;DR

В headless/sandbox-превью **скриншоты** страниц с бесконечными CSS-анимациями таймаутят,
**IntersectionObserver не фаерится**, а **CSS/HTML кэшируются**. Верифицируй UI **DOM-метриками**
(`getBoundingClientRect`, `getComputedStyle`), а не картинкой; форсируй состояния и обходи кэш.

## Контекст

Статический сайт (HTML/CSS/vanilla JS, без сборщика) проверялся через встроенный превью-инструмент с
headless-рендерером и `eval`-доступом к странице. На сайте — бесконечные декоративные CSS-анимации
Hero (Ken-Burns/glow/sweep), scroll-reveal и count-up на `IntersectionObserver`.

## Что произошло

- `preview_screenshot` **стабильно таймаутил** — даже после программной «заморозки» анимаций (инструмент
  перезагружает страницу заново, и `animation: … infinite` снова не даёт рендереру выйти в idle).
- `.reveal`-блоки и count-up **не активировались**: `IntersectionObserver` в headless не доставлял
  колбэки, синтетический `window.scrollTo` не двигал страницу. Замеры показывали элементы в
  pre-reveal-состоянии (сдвинуты трансформом, числа на `0`).
- Правки `style.css`/`responsive.css` и даже HTML **не подхватывались** после перезагрузки — отдавалась
  закэшированная версия; computed-стили не совпадали с файлом на диске.
- Окно превью по умолчанию схлопывалось до ~2px ширины — без ресайза любые замеры бессмысленны.
- Превью-сервер **останавливался между сессиями** — вызовы падали с «server not found».

## Корень

Headless-рендерер ждёт состояния idle перед снимком, а `animation: infinite` его не наступает.
`IntersectionObserver`/scroll в headless-окружении не доставляются как в реальном браузере. Статика
кэшируется агрессивно (per-file ETag), и обычная перезагрузка ревалидирует не всё.

## Новое правило

- Когда верифицируешь UI в headless/sandbox-превью → **меряй `getBoundingClientRect()` /
  `getComputedStyle()`**, а не скриншоты; для визуальных правок этого достаточно (позиции, размеры,
  цвета, переполнение, число колонок).
- Когда элемент за `IntersectionObserver` (reveal/count-up) → перед замером **форсируй состояние**:
  `document.querySelectorAll('.reveal').forEach(e => e.classList.add('is-visible'))`; анимацию при
  необходимости запусти вручную. Учитывай, что bounding-rect может отражать незавершённый трансформ —
  ориентируйся на layout-позицию соседей (`nextElementSibling`).
- Когда правишь CSS/HTML → **cache-bust**: перевесь `<link href="…?v="+Date.now()>` и грузи страницы
  как `page.html?v=…`; computed-стили проверяй уже после подмены.
- Всегда **`preview_resize`** до реального размера перед замерами; проверяй несколько высот окна
  (820/720/900) для fold-зависимых правок.
- **`preview_start` первым** в сессии — сервер мог упасть.
- Когда на странице есть **внешние сторонние скрипты/ресурсы** (виджет записи, шрифты, аналитика), а в
  sandbox-превью нет интернета → висящие запросы не дают рендереру выйти в idle, и `preview_screenshot`
  таймаутит так же, как на infinite-анимациях. Приём: дождаться `document.readyState === 'complete'`,
  затем `window.stop()` (оборвать висящие подзапросы) и только потом снимок; не вызывать `window.stop()`
  до загрузки документа (оборвёт саму навигацию). Надёжнее — верифицировать DOM-метриками, а факт
  подключения внешнего ресурса проверять в собранном HTML (`grep` по `dist`).
- **Избегай `rAF`/`Promise`-eval с таймаутом** на анимированных страницах — они не резолвятся
  (рендерер не idle); делай синхронные замеры в два отдельных вызова (подмена → замер).

## Применимость

- Статические сайты/лендинги в sandbox-превью с headless-рендерером.
- Не нужно при обычном headed-браузере, либо в CI с принудительно отключёнными анимациями
  (`prefers-reduced-motion`) и реальным скроллом.

## Обновлённые документы

- [checklists/frontend-review.md](../checklists/frontend-review.md) — добавлен пункт в «Tests»:
  в headless/sandbox-превью верифицировать DOM-метриками, а не скриншотами при бесконечных анимациях.

## Ссылки

- Связанный кейс: [Статический сайт автосервиса ТУРБОСЕРВИС](../case-studies/successes/2026-06-11-turboservice-static-autoservice.md)
- Связанный паттерн: [full-height-first-screen](../patterns/frontend/full-height-first-screen.md)
