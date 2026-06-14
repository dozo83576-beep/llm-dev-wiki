---
title: "Успешное решение: статический сайт детского спортивного психолога (sport-psy)"
category: "case-study"
updated: "2026-06-13"
status: "validated"
tags: ["static-site", "astro", "content-collections", "keystatic", "booking", "telegram", "seo", "vercel"]
source_priority: "internal"
date: "2026-06-13"
project_type: "landing"
stack: ["Astro", "TypeScript", "Tailwind CSS v4", "Astro Content Collections", "Keystatic", "DIKIDI", "Vercel"]
---

# Контекст

Маркетингово-контентный сайт частного специалиста (детский спортивный психолог), аудитория РФ/СНГ:
лендинг + разделы (проблемы, услуги, методы, о специалисте, отзывы, блог, контакты), SEO-страницы под
виды спорта (хоккей/футбол/теннис/гимнастика-балет) и воронка на консультацию. Требования из брифа:
«сначала смыслы, потом дизайн», CMS не WordPress, сильное SEO под разные виды спорта, формы записи и
кнопки связи, запись на бесплатную консультацию.

# Решение

Стек — **Astro static** + TypeScript + Tailwind v4. Контент — **Astro Content Collections**
(`sports`, `posts`, `reviews`) как источник правды; SEO-страницы спорта генерируются из коллекции.

Ключевые переиспользуемые решения:

- **CMS не WordPress, без потери статики**: Keystatic как git-CMS включается только локально под флагом
  `ENABLE_KEYSTATIC`; прод остаётся чистой статикой — см.
  [pattern: static-site-dev-only-cms-flag](../../patterns/frontend/static-site-dev-only-cms-flag.md).
- **Смыслы прежде дизайна**: главная построена по логике «родитель узнаёт свою ситуацию» (hero →
  «вам это знакомо?» → рефрейм → услуги 1:1 к проблемам → методы → отзывы → FAQ → CTA); тексты говорят
  и с родителем, и с тренером.
- **SEO**: уникальные title/description/canonical/OG, sitemap, robots, JSON-LD
  (ProfessionalService/FAQPage/BreadcrumbList/Article/Person), ЧПУ, перелинковка; OG-баннеры
  генерируются скриптом на `sharp` из SVG.
- **Запись через DIKIDI** (РФ-сервис) попапом на странице: бесплатная 20-мин и платная 1-ч.
  Платная вынесена на **отдельную страницу** со своим текстом и баннером-превью; обе кнопки — триггеры
  одного лоадера. См. [pattern: third-party-booking-widget](../../patterns/frontend/third-party-booking-widget.md).
- **Лиды в Telegram** через serverless endpoint `/api/lead` (honeypot, серверная валидация, экранирование,
  опц. e-mail/Resend, опц. Turnstile, dry-run без env) — см.
  [pattern: telegram-lead-notification](../../patterns/backend/telegram-lead-notification.md).
- **Деплой**: изначально под Cloudflare Pages (функция в `functions/`), затем мигрировано на **Vercel** —
  статика из `dist` + нативная функция `/api/lead.js` (без адаптера).
- **Дизайн-токены** по поверхностям — см.
  [semantic-theme-text-tokens](../../patterns/frontend/semantic-theme-text-tokens.md); первый экран —
  [full-height-first-screen](../../patterns/frontend/full-height-first-screen.md).

# Почему сработало

- Статический Astro дал лучший SEO/perf и предсказуемый деплой; контент в коллекциях упростил
  генерацию SEO-страниц под виды спорта.
- Дев-онли CMS закрыла требование «удобная CMS не WordPress», не утянув прод в SSR.
- Выбор DIKIDI вместо Calendly спас воронку: Calendly недоступен из РФ, а виджет грузится у посетителя —
  см. [урок про региональную доступность](../../lessons-learned/2026-06-13-region-accessible-third-party-embeds.md).
- Серверная граница лид-формы держит токены вне клиента; запись имеет graceful fallback (ссылка +
  Telegram/телефон).
- Vercel-деплой статики + одна `/api`-функция — минимум инфраструктуры под единственный серверный кусок.

# Ограничения

- Запись зависит от стороннего сервиса (DIKIDI): доступность/UX определяются провайдером; в превью без
  интернета попап не открыть.
- Telegram-лид — MVP-канал, не CRM (нет статусов/аналитики/ретраев/юридически значимого хранения).
- Часть контента — плейсхолдеры `TODO_OWNER` (контакты, домен, биография, реальные отзывы, цена и
  виджет платной записи) — заменяет владелец перед релизом.
- Демо-отзывы должны быть заменены реальными (с согласием авторов).

# Проверка

- `npm run build` (18 страниц) и `npm run check` — без ошибок; новая страница в sitemap.
- Запись: в HTML `/konsultaciya` ровно один лоадер `widget2.min.js` и ссылки `#widget=`; платная —
  отдельная страница с баннером и OG.
- Лид-функция (мок req/res, dry-run): happy → 200, без имени/контакта → 400, honeypot → 200 тихо,
  GET → 405; секретов в client-бандле нет.
- Vercel-готовность: нет адаптера/следов Cloudflare в исходниках (Turnstile-домен — легитимная капча);
  `vercel.json` валиден; `node --check api/lead.js`.
- UI верифицирован DOM-метриками (скриншоты в sandbox-превью блокируются внешними скриптами — см. урок).

# Ссылки

- [Pattern: static-site-dev-only-cms-flag](../../patterns/frontend/static-site-dev-only-cms-flag.md)
- [Pattern: third-party-booking-widget](../../patterns/frontend/third-party-booking-widget.md)
- [Pattern: telegram-lead-notification](../../patterns/backend/telegram-lead-notification.md)
- [Pattern: semantic-theme-text-tokens](../../patterns/frontend/semantic-theme-text-tokens.md)
- [Lesson: региональная доступность сторонних эмбедов](../../lessons-learned/2026-06-13-region-accessible-third-party-embeds.md)
- [Lesson: верификация статики в headless-превью](../../lessons-learned/2026-06-11-headless-preview-verification.md)
- [Похожий кейс: статический лендинг ТВОЙ ХИТ](./2026-05-27-tvoi-hit-static-landing.md)
- [Playbook: Landing](../../docs/13-playbooks/landing.md)
