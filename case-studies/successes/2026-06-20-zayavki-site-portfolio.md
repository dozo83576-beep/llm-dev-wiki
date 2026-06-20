---
title: "Успешное решение: портфолио услуг Заявки.Site"
category: "case-study"
updated: "2026-06-20"
status: "validated"
tags: ["portfolio", "landing", "astro", "pm2", "nginx", "screenshots"]
source_priority: "internal"
date: "2026-06-20"
project_type: "landing"
stack: ["Astro", "Node.js", "PM2", "Nginx", "Playwright"]
---

# Контекст

Нужно было быстро собрать портфолио для продажи услуги разработки сайтов малому бизнесу. Важные ограничения: не выдумывать клиентов, отзывы и метрики; показать реальные демо-проекты; сохранить серверную форму заявки; задеплоить на VPS; не хранить Telegram-секреты в коде.

# Решение

Сайт сделан как Astro server output на Node.js: публичные страницы портфолио, данные кейсов в простых TS-файлах, форма `POST /api/lead` с dry-run режимом и runtime env для Telegram. Кейсы используют реальные локальные проекты, а не вымышленные коммерческие результаты.

Для кейсов добавлены два слоя изображений:

- компактные превью `1365x768` для списков и карточек;
- отдельные full-page изображения для lightbox, когда нужно рассмотреть страницу целиком.

Деплой переведён с root на отдельного пользователя `zayavki`: код сайта принадлежит deploy-пользователю, `.env.production` принадлежит root и читается группой сайта, PM2 запускается от deploy-пользователя, Nginx reload разрешён через ограниченный sudo.

# Почему сработало

- Astro дал простой многостраничный сайт без CMS и лишней архитектуры.
- Серверная форма сохранила приватность Telegram token: секреты читаются только на VPS из env.
- Реальные демо-кейсы повысили доверие без риска фейковых метрик.
- Отдельные preview/fullImage устранили конфликт между компактной галереей и просмотром длинных страниц.
- Non-root deploy снизил риск: компрометация Node-процесса не равна root-доступу.

# Кодовые и архитектурные паттерны

- `src/data/cases.ts` как простой источник данных для портфолио без CMS.
- `scripts/capture-cases.mjs`: Playwright-съёмка локальных проектов на фиксированных портах.
- `scripts/deploy.ps1`: архив без `node_modules`, build artifacts и `.env*`, перенос существующего env на сервере.
- PM2 + Nginx + deploy-пользователь как VPS baseline для небольшого Node-сайта.

# Ограничения

- Это подходит для портфолио, лендинга и небольшого service-site. Для редакторского workflow нужен CMS.
- Root всё ещё нужен для первичной настройки Linux-пользователя, sudoers, Nginx и SSL.
- Full-page скриншоты не всегда полезны: если страница имеет пустой хвост или декоративный фон, для lightbox лучше фиксировать viewport/section crop.

# Проверка

- `npm test`: unit-тесты lead validation.
- `npm run check`: Astro/TypeScript.
- `npm run build`: production build.
- Playwright smoke: клик по превью открывает `/cases-full/...`, `Esc` и фон закрывают lightbox, mobile width без horizontal scroll.
- VPS smoke: PM2 online под deploy-пользователем, Nginx config ok, публичные страницы `200`, форма возвращает `{"ok":true,"dryRun":false}`.

# Ссылки

- [Playbook: Landing](../../docs/13-playbooks/landing.md)
- [Pattern: Portfolio case screenshot gallery](../../patterns/frontend/portfolio-case-screenshot-gallery.md)
- [Pattern: Non-root VPS Node deploy](../../patterns/devops/non-root-vps-node-pm2-nginx-deploy.md)
- [Урок: portfolio screenshots and cache](../../lessons-learned/2026-06-20-portfolio-screenshots-and-cache.md)
