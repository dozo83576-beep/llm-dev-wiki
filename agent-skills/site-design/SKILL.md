---
name: site-design
description: >-
  Фаза визуального дизайна сайта в D:\Work: создаёт современный, отличимый от шаблонного «AI-вида»
  интерфейс — типографика, цветовые токены по поверхностям, сетка, отступы, состояния, доступность.
  Использовать при проектировании UI/дизайн-системы лендинга, SaaS, дашборда или веб-приложения.
  Подключает встроенный дизайн-скилл рантайма (frontend-design в slash-command runtime, ui-ux-pro-max в Codex),
  накладывает одобренные предпочтения из AGENT-PREFERENCES.local.md и frontend-доки/паттерны вики.
---

# site-design — современный визуальный слой

Тонкий роутер. Цель — production-уровень дизайна, а не дженерик-шаблон. Источник правды по приёмам —
встроенный дизайн-скилл рантайма + `D:\Work\llm-dev-wiki` + одобренные предпочтения.

## Requires
- `site-architecture` и `site-content` завершены (структура и контент-модель известны). Идёт до `site-frontend`.

## Подключи дизайн-движок (сначала обнаружь доступные)
Используй **лучший доступный** движок, а не только встроенный. Сначала проверь, что подключено
(`pwsh D:\Work\tools\check-ai-tools.ps1` + список установленных скиллов), затем подключай:
- **Скиллы:** `frontend-design` (slash-command runtime), `ui-ux-pro-max` (Codex, `$ui-ux-pro-max`), и любой
  установленный пользователем дизайн-скилл (напр. `emil-design-eng`/`impeccable`/`taste`) — бери как движок.
- **Дизайн-MCP:** Figma MCP (импорт макета/токенов из готового дизайна), Canva/Gamma MCP (генерация
  ассетов/слайдов) — если подключены и задача того требует.
- **Компоненты:** `shadcn-ui`, `react-best-practices`; премиум-эффекты — `docs/02-frontend/Premium-components.md`.
- **Motion:** `emil-design-eng` если установлен; правила всё равно сверяй с `docs/02-frontend/Motion.md`.
- **Site/CRO helpers:** по `docs/07-mcp-and-ai-tools/External-site-skills.md` можно подключить
  `ux-researcher-designer`, `ui-design-system`, `page-cro`, `form-cro`, `signup-flow-cro`, `ab-test-setup`
  как review/draft helpers. Они не заменяют дизайн-токены, anti-slop правила и предпочтения.
- Нет внешних движков → работает встроенный `frontend-design` + вики (полноценный fallback).
Как добавить внешние дизайн-скиллы/MCP — `docs/07-mcp-and-ai-tools/External-design-skills.md`.
Этот скилл не дублирует их приёмы — он добавляет слой предпочтений (вкус, лицензии, кириллица) и связь с вики,
которая остаётся **source of truth по принципам**; внешние движки — исполнители.

## Сначала прочитай
- `D:\Work\AGENT-PREFERENCES.local.md` — секции «Frontend и design preferences», «Шрифты, визуальные
  референсы и стилистика», «Любимые приемы», «Не предлагать / анти-паттерны». Это приоритетный слой вкуса.
