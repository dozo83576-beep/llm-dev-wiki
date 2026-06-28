---
title: "MCP security"
category: "security"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["mcp", "ai-security"]
source_priority: "official-docs"
---

# MCP security

MCP дает агенту доступ к инструментам и данным, поэтому права должны быть минимальными. Разделяй read-only, write, deploy, billing, secrets и destructive operations.

Риски: prompt injection из внешних данных, tool poisoning, exfiltration через logs/output, неявное выполнение команд, запись в неправильный репозиторий.

Правила: read-only по умолчанию, подтверждение для мутаций, allowlist инструментов, аудит действий, запрет секретов в контексте.

Источник: [Model Context Protocol Docs](https://modelcontextprotocol.io/docs).

## Когда использовать

Любой раз, когда LLM получает tools: filesystem, GitHub, browser, database, deploy, billing, email, docs или cloud provider.

## Когда не использовать

Не давай write/deploy/secrets доступ агенту, если задача решается read-only анализом или локальным patch в ограниченной директории.

## Production-паттерны

Read-only by default, scoped filesystem roots, confirmation gates, audit logs, tool allowlist, separate credentials per environment.

## Частые ошибки

Передавать secrets в prompt, давать production DB write, доверять tool output как инструкции, не проверять путь перед записью.

## Проверка

MCP security review, prompt injection evals, dry-run для destructive actions, audit log проверка tool calls.

