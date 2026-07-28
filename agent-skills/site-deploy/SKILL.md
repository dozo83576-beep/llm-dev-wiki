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
- `site-review` пройден: нет block-пунктов и зафиксирована UAT readiness.

## Сначала прочитай
- Перед деплоем: `pwsh D:\Work\llm-dev-wiki\tools\ask-wiki.ps1 "<платформа + деплой>"` — поднимет deploy-паттерны и уроки по платформе.
- Слои контекста: project `AGENTS.md` → `D:\Work\AGENTS.md` → `AGENT-PREFERENCES.local.md` → вики — один раз за сессию, не перечитывать, если уже в контексте (правила — оркестратор `build-modern-site`).
- `D:\Work\llm-dev-wiki\prompts\deploy.md` — каркас выпуска.
- `D:\Work\llm-dev-wiki\docs\08-devops-deploy\` — только док выбранного deploy-таргета
  (`Vercel.md` / `Render.md` / `Docker.md` / …) + `Release-flow.md` и `Rollback.md`; остальное
  (observability, CI) — по потребности, не весь каталог (~96KB).
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
3. Выкат сначала в preview/staging; rollback-first — путь отката готов до promotion.
4. На preview повтори smoke-набор из `_frontend-smoke.md` и site audit для public routes.
4.5. Покажи preview/evidence уполномоченному владельцу и получи явный письменный approval на
   promotion. Только после него выполняй production promotion.
5. Подключи monitoring/alerts (Sentry/OTel) и проверь, что они получают данные.
5.5. По умолчанию helper не нужен; при конкретном пробеле используй максимум один deploy/ops helper. Prod-мутации,
   DNS, billing и секреты всё равно только после явного подтверждения.
6. Прогон release-readiness; зафиксируй ссылку на deploy и метрики.
7. **Артефакт.** Сохрани в корень проекта `_deploy.md`: production/staging URL, commit/tag релиза,
   применённые миграции, rollback-путь, статус monitoring/alerts, preview smoke и promotion approval.
   Это evidence фазы для `_pipeline-status.md` (verifier принимает и голый production URL в строке
   статуса, но файл — основной путь) и вход для `site-handoff`.

## Quality gate
- release-readiness и infrastructure-readiness пройдены; rollback-путь проверен.
- Для проектов с данными — backup-restore-drill пройден.
- Единый smoke и site audit пройдены на preview; promotion approval зафиксирован до production.
- Секреты не в репозитории/логах; monitoring активен.
- Для VPS Node-сайта: `pm2 status` показывает не-root пользователя, `.env.production` не перетёрт deploy-архивом, Nginx reload выполняется через ограниченный sudo.
- Prod-мутации/DNS/billing — только после явного подтверждения.
- Релиз зафиксирован в `_deploy.md` проекта (URL, tag, rollback, monitoring).
- Проверяет: чеклисты (self-check + tool: site-audit, монитор) + явное подтверждение для рискованных операций.

## Передача дальше
`site-handoff` — передача сайта клиенту (handoff.md, доступы, приёмка, поддержка), затем `capture-learnings`.
