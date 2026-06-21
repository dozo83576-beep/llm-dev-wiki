---
name: site-deploy
description: >-
  Фаза деплоя сайта в D:\Work: переменные окружения, миграции, rollback-first релиз, preview-перед-prod,
  observability и алерты. Использовать при выпуске сайта/веб-приложения на Vercel, Render, Cloudflare,
  Docker или ином таргете. Маршрутизирует в prompts/deploy, devops-доки и release-readiness checklist из
  D:\Work\llm-dev-wiki. Не выполняет prod-мутации, DNS, billing или работу с секретами без явного подтверждения.
---

# site-deploy — выпуск

Тонкий роутер. Источник правды — `D:\Work\llm-dev-wiki`. Рискованные операции — только через dry-run или план отката и явное подтверждение.

## Requires
- `site-review` пройден: нет block-пунктов, UAT и client sign-off (`qa-acceptance`) получены.

## Сначала прочитай
- `D:\Work\llm-dev-wiki\prompts\deploy.md` — каркас выпуска.
- `D:\Work\llm-dev-wiki\docs\08-devops-deploy\` — `Vercel.md`, `Render.md`, `Docker.md`,
  `Docker-compose.md`, `Environment-variables.md`, `Release-flow.md`, `Rollback.md`, `Observability.md`,
  `Sentry.md`, `OpenTelemetry.md`, `CI-templates.md`, `GitHub-actions.md`.
- `D:\Work\llm-dev-wiki\patterns\devops\` — `preview-before-production.md`, `rollback-first-release.md`.
- Для VPS Node-сайта: `D:\Work\llm-dev-wiki\patterns\devops\non-root-vps-node-pm2-nginx-deploy.md`.
- `D:\Work\llm-dev-wiki\checklists\` — `release-readiness.md`, `infrastructure-readiness.md` (DNS/SSL/CDN),
  `backup-restore-drill.md` (для проектов с БД/данными).
- `D:\Work\llm-dev-wiki\docs\07-mcp-and-ai-tools\External-site-skills.md` — optional helpers
  `ci-cd-pipeline-builder`, `observability-designer`, `runbook-generator`, если они установлены.

## Шаги
1. Проверь env vars и секреты (из менеджера секретов/CI, не из репозитория).
1.5. Инфраструктура: пройди `infrastructure-readiness.md` (домен, DNS, SSL/HTTPS, CDN) до переключения на production-домен. Для проектов с данными — `backup-restore-drill.md`.
1.6. Если deploy target — VPS для Node-сайта, root-деплой запрещён как default: создать отдельного пользователя, SSH key, PM2 под этим пользователем, `.env.production` вне архива, ограниченный sudo только для `nginx -t` и reload.
2. Подготовь миграции (обратимые, expand-contract) и план отката.
3. Выкат сначала в preview/staging, затем production; rollback-first — путь отката готов до релиза.
4. На preview/staging для public routes запусти `pwsh D:\Work\llm-dev-wiki\tools\site-audit.ps1 -Url <preview-url>` или зафиксируй documented exception.
5. Подключи monitoring/alerts (Sentry/OTel) и проверь, что они получают данные.
5.5. Если доступны deploy/ops helpers, используй их для черновика CI, observability или runbook; prod-мутации,
   DNS, billing и секреты всё равно только после явного подтверждения.
6. Прогон release-readiness; зафиксируй ссылку на deploy и метрики.

## Quality gate
- release-readiness и infrastructure-readiness пройдены; rollback-путь проверен.
- Для проектов с данными — backup-restore-drill пройден.
- Site audit smoke пройден для public routes перед production.
- Секреты не в репозитории/логах; monitoring активен.
- Для VPS Node-сайта: `pm2 status` показывает не-root пользователя, `.env.production` не перетёрт deploy-архивом, Nginx reload выполняется через ограниченный sudo.
- Prod-мутации/DNS/billing — только после явного подтверждения.
- Проверяет: чеклисты (self-check + tool: site-audit, монитор) + явное подтверждение для рискованных операций.

## Передача дальше
`site-handoff` — передача сайта клиенту (handoff.md, доступы, приёмка, поддержка), затем `capture-learnings`.
