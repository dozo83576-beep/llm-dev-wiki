---
title: "Rate limiting"
category: "security"
updated: "2026-05-24"
status: "active"
tags: ["rate-limit", "abuse"]
source_priority: "internal"
---

# Rate limiting

Rate limiting нужен для login, signup, password reset, AI endpoints, expensive search, webhooks и публичных API.

Ключи лимита: IP, user id, tenant id, API key, route group. Для AI добавляй budget limits и usage alerts.

