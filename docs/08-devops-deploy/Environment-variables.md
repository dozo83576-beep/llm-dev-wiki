---
title: "Environment variables"
category: "devops"
updated: "2026-05-24"
status: "active"
tags: ["env", "config"]
source_priority: "internal"
---

# Environment variables

Env vars должны быть валидированы на старте приложения. Делай `.env.example` без секретов, разделяй client/server variables, фиксируй required/optional значения.

Для Next.js client-exposed переменные должны иметь явный публичный префикс и не содержать секретов.

