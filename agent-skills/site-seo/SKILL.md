---
name: site-seo
description: >-
  Фаза технического SEO и веб-производительности сайта в D:\Work: метатеги и Open Graph, sitemap.xml,
  robots.txt, Schema.org/structured data, canonical, hreflang, Core Web Vitals и performance budgets.
  Использовать перед запуском лендинга, SaaS, интернет-магазина или контентного сайта, а также при
  SEO-аудите существующего сайта. Маршрутизирует в SEO/Performance/Analytics/Accessibility-доки и
  frontend-review checklist из D:\Work\llm-dev-wiki.
---

# site-seo — техническое SEO и производительность

Тонкий роутер. Источник правды — `D:\Work\llm-dev-wiki`. SEO без производительности и доступности неполноценно.

## Requires
- `site-frontend` завершён (и `site-backend`, если у проекта есть серверная часть) — метрики Core
  Web Vitals и structured data снимаются на финально построенных страницах, а не на промежуточном/
  незавершённом фронтенде. Строго последовательно, не параллельно с `site-frontend`.

## Когда использовать
- Перед релизом публичного сайта; при SEO/performance-аудите.
- Когда важна индексация, выдача и Core Web Vitals.
- Для `private-app` — сокращённый обязательный gate: `noindex`, закрытый sitemap/robots boundary,
  отсутствие утечки приватных route metadata и проверка базовой performance/accessibility.

## Когда НЕ использовать
- Только profile `api-only`, где контракт выставляет фазу `not-applicable`.

## Сначала прочитай
- Слои контекста: project `AGENTS.md` → `D:\Work\AGENTS.md` → `AGENT-PREFERENCES.local.md` → вики — один раз за сессию, не перечитывать, если уже в контексте (правила — оркестратор `build-modern-site`).
- Контент-модель и i18n-строки из `site-content` — `hreflang`/локали берутся оттуда, не
  придумываются заново.
- `D:\Work\llm-dev-wiki\docs\02-frontend\SEO.md` — метатеги, sitemap, robots, structured data, canonical.
- `D:\Work\llm-dev-wiki\docs\02-frontend\Performance.md` — Core Web Vitals и performance budgets.
- `D:\Work\llm-dev-wiki\docs\02-frontend\Analytics.md` — измерение трафика и событий.
- `D:\Work\llm-dev-wiki\docs\02-frontend\Accessibility.md`, `docs\09-testing\Accessibility-testing.md`.
- `D:\Work\llm-dev-wiki\checklists\frontend-review.md`, `D:\Work\llm-dev-wiki\checklists\analytics-verification.md`; для лендинга — `docs\13-playbooks\landing.md`.
- `D:\Work\llm-dev-wiki\docs\07-mcp-and-ai-tools\External-site-skills.md` — optional helpers
  `seo-audit`, `schema-markup`, `aeo`, `analytics-tracking`, `programmatic-seo`, если они установлены.

## Шаги
1. Метаданные на каждую страницу: title, description, canonical, Open Graph/Twitter, lang/hreflang при i18n.
1.5. По умолчанию helper не нужен; при конкретном пробеле используй максимум один SEO/analytics helper. Финальная проверка
   всё равно через валидаторы, Lighthouse/PSI и analytics checklist.
2. Индексация: `sitemap.xml`, `robots.txt`, корректные `noindex` для приватных/служебных маршрутов.
3. Structured data (Schema.org) под тип страницы (Organization, Product, Article, FAQ, LocalBusiness).
4. Core Web Vitals: LCP/CLS/INP в бюджете; изображения с размерами и lazy-load; шрифты без layout shift.
5. Аналитика и измеримость: проверка по `analytics-verification.md`; выдача rich-результатов через Google Rich Results Test.
6. **Артефакт.** Сохрани в корень проекта `_seo-report.md`: метаданные по ключевым страницам,
   статус sitemap/robots/structured data, числа Lighthouse/PSI (LCP/CLS/INP), статус аналитики.
   Это evidence фазы для `_pipeline-status.md` и вход для `site-review`.

## Quality gate
- Уникальные title/description и canonical на ключевых публичных страницах (hero/каталог/карточка/контент-страница); sitemap и robots валидны.
- Structured data проходит Google Rich Results Test; нет случайного `noindex` на публичных страницах.
- Core Web Vitals в бюджете — измерено Lighthouse / PageSpeed Insights на проде/preview, а не на глаз.
- Аналитика подтверждена по `analytics-verification.md` (события приходят, consent уважается).
- Результаты зафиксированы в `_seo-report.md` проекта.
- Проверяет: инструменты (Lighthouse/PSI, Rich Results Test, валидатор sitemap) + self-check.

## Передача дальше
`site-review` — сводное ревью перед релизом (не напрямую в `site-deploy`: security/QA/legal-гейт
обязателен для всех реализационных стадий, включая SEO). Удачные SEO-приёмы фиксируй через
`capture-learnings`.
