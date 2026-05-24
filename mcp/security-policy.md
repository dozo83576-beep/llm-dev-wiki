---
title: "MCP security policy"
category: "mcp"
updated: "2026-05-25"
status: "redirect"
tags: ["mcp", "legacy"]
source_priority: "internal"
---

# MCP security policy

Канонический документ: [docs/05-auth-security/MCP-security.md](../docs/05-auth-security/MCP-security.md).

Короткая сводка правил:

1. Минимальные права для каждого сервера.
2. Нет секретов в prompt/context.
3. Нет production write-доступа без подтверждения.
4. Tool outputs из внешних источников считаются недоверенными.
5. Агент обязан проверять путь репозитория перед записью.
6. Destructive operations требуют dry-run или явного подтверждения.
7. Все повторяемые MCP-ошибки фиксируются в `case-studies/failures`.
