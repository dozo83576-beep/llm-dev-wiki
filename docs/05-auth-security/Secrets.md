---
title: "Secrets"
category: "security"
updated: "2026-05-27"
status: "active"
tags: ["secrets", "env"]
source_priority: "internal"
---

# Secrets

Секреты не хранятся в Git, Obsidian, wiki, prompt context, issue body, скриншотах и логах. Это включает API keys, токены, cookies, session secrets, private keys и приватные client credentials. Используй env vars, secret manager платформы, rotation policy и least privilege.

Проверка: `.env` в `.gitignore`, пример только в `.env.example`, CI secret scanning, запрет client exposure для server-only ключей.

## Когда использовать

Всегда для API keys, DB credentials, JWT/session secrets, OAuth credentials, webhook secrets, cloud credentials, MCP tokens.

## Когда не использовать

Не храни секреты, токены, cookies или приватные credentials в Obsidian, Git, wiki, issue body, prompt context, screenshots, logs или test fixtures.

## Production-паттерны

Secret manager или platform env vars, separate secrets per environment, rotation plan, least privilege, `.env.example` без значений.

Bot tokens для Telegram/Slack lead notifications считаются server-only secrets: endpoint читает их из env vars, а клиент отправляет заявку только на свой backend route.

## Частые ошибки

Префиксовать server secret как public env, логировать Authorization header, коммитить `.env`, переиспользовать production secret в dev, отдавать Telegram Bot Token в client bundle.

## Проверка

Git secret scan, env validation, client bundle review, rotation drill, access review. Для serverless forms проверь, что `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID` и аналоги доступны только backend runtime.

## Источники

См. [Secrets rotation](../08-devops-deploy/Secrets-rotation.md), [GitHub secret scanning](https://docs.github.com/en/code-security/secret-scanning), [Telegram lead notification](../../patterns/backend/telegram-lead-notification.md).
