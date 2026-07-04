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
- `site-design` завершён (есть утверждённые дизайн-токены) и `site-content` (контент-модель/тексты).
- Если у проекта есть backend: `site-backend` завершён — UI строится против реально работающего API,
  а не бумажного контракта. Для чисто статических сайтов без backend это условие снимается.
- Строго последовательно после `site-backend` (если есть), не параллельно.

## Сначала прочитай
- Project-local `AGENTS.md` в корне проекта, если есть — высший приоритет контекста (см.
  `D:\Work\AGENTS.md` и оркестратор `build-modern-site`).
- `D:\Work\llm-dev-wiki\prompts\implement-frontend.md` — каркас реализации.
- `D:\Work\llm-dev-wiki\docs\02-frontend\` — `React.md`, `TypeScript.md`, `Routing.md`, `Shadcn.md`, `I18n.md`.
- `D:\Work\llm-dev-wiki\patterns\frontend\` — границы server/client, валидация форм, токены текста.
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

## Quality gate
- Проходит `checklists\frontend-review.md` (нет block-пунктов).
- Локальная проверка в браузере: через локальный http-сервер, а не `file://`; предпочтительно Preview MCP / Playwright MCP (см. шаг 7).
- Для case gallery: preview не должен быть full-page полотном, fullImage открывается в lightbox, нет пустых хвостов и horizontal scroll на mobile.
- Нет незавершённых маркеров; ошибки обрабатываются.
- Проверяет: `frontend-review.md` как self-check + локальный прогон в браузере.

## Передача дальше
`site-seo` — оптимизация уже реализованных страниц (метрики снимаются на реальном билде, не на
промежуточном состоянии), строго последовательно. Затем `site-review`.
