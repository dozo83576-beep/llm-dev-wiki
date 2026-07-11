---
name: site-frontend
description: >-
  Фаза реализации frontend сайта в D:\Work: маршруты, компоненты, состояние, формы, доступность и
  performance budgets на выбранном стеке и утверждённых дизайн-токенах. Использовать при написании или
  рефакторинге UI лендинга, SaaS, дашборда или веб-приложения. Маршрутизирует в implement-frontend,
  frontend-доки и frontend-паттерны D:\Work\llm-dev-wiki; код проверяется frontend-review checklist.
---

# site-frontend — реализация frontend

Тонкий роутер. Источник правды — `D:\Work\llm-dev-wiki`. Рабочий код без незавершённых маркеров, с обработкой ошибок и тестами.

## Requires
- `site-design` завершён (есть утверждённые дизайн-токены; для лендинга — `DESIGN-DIRECTION.md`) и
  `site-content` (контент-модель/тексты — `_content-model.md` проекта).
- Если у проекта есть backend: `site-backend` завершён — UI строится против реально работающего API,
  а не бумажного контракта. Для чисто статических сайтов без backend это условие снимается.
- Строго последовательно после `site-backend` (если есть), не параллельно.
- Для `marketplace` фаза единична: один `_frontend-smoke.md` обязан содержать явно маркированные
  секции `Public storefront` и `Private console`; 18-я фаза не создаётся.

## Сначала прочитай
- Слои контекста: project `AGENTS.md` → `D:\Work\AGENTS.md` → `AGENT-PREFERENCES.local.md` → вики — один раз за сессию, не перечитывать, если уже в контексте (правила — оркестратор `build-modern-site`).
- `D:\Work\llm-dev-wiki\prompts\implement-frontend.md` — каркас реализации.
- `D:\Work\llm-dev-wiki\docs\02-frontend\` — `React.md`, `TypeScript.md`, `Routing.md`, `Shadcn.md`, `I18n.md`.
- `patterns\frontend\` — выборочно через `ask-wiki.ps1 "<стек + компонент/проблема>"` (top-2–3:
  границы server/client, валидация форм, токены текста), не каталог целиком (~150KB).
- Для портфолио и кейсов: `D:\Work\llm-dev-wiki\patterns\frontend\portfolio-case-screenshot-gallery.md`.
- `D:\Work\llm-dev-wiki\checklists\frontend-review.md` — критерии качества (использовать как self-check).
- `D:\Work\llm-dev-wiki\docs\07-mcp-and-ai-tools\External-site-skills.md` — optional helpers
  `senior-frontend`, `api-design-reviewer`, `database-designer`, если они установлены и релевантны.

## Шаги
1. Реализуй маршруты и компоненты по плану этапов и дизайн-токенам из `site-design`. Если существует
   `DESIGN-DIRECTION.md` (лендинг/продающая страница) — сверяйся с ним при реализации first
   viewport, карточек, CTA, секционного ритма, типографики и mobile, не только с токенами.
1.5. Если доступен `senior-frontend`, используй его как review/helper для React/Next/TypeScript; для простого
   Astro/static сайта не тащи React/Tailwind только из-за helper-а.
2. Состояние и данные: явные границы server/client, кэш-политика, загрузка/ошибки/пустые состояния.
3. Формы: client-side UX-валидация + расчёт на серверную перепроверку (валидация не доверяется клиенту).
4. Доступность и performance budgets; i18n при необходимости.
5. Для портфолио/кейсов: использовать реальные скриншоты, разделить preview/fullImage, проверить lightbox, mobile и cache-busting plan.
6. Unit-тесты ключевой логики и ≥5 edge cases.
7. **Верификация в браузере (а не «проверь вручную»):** если подключён **Preview MCP** — `preview_start`,
   затем `preview_console_logs`/`preview_snapshot`/`preview_screenshot`/`preview_resize` (mobile/desktop);
   иначе **Playwright MCP**. Проверь первый экран, формы (happy/error), CTA, отсутствие overlap и horizontal scroll.
8. **Артефакт.** Сохрани в корень проекта `_frontend-smoke.md`: результаты браузерной верификации из
   шага 7 (первый экран, формы happy/error, mobile/desktop, console без критичных ошибок, пути к
   скриншотам), статус `frontend-review.md`. Для `marketplace` в этом одном файле сделай секции
   `Public storefront` и `Private console`. Это evidence фазы для `_pipeline-status.md` и вход для
   `site-seo`/`site-review`.

## Quality gate
- Проходит `checklists\frontend-review.md` (нет block-пунктов).
- Результаты браузерного smoke зафиксированы в `_frontend-smoke.md` проекта.
- Для `marketplace` `_frontend-smoke.md` содержит секции `Public storefront` и `Private console`.
- Локальная проверка в браузере: через локальный http-сервер, а не `file://`; предпочтительно Preview MCP / Playwright MCP (см. шаг 7).
- Для case gallery: preview не должен быть full-page полотном, fullImage открывается в lightbox, нет пустых хвостов и horizontal scroll на mobile.
- Нет незавершённых маркеров; ошибки обрабатываются.
- Проверяет: `frontend-review.md` как self-check + локальный прогон в браузере.

## Передача дальше
`site-seo` — оптимизация уже реализованных страниц (метрики снимаются на реальном билде, не на
промежуточном состоянии), строго последовательно. Затем `site-review`.
Опционально (живая дизайн-система, `docs/07-mcp-and-ai-tools/Claude-Design-and-DesignSync.md`): если
проект ведёт design-system проект на claude.ai/design — запушь реализованные компоненты/токены обратно
(DesignSync, `@dsCard`-превью из `_design/ds-preview/`), инкрементально и только после ревью `finalize_plan`.
