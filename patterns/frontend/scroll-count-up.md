---
title: "Pattern: Scroll-triggered count-up (счётчики при скролле)"
category: "pattern"
updated: "2026-06-11"
status: "active"
tags: ["frontend", "javascript", "animation", "intersection-observer", "accessibility"]
source_priority: "internal"
area: "frontend"
date: "2026-06-11"
---

# Pattern: Scroll-triggered count-up (счётчики при скролле)

## Назначение

Анимировать числовые метрики (лет на рынке, клиентов, гарантия) — число «накручивается» от 0 к
целевому при попадании блока в вьюпорт. Лёгкая «живость» без сторонних библиотек, с обязательным
fallback для доступности.

## Когда использовать

- Блок статистики/«цифры доверия» на лендинге, который появляется по мере скролла.
- Уже есть scroll-reveal на `IntersectionObserver` — count-up зеркалит тот же паттерн.

## Когда не использовать

- Числа над сгибом (видны сразу) — анимация не нужна или запускается на загрузке.
- Точные данные, где промежуточные «прокручивающиеся» значения могут ввести в заблуждение.

## Структура

- Селектор `[data-count-to]`; `IntersectionObserver` (threshold ~0.4). На первом пересечении —
  запустить анимацию и `unobserve` (одноразово).
- Анимация через `requestAnimationFrame`: `value = Math.round(target * easeOut(progress))`,
  длительность ~1.2–1.5 c.
- **Число и единицы — разные DOM-узлы.** Анимировать только числовой `<span>`; суффикс («+», «года»,
  «мин») держать в отдельном узле, иначе текст «прыгает» по ширине на каждом кадре.
- Форматирование тысяч (пробел-разделитель / `toLocaleString`).

## Реализация (пример)

```js
function initCounters() {
  var els = document.querySelectorAll('[data-count-to]');
  if (!els.length) return;
  var reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
  var fmt = function (n) { return String(n).replace(/\B(?=(\d{3})+(?!\d))/g, ' '); };

  // Fallback: нет анимации / нет наблюдателя → сразу финальное значение
  if (reduce || !('IntersectionObserver' in window)) {
    els.forEach(function (el) { el.textContent = fmt(+el.dataset.countTo); });
    return;
  }
  var io = new IntersectionObserver(function (entries, obs) {
    entries.forEach(function (e) {
      if (!e.isIntersecting) return;
      obs.unobserve(e.target);
      var target = +e.target.dataset.countTo, start = null, DUR = 1500;
      (function frame(now) {
        if (!start) start = now;
        var p = Math.min((now - start) / DUR, 1), eased = 1 - Math.pow(1 - p, 3);
        e.target.textContent = fmt(Math.round(target * eased));
        if (p < 1) requestAnimationFrame(frame);
      })(performance.now());
    });
  }, { threshold: 0.4 });
  els.forEach(function (el) { io.observe(el); });
}
```

```html
<div class="stat__value"><span data-count-to="30000">0</span><span class="stat__unit">+</span></div>
```

## Production-паттерны

- **Обязательный fallback** на финальное значение при `prefers-reduced-motion` или отсутствии
  `IntersectionObserver` — иначе число «застрянет» на `0`.
- Зарезервировать ширину/высоту блока числа, чтобы анимация не вызывала сдвиг layout (CLS).

## Частые ошибки

- Анимировать узел вместе с суффиксом → текст дёргается.
- Забыть reduced-motion / no-IO fallback → пользователь видит `0` (особенно заметно в headless-превью,
  где `IntersectionObserver` не фаерится — см. урок ниже).

## Альтернативы

- CSS `@property`-анимация числа (ограниченная поддержка) — без JS, но сложнее форматировать.
- Готовые библиотеки (countUp.js) — лишняя зависимость для одного блока.

## Источники

- Внутренний кейс: [Статический сайт автосервиса ТУРБОСЕРВИС](../../case-studies/successes/2026-06-11-turboservice-static-autoservice.md).
- Связанный урок: [Верификация статики в headless-превью](../../lessons-learned/2026-06-11-headless-preview-verification.md).
