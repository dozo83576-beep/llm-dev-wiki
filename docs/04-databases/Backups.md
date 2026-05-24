---
title: "Backups"
category: "database"
updated: "2026-05-24"
status: "active"
tags: ["backup", "restore"]
source_priority: "mixed"
---

# Backups

Backup считается существующим только после успешного restore-теста. Определи RPO, RTO, частоту, хранение, шифрование, доступы и процедуру восстановления.

Минимум: автоматические backups, отдельная проверка restore, журнал последней проверки.

## Когда использовать

Всегда для production БД, файлового хранилища, vector store и критичных конфигураций. Backup нужен до первого production-релиза.

## Когда не использовать

Не считай backup готовым, если restore ни разу не проверялся. Snapshot без процедуры восстановления не является рабочей защитой.

## Production-паттерны

Определи RPO/RTO, частоту, retention, encryption, access control, offsite copy и restore owner. Для миграций делай backup перед рискованным изменением.

## Частые ошибки

Хранить backup в том же failure domain, не шифровать, не проверять restore, не документировать восстановление после удаления tenant.

## Проверка

Периодический restore drill, checksum/size validation, проверка прав доступа, тест восстановления на staging.

## Источники

См. [PostgreSQL Backup and Restore](https://www.postgresql.org/docs/current/backup.html), [Rollback](../08-devops-deploy/Rollback.md).
