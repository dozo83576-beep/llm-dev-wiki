---
title: "Pattern: Privacy-friendly lead analytics"
category: "pattern"
updated: "2026-06-20"
status: "active"
tags: ["analytics", "lead-form", "privacy", "jsonl"]
source_priority: "internal"
area: "backend"
date: "2026-06-20"
---

# Privacy-friendly lead analytics

## Назначение

Минимальная аналитика формы заявки без cookies, внешних счётчиков и персональных данных. Подходит для раннего сайта услуг, где нужно понять, какие страницы и CTA приводят заявки, но нельзя усложнять проект Метрикой/consent.

## Структура события

Пиши только whitelist-поля:

- `timestamp`
- `event`: `lead_success`, `lead_dry_run`, `lead_error`
- `source`
- `service`
- `need`
- `page`
- `telegramStatus`

Не писать: имя, контакт, сообщение, текущий сайт клиента, IP, user-agent, токены, raw payload.

## Production-паттерны

- Формат хранения: JSONL, один event на строку.
- Path задаётся env (`ANALYTICS_LOG_PATH`), production default лежит вне deploy-архива.
- Ошибка записи analytics не ломает форму: warn в server log и обычный ответ заявки.
- Unit-тест проверяет отсутствие PII и работу при недоступном path.

## Частые ошибки

- Логировать весь payload формы ради удобства.
- Смешивать analytics и lead delivery: падение аналитики не должно мешать Telegram-заявке.
- Хранить JSONL внутри репозитория или deploy-архива.

## Источники

- [Pattern: Telegram lead notification](telegram-lead-notification.md)
- [Release readiness checklist](../../checklists/release-readiness.md)
- [Legal compliance checklist](../../checklists/legal-compliance.md)
