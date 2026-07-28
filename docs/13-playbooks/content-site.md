---
title: "Playbook: Content site"
category: "playbooks"
updated: "2026-07-21"
status: "active"
tags: ["content", "corporate", "cms", "seo", "static"]
source_priority: "internal"
---

# Playbook: Content site

Публичный корпоративный, редакционный или справочный сайт, где основная ценность — страницы,
материалы, навигация и органический трафик, а не приложение после авторизации. Playbook закрывает
разрыв между одностраничным landing и полноценным SaaS/e-commerce.

## Когда использовать

- Корпоративный сайт, каталог услуг, медиа, блог, документация или help center.
- Контентом владеют разработчики либо редакторы через CMS.
- Нужны SEO, sitemap, redirects, поиск, локали или многостраничная информационная архитектура.

## Когда не использовать

- Один оффер и один основной CTA — используй `landing`.
- Есть защищённые роли, сложное состояние приложения или billing — используй `saas`/`admin-dashboard`.
- Каталог заканчивается корзиной и checkout — используй `ecommerce`.

## Delivery profile и стек

- `public-static` — default: Astro/Eleventy/Hugo, filesystem content или hosted CMS на build-time.
- `public-fullstack` — если нужны server search, preview, персонализация, формы или self-hosted CMS.
- Стек выбирается после discovery и reference analysis; CMS не добавляется без реального
  редакторского workflow.

## Порядок разработки

1. Зафиксировать аудиторию, владельца контента, типы материалов, локали и lifecycle публикации.
2. Провести reference analysis: 3–5 сопоставимых сайтов, IA, поиск, шаблоны страниц и SEO-бенчмарк.
3. Спроектировать content model, URL taxonomy, navigation, breadcrumbs, redirects и ownership.
4. Выбрать static/CMS boundary, preview/publish workflow и cache invalidation.
5. Утвердить дизайн-направление на реальном контенте, включая длинные заголовки, таблицы и media.
6. Реализовать шаблоны страниц, поиск/фильтры при необходимости, empty/error states и accessibility.
7. Проверить metadata, canonical, sitemap, robots, structured data, hreflang и Core Web Vitals.
8. Пройти link/redirect/content smoke, editorial UAT, preview deploy и production handoff.

## Production-паттерны

- Контент имеет один source of truth; не дублируй записи между filesystem, CMS и product DB.
- Redirect map версионируется и тестируется до миграции URL.
- Preview не индексируется; production canonical не указывает на preview-домен.
- Изображения имеют размеры, responsive variants, alt policy и лицензионное происхождение.
- Для больших коллекций заранее фиксируются pagination/search/indexing и build-time budgets.

## Проверка

- Все обязательные content types имеют реальные примеры и проходят schema validation.
- Broken links, redirects, sitemap и canonical проверены автоматически.
- Редактор может создать, предварительно просмотреть, опубликовать и снять материал без доступа к секретам.
- Mobile/desktop, keyboard navigation, empty search и 404/500 проходят smoke.
- Для `public-static` фаза `site-backend` отмечена `not-applicable`; server-side функциональность не маскируется под static.

## Частые ошибки

- Отправлять любой «каталог» в e-commerce/Shopify, хотя это каталог услуг без cart/checkout.
- Добавлять CMS без владельца editorial workflow или backend к полностью static delivery profile.
- Проектировать шаблоны на lorem ipsum и обнаруживать переполнение только после загрузки контента.
- Менять URL taxonomy без redirect map и проверки canonical/sitemap.

## Связанные документы

- [CMS content](../02-frontend/CMS-content.md)
- [Content migration](../02-frontend/Content-migration.md)
- [SEO](../02-frontend/SEO.md)
- [I18n](../02-frontend/I18n.md)
- [Frontend blueprints](../02-frontend/Frontend-blueprints.md)

## Источники

- [Site pipeline contract](../../resources/site-pipeline-contract.json)
- [Site architecture decision router](../01-development-process/site-architecture-decision-router.md)
