---
title: "Pattern: MCP read-only default"
category: "patterns"
updated: "2026-05-24"
status: "active"
tags: ["ai", "mcp", "security"]
source_priority: "internal"
---

# MCP read-only default

MCP-инструменты должны начинаться с read-only доступа, потому что агент может ошибиться или попасть под prompt injection.

## Когда использовать

Любой агентный workflow с filesystem, GitHub, database, deploy, billing, DNS или cloud tools.

## Когда не использовать

Write-доступ допустим только для ограниченной рабочей директории или после явного подтверждения.

## Production-паттерны

Read-only by default, allowlist tools, confirmation gates для mutations, separate production credentials.

## Частые ошибки

- Давать production write без dry-run.
- Передавать secrets в model context.
- Не логировать tool actions.

## Проверка

MCP security review, negative prompt injection tests, audit log review.

Источники: [MCP security](../../docs/05-auth-security/MCP-security.md), [Tool permissions](../../docs/07-mcp-and-ai-tools/Tool-permissions.md).
