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

## Когда использовать

Всегда для API keys, DB credentials, JWT/session secrets, OAuth credentials, webhook secrets, cloud credentials, MCP tokens.

## Когда не использовать

Не храни секреты в Obsidian, Git, issue body, prompt, screenshots, logs или test fixtures.

## Production-паттерны

Secret manager или platform env vars, separate secrets per environment, rotation plan, least privilege, `.env.example` без значений.

## Частые ошибки

Префиксовать server secret как public env, логировать Authorization header, коммитить `.env`, переиспользовать production secret в dev.

## Проверка

Git secret scan, env validation, client bundle review, rotation drill, access review.

## Источники

См. [Secrets rotation](../08-devops-deploy/Secrets-rotation.md), [GitHub secret scanning](https://docs.github.com/en/code-security/secret-scanning).

