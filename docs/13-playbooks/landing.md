---
title: "Playbook: Landing"
category: "playbooks"
updated: "2026-05-27"
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

[Astro](../02-frontend/Astro.md) (или Next.js статика) + Tailwind + forms endpoint (Resend / собственный) + analytics (Plausible/Umami) + SEO metadata + Lighthouse checks + image optimization. Для сайта с десятками страниц добавь [CMS content](../02-frontend/CMS-content.md).

## Порядок разработки

1. **Offer**: кому продаём, какую проблему решаем, какой главный CTA.
2. **Content outline**: hero, social proof, features, objections, FAQ, finally CTA.
3. **Copy first**: пишем тексты, потом дизайн — а не наоборот.
4. **SEO**: title, description, OG tags, structured data (Product/Article/FAQ), правильный canonical.
5. **UI**: responsive, mobile-first, fast first viewport (LCP < 2s), semantic text tokens для светлых и темных секций.
6. **Forms**: zod / pydantic валидация, honeypot + (опционально) Turnstile/hCaptcha, double opt-in для email, storage в CRM/Sheets/Notion или MVP-уведомление в Telegram/Slack через serverless endpoint.
7. **Analytics**: page view, scroll depth, CTA click, form submit, conversion funnel.
8. **Visual/a11y smoke**: после переноса дизайна на реальные секции проверить FAQ, формы, карточки с фото и CTA на computed color + contrast ratio.
9. **Performance**: image optimization (WebP/AVIF), font-display swap, минимальный JS.
10. **A/B test plan** (опционально): один тест за раз, понятная метрика.

## Production-паттерны

- Статика по умолчанию (SSG), серверный код только для form submit.
- Edge / CDN с long cache + revalidate on deploy.
- Forms endpoint — отдельный микросервис, не валит всю страницу при ошибке.
- Notification в Slack / Telegram / email при новом лиде, plus storage в CRM.
- Для Telegram/Slack MVP токены хранятся только в server env vars; endpoint повторно валидирует payload, экранирует сообщение и имеет fallback для пользователя.
- 404 / 500 пользовательские страницы, не дефолт vercel'а.

## Анти-паттерны

- Hero без реального продукта/демо — клиент не понимает, что покупает.
- Тяжёлый React-фреймворк ради одного аккордеона.
- Не проверять mobile first viewport — > 60% трафика обычно мобильный.
- Form без spam protection — лиды забиваются ботами.
- Отправлять лид напрямую из браузера в Telegram/Slack — токен утечет в client bundle.
- Динамические скрипты-аналитики, блокирующие первый рендер.

## Security risks

Form-spam → email/Telegram overflow, утечка лидов через открытый Google Sheet, XSS/HTML injection из пользовательского input в уведомлении, CSRF на form endpoint, экспонированный admin endpoint в том же домене.

## Performance risks

Hero-видео без poster, неоптимизированные images (Mb на page weight), сторонние chat-widgets / GTM добавляют 500ms+ к TTI.

## Testing strategy

- Lighthouse CI: performance ≥ 90, a11y ≥ 95, SEO ≥ 95 как baseline.
- Cross-browser smoke (Chrome / Safari / Firefox / mobile Safari).
- Form happy/error/spam path — integration test.
- Notification happy/error/dry-run path для Telegram/Slack endpoint.
- Visual regression на hero / pricing sections.
- Contrast smoke для светлых секций и media cards: белый текст не должен наследоваться на светлый фон.

## Edge cases

- Multi-language: hreflang, отдельные urls, не на одной странице.
- A/B variant indexing — не дублировать SEO в Google.
- Бесконечная подача рекламы → fraud-clicks: rate-limit по IP.

## Источники

- См. [Astro](../02-frontend/Astro.md), [CMS content](../02-frontend/CMS-content.md), [Frontend blueprints](../02-frontend/Frontend-blueprints.md), [Performance](../02-frontend/Performance.md), [SEO](../02-frontend/SEO.md), [Forms validation](../02-frontend/Forms-validation.md), [Analytics](../02-frontend/Analytics.md), [semantic theme text tokens](../../patterns/frontend/semantic-theme-text-tokens.md), [telegram lead notification](../../patterns/backend/telegram-lead-notification.md).
