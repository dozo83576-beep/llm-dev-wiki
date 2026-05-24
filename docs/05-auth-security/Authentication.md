---
title: "Authentication"
category: "security"
updated: "2026-05-24"
status: "active"
tags: ["auth", "authentication"]
source_priority: "official-docs"
---

# Authentication

Authentication отвечает на вопрос "кто пользователь". Для web-приложений выбирай session/OIDC/Auth.js/Supabase Auth вместо самописной auth, если нет жесткой причины.

Правила: secure cookies, MFA для админов, password hashing через Argon2/bcrypt, reset tokens с TTL, audit log для входов и критичных изменений.

Источники: [Auth.js Docs](https://authjs.dev/), [Supabase Auth Docs](https://supabase.com/docs/guides/auth).

