---
title: "Release readiness checklist"
category: "checklist"
updated: "2026-05-24"
status: "active"
tags: ["release", "deploy", "release-gate"]
source_priority: "internal"
---

# Release readiness checklist

Gated checklist для production-релиза. Срабатывает после прохождения [security-review](security-review.md) и перед [release flow](../docs/08-devops-deploy/Release-flow.md). Формат: критерий — проверка — owner — severity — ссылка.

## Code quality

- [ ] **CI зелёный** на main / релизной ветке (lint, typecheck, unit + integration tests, build) — tech lead — block — [CI templates](../docs/08-devops-deploy/CI-templates.md).
- [ ] **PR review** — минимум 1 approval; critical changes — 2 — tech lead — block.
- [ ] **No `// TODO` / `// FIXME`** в новом коде без trackера — tech lead — warn.
- [ ] **Coverage** для critical логики ≥ baseline — backend owner — warn — [Test pyramid](../docs/09-testing/Test-pyramid.md).

## Database

- [ ] **Migrations проверены** на staging; обратимы или backward-compatible — backend owner — block — [Migrations](../docs/04-databases/Migrations.md), [expand-contract pattern](../patterns/database/expand-contract-migration.md).
- [ ] **Long-running migration** (≥30s) запускается отдельным шагом, не блокирует deploy — devops owner — block.
- [ ] **Backup** актуален; restore-drill пройден в текущем квартале — devops owner — warn — [Backups](../docs/04-databases/Backups.md).
- [ ] **Schema changes** ревьюнуты через `database-review` checklist — backend owner — block — [database-review](database-review.md).

## Environment & config

- [ ] **Environment variables** настроены для target environment; `.env.example` совпадает — devops owner — block — [Environment variables](../docs/08-devops-deploy/Environment-variables.md).
- [ ] **Secrets** загружены в secret manager и проверены smoke-проверкой — devops owner — block — [Secrets rotation](../docs/08-devops-deploy/Secrets-rotation.md).
- [ ] **Feature flags** настроены: новые фичи выключены по умолчанию — product owner — warn.

## Preview & smoke

- [ ] **Preview / staging deploy** зелёный и доступен — devops owner — block.
- [ ] **Smoke E2E** на preview пройдены (login, key write, key read) — QA — block — [E2E testing](../docs/09-testing/E2E-testing.md).
- [ ] **Critical user-journey** проверен вручную stakeholder'ом — product owner — warn.

## Observability & alerts

- [ ] **Logs / metrics / traces** отдают с правильным `release` тегом — devops owner — block — [Observability](../docs/08-devops-deploy/Observability.md).
- [ ] **Error tracking** активен; release uploaded в Sentry — devops owner — block — [Sentry](../docs/08-devops-deploy/Sentry.md).
- [ ] **Alert routing** настроен (pager / Slack) для критичных метрик — SRE — block — [Incident workflow](../docs/08-devops-deploy/Incident-workflow.md).
- [ ] **Uptime checks** на критичных URL включены — devops owner — warn.

## Security

- [ ] **Security review** пройден — security owner — block — [security-review](security-review.md).
- [ ] **MCP / AI tools** прошли отдельный security review — AI owner — block — [ai-agent-review](ai-agent-review.md).

## Communication & rollback

- [ ] **Release announce** в команды (Slack / email) с временем и блокирующими — release manager — block.
- [ ] **Rollback план** определён: команды отката, owner решения, max acceptable downtime — devops owner — block — [Rollback](../docs/08-devops-deploy/Rollback.md).
- [ ] **On-call покрытие** на ближайшие 4–8 часов после деплоя — SRE — block.
- [ ] **Customer comms** подготовлены, если изменения публичны (UI / breaking change) — product owner — warn.

## Knowledge capture

- [ ] **Документация deploy/rollback** обновлена — devops owner — warn.
- [ ] **После релиза** запланирована запись в [case-studies/successes](../case-studies/successes), [case-studies/failures](../case-studies/failures) или [lessons-learned](../lessons-learned) — tech lead — warn.

## Stop conditions

Любой `block`-критерий не выполнен → релиз откладывается. Несколько `warn` подряд → пересмотр процесса, не отмахиваться.
