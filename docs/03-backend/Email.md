---
title: "Email"
category: "backend"
updated: "2026-05-24"
status: "active"
tags: ["email", "notifications"]
source_priority: "internal"
---

# Email

Email нужен для auth, transactional notifications, billing, lifecycle и marketing. Transactional и marketing потоки должны быть разделены.

## Production-паттерны

- Templates версионируются.
- Отправка через queue.
- Idempotency для критичных писем.
- Bounce/complaint handling.
- Unsubscribe для marketing.

## Проверка

- Snapshot/render tests для шаблонов.
- Integration test с sandbox provider.
- Проверка SPF/DKIM/DMARC перед production.

