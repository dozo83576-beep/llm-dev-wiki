---
title: "WordPress local smoke on Windows"
category: "lesson"
updated: "2026-06-21"
status: "active"
tags: ["wordpress", "wp-cli", "windows", "sqlite", "smoke"]
source_priority: "internal"
date: "2026-06-21"
project_type: "other"
---

# WordPress local smoke on Windows

## Контекст

Локальный smoke WordPress-пакета на Windows без Docker/MySQL: PHP из WinGet, WP-CLI Phar, SQLite Database Integration.

## Что сработало

- Не менять системный PHP. Создать project-local `php.ini` и запускать `php -c .tools/php-smoke.ini`.
- Если путь к установленному PHP содержит кириллицу, скопировать нужные DLL расширений в ASCII-путь проекта, например `.tools/php-ext`, и указать его как `extension_dir`.
- Для SQLite smoke достаточно `php_pdo_sqlite.dll`, `php_sqlite3.dll`, `php_openssl.dll`, `php_curl.dll` и `libsqlite3.dll`.
- `sqlite-database-integration` для первого install проще распаковывать напрямую в `wp-content/plugins` и копировать `db.copy` в `wp-content/db.php`, потому что `wp plugin install` может требовать уже существующий `wp-config.php`.
- Mu-plugin в подпапке не загружается сам: нужен loader-файл прямо в `wp-content/mu-plugins/*.php`.

## Риск

WP-CLI `wp core download` latest может скачать архив WordPress, несовместимый с Windows extraction. В проверке 2026-06-21 WordPress 7.0 содержал путь с именем файла, заканчивающимся точкой, и не распаковался на Windows.

## Правило

Для Windows smoke закрепляй проверенную версию WordPress через `wp core download --version=<version>`, пока latest-архив не проверен на Windows. Production-версию выбирать отдельно по официальным требованиям и staging-проверке.

## Проверка

Минимальный gate:

```powershell
php .\tests\*.php
Get-ChildItem .\wp-content -Recurse -Filter *.php | ForEach-Object { php -l $_.FullName }
pwsh .\tools\local-wp-smoke.ps1
```