- `D:\Work\llm-dev-wiki\docs\02-frontend\Shadcn.md`, `React.md`, `TypeScript.md`, `Routing.md`, `I18n.md`.
- `D:\Work\llm-dev-wiki\patterns\frontend\` — `semantic-theme-text-tokens.md`, `anti-ai-slop-design.md`,
  `purposeful-motion.md`, `cyrillic-self-host-fonts.md`, `server-client-boundary.md`, `form-validation-boundary.md`.
- Анимации: `D:\Work\llm-dev-wiki\docs\02-frontend\Motion.md` (длительности, easing, reduced-motion, performance).
- Шрифты/цвет/компоновка: `D:\Work\llm-dev-wiki\docs\02-frontend\Typography-fonts.md` (каталог + кириллица + лицензии + стартер-пак `resources\fonts\`),
  `Color-palettes.md`, `patterns\frontend\layout-archetypes.md`.
- Референс-галереи: `D:\Work\llm-dev-wiki\resources\design-inspiration.md` (Awwwards/Godly/Land-book/Mobbin/21st.dev и т.д.).
- Для лендингов/продающих страниц: `D:\Work\llm-dev-wiki\docs\02-frontend\Premium-components.md`,
  `D:\Work\llm-dev-wiki\prompts\design-direction-brief.md`.

## Шаги
1. Применить предпочтения из AGENT-PREFERENCES (шрифты, палитра, стиль, запрещённые приёмы) как стартовые ограничения.
1.5. Перебить дефолтный house style модели (кремовый ~`#F4F1EA` / serif / терракот): задать **конкретные** значения
   `фон hex / акцент hex / шрифт`, а не общие фразы. Сначала спросить про референсы. **Нет референсов — активно
   сходить (WebFetch/WebSearch) на галереи из `resources/design-inspiration.md`** под нишу и извлечь ДНК (не копируя
   вёрстку). Шрифт брать из `Typography-fonts.md` (кириллица + лицензия проверены), палитру — из `Color-palettes.md`,
   компоновку — из `layout-archetypes.md`. Для лендингов записать артефакт `DESIGN-DIRECTION.md`
   по `prompts/design-direction-brief.md` и **показать 1 из 3–4 направлений на выбор до реализации**.
1.6. Для продающего сайта/портфолио `DESIGN-DIRECTION.md` обязателен даже если проект уже начат: без него не продолжать
   визуальный редизайн, иначе агент скатится в прежний шаблон.
2. Подключить дизайн-движок рантайма и собрать дизайн-направление: типографическая шкала, цветовые токены
   **по поверхностям** (text-on-dark / text-on-light — не один глобальный `--text`), сетка, отступы, радиусы, тени.
   Анти-слоп детали: Lucide вместо эмодзи, дефис вместо тире, mono-метки/индексы, hairline, ghost-числа.
2.5. Анти-повторяемость: явно выбрать оси вариативности (hero-архитектура / типографический стек /
   плотность сетки / характер motion) и не переиспользовать связку из прошлого проекта (сверься с `case-studies/`).
3. Определить состояния (hover/focus/disabled/loading/empty/error) и motion-бюджет по `Motion.md`
   (UI < 300ms, `ease-out`, только `transform`/`opacity`).
4. Доступность: контраст AA+, фокус-ринги, клавиатура, семантика, prefers-reduced-motion.
5. Зафиксировать дизайн-токены как single source (CSS vars / theme), на которые опирается реализация.

## Команды-ручки ревью дизайна
Общий словарь для итераций над уже собранным экраном (можно адресовать секции или всему макету):
- `audit` — пройтись по чек-листу анти-слопа и a11y, выписать конкретные нарушения.
- `critique` — честная оценка «дёшево vs дорого» с причинами.
- `polish` — довести детали (типографика, спейсинг, состояния, hairline/ghost-числа) без смены направления.
- `distill` — убрать лишнее, упростить до сути (меньше блоков, тише декор).
- `bolder` / `quieter` — усилить или приглушить визуальную интенсивность (контраст, размер, motion).
- `animate` — добавить motion по `Motion.md`/`purposeful-motion.md` строго в бюджете.

## Quality gate
- Контраст проверен (фактические computed-цвета, не только ожидаемые); нет светлого текста на светлом фоне.
- Токены по поверхностям, а не одна глобальная переменная текста.
- Соблюдены анти-паттерны из AGENT-PREFERENCES.
- Нет дефолтного «AI-вида»: эмодзи, длинного/среднего тире, дефолтного кремового/serif, layout «hero + 3 карточки».
- Для продающего сайта есть `DESIGN-DIRECTION.md` с выбранным направлением, hex-цветами, типографикой и стоп-факторами.
- Есть микро-детали (mono-метки/индексы, hairline, ghost-числа) и motion-бюджет (`prefers-reduced-motion`).
- Кириллица не сыпется в tofu; шрифт self-host для прода / СНГ.
- Проверяет: self-check агента + дизайн-движок рантайма; контраст по computed-цветам (tool).

## Передача дальше
`site-frontend` — реализация по утверждённым дизайн-токенам. Удачные дизайн-решения, одобренные
пользователем, в конце цикла фиксируй через `capture-learnings`.
