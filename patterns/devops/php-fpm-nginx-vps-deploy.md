---
title: "Pattern: PHP-FPM + Nginx + MySQL non-root VPS deploy"
category: "patterns"
updated: "2026-07-02"
status: "active"
tags: ["php", "wordpress", "nginx", "vps", "deploy", "devops"]
source_priority: "internal"
---

# PHP-FPM + Nginx + MySQL non-root VPS deploy

PHP-аналог [non-root Node/PM2/Nginx паттерна](non-root-vps-node-pm2-nginx-deploy.md): те же принципы (изолированные пользователи, минимальный sudoers, бэкап перед деплоем, dry-run), но рантайм — PHP-FPM вместо PM2. Референс-тулинг: `local-market-woo/tools/deploy-staging.ps1` и `tools/nginx/`.

## Когда использовать

WordPress/WooCommerce, Laravel и другой PHP на одном VPS; рядом могут жить статический SPA-бандл и вспомогательный сервис (например, Python-бот под systemd).

## Когда не использовать

Managed WP-хостинг с собственным пайплайном; контейнерные платформы (там свой паттерн); Vercel/Cloudflare — PHP они не исполняют.

## Production-паттерны

- **Пользователи**: `appuser` владеет `/var/www/<site>` и выделенным пулом PHP-FPM (не общий `www-data`, если сервер мультисайтовый). Вспомогательный сервис — под отдельным `botuser`/`svcuser` со своим systemd-юнитом (`NoNewPrivileges`, `ProtectSystem=strict`, `ReadWritePaths` только своя папка); к файлам и БД основного приложения он доступа не имеет — интеграция только по localhost-HTTP.
- **Nginx-раскладка**: `*.php` → unix-сокет пула FPM; `location /` → try_files под permalinks; статический SPA — `location /<subpath>/ { alias …; try_files $uri $uri/ /<subpath>/index.html; }` на том же домене (один сертификат, без CORS). Приватные каталоги загрузок (`uploads/<private>/`) — `deny all`, отдача только через приложение с проверкой прав.
- **Секреты**: креды БД и ключи — в `wp-config.php`/`.env` с правами 640, никогда в репозитории; шаблон констант держать в репо как `*-snippet` с плейсхолдерами.
- **Деплой-скрипт** (dry-run по умолчанию, `-Apply` для реального прогона): (1) `wp db export` в таймстампированный бэкап, (2) tar-бэкап заменяемых частей (тема/mu-plugin/SPA-каталог), (3) распаковка нового пакета, (4) `wp theme activate` + сид + `wp rewrite flush`, (5) сборка и заливка SPA-статики, (6) обновление вспомогательного сервиса: venv + `pip install`, `systemctl restart` через ограниченный `sudoers.d`, health-check `systemctl is-active` после рестарта.
- **sudoers.d/<site>**: деплой-пользователю только `nginx -t`, `systemctl reload nginx`, `systemctl restart <svc>` — ничего больше.

## Частые ошибки

- Один общий `www-data` на несколько сайтов — компрометация одного сайта читает файлы всех.
- SPA на поддомене «для чистоты» — платой становятся CORS и второй сертификат; same-origin subpath проще и безопаснее для cookie/Basic-auth сценариев.
- Деплой без предварительного `wp db export` — миграции WP/WC необратимы.
- Вспомогательный сервис с доступом к MySQL приложения «для удобства» — расширяет blast radius; правильная граница — internal HTTP + HMAC.

## Проверка

Dry-run скрипта печатает полный план без SSH-мутаций; после `-Apply`: смок публичных страниц, `401` на защищённых REST-роутах без авторизации, health-check systemd-сервиса, `pwsh tools/site-audit.ps1 -Url <staging>`.

Источники: [non-root Node deploy](non-root-vps-node-pm2-nginx-deploy.md), [WordPress+WooCommerce backend](../../docs/03-backend/WordPress-WooCommerce-backend.md), [Release readiness](../../checklists/release-readiness.md).
