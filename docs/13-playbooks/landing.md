---
title: "Playbook: Landing"
category: "playbooks"
updated: "2026-06-22"
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
- Портфолио услуг / lead-generation portfolio: показать реальные демо-кейсы, собрать заявку и дать понятный канал связи.

## Когда не использовать

- Полноценный продукт-сайт с десятками страниц — нужен мини-CMS / Astro Content или headless CMS.
- Сложный интерактивный демо-блок — там это уже product page.

## Стек по умолчанию

[Astro](../02-frontend/Astro.md) (или Next.js статика) + Tailwind + forms endpoint (Resend / собственный) + analytics (Plausible/Umami) + SEO metadata + Lighthouse checks + image optimization. Для сайта с десятками страниц добавь [CMS content](../02-frontend/CMS-content.md); для editor-owned marketing проверь [WordPress](../02-frontend/WordPress.md) или [Webflow](../02-frontend/Webflow.md).

## Порядок разработки

1. **Offer**: кому продаём, какую проблему решаем, какой главный CTA.
2. **Content outline**: hero, social proof, features, objections, FAQ, finally CTA.
3. **Copy first**: пишем тексты, потом дизайн — а не наоборот.
4. **Design direction**: перебить дефолтный house style модели (кремовый/serif), записать `DESIGN-DIRECTION.md` по [design-direction-brief](../../prompts/design-direction-brief.md), показать 3–4 направления (`фон hex / акцент hex / шрифт`) и дождаться выбора до UI. Приёмы — [anti-ai-slop design](../../patterns/frontend/anti-ai-slop-design.md).
5. **Competitor outliers**: перед UI быстро сравнить 3–5 сильных и 3–5 слабых сайтов ниши. Зафиксировать, что берём из лидеров и какие анти-паттерны избегаем.
6. **SEO**: title, description, OG tags, structured data (Product/Article/FAQ), правильный canonical.
7. **UI**: responsive, mobile-first, fast first viewport (LCP < 2s), semantic text tokens для светлых и темных секций.
8. **Forms / chat widget**: zod / pydantic валидация, honeypot + (опционально) Turnstile/hCaptcha, double opt-in для email, storage в CRM/Sheets/Notion или MVP-уведомление в Telegram/Slack через serverless endpoint. Если нужен AI-консультант, проектируй его по [AI chat widget](../07-mcp-and-ai-tools/AI-chat-widget.md) и держи provider key только на backend.
9. **Analytics**: page view, scroll depth, CTA click, form submit, conversion funnel.
10. **Visual/a11y smoke**: после переноса дизайна на реальные секции проверить FAQ, формы, карточки с фото и CTA на computed color + contrast ratio.
11. **Performance**: image optimization (WebP/AVIF), font-display swap, минимальный JS.
12. **A/B test plan** (опционально): один тест за раз, понятная метрика.

### Вариант: портфолио услуг

- Показывать только реальные демо-проекты или разрешённые кейсы; не выдумывать клиентов, отзывы, конверсию и заявки.
- Данные кейсов держать в простом data/content слое; CMS добавлять только при реальном редакторском workflow.
- Для галереи кейсов использовать отдельные preview/fullImage: компактные превью не должны быть full-page полотнами, lightbox открывает отдельный полный скриншот.
- Для формы заявки хранить токены уведомлений только в server env; если env нет, endpoint должен иметь dry-run/fallback и понятное сообщение.
- Для VPS Node deploy по умолчанию использовать non-root пользователя, PM2, Nginx reverse proxy и `.env.production` вне архива.

### Вариант: lead-generation с каталогом и калькулятором

- Если пользователь дал или в ходе проекта был создан visual reference, сохранить его в проекте и использовать как проверяемый source of truth для first viewport, карточек, CTA, секционного ритма, типографики и mobile.
- Для каталогов, калькуляторов и FAQ применять [screen-section lead landing](../../patterns/frontend/screen-section-lead-landing.md): один смысловой блок на экран, а длинный контент — через bounded viewport и внутреннюю прокрутку.
- Финансовые цифры, платежи, предложения и налоговые оценки всегда маркировать как предварительный расчет, не публичную оферту.
- Если нет подтвержденных клиентских историй, не писать "реальные кейсы"; вместо этого использовать "готовые предложения" или "сценарии" из фактических моделей/услуг каталога.
- Квиз-воронка должна вести в основной расчет или форму и передавать выбранные параметры, а не жить отдельной веткой без продолжения.
- Фото карточек должны соответствовать названию позиции; если фото не хватает, использовать легальный источник/локальную генерацию и фиксировать attribution или `photo-sourcing`.

