---
title: "local-market-woo: маркетплейс на WooCommerce с кастомным mu-plugin"
category: "case-study"
updated: "2026-07-02"
status: "active"
tags: ["woocommerce", "wordpress", "marketplace", "php", "react", "telegram", "case"]
source_priority: "internal"
date: "2026-07-02"
project_type: "marketplace"
---

# local-market-woo: маркетплейс на WooCommerce

## Задача

Маркетплейс локальных производителей «под ключ»: стек зафиксирован клиентом (WordPress + WooCommerce, PHP 8, MySQL, React SPA-кабинет продавца, Action Scheduler, aiogram-бот). Требования: регистрация продавцов с модерацией документов, разбивка мультивендорной корзины на суб-заказы, настраиваемая комиссия, очередь модерации товаров, реестр выплат, отзывы «один на заказ», уведомления email+Telegram.

## Ключевые решения

- **Кастомный mu-plugin вместо Dokan/WCFM**: требование кастомных REST-эндпоинтов и отдельного React-кабинета делает готовые multivendor-плагины избыточными (их панели дублируют кабинет). Вся логика — поверх нативных хуков WC.
- **Суб-заказы как проекция единого платежа** (кастомные таблицы, не дочерние shop_order): один чекаут — один платёж; комиссия со снапшотом ставки; выплаты через леджер с hold-периодом и CSV-экспортом (сплит-платежи осознанно за скоупом MVP). См. [pattern](../../patterns/backend/woocommerce-marketplace-order-split.md).
- **Модерация «бесплатно» через capabilities**: продавцам не выдан `publish_products` → их товары автоматически `pending`; отклонение — кастомный post status; модератор работает в штатной админке.
- **Auth SPA — Application Passwords** (ядро WP): same-origin subpath `/cabinet/` → без CORS и JWT-плагинов; логин-эндпоинт минтит app password на сервере.
- **Интеграция с ботом — outbox + HMAC push**: WP пишет события в outbox-таблицу с `idempotency_key UNIQUE`, recurring-джоба Action Scheduler пушит их на localhost-эндпоинт aiogram-бота с HMAC-подписью; бот без доступа к MySQL; привязка продавца — `/start <token>` диплинк.
- **Структура репо по образцу medtour-wp**: mu-plugin + классическая тема + `tools/local-wp-smoke.ps1` + `tools/deploy-staging.ps1` (dry-run по умолчанию), плюс `frontend/` (Vite) и `bot/` (Python) как независимые по деплою сиблинги.

## Результат

- 26 PHP-файлов (lint clean), React SPA (6 Vitest-тестов + tsc), aiogram-бот (9 pytest).
- Живые интеграционные тесты через `wp eval-file` против реального WP+WC: разбивка мультивендорной корзины с корректной комиссией по всем 4 уровням приоритета, идемпотентность повторного хука, изоляция продавцов, uniqueness отзывов на уровне БД (включая обход PHP-слоя).
- Сквозная демонстрация в браузере: модерация продавца → витрина → кабинет → создание заказа → суб-заказ + леджер + статистика продавца.
- Найденные при сборке дефекты дали 6+ новых пунктов в [урок про Windows-smoke](../../lessons-learned/2026-06-21-wordpress-windows-local-smoke.md).

## Ограничения / что не сделано

Проект собирался в обход пайплайна build-modern-site (см. [урок](../../lessons-learned/2026-07-02-build-modern-site-plan-mode-bypass.md)): нет юридических страниц (152-ФЗ), SEO витрины, формального ревью по чеклистам и реального VPS-деплоя. Дизайн кабинета утилитарный, вне anti-slop процесса.

Источники: [WordPress+WooCommerce backend](../../docs/03-backend/WordPress-WooCommerce-backend.md), [PHP-FPM deploy pattern](../../patterns/devops/php-fpm-nginx-vps-deploy.md), референс-код `D:\Work\local-market-woo`.
