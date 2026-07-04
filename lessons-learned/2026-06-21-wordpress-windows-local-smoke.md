---
title: "WordPress local smoke on Windows"
category: "lesson"
updated: "2026-07-02"
status: "active"
tags: ["wordpress", "woocommerce", "wp-cli", "windows", "sqlite", "smoke"]
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

## Дополнение 2026-07-02 (прогон local-market-woo, WooCommerce)

Урок про WP 7.0 подтвердился повторно: latest снова не распаковался на Windows (MAX_PATH/имена файлов), рабочий пин — `--version=6.9`. **Важно: этот урок был в вики, но не был поднят перед работой — проблема решалась заново с нуля.** Проверяй lessons-learned по тегам стека до старта.

Новые находки:

- **WooCommerce требует свежий WP core**: минимальная версия WP у WC растёт (актуальный WC требовал WP 6.9 при пине смока на 6.8.3) — пин версии проверять при каждом обновлении смока.
- **`wp rewrite structure|flush` ломается с кастомным php.ini**: WP-CLI порождает дочерний `php` БЕЗ `-c <ini>`, и SQLite-расширения теряются («PDO Driver for SQLite is missing»). Лечение: `wp option update permalink_structure '/%postname%/'` + `wp eval 'flush_rewrite_rules(false);'` — всё in-process.
- **Pretty permalinks обязательны для REST**: на свежей установке без permalink structure все `/wp-json/*` роуты отдают контент главной/404 — кастомный REST «молча» не работает.
- **SQLite drop-in + WooCommerce**: выключать HPOS (`wp option set woocommerce_custom_orders_table_enabled no`), иначе datatype mismatch; email-шаблоны WC на SQLite падают при смене статуса заказа (безвредно для данных, но шумно) — на MySQL не воспроизводится.
- **mu-plugin и бутстрап**: код на `init`, пишущий в `wp_options`/роли, обязан гардиться `is_blog_installed()` — mu-plugins исполняются уже во время `wp core install`, до создания таблиц.
- **PowerShell `Copy-Item -Recurse` в существующую папку** вкладывает источник внутрь цели вместо замены — перед синком копии удалять цель (`Remove-Item -Recurse`) или использовать robocopy /MIR.

## Проверка

Минимальный gate:

```powershell
php .\tests\*.php
Get-ChildItem .\wp-content -Recurse -Filter *.php | ForEach-Object { php -l $_.FullName }
pwsh .\tools\local-wp-smoke.ps1
```