## Production-паттерны

- Статика по умолчанию (SSG), серверный код только для form submit.
- Edge / CDN с long cache + revalidate on deploy.
- Forms endpoint — отдельный микросервис, не валит всю страницу при ошибке.
- Notification в Slack / Telegram / email при новом лиде, plus storage в CRM.
- Для Telegram/Slack MVP токены хранятся только в server env vars; endpoint повторно валидирует payload, экранирует сообщение и имеет fallback для пользователя.
- 404 / 500 пользовательские страницы, не дефолт vercel'а.

### Конверсионные микро-принципы

- H1 не длиннее 7 слов, оффер понятен с первого взгляда — сайты «глядят», не читают.
- Один экран = одна мысль. Главная ошибка — высокая плотность текста.
- Trust/proof должен появиться до первого серьёзного сомнения: логотипы, цифры, демо, лицензии, реальные кейсы или явные плейсхолдеры.
- «Don't make me think»: green=good / red=bad, без нагрузки на критическое мышление.
- Баланс контента 70% польза / 20% кейсы / 10% продажа; дефицит + дедлайн у CTA.
- Честность данных: только реальные кейсы/цифры/отзывы; нет — явные плейсхолдеры, не выдумка.

## Анти-паттерны

- Hero без реального продукта/демо — клиент не понимает, что покупает.
- Портфолио с фейковыми коммерческими метриками — юридический и репутационный риск.
- Тяжёлый React-фреймворк ради одного аккордеона.
- Не проверять mobile first viewport — > 60% трафика обычно мобильный.
- Form без spam protection — лиды забиваются ботами.
- Отправлять лид напрямую из браузера в Telegram/Slack — токен утечет в client bundle.
- Динамические скрипты-аналитики, блокирующие первый рендер.
- Дефолтный «AI-вид»: кремовый фон + serif, layout «hero + 3 карточки», эмодзи вместо иконок, длинное/среднее тире в копии.
- AI-чат-виджет без границ: выдумывает цены, обещает результат, собирает ПДн без consent или светит API key во frontend.

## Security risks

Form-spam → email/Telegram overflow, утечка лидов через открытый Google Sheet, XSS/HTML injection из пользовательского input в уведомлении, CSRF на form endpoint, экспонированный admin endpoint в том же домене. Для AI-виджетов добавляются prompt injection, утечка PII в логи, hallucinated claims и exposed provider key.

## Performance risks

Hero-видео без poster, неоптимизированные images (Mb на page weight), сторонние chat-widgets / GTM добавляют 500ms+ к TTI. Если hero-video нужен как вау-эффект, используй короткий muted loop с poster, lazy policy и fallback для reduced data/motion.

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

- См. [Astro](../02-frontend/Astro.md), [Eleventy](../02-frontend/Eleventy.md), [Hugo](../02-frontend/Hugo.md), [CMS content](../02-frontend/CMS-content.md), [WordPress](../02-frontend/WordPress.md), [Webflow](../02-frontend/Webflow.md), [Frontend blueprints](../02-frontend/Frontend-blueprints.md), [Performance](../02-frontend/Performance.md), [SEO](../02-frontend/SEO.md), [Forms validation](../02-frontend/Forms-validation.md), [Analytics](../02-frontend/Analytics.md), [AI chat widget](../07-mcp-and-ai-tools/AI-chat-widget.md), [semantic theme text tokens](../../patterns/frontend/semantic-theme-text-tokens.md), [telegram lead notification](../../patterns/backend/telegram-lead-notification.md), [portfolio case screenshot gallery](../../patterns/frontend/portfolio-case-screenshot-gallery.md), [screen-section lead landing](../../patterns/frontend/screen-section-lead-landing.md), [non-root VPS Node deploy](../../patterns/devops/non-root-vps-node-pm2-nginx-deploy.md), [anti-ai-slop design](../../patterns/frontend/anti-ai-slop-design.md), [cyrillic / self-host fonts](../../patterns/frontend/cyrillic-self-host-fonts.md), [Premium-components](../02-frontend/Premium-components.md), [design-direction-brief](../../prompts/design-direction-brief.md).
