---
title: "Pattern: Contextual anti-AI-slop design"
category: "patterns"
updated: "2026-08-10"
status: "active"
tags: ["frontend", "design", "anti-ai-slop", "landing"]
source_priority: "internal"
area: "frontend"
date: "2026-08-10"
---

# Contextual anti-AI-slop design

Используй паттерн, когда нужно не сделать скучный AI-slop лендинг или шаблонный интерфейс, но
сохранить brief, бренд и ограничения продукта. Он хранит локальные failure patterns, а не заменяет
дизайн-мышление модели. Codex и Claude
нативно определяют направление, композицию, типографику, UX и реализацию. `site-design` нужен только
в полном маршруте или при явном вызове для `DESIGN-DIRECTION.md`, локальных gates и resume.

## Сначала определить поверхность

- **Marketing / brand:** различимость, доверие, ясный оффер и визуальный характер.
- **Product / operate:** плотность, состояния, скорость работы и согласованность с design system.
- **Content / read:** ритм чтения, навигация, типографика и длина строки.
- **Experience:** выразительность допустима, если она не ломает задачу, доступность и performance.

Brand brief, существующий UI и accessibility имеют приоритет над общими анти-слоп эвристиками.
Для redesign сначала зафиксируй, что сохраняется: IA, tokens, компоненты, copy и узнаваемые паттерны.
Не меняй это молча.

Для `direct`-правки явно сохрани применимые brand, responsive, accessibility и существующее
поведение; улучшение одной поверхности не разрешает незапрошенный redesign остальных.
Для любой web-поверхности опиши релевантное responsive-поведение, если brief явно не ограничивает
результат фиксированным viewport.

## Дизайн-направление

До крупной реализации сформулируй одно обоснованное направление. Альтернативы нужны только когда
неопределённость материально меняет решение пользователя. Зафиксируй качественные оси:

- `visual variance`: restrained / balanced / expressive;
- `information density`: spacious / balanced / dense;
- `motion budget`: static / functional / expressive;
- typography, palette, spacing, surfaces и image language;
- состояния, responsive-поведение и проверяемые acceptance criteria.

Это дисциплина выбора, а не случайная ротация стилей. Направление выводится из аудитории, задачи,
бренда, контента и предоставленных референсов.

## Подозрительные дефолты

Повторяемый приём считается сигналом для проверки, а не абсолютным запретом. Спроси, объясняется ли
он продуктом или evidence. Особенно проверяй:

- одинаковые карточки и одинаковый ритм всех секций;
- декоративные градиенты, blur/glass и тени без иерархической функции;
- один и тот же нейтральный шрифт, палитру и centered hero по привычке;
- вложенные cards, icon tile над каждым заголовком и декоративные labels без смысла;
- серый текст на цветной поверхности, слабый contrast и несогласованные радиусы;
- движение, которое не сообщает hierarchy, feedback или state transition;
- выдуманные цифры, кейсы, отзывы, имена, логотипы и product screenshots.

Любой из этих приёмов допустим, если его требует бренд, задача или подтверждённый референс.

## Production floor

- Реальные assets используй из входов проекта. Если нужен новый внешний asset, честно обозначь
  необходимость поиска, лицензирования или генерации; не подменяй его fake UI.
- Для интерактивной поверхности учитывай loading, empty, error, success, disabled, focus и overflow
  пропорционально реальному поведению.
- Motion уважает `prefers-reduced-motion` и не ухудшает LCP/INP.
- Шрифты для русского текста проверяются на кириллицу, лицензию и способ self-host.
- Цвет текста задаётся по поверхности; один глобальный token не должен ломать mixed themes.

## Проверка готового результата

Сначала проверь собранный render, а не только исходники. По умолчанию объедини desktop и mobile в
один осмотр, исправь подтверждённые проблемы пакетом и сделай подтверждающую проверку. Расширяй цикл
только при новом evidence или повышенном риске. Browser evidence нельзя заменить self-review.

## Инструменты и предпочтения

- Внешний поиск нужен для актуальных референсов, конкурентов, лицензий и доступности ресурсов.
- Browser/Figma/ImageGen подключаются только когда задача зависит от внешнего состояния или требует
  соответствующего артефакта.
- Личные вкусы из `D:/Work/AGENT-PREFERENCES.local.md` — нижележащий preference layer, а не
  универсальные правила. Проектный brief и brand system всегда выше.

## Источники

- [Design direction brief](../../prompts/design-direction-brief.md)
- [Purposeful motion](purposeful-motion.md)
- [Cyrillic self-host fonts](cyrillic-self-host-fonts.md)
- [Semantic theme text tokens](semantic-theme-text-tokens.md)
- [Impeccable](https://github.com/pbakaus/impeccable) — audited 2026-08-10, patterns only
- [Taste Skill](https://github.com/leonxlnx/taste-skill) — audited 2026-08-10, patterns only
