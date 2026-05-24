---
title: "MCP overview"
category: "ai-tools"
updated: "2026-05-24"
status: "active"
tags: ["mcp", "agents"]
source_priority: "official-docs"
---

# MCP overview

Model Context Protocol стандартизирует подключение LLM-клиентов к инструментам, ресурсам и данным. Для разработки сайтов MCP полезен для GitHub, файлов, документации, браузера, БД, cloud provider и issue trackers.

Источник: [MCP Docs](https://modelcontextprotocol.io/docs).

## Когда использовать

Используй MCP, когда агенту нужен контролируемый доступ к repo, docs, browser, issue tracker, database, cloud logs или automation tools.

## Когда не использовать

Не подключай MCP “на всякий случай”. Каждый server расширяет attack surface и должен иметь понятную задачу.

## Production-паттерны

Read-only by default, минимальные scopes, explicit confirmation для mutations, audit tool calls, separate environments.

## Частые ошибки

Давать broad filesystem root, production DB write, secrets access, deploy permissions без gates, доверять external tool output.

## Проверка

MCP inventory, permission review, prompt injection tests, dry-run destructive flows, smoke "перечисли активные tools" перед началом сессии.

## Edge cases

- Tool discovery: клиент получает список tools на старте — добавление нового tool требует осознанной проверки.
- Streaming результаты vs дискретные ответы — особенности UX.
- Resources vs Tools: read-only данные — это resource, действия — tools.
- Multiple servers, перекрывающие имена tools — collision resolution policy.
- Долгоживущие session-агенты — периодически перечитывать политику и инвалидировать кеш tool listing.

## Security risks

Prompt injection через tool output, tool poisoning (MCP-сервер компрометирован), confused deputy (агент использует свои привилегии от имени пользователя), exfiltration через logs MCP-сервера.

## Источники

- [Model Context Protocol Docs](https://modelcontextprotocol.io/docs) — проверено 2026-05-24.
- См. [Tool permissions](Tool-permissions.md), [MCP security](../05-auth-security/MCP-security.md), [Recommended MCP servers](Recommended-MCP-servers.md), [Setup Claude Desktop](Setup-Claude-Desktop.md), [Setup Codex](Setup-Codex.md).

