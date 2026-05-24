---
title: "Secrets"
category: "security"
updated: "2026-05-24"
status: "active"
tags: ["secrets", "env"]
source_priority: "internal"
---

# Secrets

Секреты не хранятся в Git, Obsidian, промптах, скриншотах и логах. Используй env vars, secret manager платформы, rotation policy и least privilege.

Проверка: `.env` в `.gitignore`, пример только в `.env.example`, CI secret scanning, запрет client exposure для server-only ключей.

