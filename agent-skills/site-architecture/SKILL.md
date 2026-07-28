---
name: site-architecture
description: >-
  Фаза проектирования архитектуры сайта в D:\Work: компоненты, границы ответственности, data flow, API,
  модель данных, auth, очереди, интеграции и deploy, с разбивкой реализации на 3–6 проверяемых этапов.
  Использовать после выбора стека и до написания кода. Маршрутизирует в design-architecture,
  implementation-plan, design-database и профильный playbook из D:\Work\llm-dev-wiki.
---

# site-architecture — архитектура и план

Тонкий роутер. Источник правды — `D:\Work\llm-dev-wiki`. Перед кодом всегда сначала архитектура.

## Requires
- `site-stack` завершён (стек выбран и обоснован — артефакт `_stack.md` проекта) и есть план сайта
  из `site-competitive-analysis` (`_competitive-analysis.md`); требования — из `_discovery.md`.

## Сначала прочитай
- Перед проектированием: `pwsh D:\Work\llm-dev-wiki\tools\ask-wiki.ps1 "<домен + API/данные/auth>"` — поднимет паттерны и уроки по архитектуре.
- Слои контекста: project `AGENTS.md` → `D:\Work\AGENTS.md` → `AGENT-PREFERENCES.local.md` → вики — один раз за сессию, не перечитывать, если уже в контексте (правила — оркестратор `build-modern-site`).
- `_competitive-analysis.md` проекта (артефакт `site-competitive-analysis`) — полный план, sitemap
  и приоритизированные фичи из конкурентного анализа.
- `D:\Work\llm-dev-wiki\prompts\design-architecture.md` — каркас архитектуры.
- `D:\Work\llm-dev-wiki\prompts\implementation-plan.md` — разбивка на этапы с acceptance.
- `D:\Work\llm-dev-wiki\prompts\design-database.md` — модель данных, индексы, миграции.
- Только файл playbook, выбранного на фазе 3 (путь — в `_pipeline-status.md`), не каталог
  `docs\13-playbooks\` целиком.
- `D:\Work\llm-dev-wiki\docs\06-api-design\` — выборочно: при проектировании API-контрактов открой
  REST/OpenAPI + контракт ошибок; остальное (пагинация, версии, WebSockets) — по потребности проекта.
- `D:\Work\llm-dev-wiki\patterns\` — не каталог целиком: `ask-wiki.ps1 "<домен + паттерн>"` → открой
  top-2–3 релевантных (api, backend, database, security, devops).
- `D:\Work\llm-dev-wiki\docs\07-mcp-and-ai-tools\External-site-skills.md` — optional helpers для API/БД,
  если они установлены. Конфликтующий внешний `site-architecture` не использовать вместо этого локального скилла.

## Шаги
1. Опиши компоненты и границы ответственности: frontend, backend, данные, auth, API, очереди,
   интеграции, deploy. Для playbook `ai-rag-app` — отдельным компонентом добавь ingestion/indexing
   pipeline (source curation, chunking, embedding, версионирование индекса), это не «просто backend».
   Для playbook `real-time-app` — явно зафиксируй транспорт (WebSocket/SSE/polling) и
   hosting-совместимость: stateful long-lived соединения требуют не-serverless таргет, не
   Vercel-style edge functions.
1.5. Сверься с `D:\Work\llm-dev-wiki\resources\technology-watchlist.json` и (если подключены)
   context7/WebSearch на предмет текущих best-practice архитектурных паттернов для этого типа
   продукта (RSC/edge functions/ISR/streaming/event-driven и т.п.). Цель — не просто повторить то,
   что уже сделали конкуренты (план из `site-competitive-analysis`), а по возможности их обогнать.
2. Нарисуй data flow и ключевые контракты (REST/OpenAPI, события, вебхуки).
2.5. По умолчанию helper не нужен. При конкретном пробеле выбери не более одного из
   `api-design-reviewer`/`database-designer`; итог остаётся по локальным prompts и playbook.
3. Спроектируй модель данных: сущности, связи, индексы, миграции, audit log, backup.
4. Перечисли top-5 security-рисков и mitigations; отметь edge cases (≥5).
5. Разбей реализацию на 3–6 этапов, каждый с измеримым acceptance.
6. **Артефакт.** Сохрани архитектуру в корень проекта как `_architecture.md`: компоненты и границы,
   data flow, API-контракты, модель данных, top-5 рисков, edge cases и план этапов с acceptance.
   Это вход для `site-content`, `site-backend` и `site-frontend` — и точка resume. Если файл уже
   существует — актуализируй, а не проектируй с нуля.

## Quality gate
- Есть карта компонентов, data flow, модель данных и API-контракты.
- План этапов с acceptance; top-5 рисков; ≥5 edge cases.
- Проверяет: self-check агента по prompts/implementation-plan; план зафиксирован как артефакт
  `_architecture.md` (или запланирован к материализации после одобрения плана).

## Передача дальше
После `project-agents` выполни применимый `site-content`. Затем `site-design` и `site-backend`
независимы и могут закрываться в любом порядке; `site-frontend` ждёт оба применимых результата.
Для profile `api-only` контракт выставляет content/design/frontend/SEO как `not-applicable`.

Для playbook `marketplace` фазы `site-design` и `site-frontend` остаются единичными (18-й фазы нет):
их artifact обязан содержать две явно маркированные секции — `Public storefront` (SEO, покупатели) и
`Private console` (продавец/модерация, без публичной индексации). Не смешивать токены и SEO-требования
этих секций.
