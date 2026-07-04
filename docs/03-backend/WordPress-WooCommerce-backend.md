---
title: "WordPress + WooCommerce backend"
category: "backend"
updated: "2026-07-02"
status: "active"
tags: ["wordpress", "woocommerce", "php", "marketplace", "rest", "mu-plugin"]
source_priority: "internal"
---

# WordPress + WooCommerce backend

WooCommerce как backend для магазина/маркетплейса, когда WordPress зафиксирован клиентом. Кастомная бизнес-логика строится поверх нативных механизмов WP/WC (хуки, CPT, кастомные таблицы, Action Scheduler), а не через тяжёлые multivendor-плагины. Референс-реализация: проект `local-market-woo` (см. [case study](../../case-studies/successes/2026-07-02-local-market-woo-woocommerce-marketplace.md)).

## Когда использовать

- Клиент/бриф фиксирует WordPress + WooCommerce, при этом нужна кастомная логика: кабинет продавца, суб-заказы, комиссия, модерация.
- Требуются кастомные REST-эндпоинты и отдельный SPA-кабинет (готовые Dokan/WCFM со своими панелями становятся избыточны и мешают).
- Один сервер/VPS, MySQL, PHP-FPM — классический LEMP без контейнеров.

## Когда не использовать

- Стек свободный — для маркетплейса дефолт JS-стек (см. [stack-selection](../01-development-process/stack-selection.md), строка «Маркетплейс»).
- Нужны сплит-платежи на чекауте (Stripe Connect-класс) с первого дня — WooCommerce нативно так не умеет, придётся строить поверх эквайринга.
- Домен по сути SaaS с многоарендной моделью — posts/meta не заменяют нормальную доменную БД.

## Production-паттерны

- **mu-plugin, не обычный плагин**: ядро бизнес-логики кладётся в `wp-content/mu-plugins/<slug>-core/` с loader-файлом `<slug>-core.php` рядом (mu-plugins в подпапке сами не грузятся). Нельзя деактивировать из админки — доменная логика не «опция».
- **Гард бутстрапа**: любые записи в `wp_options`/роли на `init` оборачивать в `is_blog_installed()` — mu-plugins грузятся и во время `wp core install`, до существования таблиц.
- **Кастомные таблицы через dbDelta** с версионированием в `wp_options` (`<slug>_db_version`) — для транзакционных/объёмных данных (суб-заказы, леджер, отзывы). Postmeta — для сущностей, которым нужны админ-UI/медиатека (профиль продавца как CPT).
- **Кастомный REST-неймспейс** (`<slug>/v1`): каждый хендлер, отдающий ресурсы владельца, обязан проверять принадлежность (ABAC поверх ролей), единый контракт ошибок `{code, message, details, correlationId}`, опциональный `Idempotency-Key` на мутациях.
- **Auth для same-origin SPA — Application Passwords (ядро WP)**: SPA раздаётся с того же домена (напр. `/cabinet/`), логин-эндпоинт минтит app password на сервере (`WP_Application_Passwords::create_new_application_password`), SPA шлёт Basic Auth. Без сторонних JWT-плагинов и без CORS. Рейт-лимит логина — транзиент-счётчик IP+username.
- **Action Scheduler — штатная очередь**: библиотека внутри WooCommerce (таблицы `wp_actionscheduler_*`, UI в Tools → Scheduled Actions, retry из коробки). `as_enqueue_async_action` для событийных задач, `as_schedule_recurring_action` c гардом `as_has_scheduled_action` для периодических. Это ответ на «Celery-подобную очередь» в WP-стеке. См. [Background jobs](Background-jobs.md).
- **Модерация без кастомного стейта**: продавцам не выдавать `publish_products` — WordPress сам переводит их товары в `pending`; отклонение — кастомный `register_post_status`. Модератор работает в штатной админке.
- **PII шифровать через sodium_compat** (в ядре WP с 5.2): ключ — константа в `wp-config.php`, не в БД.
- **Интеграция с внешним сервисом (бот и т.п.)**: WP пушит по внутреннему HTTP (localhost) с HMAC-подписью, события — через outbox-таблицу с `idempotency_key UNIQUE`, дрейнится recurring-джобой Action Scheduler. Внешний сервис не получает доступа к MySQL.

## Частые ошибки

- Ставить Dokan/WCFM «для скорости», когда требуется кастомный кабинет — двойная панель, конфликт моделей данных.
- Забыть pretty permalinks: без них `/wp-json/*` не маршрутизируется (404 на все кастомные REST-роуты).
- Полагаться только на PHP-проверку уникальности (отзыв на заказ и т.п.) — нужен UNIQUE-констрейнт в БД, PHP-слой перегоняется параллельными запросами.
- Пересчитывать комиссию по текущим ставкам для старых заказов — ставка снапшотится в момент заказа.
- Локальная разработка: SQLite drop-in требует выключенного HPOS (`woocommerce_custom_orders_table_enabled=no`); email-шаблоны WC на SQLite падают (только local-проблема). См. [урок](../../lessons-learned/2026-06-21-wordpress-windows-local-smoke.md).

## Проверка

- `php -l` по всем PHP; standalone-тесты чистых функций; интеграционные тесты через `wp eval-file` против локального WP+WC (smoke-скрипт по образцу `local-wp-smoke.ps1`).
- Обязательные сценарии маркетплейса: разбивка мультивендорной корзины, все уровни комиссии, изоляция продавцов (403/404 на чужое), идемпотентность повторного хука, uniqueness отзывов на уровне БД.
- Деплой: [PHP-FPM/Nginx VPS pattern](../../patterns/devops/php-fpm-nginx-vps-deploy.md).

## Источники

- [WooCommerce Developer Docs](https://developer.woocommerce.com/)
- [Action Scheduler](https://actionscheduler.org/)
- [WordPress REST API Handbook](https://developer.wordpress.org/rest-api/)
- См. [WordPress](../02-frontend/WordPress.md), [marketplace playbook](../13-playbooks/marketplace.md), [order-split pattern](../../patterns/backend/woocommerce-marketplace-order-split.md).
