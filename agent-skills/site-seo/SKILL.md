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
- `site-content` завершён (страницы, тексты, hreflang определены).
- Идёт **параллельно с `site-frontend`** после site-content; финальные метрики снимаются на реализованных страницах.

## Когда использовать
- Перед релизом публичного сайта; при SEO/performance-аудите.
- Когда важна индексация, выдача и Core Web Vitals.

## Когда НЕ использовать
- Внутренние админки/дашборды за авторизацией без публичной индексации — достаточно базовых метатегов и `noindex`.

## Сначала прочитай
- `D:\Work\llm-dev-wiki\docs\02-frontend\SEO.md` — метатеги, sitemap, robots, structured data, canonical.
- `D:\Work\llm-dev-wiki\docs\02-frontend\Performance.md` — Core Web Vitals и performance budgets.
- `D:\Work\llm-dev-wiki\docs\02-frontend\Analytics.md` — измерение трафика и событий.
- `D:\Work\llm-dev-wiki\docs\02-frontend\Accessibility.md`, `docs\09-testing\Accessibility-testing.md`.
- `D:\Work\llm-dev-wiki\checklists\frontend-review.md`, `D:\Work\llm-dev-wiki\checklists\analytics-verification.md`; для лендинга — `docs\13-playbooks\landing.md`.
- `D:\Work\llm-dev-wiki\docs\07-mcp-and-ai-tools\External-site-skills.md` — optional helpers
  `seo-audit`, `schema-markup`, `aeo`, `analytics-tracking`, `programmatic-seo`, если они установлены.

## Шаги
1. Метаданные на каждую страницу: title, description, canonical, Open Graph/Twitter, lang/hreflang при i18n.
1.5. Если доступны SEO/analytics helpers, используй их для аудита и draft schema/событий; финальная проверка
   всё равно через валидаторы, Lighthouse/PSI и analytics checklist.
2. Индексация: `sitemap.xml`, `robots.txt`, корректные `noindex` для приватных/служебных маршрутов.
3. Structured data (Schema.org) под тип страницы (Organization, Product, Article, FAQ, LocalBusiness).
4. Core Web Vitals: LCP/CLS/INP в бюджете; изображения с размерами и lazy-load; шрифты без layout shift.
5. Аналитика и измеримость: проверка по `analytics-verification.md`; выдача rich-результатов через Google Rich Results Test.

## Quality gate
- Уникальные title/description и canonical на ключевых публичных страницах (hero/каталог/карточка/контент-страница); sitemap и robots валидны.
- Structured data проходит Google Rich Results Test; нет случайного `noindex` на публичных страницах.
- Core Web Vitals в бюджете — измерено Lighthouse / PageSpeed Insights на проде/preview, а не на глаз.
- Аналитика подтверждена по `analytics-verification.md` (события приходят, consent уважается).
- Проверяет: инструменты (Lighthouse/PSI, Rich Results Test, валидатор sitemap) + self-check.

## Передача дальше
`site-deploy` — выпуск. Удачные SEO-приёмы фиксируй через `capture-learnings`.
