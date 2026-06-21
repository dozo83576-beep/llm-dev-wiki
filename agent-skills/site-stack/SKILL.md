---
name: site-stack
description: >-
  Фаза выбора стека при сборке сайта в D:\Work: сравнивает 2–3 варианта по типу продукта, команде,
  срокам, нагрузке, интеграциям и бюджету и выбирает один с аргументацией. Использовать после
  discovery, когда нужно зафиксировать frontend/backend/БД/hosting. Маршрутизирует в stack-selection,
  architecture-decision-router и готовые stack-blueprints из D:\Work\llm-dev-wiki, с учётом предпочтений
  стека из AGENT-PREFERENCES.
---

# site-stack — выбор стека

Тонкий роутер. Источник правды — `D:\Work\llm-dev-wiki`. Не выбирай стек «потому что популярный» — нужны причины.

## Requires
- `site-discovery` завершён (тип продукта, требования, acceptance), либо raw request → preflight (см. шаг 1).

## Сначала прочитай
- `D:\Work\llm-dev-wiki\docs\01-development-process\new-site-preflight-tool.md` — executable preflight для raw request.
- `D:\Work\llm-dev-wiki\docs\01-development-process\stack-selection.md` — критерии выбора.
- `D:\Work\llm-dev-wiki\docs\01-development-process\site-architecture-decision-router.md` — роутер по типу.
- `D:\Work\llm-dev-wiki\stacks\` — готовые blueprints: `nextjs-fullstack.md`, `react-spa-api.md`,
  `nestjs-postgres.md`, `fastapi-postgres.md`, `django-postgres.md`, `laravel.md`.
- `D:\Work\llm-dev-wiki\prompts\choose-stack.md` — формат сравнения.
- `D:\Work\AGENT-PREFERENCES.local.md` — одобренные стек-defaults (применять как preference layer, но
  проверять актуальность версий по официальным источникам, не по памяти).
- `D:\Work\llm-dev-wiki\docs\07-mcp-and-ai-tools\External-site-skills.md` — список external helpers и
  default-исключений. Не используй внешние scaffold/generator helpers для выбора стека без явного запроса.

## Шаги
1. Если пользователь пишет `Я хочу создать сайт <описание сайта>`, трактуй текст после фразы как raw request. Если есть raw request, запусти `pwsh D:\Work\llm-dev-wiki\tools\new-site-preflight.ps1 -Request "<raw request>"`. При `needs-discovery` задай вопросы и не фиксируй стек.
2. Возьми тип проекта из discovery и примени decision router.
3. Сравни 2–3 кандидата по критериям stack-selection; для каждого отвергнутого — причина «не выбран».
3.5. Если внешний helper предлагает стек, проверь его против wiki router, KISS/Astro-default и требований проекта.
4. Выбери один стек и сошлись на соответствующий blueprint в `stacks/`.
5. Проверь актуальность ключевых версий/лицензий по официальным докам (не по памяти модели и не по preference).

## Quality gate
- Выбран один стек с аргументацией и ссылкой на blueprint.
- Указаны причины отказа от альтернатив.
- Версии/лицензии сверены с актуальными источниками.
- Проверяет: self-check агента + сверка версий по официальным докам (tool/web).

## Передача дальше
`site-architecture` — проектирование архитектуры на выбранном стеке.
