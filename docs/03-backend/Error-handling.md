---
title: "Error handling"
category: "backend"
updated: "2026-05-24"
status: "active"
tags: ["errors", "api"]
source_priority: "internal"
---

# Error handling

Ошибки дели на validation, auth, permission, not found, conflict, rate limit, upstream, internal. Клиенту возвращай стабильный код, сообщение и correlation id; внутренние детали оставляй в логах.

Повторяемые ошибки должны иметь тесты и попадать в `case-studies/failures`, если повлияли на проект.

