---
title: "MCP security"
category: "security"
updated: "2026-05-24"
status: "active"
tags: ["mcp", "ai-security"]
source_priority: "official-docs"
---

# MCP security

MCP дает агенту доступ к инструментам и данным, поэтому права должны быть минимальными. Разделяй read-only, write, deploy, billing, secrets и destructive operations.

Риски: prompt injection из внешних данных, tool poisoning, exfiltration через logs/output, неявное выполнение команд, запись в неправильный репозиторий.

Правила: read-only по умолчанию, подтверждение для мутаций, allowlist инструментов, аудит действий, запрет секретов в контексте.

Источник: [Model Context Protocol Docs](https://modelcontextprotocol.io/docs).

