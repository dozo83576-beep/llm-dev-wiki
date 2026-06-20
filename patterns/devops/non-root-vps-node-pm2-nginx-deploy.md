---
title: "Pattern: Non-root VPS Node + PM2 + Nginx deploy"
category: "pattern"
updated: "2026-06-20"
status: "active"
tags: ["vps", "node", "pm2", "nginx", "deploy", "secrets"]
source_priority: "internal"
area: "devops"
date: "2026-06-20"
---

# Pattern: Non-root VPS Node + PM2 + Nginx deploy

## Назначение

Запускать Node-сайт на VPS без root-процесса и без root-деплоя, сохраняя простую схему PM2 + Nginx reverse proxy.

## Когда использовать

- Небольшой Astro/Next/Node-сайт на VPS.
- Нужен runtime endpoint для формы, webhooks или server rendering.
- Нет полноценного CI/CD, но нужен повторяемый deploy-скрипт.
- Секреты должны жить только на VPS и не перетираться архивом.

## Когда не использовать

- Есть container platform, managed PaaS или Kubernetes с нормальным secret manager.
- Нужны blue/green/canary релизы и несколько инстансов.
- Команда не готова администрировать Linux, Nginx, SSL и systemd.

## Структура

- Linux-пользователь приложения, например `appuser`, владеет `/var/www/<site>` и запускает PM2.
- Runtime env лежит в `/var/www/<site>/.env.production`, владелец `root:<site-group>`, права `640`.
- Deploy по SSH-ключу идёт под `appuser`, не под root.
- `sudoers.d/<site>` разрешает только нужные команды, например `/usr/sbin/nginx -t` и `/usr/bin/systemctl reload nginx`.
- `ecosystem.config.cjs` загружает env через shell перед `npm start`.

## Реализация (пример)

```js
module.exports = {
  apps: [
    {
      name: "site",
      script: "bash",
      args: "-lc 'set -a; . /var/www/site/.env.production; set +a; npm start'",
      env: { HOST: "127.0.0.1", PORT: "4321" },
    },
  ],
};
```

Deploy-архив не должен включать `.env*`, `node_modules`, `dist`, локальные кеши и временные артефакты. Скрипт копирует текущий `.env.production` только на сервере или оставляет существующий файл на месте.

## Production-паттерны

- Проверять `node -v`, `pm2 status`, `curl http://127.0.0.1:<port>`, `nginx -t`, публичный HTTPS URL.
- PM2 startup на пользователя приложения: systemd unit `pm2-<user>`.
- Root нужен только для первичной настройки пользователя, группы, sudoers, Nginx и SSL.
- После попадания секретов в чат/логи — сменить пароль и перевыпустить токены.

## Частые ошибки

- Деплоить и запускать PM2 от root.
- Держать Telegram/API token в `ecosystem.config.cjs`.
- Перезаписывать `.env.production` архивом с локальной машины.
- Давать deploy-пользователю полный passwordless sudo.
- Делать рекурсивный `find ... -exec mv` без `-maxdepth 1`: дочерние файлы могут уже быть перемещены.

## Альтернативы

- Vercel/Render/Cloudflare Pages — проще для статических или serverless-сайтов.
- Docker Compose — лучше, если нужны несколько сервисов или repeatable runtime.
- GitHub Actions deploy — лучше для командной разработки и audit trail.

## Источники

- [Успешное решение: портфолио услуг Заявки.Site](../../case-studies/successes/2026-06-20-zayavki-site-portfolio.md)
- [Release flow](../../docs/08-devops-deploy/Release-flow.md)
- [Release readiness checklist](../../checklists/release-readiness.md)
