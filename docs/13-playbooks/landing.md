---
title: "Playbook: Landing"
category: "playbooks"
updated: "2026-05-24"
status: "active"
tags: ["landing", "seo", "conversion", "marketing"]
source_priority: "internal"
---

# Playbook: Landing

Маркетинговая страница: рассказывает оффер, собирает лиды или ведёт в продукт. Главная метрика — конверсия в CTA, главные риски — медленная загрузка, плохой SEO и спам в формах.

## Когда использовать

- Запуск нового продукта / waitlist / pre-launch.
- Отдельный канал под рекламную кампанию.
- Описание SaaS-продукта рядом с приложением (`/` лендинг, `/app` продукт).

## Когда не использовать

- Полноценный продукт-сайт с десятками страниц — нужен мини-CMS / Astro Content или headless CMS.
- Сложный интерактивный демо-блок — там это уже product page.

## Стек по умолчанию

Astro (или Next.js статика) + Tailwind + forms endpoint (Resend / собственный) + analytics (Plausible/Umami) + SEO metadata + Lighthouse checks + image optimization.

## Порядок разработки

1. **Offer**: кому продаём, какую проблему решаем, какой главный CTA.
2. **Content outline**: hero, social proof, features, objections, FAQ, finally CTA.
3. **Copy first**: пишем тексты, потом дизайн — а не наоборот.
4. **SEO**: title, description, OG tags, structured data (Product/Article/FAQ), правильный canonical.
5. **UI**: responsive, mobile-first, fast first viewport (LCP < 2s).
6. **Forms**: zod / pydantic валидация, honeypot + (опционально) Turnstile/hCaptcha, double opt-in для email, storage в CRM/Sheets/Notion.
7. **Analytics**: page view, scroll depth, CTA click, form submit, conversion funnel.
8. **Performance**: image optimization (WebP/AVIF), font-display swap, минимальный JS.
9. **A/B test plan** (опционально): один тест за раз, понятная метрика.

## Production-паттерны

- Статика по умолчанию (SSG), серверный код только для form submit.
- Edge / CDN с long cache + revalidate on deploy.
- Forms endpoint — отдельный микросервис, не валит всю страницу при ошибке.
- Notification в Slack / email при новом лиде, plus storage в CRM.
- 404 / 500 пользовательские страницы, не дефолт vercel'а.

## Анти-паттерны

- Hero без реального продукта/демо — клиент не понимает, что покупает.
- Тяжёлый React-фреймворк ради одного аккордеона.
- Не проверять mobile first viewport — > 60% трафика обычно мобильный.
- Form без spam protection — лиды забиваются ботами.
- Динамические скрипты-аналитики, блокирующие первый рендер.

## Security risks

Form-spam → email overflow, утечка лидов через открытый Google Sheet, XSS из пользовательского input, CSRF на form endpoint, экспонированный admin endpoint в том же домене.

## Performance risks

Hero-видео без poster, неоптимизированные images (Mb на page weight), сторонние chat-widgets / GTM добавляют 500ms+ к TTI.

## Testing strategy

- Lighthouse CI: performance ≥ 90, a11y ≥ 95, SEO ≥ 95 как baseline.
- Cross-browser smoke (Chrome / Safari / Firefox / mobile Safari).
- Form happy/error/spam path — integration test.
- Visual regression на hero / pricing sections.

## Edge cases

- Multi-language: hreflang, отдельные urls, не на одной странице.
- A/B variant indexing — не дублировать SEO в Google.
- Бесконечная подача рекламы → fraud-clicks: rate-limit по IP.

## Источники

- См. [Performance](../02-frontend/Performance.md), [SEO](../02-frontend/SEO.md), [Forms validation](../02-frontend/Forms-validation.md), [Analytics](../02-frontend/Analytics.md).
