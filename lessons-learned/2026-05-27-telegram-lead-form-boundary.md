---
title: "Урок: Telegram lead form требует серверной границы"
category: "lesson"
updated: "2026-05-27"
status: "active"
tags: ["landing", "forms", "telegram", "serverless", "security"]
source_priority: "internal"
date: "2026-05-27"
project_type: "landing"
---

# Вывод

Telegram-бот хорошо подходит как быстрый канал лидов для MVP-лендинга, но токен, валидация, allowlist и форматирование сообщения должны находиться на сервере.

# Контекст

В проекте "ТВОЙ ХИТ" статический сайт собирает заявки через формы и отправляет их на endpoint `/api/lead`. Endpoint валидирует payload и доставляет уведомление в Telegram-чат через Bot API.

# Что произошло

Форма получила полноценную границу между UX и безопасностью: клиент форматирует телефон, показывает ошибки и loading state, а сервер заново нормализует телефон, проверяет направление, обрабатывает honeypot и скрывает Telegram Bot Token в env vars.

# Корень

Лендинговая форма выглядит простой, но она принимает персональные данные и вызывает внешний API. Если отправлять лид напрямую из браузера в Telegram, токен попадет в client bundle, а validation/spam protection будут обходиться.

# Новое правило

Когда лендинг отправляет лид в Telegram, делай serverless boundary: client отвечает за UX, endpoint отвечает за validation, secrets, escaping, dry-run и ошибки внешнего API.

# Применимость

Работает для небольших лендингов, промо-страниц и теста оффера. Не заменяет CRM, очередь или базу данных, если лиды критичны, требуют статусов обработки, аналитики, ретраев или юридически значимого хранения.

# Обновленные документы

- [Pattern: Telegram lead notification](../patterns/backend/telegram-lead-notification.md) - повторяемая структура решения.
- [Playbook: Landing](../docs/13-playbooks/landing.md) - Telegram/Slack как MVP notification channel.
- [Forms and validation](../docs/02-frontend/Forms-validation.md) - client validation только UX, server validation обязательна.
- [Secrets](../docs/05-auth-security/Secrets.md) - bot token как server-only secret.

# Ссылки

- [Успешное решение: статический лендинг ТВОЙ ХИТ](../case-studies/successes/2026-05-27-tvoi-hit-static-landing.md)
- [Frontend review checklist](../checklists/frontend-review.md)
