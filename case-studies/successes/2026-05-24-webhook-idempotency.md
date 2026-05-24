---
title: "Успешное решение: idempotent webhooks"
category: "case-study"
updated: "2026-05-24"
status: "validated"
tags: ["webhooks", "payments", "backend"]
source_priority: "internal"
date: "2026-05-24"
project_type: "SaaS"
stack: ["NestJS", "PostgreSQL"]
---

# Контекст

Платежный провайдер повторно отправлял события при временных ошибках backend.

# Решение

Добавлена таблица processed webhook events с уникальным `event_id`, проверкой подписи и обработкой бизнес-логики через queue.

# Почему сработало

Повторные события перестали создавать дубли подписок и платежных записей.

# Кодовые и архитектурные паттерны

Webhook endpoint быстро валидирует событие, сохраняет idempotency marker и передает работу в background job.

# Ограничения

Нужно отдельно обрабатывать out-of-order events и reconciliation с provider API.

# Проверка

Integration tests: valid signature, invalid signature, duplicate event, queue failure retry.

# Ссылки

[Webhooks](../../docs/03-backend/Webhooks.md), [Payments](../../docs/03-backend/Payments.md).
