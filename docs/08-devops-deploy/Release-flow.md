---
title: "Release flow"
category: "devops"
updated: "2026-06-19"
status: "active"
tags: ["release", "deploy", "cd"]
source_priority: "internal"
---

# Release flow

Release flow должен быть скучным, повторяемым и проверяемым. Каждый шаг — gate с измеримым критерием прохождения; провал любого шага останавливает релиз.

## Когда использовать

- Любой production deploy: feature, bugfix, hotfix, migration.
- Изменения, влияющие на пользователей или данные.

## Когда не использовать

- Изменение документации/конфигурации без runtime effect — отдельный lightweight flow.
- Hotfix критической безопасности — отдельная ускоренная процедура с пост-фактум ретро.

## Шаги (gated)

1. **PR review + зелёный CI** — критерий: required checks passed, ≥1 approval, нет открытых блокеров.
2. **Preview / staging deploy** — критерий: deploy зелёный, healthcheck отдаёт OK.
3. **Smoke tests** — критерий: критичные user-journey проходят (login, key write, key read).
4. **Migration dry-run или staging migration** — критерий: миграция применена на staging, нет ошибок, rollback проверен.
5. **Security checklist** — [checklists/security-review.md](../../checklists/security-review.md) пройден.
6. **Release readiness checklist** — [checklists/release-readiness.md](../../checklists/release-readiness.md) пройден.
7. **Production deploy** — выполняется в окно, заранее объявлено в Slack.
8. **Monitoring window** — 30–60 мин активного наблюдения за метриками и логами.
9. **Client handoff** — сгенерирован `handoff.md`, доступы переданы безопасно, письменная приемка получена.
10. **Knowledge capture** — если был incident или нестандартное решение → запись в `lessons-learned` / `case-studies`.

## Stop conditions

- Failing tests.
- Unknown migration impact или нет proven rollback path.
- Missing rollback, missing feature flag для рискованных функций.
- Secrets / env vars не настроены в production.
- Critical security finding (open OWASP issue, утечка credentials).
- Vendor / dependency outage блокирует smoke-тест.
- Open S1/S2 incident в продакшене.
- Передача заказчику требует секреты в plain text файле вместо password manager или приглашений в сервисы.

## Production-паттерны

- Trunk-based: короткие feature branches, мердж в main несколько раз в день.
- Continuous Deployment с feature flags для контроля видимости.
- Database migrations отдельным шагом от code release (expand → migrate → contract).
- Для VPS Node-сайтов default: отдельный deploy-пользователь, PM2 от этого пользователя, Nginx reverse proxy, `.env.production` вне архива; root только для первичной настройки и ограниченного sudo.
- Canary / progressive rollout для критичных изменений.
- Roll-forward по умолчанию, rollback как safety net.
- Для клиентских сайтов после production monitoring генерировать `handoff.md` через [site handoff template](../10-templates/handoff.md).

## Частые ошибки

- "Просто маленький фикс" без CI/preview — ломает production.
- Friday-deploy без on-call покрытия в выходные.
- Применить миграцию и сразу выкатить новый код — нет окна для проверки.
- Не объявлять релиз в чат — другие команды не знают, на чём смотреть отказы.
- Запускать Node/PM2 от root на VPS и хранить runtime secrets в process manager config.

## Security risks

Утечка credentials через build logs, выкатить включённый feature flag для всех вместо canary, пропустить security review на "минорный" deploy.

## Testing strategy

- CI verify job обязателен.
- Preview / staging как репликация production-инвариантов.
- Smoke pack — короткий набор сценариев, < 5 мин.
- Periodic chaos / game day для проверки runbook'ов.

## Edge cases

- Hotfix-релиз: усечённый flow, но с обязательным post-mortem.
- Multi-service release: dependency-граф deploy-ов, feature flag координация.
- Откат БД-миграции: только если она backward-compatible, иначе fix forward.

## Источники

- [Google SRE — Release Engineering](https://sre.google/sre-book/release-engineering/) — проверено 2026-05-24.
- См. [Rollback](Rollback.md), [Migrations](../04-databases/Migrations.md), [release-readiness checklist](../../checklists/release-readiness.md), [non-root VPS Node deploy](../../patterns/devops/non-root-vps-node-pm2-nginx-deploy.md).
