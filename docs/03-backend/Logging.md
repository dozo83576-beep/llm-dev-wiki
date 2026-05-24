---
title: "Logging"
category: "backend"
updated: "2026-05-24"
status: "active"
tags: ["logging", "observability"]
source_priority: "internal"
---

# Logging

Логи должны отвечать: что случилось, где, для какого request/user/entity, с каким correlation id, какой outcome.

Не логируй пароли, токены, cookies, полные платежные данные и приватные payloads. Для Node.js используй Pino/Winston, для Python structlog/loguru/standard logging.

