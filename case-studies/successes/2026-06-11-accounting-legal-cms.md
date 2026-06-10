---
title: "Успешное решение: CMS-сайт бухгалтерских и юридических услуг"
category: "case-study"
updated: "2026-06-11"
status: "validated"
tags: ["nextjs", "payload", "cms", "content-site", "forms", "site-audit"]
source_priority: "internal"
date: "2026-06-11"
project_type: "content-site"
stack: ["Next.js 16", "Payload CMS 3", "PostgreSQL", "Resend", "Vercel Blob", "Playwright", "Vitest"]
---

# Контекст

Нужно было собрать расширенный сайт-визитку для бухгалтерских и юридических услуг: публичные SEO-страницы, статьи, квизы, формы заявок и CMS-админку для редактирования контента. Требования включали мобильную адаптивность, формы обратной связи, стартовый тематический контент и возможность добавлять новые страницы.

# Решение

Выбран code-first CMS-подход: Next.js App Router и Payload CMS в одной TypeScript-кодовой базе. Публичный сайт получил fallback-контент в коде для раннего visual/browser smoke без базы, а Payload schema и seed-скрипт остались отдельным CMS-слоем для production-настройки через `DATABASE_URL`.

Формы заявок валидируются на сервере, используют honeypot, поддерживают dry-run email и сохраняют лиды в CMS при наличии базы. Публичные страницы имеют metadata, sitemap, robots и базовые security headers. Для hero использован project-bound bitmap asset, а не SVG-заглушка.

# Почему сработало

- Payload хорошо подошёл, потому что нужны редакторские коллекции, роли, медиа, заявки и квизы без отдельной Strapi/WordPress-инфраструктуры.
- Public fallback content позволил проверить frontend, адаптивность и формы до подключения Postgres.
- Dry-run email снизил риск утечки секретов и позволил проверить путь заявки без реального Resend API key.
- Минимальные security headers закрыли findings `site-audit.ps1 -SkipLighthouse` без сложного CSP, который мог бы сломать Next.js/Payload admin.

# Кодовые и архитектурные паттерны

- Для MVP content site держать отдельно: Payload schema, public fallback content и seed.
- Для форм использовать shared validation module и серверный endpoint; не отправлять email или заявки напрямую из браузера.
- Для редакторского контента добавлять SEO-поля, slug uniqueness, draft/publish и role-based access до первого запуска админки.
- Для handoff запускать: unit tests, lint, typecheck, build, Playwright smoke и `site-audit.ps1 -SkipLighthouse`.

# Ограничения

Подход не заменяет полноценный production deploy: для админки и seed нужна реальная Postgres-база, секрет `PAYLOAD_SECRET`, storage token и email provider. Public fallback content удобен для MVP smoke, но после подключения CMS нужно определить source of truth и не поддерживать два независимых набора контента вручную.

# Проверка

- `npm test` — unit-тесты валидации заявок и scoring квизов.
- `npm run lint` — ESLint.
- `npx tsc --noEmit` — TypeScript.
- `npm run build` — Next.js production build.
- `npm audit --omit=dev` — 0 vulnerabilities после npm overrides для транзитивных пакетов.
- Playwright smoke — основные public routes, форма заявки и квиз.
- `pwsh tools/site-audit.ps1 -Url http://localhost:3000 -SkipLighthouse` — findings 0 после добавления headers.

# Ссылки

- [Payload CMS](../../docs/02-frontend/Payload-CMS.md)
- [CMS and content sites](../../docs/02-frontend/CMS-content.md)
- [Site audit tooling](../../docs/09-testing/Site-audit-tooling.md)
- [Forms validation](../../docs/02-frontend/Forms-validation.md)
- [Security testing](../../docs/09-testing/Security-testing.md)
