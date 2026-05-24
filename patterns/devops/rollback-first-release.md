---
title: "Pattern: Rollback-first release"
category: "patterns"
updated: "2026-05-24"
status: "active"
tags: ["devops", "release", "rollback"]
---

# Rollback-first release

Если rollback не понятен, release не готов.

## Когда использовать

Каждый production deploy, особенно миграции, payments, auth, permissions и infrastructure changes.

## Когда не использовать

Для локальных прототипов rollback-процесс может быть простым удалением окружения.

## Production-паттерны

Определи rollback trigger, owner, команды, data compatibility и monitoring window до deploy.

## Частые ошибки

- Откатывать код после destructive migration без восстановления данных.
- Не знать, кто принимает решение об откате.
- Не проверять rollback на staging.

## Проверка

Release readiness checklist, staging rollback smoke, post-release monitoring.

Источники: [[../../docs/08-devops-deploy/Rollback|Rollback]], [[../../checklists/release-readiness|Release readiness]].

