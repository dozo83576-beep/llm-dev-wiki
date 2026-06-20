---
title: "Backup and restore drill checklist"
category: "checklist"
updated: "2026-06-19"
status: "active"
tags: ["backup", "restore", "disaster-recovery", "database", "release-gate"]
source_priority: "internal"
---

# Backup and restore drill checklist

Gate проверки, что данные реально восстановимы, а не «бэкап вроде делается». Срабатывает перед релизом
проектов с базой данных или важным пользовательским контентом. Формат: критерий — проверка — owner — severity.

## Бэкапы

- [ ] **Автобэкап** включён и идёт по расписанию (БД и пользовательские загрузки) — devops — block — [Backups](../docs/04-databases/Backups.md).
- [ ] **Хранение** в отдельном от прода месте/регионе; срок хранения задан — devops — warn.
- [ ] **Шифрование** бэкапов включено — devops — warn.

## Restore-drill

- [ ] **Пробное восстановление** из последнего бэкапа выполнено в изолированной среде — devops — block.
- [ ] **Целостность** проверена: ключевые таблицы/данные на месте после restore — backend owner — block.
- [ ] **RTO/RPO** зафиксированы (время восстановления и допустимая потеря данных) — devops — warn.

## Документация

- [ ] **Runbook восстановления** описан: шаги, команды, owner решения — devops — warn — [Rollback](../docs/08-devops-deploy/Rollback.md).

## Stop conditions

Любой `block` не выполнен → нельзя гарантировать восстановимость; для проектов с данными релиз откладывается. Условия бэкапа и ответственность отражаются в `handoff.md`.

## Источники

- [Backups](../docs/04-databases/Backups.md)
- [Rollback](../docs/08-devops-deploy/Rollback.md)
- [release-readiness](release-readiness.md)
