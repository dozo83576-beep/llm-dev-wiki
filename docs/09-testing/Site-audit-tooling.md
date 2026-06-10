---
title: "Site audit tooling"
category: "testing"
updated: "2026-06-10"
status: "active"
tags: ["site-audit", "security-headers", "lighthouse", "performance"]
source_priority: "internal"
---

# Site audit tooling

`tools/site-audit.ps1` — lightweight release smoke для сайта по URL. Он проверяет базовые security headers, CORS-risk и Lighthouse scores без изменения сайта. Lighthouse запускается через pinned package `lighthouse@13.4.0`, чтобы результаты были воспроизводимее; обновлять pin нужно отдельным review.

## Когда использовать

- Перед публикацией landing, SaaS, e-commerce или dashboard.
- После изменения headers, CDN, middleware, CSP, assets или routing.
- Перед handoff пользователю, если есть локальный dev server или staging URL.

## Когда не использовать

- Как замену OWASP ZAP, Burp, manual security review или pen-test.
- Для destructive DAST, fuzzing, auth brute-force или нагрузочного тестирования.
- На production без понимания, что Lighthouse создаёт реальный браузерный трафик.

## Команды

```powershell
# Полный smoke: headers + Lighthouse
pwsh tools/site-audit.ps1 -Url http://localhost:3000

# Несколько маршрутов
pwsh tools/site-audit.ps1 -Url http://localhost:3000 -Routes /pricing,/checkout,/login

# Только security headers, удобно для CI/dev smoke
pwsh tools/site-audit.ps1 -Url http://localhost:3000 -SkipLighthouse -FailOnMedium

# Кастомные thresholds
pwsh tools/site-audit.ps1 -Url https://staging.example.com -LighthouseMinPerformance 85 -FailOnHigh
```

Отчёты пишутся в `site-audit-report.md`, `site-audit-report.json`, `lighthouse-*.html` и `lighthouse-*.json`. Эти файлы local-only и не коммитятся.

## Как подключить в проект

Для проектов в `D:\Work` добавь handoff command в README, project-local docs или `package.json` script:

```powershell
pwsh D:\Work\llm-dev-wiki\tools\site-audit.ps1 -Url http://localhost:3000
```

Готовый snippet для npm scripts и CI/manual smoke см. в [site audit project command](../10-templates/site-audit-project-command.md). Для CI без браузера используй `-SkipLighthouse -FailOnMedium`; полный Lighthouse лучше запускать на локальном/staging handoff.

## Что проверяет

- `Content-Security-Policy`.
- `X-Frame-Options` или `frame-ancestors` в CSP.
- `Referrer-Policy`.
- `Permissions-Policy`.
- `Strict-Transport-Security` для HTTPS.
- Небезопасное сочетание `Access-Control-Allow-Origin: *` и `Access-Control-Allow-Credentials: true`.
- Lighthouse: performance, accessibility, SEO, best practices.

## Как читать результат

- `high` — блокер для релиза, если не оформлено явное исключение.
- `medium` — исправить до production или задокументировать owner exception.
- `low` — не блокирует прототип, но должно попасть в backlog.

Default thresholds: performance `90`, accessibility `95`, SEO `95`, best-practices `90`.

## Production-паттерны

- Запускать на staging или локальном preview URL перед handoff.
- Проверять не только `/`, но и public money pages: `/pricing`, `/checkout`, `/login`, `/contact`.
- Для PR/CI использовать `-SkipLighthouse -FailOnMedium`, если нужен быстрый headers smoke без браузера.
- Для release candidate сохранять HTML Lighthouse report локально и сравнивать с предыдущим release.
- Любой `high` finding превращать в release blocker или явное security exception с owner и сроком пересмотра.

## Частые ошибки

- Считать `site-audit.ps1` полноценным security scan: он не проверяет auth flows, IDOR, CSRF, SSRF и бизнес-логику.
- Запускать Lighthouse только на desktop и не смотреть mobile viewport.
- Игнорировать CSP warning, потому что "сайт работает": CSP ломается чаще всего после добавления analytics/chat/checkout scripts.
- Проверять только home page, хотя реальные риски живут в checkout, auth, dashboard и form routes.
- Коммитить generated audit reports в репозиторий.

## Проверка

- `pwsh tools/site-audit.ps1 -Url <url> -SkipLighthouse -FailOnMedium` проходит без medium/high findings.
- `pwsh tools/site-audit.ps1 -Url <url>` создаёт `site-audit-report.md`, `site-audit-report.json` и Lighthouse reports.
- Security headers соответствуют [Security testing](Security-testing.md) и [security-review checklist](../../checklists/security-review.md).
- Lighthouse scores не ниже проекта-specific thresholds или documented exception.

## Ограничения

Инструмент не логинится, не проверяет business logic, IDOR, CSRF flows, SSRF, upload abuse, dependency CVE и secrets в репозитории. Для этого нужны [Security testing](Security-testing.md), [E2E testing](E2E-testing.md), SAST/SCA/secrets scan и manual review.
