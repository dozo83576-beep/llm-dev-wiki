---
title: "Premium components"
category: "frontend"
updated: "2026-06-19"
status: "active"
tags: ["frontend", "components", "animation", "design", "react"]
source_priority: "community"
---

# Premium components

Справочник по компонент-репозиториям и движкам анимаций для сайтов агентского уровня. Цель — premium-приёмы (текст-эффекты, magnetic-кнопки, particle-фоны, reveal-анимации) без «AI-слопа» и без раздувания бандла. Дополняет [Anti-AI-slop design](../../patterns/frontend/anti-ai-slop-design.md).

## Каталог

- **[react-bits](https://github.com/DavidHDev/react-bits)** — текст-эффекты, marketing-секции, готовые анимированные блоки.
- **[Aceternity UI](https://ui.aceternity.com)** — 3D-карты, glowing beams, particle-фоны, magnetic buttons, spotlight.
- **[Magic UI](https://github.com/magicuidesign/magicui)** — анимированные Framer Motion компоненты (marquee, counter, beams).
- **[shadcn/ui](https://ui.shadcn.com)** — чистая база компонентов (см. [Shadcn](Shadcn.md)).
- **[Framer Motion](https://www.framer.com/motion/) / [GSAP](https://gsap.com)** — движки анимаций (reveal-stagger, hover-lift, timeline).
- **[Lucide](https://lucide.dev)** — линейные иконки вместо эмодзи.

## Когда использовать

- Лендинг / промо-страница на React или Next.js, где нужен premium-визуал и интерактив.
- Нужны конкретные эффекты (spotlight в hero, counter-up на цифрах, marquee логотипов), которые дорого писать с нуля.
- Базовые формы/кнопки/диалоги — бери из shadcn/ui, не изобретай.

## Когда не использовать

- Статичный одностраничный HTML без сборки — не тащи React ради одного аккордеона (анти-паттерн из [Playbook: Landing](../13-playbooks/landing.md)). Переноси приёмы вручную как CSS/JS.
- Внутренняя админка / дашборд, где важнее плотность данных и скорость, а не decorative-анимации.
- Бюджет производительности уже на пределе — лишние анимированные компоненты бьют по LCP/INP.

## Правила переноса

- **Одиночный HTML:** переноси приём вручную (CSS keyframes / IntersectionObserver / небольшой JS), не подключай React-рантайм. Скопировать визуальную идею, не зависимость.
- **React / Next.js:** подключай компоненты напрямую; держи их за `dynamic import` / ниже первого экрана, чтобы не блокировать LCP.
- Анимации уважают `prefers-reduced-motion` (см. [Accessibility](Accessibility.md)).
- Иконки — Lucide, не эмодзи; копия — без длинного/среднего тире.

## Частые ошибки

- Тянуть Framer Motion / GSAP в статичный лендинг ради одного эффекта.
- Копировать компонент вместе с тяжёлой зависимостью, когда хватило бы 20 строк CSS.
- Particle-фон или 3D-карта на первом экране, убивающие LCP на мобильном.
- Эмодзи-иконки из туториала вместо линейных Lucide.
- Слепой copy-paste без адаптации под дизайн-направление — снова получается «как у всех».

## Security / performance risks

- Каждая библиотека добавляет JS в bundle — меряй вес и TTI (см. [Performance](Performance.md)).
- Сторонние компоненты могут тянуть транзитивные зависимости — проверяй дерево перед добавлением.
- Decorative-скрипты не должны блокировать первый рендер; грузи лениво.

## Testing strategy

- Bundle-size до/после добавления компонента; first-load JS в бюджете.
- Lighthouse performance ≥ 90, a11y ≥ 95 после интеграции.
- Анимации отключаются при `prefers-reduced-motion`.
- Cross-browser smoke на hero с эффектами (Chrome / Safari / mobile Safari).

## Edge cases

- SSR/Next.js: компоненты с `window`/`document` нужны как client components, иначе падают при гидрации.
- Кириллица в текст-эффектах: проверь, что шрифт её поддерживает (см. [Cyrillic / self-host fonts](../../patterns/frontend/cyrillic-self-host-fonts.md)).
- Лицензии: проверяй лицензию репозитория перед коммерческим использованием.

## Источники

- [Anti-AI-slop design](../../patterns/frontend/anti-ai-slop-design.md)
- [Typography-fonts](Typography-fonts.md), [Color-palettes](Color-palettes.md), [Layout archetypes](../../patterns/frontend/layout-archetypes.md)
- [design-inspiration (галереи)](../../resources/design-inspiration.md)
- [Playbook: Landing](../13-playbooks/landing.md)
- [Shadcn](Shadcn.md), [Performance](Performance.md), [Accessibility](Accessibility.md)
- react-bits: https://github.com/DavidHDev/react-bits
- Aceternity UI: https://ui.aceternity.com
- Magic UI: https://github.com/magicuidesign/magicui
