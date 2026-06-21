---
title: "Pattern: Purposeful motion"
category: "pattern"
updated: "2026-06-20"
status: "active"
tags: ["frontend", "motion", "animation", "performance", "accessibility"]
source_priority: "internal"
area: "frontend"
date: "2026-06-20"
---

# Pattern: Purposeful motion

## Назначение

Паттерн даёт повторяемый способ добавлять анимации, которые ощущаются «дорого» и не вредят
performance/доступности. Главный принцип: каждая анимация оправдывает себя функцией (feedback,
пространственная связность, индикация состояния) и частотой показа, а не «это красиво». Полные
правила и числа — в [Motion](../../docs/02-frontend/Motion.md); здесь — готовая схема применения.

## Когда использовать

- Лендинг/продающая страница: нужен один запоминающийся момент, а не россыпь дёрганий.
- Продуктовый UI с модалками, drawer, тостами, поповерами, переключениями состояний.
- Когда дизайн уже «не слоп», но ощущается статичным/плоским.

## Когда не использовать

- Частые, клавиатурой-инициированные действия (command palette, шорткаты) — не анимировать.
- Плотные дашборды/админки — только минимальный, быстрый feedback.
- Пользователь с `prefers-reduced-motion: reduce` — движение убрать (см. ниже).

## Структура

Решение принимается по трём вопросам перед кодом:

1. **Анимировать вообще?** Чем чаще действие, тем меньше анимации (100+/день → ноль; редкое → можно delight).
2. **Зачем?** Должен быть функциональный ответ: feedback / spatial / state / explanation. «Cool» при высокой частоте → нет.
3. **Чем?** Длительность < 300ms для UI, `ease-out` на вход/выход, анимировать только `transform`/`opacity`.

Бюджет на страницу: один оркестрированный page-load (staggered reveal, 30–80ms между элементами)
делает больше для wow, чем десяток разрозненных микро-интеракций.

## Реализация (пример)

```css
:root { --ease-out: cubic-bezier(0.23, 1, 0.32, 1); }

/* 1. Один оркестрированный вход секции, stagger 60ms */
.reveal {
  opacity: 0;
  transform: translateY(8px);
  animation: reveal 320ms var(--ease-out) forwards;
}
.reveal:nth-child(1) { animation-delay: 0ms; }
.reveal:nth-child(2) { animation-delay: 60ms; }
.reveal:nth-child(3) { animation-delay: 120ms; }
@keyframes reveal { to { opacity: 1; transform: translateY(0); } }

/* 2. Feedback нажатия — живая кнопка */
.button { transition: transform 160ms var(--ease-out); }
.button:active { transform: scale(0.97); }

/* 3. Hover только на точном указателе */
@media (hover: hover) and (pointer: fine) {
  .card:hover { transform: translateY(-4px); }
}

/* 4. Обязательный reduced-motion: убрать движение, оставить opacity */
@media (prefers-reduced-motion: reduce) {
  .reveal { animation: fade 200ms ease forwards; transform: none; }
  .card:hover, .button:active { transform: none; }
}
@keyframes fade { from { opacity: 0; } to { opacity: 1; } }
```

## Production-паттерны

- Только `transform`/`opacity`; никаких `transition: all` — перечислять свойства.
- Прерываемый/часто-перезапускаемый UI (тосты) → CSS `transition`, не `@keyframes`.
- Выход быстрее входа; поповеры от триггера, модалки от центра; вход со `scale(0.95)`, не `scale(0)`.
- Reduced-motion обязателен в каждом компоненте с движением (reduced ≠ полное отсутствие — opacity/color для понятности оставить).

## Частые ошибки

- Анимация на частом/клавиатурном действии → ощущение тормозов.
- `ease-in` на UI; длительности > 300ms; вход из `scale(0)`.
- Hover-анимация без media-гейта → ложный hover на тач-устройствах.
- Декоративные particle/blur-фоны валят INP/LCP; `blur()` > 20px дорогой.
- Framer Motion `x/y` под нагрузкой дропает кадры — полный `transform`-стринг или CSS.

## Альтернативы

- Полностью статичный UI — для внутренних инструментов и при жёстком performance-бюджете это
  валидно: лучше ноль анимаций, чем дёрганые.
- Spring/Framer Motion — когда нужны прерываемые жесты с инерцией (drag-to-dismiss); для
  предопределённых входов дешевле и стабильнее CSS.

## Источники

- [Motion / UI-анимации](../../docs/02-frontend/Motion.md)
- [Pattern: Anti-AI-slop design](anti-ai-slop-design.md)
- [Accessibility](../../docs/02-frontend/Accessibility.md), [Performance](../../docs/02-frontend/Performance.md)
- Emil Kowalski — animations.dev / emilkowal.ski (проверено 2026-06-20)
