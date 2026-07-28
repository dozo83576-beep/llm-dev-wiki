---
name: site-stack
description: >-
  Фаза выбора стека при сборке сайта в D:\Work: сравнивает 2–3 варианта по типу продукта, команде,
  срокам, нагрузке, интеграциям, бюджету и тех-бенчмарку конкурентов и выбирает один с аргументацией.
  Использовать после discovery и конкурентного анализа, когда нужно зафиксировать frontend/backend/
  БД/hosting. Маршрутизирует в stack-selection, architecture-decision-router и готовые
  stack-blueprints из D:\Work\llm-dev-wiki, с учётом предпочтений стека из AGENT-PREFERENCES.
---

# site-stack — выбор стека

Тонкий роутер. Источник правды — `D:\Work\llm-dev-wiki`. Не выбирай стек «потому что популярный» — нужны причины.

## Requires
- `site-discovery` завершён (тип продукта, требования, acceptance — артефакт `_discovery.md`
  проекта) **и** `site-competitive-analysis` завершён (нужен тех-бенчмарк и stack-сигналы
  конкурентов из `_competitive-analysis.md`, чтобы решение не принималось вслепую). Preflight уже
  выполнен оркестратором и здесь не запускается повторно.

## Сначала прочитай
- Перед сравнением вариантов: `pwsh D:\Work\llm-dev-wiki\tools\ask-wiki.ps1 "<тип продукта + кандидаты стека>"` — поднимет профильные доки и уроки по стекам.
- Слои контекста: project `AGENTS.md` → `D:\Work\AGENTS.md` → `AGENT-PREFERENCES.local.md` → вики — один раз за сессию, не перечитывать, если уже в контексте (правила — оркестратор `build-modern-site`).
- `D:\Work\llm-dev-wiki\docs\01-development-process\site-stack-router-tool.md` — rule-based router,
  исполняемый смоук перед выбором стека.
- `D:\Work\llm-dev-wiki\docs\01-development-process\stack-selection.md` — критерии выбора.
- `D:\Work\llm-dev-wiki\resources\technology-watchlist.json` — **точечно по кандидатам**
  (Select-String по имени технологии или вывод `check-updates.ps1`), не весь файл: здесь стек
  фиксируется впервые, важна актуальность именно сравниваемых вариантов.
- `D:\Work\llm-dev-wiki\docs\01-development-process\site-architecture-decision-router.md` — роутер по типу.
- `D:\Work\llm-dev-wiki\stacks\` — только blueprints сравниваемых кандидатов (2–3 файла из:
  `nextjs-fullstack.md`, `react-spa-api.md`, `nestjs-postgres.md`, `fastapi-postgres.md`,
  `django-postgres.md`, `laravel.md`), не все шесть.
- `D:\Work\llm-dev-wiki\prompts\choose-stack.md` — формат сравнения.
- `D:\Work\AGENT-PREFERENCES.local.md` — одобренные стек-defaults (применять как preference layer, но
  проверять актуальность версий по официальным источникам, не по памяти).
- `D:\Work\llm-dev-wiki\docs\07-mcp-and-ai-tools\External-site-skills.md` — список external helpers и
  default-исключений. Не используй внешние scaffold/generator helpers для выбора стека без явного запроса.

## Шаги
1. Возьми primary playbook, delivery profile и supporting guides из status v2; не переклассифицируй продукт.
2. Возьми ограничения из discovery и примени stack decision router.
2.5. Сверь тех-бенчмарк и stack & rendering signals конкурентов из `_competitive-analysis.md`: если
   конкуренты на устаревшем/медленном стеке — используй это как шанс обогнать (современный SSR/edge/
   ISR/streaming-стек); если конкуренты уже на современном стеке — минимум не отставать по тем же
   характеристикам (Lighthouse-пороги из шага 3 конкурентного анализа).
3. Сравни 2–3 кандидата по критериям stack-selection; для каждого отвергнутого — причина «не выбран».
3.5. Если внешний helper предлагает стек, проверь его против wiki router, KISS/Astro-default и требований проекта.
4. Выбери один стек и сошлись на соответствующий blueprint в `stacks/`.
5. Проверь актуальность ключевых версий/лицензий по официальным докам (не по памяти модели и не по
   preference). Executable-проверка свежести watchlist-технологий:
   `pwsh D:\Work\llm-dev-wiki\tools\check-updates.ps1` (или свежий лог
   `D:\Work\.agent-skills\logs\freshness-*.log` от планового `check-stack-freshness.ps1`).
6. **Артефакт.** Сохрани решение в корень проекта как `_stack.md`: выбранный стек со ссылкой на
   blueprint, сравнённые кандидаты, причины отказов, сверка с тех-бенчмарком конкурентов, версии.
   Это вход для `site-architecture` и точка resume. Если файл уже существует — не пересматривай
   выбор без явной причины, только актуализируй.

## Quality gate
- Выбран один стек с аргументацией и ссылкой на blueprint.
- Решение сохранено в `_stack.md` проекта (или запланировано к материализации после одобрения плана).
- Указаны причины отказа от альтернатив.
- Решение явно сверено с тех-бенчмарком конкурентов (обогнать/не отстать), а не выбрано вслепую.
- Версии/лицензии сверены с актуальными источниками.
- Проверяет: self-check агента + сверка версий по официальным докам (tool/web).

## Передача дальше
`site-architecture` — проектирование архитектуры на выбранном стеке.
